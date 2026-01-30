# Pilot Mobile App - Detailed Planning Document

## 1. Overview

The Pilot App ("SendIt Pilot - Deliver & Earn") is the delivery partner-facing mobile application for accepting jobs, managing deliveries, and tracking earnings.

**Platform:** Flutter (iOS & Android)

## 2. Technology Stack

### Core
- **Framework:** Flutter 3.16+
- **Language:** Dart
- **Navigation:** GoRouter 13.x
- **State Management:** GetX
- **UI Components:** Material Design + Custom Widgets
- **Forms:** flutter_form_builder + form_builder_validators

### Key Packages
- **Maps:** google_maps_flutter
- **Location:** geolocator, background_location (background tracking)
- **Notifications:** firebase_messaging, flutter_local_notifications
- **Camera:** image_picker (documents & delivery photos)
- **Storage:** shared_preferences, hive
- **WebSocket:** socket_io_client
- **HTTP:** dio with interceptors
- **Background Tasks:** workmanager

## 3. App Architecture

### 3.1 Folder Structure
```
sendit_pilot/
├── lib/
│   ├── core/             # Core utilities
│   │   ├── api/          # API client
│   │   ├── constants/    # Constants & config
│   │   ├── theme/        # Design system
│   │   └── utils/        # Helper functions
│   ├── models/           # Data models
│   │   ├── pilot.dart
│   │   ├── job.dart
│   │   ├── vehicle.dart
│   │   └── ...
│   ├── providers/        # State management
│   │   ├── auth_provider.dart
│   │   ├── pilot_provider.dart
│   │   ├── job_provider.dart
│   │   ├── earnings_provider.dart
│   │   ├── vehicle_provider.dart
│   │   └── location_provider.dart
│   ├── screens/          # Screen widgets
│   │   ├── auth/
│   │   ├── registration/
│   │   ├── home/
│   │   ├── active_job/
│   │   ├── earnings/
│   │   └── profile/
│   ├── widgets/          # Reusable widgets
│   │   ├── common/
│   │   ├── jobs/
│   │   ├── earnings/
│   │   └── documents/
│   ├── services/         # Business logic
│   │   ├── location_service.dart
│   │   ├── socket_service.dart
│   │   ├── background_service.dart
│   │   └── navigation_service.dart
│   ├── routes/           # Navigation/routing
│   │   └── app_router.dart
│   └── main.dart         # App entry point
├── assets/               # Images, fonts, icons
└── pubspec.yaml          # Dependencies
```

### 3.2 State Management (Riverpod)

**Providers:**
- `authProvider` - Authentication state
- `pilotProfileProvider` - Pilot profile & verification status
- `jobProvider` - Active jobs, incoming requests, job history
- `earningsProvider` - Earnings data, wallet balance
- `vehicleProvider` - Registered vehicles, active vehicle
- `notificationProvider` - Notifications
- `locationProvider` - Current location tracking

## 4. Screen Specifications

### 4.1 Registration & Onboarding

#### Screen 1: Welcome/Splash
**Components:**
- App logo
- Tagline: "Ride. Earn. Repeat."
- "Get Started" button
- "Login" button

#### Screen 2: Phone Login (Same as User App)
**Components:**
- Country code + phone input
- "Send OTP" button

**API:**
```typescript
POST /api/v1/auth/send-otp
{
  phone: "9484707535",
  country_code: "+91",
  user_type: "pilot"
}
```

#### Screen 3: OTP Verification
**Same as user app**

#### Screen 4: Registration Form (New Pilots)
**Step 1: Personal Details**
- Full name (required)
- Email address (required)
- Date of birth (required, must be 16+)
- Full address (required)
- City, State, Pincode
- Profile photo upload
- "Next" button

**Validation:**
- Age validation (16+ for EV Cycle, 18+ for motorized)
- Email format validation

**Step 2: Vehicle Details**
- Vehicle type selector:
  - Cycle
  - EV Cycle
  - 2 Wheeler (with fuel type: CNG, Petrol, EV)
  - 3 Wheeler (with fuel type: CNG, Diesel, EV, Petrol)
  - Truck (with fuel type)
- Vehicle number input
- Vehicle model/make
- "Next" button

**Step 3: Document Upload**
**Required documents based on age & vehicle:**

For 18+ with motorized vehicles:
- ID Proof (Aadhar/PAN/Passport)
- Driving License
- Vehicle Registration Certificate (RC)
- Insurance certificate
- Pollution certificate (if applicable)

For 16-18 with EV Cycle:
- ID Proof (Aadhar/School ID)
- Parental Consent Form (template download)
- Parent's ID proof

**Upload Component:**
- Document type label
- Camera/Gallery picker
- Preview thumbnail
- Upload status indicator
- Re-upload option

**Step 4: Bank Details**
- Account holder name
- Bank name
- Account number
- IFSC code
- Upload cancelled cheque/passbook
- "Submit for Verification" button

**API:**
```typescript
POST /api/v1/pilots/register
{
  name: "Ankit Kothiya",
  email: "ankit@example.com",
  date_of_birth: "1995-05-15",
  age: 28,
  address: "...",
  city: "Ahmedabad",
  state: "Gujarat",
  pincode: "380001",
  vehicle_details: {
    type: "2_wheeler",
    category: "ev",
    number: "GJ-14-AR-4905",
    model: "Honda Activa Electric"
  },
  documents: {
    id_proof: "url",
    driving_license: "url",
    vehicle_rc: "url",
    insurance: "url"
  },
  bank_details: {
    account_holder: "Ankit Kothiya",
    account_number: "123456789",
    ifsc: "SBIN0001234",
    bank_name: "State Bank of India"
  }
}
```

#### Screen 5: Verification Pending
**Components:**
- Success icon
- Message: "Your application is under review"
- Estimated time: "24-48 hours"
- Support contact info
- "24/7 Support" badge
- "Track Status" button

**Logic:**
- Poll API for verification status
- Push notification when approved/rejected

### 4.2 Main Dashboard

#### Screen 6: Home/Dashboard
**Header:**
- Greeting: "Hey [Name], Good Morning"
- Tagline: "Ride. Earn. Repeat."
- Menu icon

**Online/Offline Toggle:**
- Large prominent switch
- Current status display
- "Go Online" / "Go Offline"

**When Offline:**
- Grayed-out map
- Message: "You're offline. Go online to start receiving orders"
- Missed order value display: "You missed ₹1,850 in orders today"

**When Online:**
- Live map showing current location
- Available jobs indicator
- Incoming job popup overlay

**Stats Cards (Tabs):**
- **Today Tab:**
  - Earning: ₹9,800
  - Total Hours: 08.00
  - Rides: 15
- **This Week Tab:**
  - Earning: ₹45,000
  - Total Hours: 45.00
  - Rides: 82

**Active Vehicle Display:**
- Vehicle icon
- Type & category (2 Wheeler - EV)
- Registration number (GJ-27-CC-0758)
- Battery percentage (for EV)
- "Change Vehicle" option

**Quick Actions:**
- My Earnings
- My Vehicles
- My Wallet
- Rewards

**State Required:**
```typescript
{
  isOnline: boolean,
  currentLocation: Coordinates,
  todayStats: { earnings, hours, rides },
  weekStats: { earnings, hours, rides },
  activeVehicle: Vehicle,
  missedOrderValue: number
}
```

### 4.3 Job Management

#### Screen 7: Incoming Job Request (Modal/Popup)
**Appears when online and job assigned**

**Components:**
- **Fare:** ₹430.00 (large, prominent)
- **Load Assist Needed:** Checkbox indicator
- **Pickup Section:**
  - Icon
  - "5 mins away"
  - "1.2 km"
  - Full address
- **Drop Section:**
  - Icon
  - "25 mins"
  - "10.2 km"
  - Full address
- **Package Details:**
  - Type of goods (if available)
  - Weight estimate
- **Timer:** 30 seconds countdown (auto-decline)
- **Actions:**
  - "Decline" button (left)
  - "Accept" button (right, prominent)

**Multiple Jobs:**
- If multiple jobs incoming, show stacked cards
- Can accept multiple simultaneously
- Route optimization suggested

**WebSocket:**
```typescript
socket.on('job:new', (jobData) => {
  // Show popup
  // Start timer
});
```

**API:**
```typescript
PUT /api/v1/pilots/jobs/:id/accept
{
  pilot_id: "uuid",
  estimated_arrival: "5 mins"
}
```

#### Screen 8: Active Job Screen
**Navigation Mode**

**Map View:**
- Full-screen map
- Pickup marker (if not picked up)
- Drop marker
- Route polyline
- Current location
- Turn-by-turn navigation
- ETA display

**Job Info Card (Bottom Sheet):**
- Order ID
- Package details
- Customer contact button
- Actions based on status:
  - "Navigate to Pickup" → "Arrived at Pickup"
  - "Collect Package" → "Start Delivery"
  - "Navigate to Drop" → "Arrived at Drop"
  - "Complete Delivery"

**Photo Capture:**
- Camera opens when:
  - Collecting package (optional)
  - Completing delivery (required)
- Preview and retake option
- "Upload & Continue" button

**Payment Collection (COD):**
- If COD, show collection prompt
- Amount to collect
- "Collected Cash" confirmation

**Status Flow:**
```
Assigned → Navigating to Pickup → Arrived at Pickup → 
Package Collected → In Transit → Arrived at Drop → 
Delivered → Rating (optional)
```

**API Calls:**
```typescript
PUT /api/v1/pilots/jobs/:id/status
{
  status: "picked_up",
  timestamp: "2026-01-29T10:30:00Z",
  photo_url: "url" // if applicable
}
```

**Navigation Integration:**
```typescript
// Open external navigation
const openNavigation = (lat, lng) => {
  const url = Platform.select({
    ios: `maps:0,0?q=${lat},${lng}`,
    android: `geo:0,0?q=${lat},${lng}`
  });
  Linking.openURL(url);
};
```

#### Screen 9: Multiple Active Jobs
**When multiple jobs accepted:**
- List view of active jobs
- Optimized route displayed
- Next job highlighted
- Tap to expand details
- Route view showing all stops

### 4.4 Earnings & Wallet

#### Screen 10: My Wallet
**Header:**
- Pilot name
- Wallet balance (large): ₹430.00

**Quick Actions (Grid):**
- Add Money
- Withdraw
- Bank Details
- Reward Points

**Transaction History:**
- "View All" link
- Recent 5 transactions:
  - Icon (credit/debit)
  - Description ("Admin Credited", "Order #1234")
  - Amount (+ green / - red)
  - Date & time
  - Status (for withdrawals)

**Transaction Types:**
- Order earnings (+ green)
- Withdrawal (- red)
- Bonus/rewards (+ green)
- Admin credit/debit
- Referral earnings

**API:**
```typescript
GET /api/v1/pilots/wallet/transactions?page=1&limit=20
```

#### Screen 11: Add Money to Wallet
**Components:**
- Amount chips (₹100, ₹500, ₹1000)
- Custom amount input
- Payment method selector
- UPI, Card, Net Banking options
- "Add Money" button

#### Screen 12: Withdraw Money
**Components:**
- Available balance display
- Minimum withdrawal: ₹500
- Withdrawal amount input
- Bank account selector (from saved)
- "Withdraw" button
- Processing note: "Withdrawals take 5-7 business days"

**Validation:**
- Amount <= available balance
- Amount >= minimum withdrawal

**API:**
```typescript
POST /api/v1/pilots/wallet/withdraw
{
  amount: 1000,
  bank_account_id: "uuid"
}
```

#### Screen 13: Earnings Dashboard
**Period Selector:**
- Today | This Week | This Month | Custom Range

**Summary Cards:**
- Total Earnings
- Completed Rides
- Total Hours
- Average per ride
- Incentives earned

**Earnings Chart:**
- Bar/line chart showing daily earnings
- Interactive (tap to see details)

**Ride-wise Breakdown:**
- List of completed rides
- Each showing:
  - Order ID
  - Route (pickup → drop)
  - Distance
  - Duration
  - Earnings
  - Date & time

**Export:**
- "Download Report" button (PDF/Excel)

**API:**
```typescript
GET /api/v1/pilots/earnings?period=this_week
```

### 4.5 Vehicles

#### Screen 14: My Vehicles
**Vehicle List:**
- Card for each registered vehicle
- Active vehicle highlighted with "Active" badge
- "Go Green" badge for EVs

**Vehicle Card:**
- Vehicle icon
- Type & category (2 wheeler - EV)
- Registration number (GJ-14-AR-4905)
- Document status (Verified/Pending)
- Toggle to activate
- Edit icon

**Actions:**
- Tap card to expand details
- Toggle to switch active vehicle
- "Add New Vehicle" button

**Add Vehicle Flow:**
- Same as registration
- Vehicle details form
- Document upload
- Submit for verification

**API:**
```typescript
GET /api/v1/pilots/vehicles

POST /api/v1/pilots/vehicles
{
  vehicle_type: "3_wheeler",
  vehicle_category: "diesel",
  vehicle_number: "GJ-27-BR-1234",
  vehicle_model: "Bajaj Auto"
}

PUT /api/v1/pilots/vehicles/:id/activate
```

### 4.6 Rewards & Referrals

#### Screen 15: Rewards & Referrals
**Referral Section:**
- Referral code display (large): "5DTJ23"
- Copy & Share buttons
- Referral link

**Rewards Progress:**
- "Refer More, Earn More"
- Progress indicator: 5/10 referrals
- Reward per referral: "100 Reward Points"

**Available Rewards:**
- Total points: 250
- "Redeem Your Rewards" button
- Redemption options:
  - Convert to wallet cash
  - Use for fuel/maintenance discounts

**Referral History:**
- List of referred pilots
- Name
- Status (Signed up, Completed 1st ride)
- Reward earned
- Date

**Points History:**
- Transaction log:
  - Earned from referral
  - Earned from ride milestones
  - Redeemed for coupon
  - Used for wallet credit

**Share Text:**
```
Join SendIt as a delivery partner! Use my code: 5DTJ23
Earn money with flexible hours.
Download: [App Link]
```

### 4.7 Profile & Settings

#### Screen 16: Profile
**Header:**
- Profile photo (editable)
- Name
- Phone number
- Verification status badge

**Stats:**
- Total rides
- Rating (4.8★)
- Member since

**Sections:**

**Account:**
- Personal Information
- My Vehicles
- Bank Details
- Documents

**Earnings:**
- My Wallet
- Earnings Dashboard
- Rewards & Referrals

**Support:**
- Help Center
- Contact Support
- FAQs

**Settings:**
- Notification Settings
- Language Preference
- App Settings

**Legal:**
- Terms & Conditions
- Privacy Policy

**Action:**
- Logout

#### Screen 17: Personal Information
**Editable Fields:**
- Name
- Email
- Address
- Profile photo

**Non-editable:**
- Phone (show change option with verification)
- Date of birth
- Verification status

#### Screen 18: Bank Details
**Display:**
- Account holder name
- Bank name
- Account number (masked)
- IFSC code

**Actions:**
- View full details (with authentication)
- Update bank details (new verification required)
- Add alternate account

#### Screen 19: Documents
**Document List:**
- ID Proof (Verified ✓)
- Driving License (Verified ✓)
- Vehicle RC (Pending verification)
- Insurance (Expiring soon ⚠️)

**Actions:**
- View document
- Re-upload (if expired/rejected)
- Download

**Expiry Alerts:**
- Notification 30 days before expiry
- Reminder to update

#### Screen 20: Notification Settings
**Toggles:**
- Job notifications
- Earnings updates
- Promotional offers
- App updates
- Sound alerts
- Vibration

### 4.8 Support

#### Screen 21: Help Center
**Categories:**
- Getting Started
- Managing Orders
- Earnings & Payments
- Account Issues
- App Troubleshooting

**FAQ Accordion:**
- Expandable questions
- Search functionality

**Contact Support:**
- In-app chat
- Email: support@drop-it.co
- Phone: +91 94847 07535
- "24/7 Support" badge

## 5. Key Features Implementation

### 5.1 Online/Offline Toggle
```typescript
const toggleOnlineStatus = async () => {
  const newStatus = !isOnline;
  
  // Update local state immediately
  dispatch(setOnlineStatus(newStatus));
  
  // Start/stop location tracking
  if (newStatus) {
    await startLocationTracking();
    await connectSocket();
  } else {
    await stopLocationTracking();
    await disconnectSocket();
  }
  
  // Update backend
  await api.put('/pilots/online-status', {
    online: newStatus,
    location: currentLocation
  });
};
```

### 5.2 Background Location Tracking
```typescript
// location.service.ts
import BackgroundGeolocation from 'react-native-background-geolocation';

export const startLocationTracking = () => {
  BackgroundGeolocation.configure({
    desiredAccuracy: BackgroundGeolocation.HIGH_ACCURACY,
    distanceFilter: 50, // Update every 50 meters
    stationaryRadius: 25,
    locationUpdateInterval: 5000, // 5 seconds
    fastestLocationUpdateInterval: 5000,
  });
  
  BackgroundGeolocation.on('location', (location) => {
    // Send to backend via WebSocket
    socket.emit('pilot:location', {
      lat: location.coords.latitude,
      lng: location.coords.longitude,
      heading: location.coords.heading,
      speed: location.coords.speed
    });
  });
  
  BackgroundGeolocation.start();
};
```

### 5.3 Job Request Handling
```typescript
// jobsSlice.ts
const handleNewJob = (jobData: JobRequest) => {
  // Add to incoming jobs queue
  dispatch(addIncomingJob(jobData));
  
  // Show notification
  PushNotification.localNotification({
    title: 'New Job Available',
    message: `₹${jobData.fare} - ${jobData.distance} km`,
    playSound: true,
    vibrate: true
  });
  
  // Start 30-second timer
  setTimeout(() => {
    // Auto-decline if not responded
    if (!jobData.responded) {
      dispatch(autoDeclineJob(jobData.id));
    }
  }, 30000);
};
```

### 5.4 Multiple Job Management
```typescript
// Route optimization
const optimizeRoute = (jobs: Job[]) => {
  // Sort by proximity to current location
  // Then by delivery time window
  // Calculate combined route
  
  return {
    optimizedOrder: sortedJobs,
    totalDistance: number,
    estimatedDuration: number,
    route: polylineCoordinates
  };
};
```

### 5.5 Photo Capture
```typescript
import ImagePicker from 'react-native-image-picker';

const captureDeliveryPhoto = async () => {
  const result = await ImagePicker.launchCamera({
    mediaType: 'photo',
    quality: 0.8,
    maxWidth: 1024,
    maxHeight: 1024
  });
  
  if (result.assets && result.assets[0]) {
    const photo = result.assets[0];
    
    // Upload to backend
    const formData = new FormData();
    formData.append('photo', {
      uri: photo.uri,
      type: photo.type,
      name: photo.fileName
    });
    
    const response = await api.post(
      `/pilots/jobs/${jobId}/photos`,
      formData,
      { headers: { 'Content-Type': 'multipart/form-data' } }
    );
    
    return response.data.photo_url;
  }
};
```

## 6. Performance & Battery Optimization

### Location Tracking
- Use significant location changes when idle
- Increase update frequency during active delivery
- Stop tracking when offline
- Batch location updates

### Background Tasks
- Minimize background processing
- Use push notifications instead of polling
- Efficient WebSocket connection management

### Battery Usage
- Show battery usage estimate
- Allow pilots to adjust tracking frequency
- Warn when battery low

## 7. Offline Capabilities

### Data to Cache
- Pilot profile
- Vehicle details
- Pending jobs
- Recent earnings
- Bank details

### Offline Features
- View profile
- View earnings history
- View vehicle details
- Queue status updates (sync when online)

## 8. Push Notifications

### Notification Types
1. **Job Requests** (high priority)
2. **Job Updates** (order cancelled)
3. **Earnings** (payment received)
4. **Documents** (expiring soon, approved/rejected)
5. **Rewards** (referral bonus)
6. **System** (app updates, maintenance)

## 9. Analytics Events

### Track Events
- `pilot_registered`
- `verification_completed`
- `went_online`
- `went_offline`
- `job_received`
- `job_accepted`
- `job_declined`
- `job_completed`
- `earnings_withdrawn`
- `vehicle_added`
- `referral_shared`

## 10. Development Checklist

### Phase 1: Setup & Registration
- [ ] Initialize project
- [ ] Setup navigation
- [ ] Phone authentication
- [ ] Registration form
- [ ] Document upload
- [ ] Verification status

### Phase 2: Core Job Features
- [ ] Home dashboard
- [ ] Online/offline toggle
- [ ] Location tracking
- [ ] Job request popup
- [ ] Accept/decline jobs
- [ ] Active job screen
- [ ] Navigation integration
- [ ] Photo capture
- [ ] Status updates

### Phase 3: Earnings & Wallet
- [ ] Wallet screen
- [ ] Transaction history
- [ ] Add money
- [ ] Withdraw money
- [ ] Earnings dashboard
- [ ] Reports generation

### Phase 4: Vehicles & Profile
- [ ] My vehicles screen
- [ ] Add vehicle
- [ ] Switch active vehicle
- [ ] Profile management
- [ ] Bank details
- [ ] Document management

### Phase 5: Advanced
- [ ] Multiple job handling
- [ ] Route optimization
- [ ] Rewards & referrals
- [ ] Real-time updates
- [ ] Push notifications
- [ ] Background location
- [ ] Analytics

---

**Document Version:** 1.0  
**Last Updated:** 2026-01-29
