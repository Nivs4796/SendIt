# SendIt Platform - Complete Flow Diagrams

## Overview
This document provides visual flow diagrams for all major workflows and scenarios in the SendIt platform.

---

## 1. Platform Architecture Overview

```mermaid
graph TB
    subgraph "Mobile Apps"
        UA[User App<br/>Flutter]
        PA[Pilot App<br/>Flutter]
    end
    
    subgraph "Web Applications"
        AD[Admin Dashboard<br/>Next.js]
        WS[Marketing Website<br/>Next.js]
    end
    
    subgraph "Backend Services"
        API[REST API<br/>Node.js + Express]
        SOCKET[WebSocket Server<br/>Socket.io]
        QUEUE[Job Queue<br/>Bull + Redis]
    end
    
    subgraph "Databases"
        PG[(PostgreSQL<br/>Primary DB)]
        REDIS[(Redis<br/>Cache + Queue)]
    end
    
    subgraph "Third Party Services"
        MAPS[Google Maps API]
        PAY[Razorpay]
        SMS[SMS Gateway]
        FCM[Firebase FCM]
        S3[AWS S3 / GCS]
    end
    
    UA -->|HTTP/REST| API
    UA -->|WebSocket| SOCKET
    PA -->|HTTP/REST| API
    PA -->|WebSocket| SOCKET
    AD -->|HTTP/REST| API
    WS -->|Contact Forms| API
    
    API --> PG
    API --> REDIS
    SOCKET --> REDIS
    API --> QUEUE
    
    API --> MAPS
    API --> PAY
    API --> SMS
    API --> FCM
    API --> S3
    
    QUEUE --> API
```

---

## 2. User Journey: Complete Order Flow

### 2.1 Order Creation & Driver Assignment

```mermaid
sequenceDiagram
    participant U as User App
    participant API as Backend API
    participant DM as Driver Matching
    participant P as Pilot App
    participant DB as Database
    participant WS as WebSocket
    
    Note over U: User wants to book delivery
    
    U->>API: Get Price Estimate
    API->>API: Calculate fare (distance + surge)
    API-->>U: Return estimate
    
    U->>U: Review & confirm
    U->>API: Create Order (POST /orders)
    
    activate API
    API->>DB: Save order (status: pending)
    API->>DB: Deduct from wallet (if applicable)
    API-->>U: Order Created (order_id)
    
    API->>DM: Start driver matching
    activate DM
    
    DB->>DM: Get order deails
    DM->>DB: Find eligible drivers<br/>(within 5km, online, matching vehicle)
    DB-->>DM: List of drivers
    
    DM->>DM: Sort by distance, rating
    
    loop For each driver (max 5)
        DM->>WS: Send job request to driver
        WS->>P: job:new notification
        
        alt Driver accepts (within 30s)
            P->>API: Accept job
            API->>DB: Update order (status: assigned)
            DM->>DM: Stop searching
            API->>WS: Notify user (driver assigned)
            WS->>U: driver:assigned event
        else Driver rejects or timeout
            DM->>DM: Try next driver
        end
    end
    
    deactivate DM
    
    alt No driver found
        API->>DB: Update order (status: no_driver)
        API->>WS: Notify user
        WS->>U: No drivers available
    end
    
    deactivate API
```

### 2.2 Delivery Process

```mermaid
sequenceDiagram
    participant P as Pilot App
    participant API as Backend API
    participant U as User App
    participant WS as WebSocket
    participant DB as Database
    
    Note over P: Driver accepted job
    
    P->>API: Start navigation to pickup
    
    loop Every 5 seconds
        P->>WS: Send live location
        WS->>U: driver:location update
    end
    
    Note over P: Arrived at pickup
    
    P->>API: Mark "Arrived at Pickup"
    API->>DB: Update order status
    API->>WS: Notify user
    WS->>U: order:status_changed (arrived)
    
    P->>P: Capture package photo
    P->>API: Upload photo + Mark "Picked Up"
    API->>DB: Update status (picked_up), save photo
    API->>WS: Notify user
    WS->>U: order:status_changed (picked_up)
    
    Note over P: Navigate to drop location
    
    P->>API: Navigate to drop
    
    loop Every 5 seconds
        P->>WS: Send live location
        WS->>U: driver:location update
    end
    
    Note over P: Arrived at drop
    
    P->>P: Capture delivery photo
    
    alt Cash on Delivery
        P->>P: Collect cash from customer
        P->>API: Mark "Delivered" + cash collected
    else Prepaid
        P->>API: Mark "Delivered"
    end
    
    API->>DB: Update status (delivered)
    API->>DB: Credit pilot earnings
    API->>WS: Notify user
    WS->>U: order:delivered
    
    U->>U: Show rating screen
    U->>API: Submit rating & feedback
    API->>DB: Save rating
    API->>DB: Update pilot rating
```

---

## 3. Pilot Journey: Registration to First Job

### 3.1 Pilot Registration Flow

```mermaid
flowchart TD
    Start([Pilot Opens App]) --> Login{Already<br/>Registered?}
    
    Login -->|No| EnterPhone[Enter Phone Number]
    Login -->|Yes| OTPLogin[Login with OTP]
    
    EnterPhone --> SendOTP[Send OTP]
    SendOTP --> VerifyOTP{OTP<br/>Valid?}
    VerifyOTP -->|No| SendOTP
    VerifyOTP -->|Yes| PersonalInfo
    
    PersonalInfo[Enter Personal Details<br/>Name, Email, DOB] --> AgeCheck{Age >= 18?}
    
    AgeCheck -->|No, 16-18| ParentalConsent[Require Parental Consent]
    AgeCheck -->|Yes| VehicleDetails
    ParentalConsent --> VehicleDetails
    
    VehicleDetails[Select Vehicle Type<br/>& Enter Details] --> UploadDocs[Upload Documents]
    
    UploadDocs --> CheckDocs[Upload:<br/>- Aadhaar Card<br/>- Driving License<br/>- Vehicle RC<br/>- Vehicle Insurance<br/>- Bank Details]
    
    CheckDocs --> BankDetails[Enter Bank Account<br/>IFSC, Account Number]
    
    BankDetails --> Submit[Submit for Verification]
    
    Submit --> PendingVerif[Status: Pending Verification]
    
    PendingVerif --> AdminReview{Admin<br/>Reviews}
    
    AdminReview -->|Rejected| Rejected[Status: Rejected<br/>Reason provided]
    AdminReview -->|Approved| Approved[Status: Approved]
    
    Rejected --> UploadDocs
    Approved --> CanGoOnline[Can Go Online<br/>& Accept Jobs]
    
    CanGoOnline --> End([Ready to Work])
```

### 3.2 Pilot Daily Workflow

```mermaid
stateDiagram-v2
    [*] --> Offline: App opened
    
    Offline --> Online: Toggle "Go Online"
    Online --> Offline: Toggle "Go Offline"
    
    Online --> JobReceived: New job notification
    JobReceived --> JobReview: Driver reviews job
    
    JobReview --> Online: Reject/Timeout (30s)
    JobReview --> Assigned: Accept job
    
    Assigned --> NavigatingToPickup: Start navigation
    NavigatingToPickup --> AtPickup: Arrived at pickup
    
    AtPickup --> PackageCollected: Capture photo + Confirm
    PackageCollected --> InTransit: Navigate to drop
    
    InTransit --> AtDrop: Arrived at drop
    AtDrop --> Delivered: Capture photo + Confirm delivery
    
    Delivered --> EarningsCredited: System credits earnings
    EarningsCredited --> Online: Job complete, available for next
    
    Online --> [*]: End shift (go offline)
    
    note right of JobReceived
        Can accept multiple jobs
        if capacity available
    end note
    
    note right of Delivered
        If COD: Collect cash
        Update cash in hand
    end note
```

---

## 4. Payment Processing Flows

### 4.1 Wallet Payment Flow

```mermaid
sequenceDiagram
    participant U as User
    participant APP as User App
    participant API as Backend API
    participant DB as Database
    participant PAY as Razorpay
    
    Note over U: User wants to add money to wallet
    
    U->>APP: Click "Add Money"
    APP->>U: Enter amount (e.g., ₹500)
    U->>APP: Confirm
    
    APP->>API: POST /wallet/add-money {amount: 500}
    
    API->>PAY: Create Razorpay Order
    PAY-->>API: order_id, amount
    
    API->>DB: Create transaction (pending)
    API-->>APP: Return order details
    
    APP->>PAY: Open Razorpay Checkout
    U->>PAY: Complete payment<br/>(UPI/Card/NetBanking)
    
    alt Payment Success
        PAY->>API: Webhook (payment.success)
        API->>API: Verify signature
        API->>DB: Update transaction (success)
        API->>DB: Credit wallet balance
        API->>APP: Push notification
        APP->>U: Show success + updated balance
    else Payment Failed
        PAY->>API: Webhook (payment.failed)
        API->>DB: Update transaction (failed)
        API->>APP: Notify failure
        APP->>U: Show error message
    end
```

### 4.2 Order Payment with Coupon

```mermaid
flowchart TD
    Start([User reviews order]) --> HasCoupon{Apply<br/>Coupon?}
    
    HasCoupon -->|No| SelectPayment
    HasCoupon -->|Yes| EnterCode[Enter Coupon Code]
    
    EnterCode --> ValidateCoupon{Validate<br/>Coupon}
    
    ValidateCoupon -->|Invalid| ShowError[Show Error Message]
    ShowError --> EnterCode
    
    ValidateCoupon -->|Valid| ApplyDiscount[Apply Discount<br/>Recalculate Total]
    
    ApplyDiscount --> SelectPayment[Select Payment Method]
    
    SelectPayment --> PaymentChoice{Payment<br/>Method}
    
    PaymentChoice -->|Wallet| CheckBalance{Sufficient<br/>Balance?}
    CheckBalance -->|No| InsufficientFunds[Show Error:<br/>Insufficient Balance]
    InsufficientFunds --> SelectPayment
    CheckBalance -->|Yes| DeductWallet[Deduct from Wallet]
    
    PaymentChoice -->|Card/UPI| RazorpayGateway[Open Razorpay]
    RazorpayGateway --> ProcessPayment{Payment<br/>Success?}
    ProcessPayment -->|No| PaymentFailed[Show Failure]
    ProcessPayment -->|Yes| PaymentSuccess
    
    PaymentChoice -->|Cash| MarkCOD[Mark as COD]
    
    DeductWallet --> PaymentSuccess[Payment Successful]
    MarkCOD --> PaymentSuccess
    
    PaymentSuccess --> CreateOrder[Create Order in DB]
    CreateOrder --> StartMatching[Start Driver Matching]
    StartMatching --> End([Order Placed])
    
    PaymentFailed --> SelectPayment
```

---

## 5. Admin Dashboard Workflows

### 5.1 Pilot Verification Workflow

```mermaid
flowchart TD
    Start([New Pilot Registration]) --> Notification[Admin receives notification]
    
    Notification --> ViewProfile[Admin opens pilot profile]
    ViewProfile --> ReviewDocs[Review Documents:<br/>- Aadhaar<br/>- License<br/>- RC<br/>- Insurance<br/>- Bank Details]
    
    ReviewDocs --> CheckAge{Age<br/>Verification}
    
    CheckAge -->|Under 16| AutoReject[Auto Reject]
    CheckAge -->|16-18| CheckConsent{Parental<br/>Consent?}
    CheckAge -->|18+| CheckDocs
    
    CheckConsent -->|No| RejectMinor[Reject - No Consent]
    CheckConsent -->|Yes| CheckDocs
    
    CheckDocs{Documents<br/>Valid?}
    
    CheckDocs -->|No| RejectInvalid[Reject with Reason]
    RejectInvalid --> NotifyPilot[Send Notification to Pilot]
    
    CheckDocs -->|Yes| CheckVehicle{Vehicle<br/>Details OK?}
    
    CheckVehicle -->|No| RejectVehicle[Reject - Invalid Vehicle]
    CheckVehicle -->|Yes| CheckBackground{Background<br/>Check OK?}
    
    CheckBackground -->|No| RejectBackground[Reject - Failed Check]
    CheckBackground -->|Yes| Approve[Mark as Approved]
    
    Approve --> SendWelcome[Send Welcome Email/SMS]
    SendWelcome --> PilotCanOnline[Pilot can go online]
    PilotCanOnline --> End([Verification Complete])
    
    RejectMinor --> NotifyPilot
    RejectVehicle --> NotifyPilot
    RejectBackground --> NotifyPilot
    AutoReject --> NotifyPilot
    
    NotifyPilot --> End
```

### 5.2 Real-time Order Monitoring

```mermaid
graph LR
    subgraph "Order Status Board"
        A[Pending Orders<br/>Count: 5]
        B[Searching Driver<br/>Count: 12]
        C[Assigned<br/>Count: 8]
        D[In Transit<br/>Count: 15]
        E[Delivered<br/>Count: 45]
    end
    
    subgraph "Live Updates via WebSocket"
        WS[Socket.io Server]
    end
    
    subgraph "Actions"
        F[Click order]
        G[View details]
        H[Reassign driver]
        I[Cancel order]
        J[Contact user]
        K[Contact pilot]
    end
    
    WS -->|Real-time events| A
    WS -->|Real-time events| B
    WS -->|Real-time events| C
    WS -->|Real-time events| D
    WS -->|Real-time events| E
    
    A --> F
    B --> F
    C --> F
    D --> F
    E --> F
    
    F --> G
    G --> H
    G --> I
    G --> J
    G --> K
```

---

## 6. Real-Time Communication Flows

### 6.1 Live Location Tracking

```mermaid
sequenceDiagram
    participant P as Pilot App
    participant WS as WebSocket Server
    participant U as User App
    participant DB as Redis Cache
    
    Note over P: Job is in "In Transit" status
    
    P->>P: Get GPS location (every 5s)
    
    loop Every 5 seconds
        P->>WS: emit("pilot:location", {lat, lng, heading, speed})
        WS->>DB: Cache location (TTL: 30s)
        WS->>U: emit("driver:location", {lat, lng, heading})
        U->>U: Update map marker
    end
    
    Note over U: User sees live driver location
    
    alt User opens app mid-delivery
        U->>WS: Request current location
        WS->>DB: Get cached location
        DB-->>WS: Return location
        WS-->>U: Send current position
        U->>U: Show driver on map
    end
    
    Note over P: Delivery completed
    
    P->>WS: emit("pilot:location:stop")
    WS->>U: emit("tracking:ended")
    U->>U: Stop showing live location
```

### 6.2 Push Notification Flow

```mermaid
flowchart TD
    Trigger[Event Triggered<br/>e.g., Driver Assigned] --> Backend[Backend API]
    
    Backend --> GetToken[Get device token from DB]
    GetToken --> CheckPref{Notification<br/>Enabled?}
    
    CheckPref -->|No| Skip[Skip notification]
    CheckPref -->|Yes| CreatePayload[Create FCM Payload]
    
    CreatePayload --> SendFCM[Send to Firebase FCM]
    SendFCM --> FCM[Firebase Cloud Messaging]
    
    FCM --> Platform{Platform?}
    
    Platform -->|iOS| APNS[Apple Push Service]
    Platform -->|Android| GCM[Google Cloud Messaging]
    
    APNS --> iOSDevice[iOS Device]
    GCM --> AndroidDevice[Android Device]
    
    iOSDevice --> ShowNotif[Show Notification]
    AndroidDevice --> ShowNotif
    
    ShowNotif --> UserAction{User Taps?}
    
    UserAction -->|Yes| DeepLink[Deep link to app screen]
    UserAction -->|No| Dismissed[Notification dismissed]
    
    DeepLink --> AppScreen[Open relevant screen<br/>e.g., Active Order]
    
    Skip --> End([End])
    Dismissed --> End
    AppScreen --> End
```

---

## 7. Surge Pricing System

```mermaid
graph TD
    OrderRequest[Order Request Received] --> GetLocation[Extract Pickup Location]
    
    GetLocation --> CheckZone{Check Surge<br/>Pricing Zones}
    
    CheckZone -->|In surge zone| GetZoneMultiplier[Get zone multiplier<br/>e.g., 1.5x]
    CheckZone -->|Not in zone| CalcDemand[Calculate demand/supply ratio]
    
    CalcDemand --> CountOrders[Count active orders<br/>in 5km radius]
    CountOrders --> CountDrivers[Count online drivers<br/>in 5km radius]
    CountDrivers --> CalcRatio[Ratio = Orders / Drivers]
    
    CalcRatio --> RatioCheck{Ratio<br/>Value?}
    
    RatioCheck -->|< 1.5| NoSurge[Multiplier: 1.0x]
    RatioCheck -->|1.5 - 2.0| LowSurge[Multiplier: 1.2x]
    RatioCheck -->|2.0 - 3.0| MedSurge[Multiplier: 1.5x]
    RatioCheck -->|> 3.0| HighSurge[Multiplier: 2.0x]
    
    GetZoneMultiplier --> ApplyMultiplier
    NoSurge --> ApplyMultiplier[Apply Multiplier to Fare]
    LowSurge --> ApplyMultiplier
    MedSurge --> ApplyMultiplier
    HighSurge --> ApplyMultiplier
    
    ApplyMultiplier --> BaseFare[Base Fare: ₹40]
    BaseFare --> DistFare[Distance Fare: ₹5/km]
    DistFare --> Subtotal[Subtotal = Base + Distance × Multiplier]
    Subtotal --> AddTax[Add CGST 9% + SGST 9%]
    AddTax --> FinalFare[Final Fare]
    
    FinalFare --> ShowUser[Display to User]
```

---

## 8. Referral System Flow

```mermaid
sequenceDiagram
    participant U1 as User A (Referrer)
    participant APP1 as User A App
    participant API as Backend
    participant DB as Database
    participant APP2 as User B App
    participant U2 as User B (Referee)
    
    Note over U1: User A shares referral code
    
    U1->>APP1: Click "Refer & Earn"
    APP1->>API: Get referral code
    API->>DB: Fetch user.referral_code
    DB-->>API: Return code (e.g., "JOHN50")
    API-->>APP1: Return code
    APP1->>U1: Show code + share options
    
    U1->>U1: Share via WhatsApp/SMS
    
    Note over U2: User B receives referral
    
    U2->>APP2: Open app + signup
    APP2->>U2: Have a referral code?
    U2->>APP2: Enter "JOHN50"
    
    APP2->>API: POST /auth/signup {phone, referral_code}
    API->>DB: Find referrer by code
    
    alt Code valid
        API->>DB: Create referral record (status: pending)
        API-->>APP2: Signup successful
        
        Note over U2: User B completes first order
        
        U2->>API: Place first order
        API->>DB: Check if user has pending referral
        DB-->>API: Referral found
        
        API->>DB: Update referral (status: completed)
        API->>DB: Credit ₹50 to User A wallet
        API->>DB: Credit ₹50 to User B wallet
        
        API->>APP1: Push notification
        APP1->>U1: "You earned ₹50!"
        
        API->>APP2: Push notification
        APP2->>U2: "Welcome bonus ₹50 added!"
        
    else Code invalid
        API-->>APP2: Error: Invalid code
    end
```

---

## 9. Error Handling & Retry Scenarios

### 9.1 Network Failure Handling

```mermaid
flowchart TD
    Start([User Action<br/>e.g., Place Order]) --> APICall[Make API Request]
    
    APICall --> Success{Request<br/>Success?}
    
    Success -->|Yes| ProcessResponse[Process Response]
    ProcessResponse --> End([Complete])
    
    Success -->|No| CheckError{Error<br/>Type}
    
    CheckError -->|Network Timeout| RetryLogic
    CheckError -->|500 Error| RetryLogic
    CheckError -->|400 Error| ShowError[Show User Error]
    CheckError -->|401 Error| RefreshToken[Refresh Auth Token]
    
    RefreshToken --> TokenSuccess{Token<br/>Refreshed?}
    TokenSuccess -->|Yes| APICall
    TokenSuccess -->|No| LogoutUser[Logout User]
    
    RetryLogic[Exponential Backoff Retry] --> Attempt1[Wait 2s, Retry]
    Attempt1 --> Try1{Success?}
    Try1 -->|Yes| ProcessResponse
    Try1 -->|No| Attempt2[Wait 4s, Retry]
    
    Attempt2 --> Try2{Success?}
    Try2 -->|Yes| ProcessResponse
    Try2 -->|No| Attempt3[Wait 8s, Retry]
    
    Attempt3 --> Try3{Success?}
    Try3 -->|Yes| ProcessResponse
    Try3 -->|No| MaxRetries[Max Retries Reached]
    
    MaxRetries --> QueueOffline{Can Queue<br/>Offline?}
    
    QueueOffline -->|Yes| SaveLocal[Save to Local Storage]
    QueueOffline -->|No| ShowError
    
    SaveLocal --> NotifyUser[Notify: Will retry when online]
    NotifyUser --> End
    
    ShowError --> End
    LogoutUser --> End
```

---

## 10. Cancellation Scenarios

### 10.1 User Cancellation Flow

```mermaid
flowchart TD
    Start([User Clicks Cancel]) --> ConfirmDialog[Show Confirmation Dialog]
    
    ConfirmDialog --> UserConfirms{User<br/>Confirms?}
    UserConfirms -->|No| Return[Return to Order Screen]
    
    UserConfirms -->|Yes| CheckStatus{Order<br/>Status?}
    
    CheckStatus -->|Pending| NoPenalty[No Penalty]
    CheckStatus -->|Searching Driver| NoPenalty
    
    CheckStatus -->|Assigned < 3min| Penalty20[20% Penalty]
    CheckStatus -->|Assigned > 3min| Penalty50[50% Penalty]
    
    CheckStatus -->|Picked Up| Penalty100[100% Charge + Warning]
    CheckStatus -->|In Transit| CannotCancel[Cannot Cancel<br/>Show Error]
    
    NoPenalty --> RefundFull[Refund Full Amount]
    Penalty20 --> RefundPartial20[Refund 80%<br/>Deduct 20%]
    Penalty50 --> RefundPartial50[Refund 50%<br/>Deduct 50%]
    Penalty100 --> NoRefund[No Refund]
    
    RefundFull --> ProcessCancel
    RefundPartial20 --> ProcessCancel
    RefundPartial50 --> ProcessCancel
    NoRefund --> ProcessCancel
    
    ProcessCancel[Update Order: Cancelled] --> NotifyDriver{Driver<br/>Assigned?}
    
    NotifyDriver -->|Yes| SendDriverNotif[Send Cancellation Notification]
    NotifyDriver -->|No| UpdateDB
    
    SendDriverNotif --> CompensateDriver[Compensate Driver ₹50]
    CompensateDriver --> UpdateDB[Update Database]
    
    UpdateDB --> ShowConfirm[Show Cancellation Confirmed]
    ShowConfirm --> End([Order Cancelled])
    
    CannotCancel --> Return
    Return --> End
```

---

## 11. Scheduled Delivery Flow

```mermaid
gantt
    title Scheduled Delivery Timeline
    dateFormat HH:mm
    axisFormat %H:%M
    
    section User Actions
    Book delivery for 6 PM          :done, booking, 14:00, 1m
    Receive confirmation            :done, confirm, 14:01, 1m
    
    section System Processing
    Store in scheduled_jobs table   :done, store, 14:02, 1m
    Wait until allocation time      :active, wait, 14:03, 225m
    
    section Driver Matching (5:30 PM)
    Start driver search             :crit, search, 17:30, 5m
    Assign driver                   :crit, assign, 17:35, 1m
    Notify user & driver            :milestone, notify, 17:36, 0m
    
    section Delivery Execution
    Driver picks up package         :active, pickup, 17:45, 10m
    In transit to customer          :active, transit, 17:55, 25m
    Delivered at 6:20 PM            :milestone, deliver, 18:20, 0m
```

---

## 12. Multi-Stop Delivery Flow

```mermaid
graph TD
    Start([User Books Multi-Stop]) --> AddPickup[Add Pickup Location]
    
    AddPickup --> AddStops[Add Multiple Drop Locations]
    AddStops --> Stop1[Stop 1: Address A]
    Stop1 --> Stop2[Stop 2: Address B]
    Stop2 --> Stop3[Stop 3: Address C]
    
    Stop3 --> CalculateRoute[Calculate Optimized Route]
    CalculateRoute --> ShowEstimate[Show Total Fare<br/>Distance + Stops]
    
    ShowEstimate --> UserConfirms{User<br/>Confirms?}
    UserConfirms -->|No| EditStops[Edit Stops]
    EditStops --> CalculateRoute
    
    UserConfirms -->|Yes| PlaceOrder[Place Order]
    PlaceOrder --> AssignDriver[Assign Driver]
    
    AssignDriver --> DriverSees[Driver sees all stops]
    DriverSees --> Navigate1[Navigate to Pickup]
    Navigate1 --> Collect[Collect Package]
    
    Collect --> Seq1[Navigate to Stop 1]
    Seq1 --> Deliver1[Deliver to Address A]
    Deliver1 --> Photo1[Capture Photo]
    
    Photo1 --> Seq2[Navigate to Stop 2]
    Seq2 --> Deliver2[Deliver to Address B]
    Deliver2 --> Photo2[Capture Photo]
    
    Photo2 --> Seq3[Navigate to Stop 3]
    Seq3 --> Deliver3[Deliver to Address C]
    Deliver3 --> Photo3[Capture Photo]
    
    Photo3 --> AllComplete{All Stops<br/>Complete?}
    AllComplete -->|Yes| EndDelivery[Mark Order Complete]
    EndDelivery --> Calculate[Calculate Earnings]
    Calculate --> End([Multi-Stop Delivery Complete])
```

---

## 13. Wallet Withdrawal Flow (Pilot)

```mermaid
sequenceDiagram
    participant P as Pilot
    participant APP as Pilot App
    participant API as Backend
    participant DB as Database
    participant BANK as Bank Transfer API
    
    P->>APP: Click "Withdraw"
    APP->>API: GET /wallet/balance
    API->>DB: Fetch pilot wallet
    DB-->>API: balance: ₹2,450
    API-->>APP: Return balance
    
    APP->>P: Show current balance
    P->>APP: Enter amount (₹2,000)
    
    APP->>API: POST /wallet/withdraw {amount: 2000}
    
    API->>API: Validate
    
    alt Amount < minimum (₹500)
        API-->>APP: Error: Minimum ₹500
    else Amount > balance
        API-->>APP: Error: Insufficient balance
    else Bank details not verified
        API-->>APP: Error: Add bank details
    else Valid
        API->>DB: Create withdrawal request (pending)
        API->>DB: Reduce available balance
        API-->>APP: Withdrawal initiated
        
        APP->>P: Success! Processing in 1-2 days
        
        Note over API: Admin reviews (if > ₹10,000)
        
        API->>BANK: Initiate bank transfer
        
        alt Transfer Success
            BANK-->>API: Transfer successful
            API->>DB: Update status (completed)
            API->>APP: Push notification
            APP->>P: ₹2,000 transferred to account
        else Transfer Failed
            BANK-->>API: Transfer failed
            API->>DB: Update status (failed)
            API->>DB: Reverse balance
            API->>APP: Push notification
            APP->>P: Transfer failed, balance restored
        end
    end
```

---

## 14. Support Ticket Workflow

```mermaid
stateDiagram-v2
    [*] --> UserOpensSupport: User/Pilot has issue
    
    UserOpensSupport --> SelectCategory: Choose category
    SelectCategory --> DescribeIssue: Describe issue + attach files
    
    DescribeIssue --> SubmitTicket: Submit ticket
    SubmitTicket --> TicketCreated: Ticket #12345 created
    
    TicketCreated --> AssignedToAdmin: Auto-assigned to support team
    
    AssignedToAdmin --> AdminReviews: Admin reviews ticket
    
    AdminReviews --> NeedsInfo: Request more information
    NeedsInfo --> UserResponds: User provides info
    UserResponds --> AdminReviews
    
    AdminReviews --> Investigating: Admin investigates
    Investigating --> Resolved: Issue resolved
    
    Resolved --> NotifyUser: Notify user via push + email
    NotifyUser --> UserReviews: User reviews resolution
    
    UserReviews --> Satisfied: Issue resolved
    UserReviews --> NotSatisfied: Not satisfied
    
    NotSatisfied --> ReopenTicket: Reopen ticket
    ReopenTicket --> AdminReviews
    
    Satisfied --> Closed: Close ticket
    Closed --> [*]
    
    note right of TicketCreated
        Priority auto-assigned:
        - Payment issues: High
        - Order issues: Medium
        - Others: Low
    end note
```

---

## 15. Complete System Integration

```mermaid
graph TB
    subgraph "User Interactions"
        U1[Browse App]
        U2[Book Delivery]
        U3[Track Order]
        U4[Make Payment]
        U5[Rate Driver]
    end
    
    subgraph "Pilot Interactions"
        P1[Go Online]
        P2[Accept Job]
        P3[Navigate]
        P4[Complete Delivery]
        P5[Check Earnings]
    end
    
    subgraph "Admin Operations"
        A1[Verify Pilots]
        A2[Monitor Orders]
        A3[Manage Pricing]
        A4[Handle Support]
        A5[View Analytics]
    end
    
    subgraph "Core Backend Services"
        API[REST API]
        WS[WebSocket]
        QUEUE[Job Queue]
        AUTH[Auth Service]
        MATCH[Driver Matching]
        PRICE[Pricing Engine]
        NOTIF[Notification Service]
    end
    
    subgraph "Data Layer"
        PG[(PostgreSQL)]
        REDIS[(Redis)]
        S3[(File Storage)]
    end
    
    subgraph "External Services"
        MAPS[Maps API]
        PAY[Payment Gateway]
        SMS[SMS Service]
        FCM[Push Notifications]
    end
    
    U1 --> API
    U2 --> API
    U3 --> WS
    U4 --> API
    U5 --> API
    
    P1 --> API
    P2 --> WS
    P3 --> WS
    P4 --> API
    P5 --> API
    
    A1 --> API
    A2 --> WS
    A3 --> API
    A4 --> API
    A5 --> API
    
    API --> AUTH
    API --> MATCH
    API --> PRICE
    API --> NOTIF
    
    AUTH --> PG
    MATCH --> PG
    MATCH --> REDIS
    PRICE --> PG
    
    WS --> REDIS
    QUEUE --> REDIS
    
    API --> PG
    API --> S3
    API --> MAPS
    API --> PAY
    
    NOTIF --> FCM
    NOTIF --> SMS
    
    QUEUE --> MATCH
    QUEUE --> NOTIF
```

---

**Document Version:** 1.0  
**Last Updated:** 2026-01-29  
**Purpose:** Visual reference for all platform workflows
