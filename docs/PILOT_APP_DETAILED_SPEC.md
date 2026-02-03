# SendIt Pilot App - Detailed Technical Specification

**Date:** February 3, 2026  
**Version:** 1.0  
**Status:** Pre-Development

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Screen-by-Screen Specification](#screen-by-screen-specification)
3. [Backend API Mapping](#backend-api-mapping)
4. [Gap Analysis](#gap-analysis)
5. [Database Schema](#database-schema)
6. [Socket Events](#socket-events)
7. [Implementation Checklist](#implementation-checklist)

---

## 1. Overview

### App Identity
- **Name:** SendIt Pilot
- **Package:** `com.sendit.pilot`
- **Platform:** Flutter (iOS & Android)
- **Min iOS:** 14.0
- **Min Android:** API 24 (Android 7.0)

### Architecture
- **State Management:** GetX
- **API Client:** Dio with interceptors
- **Local Storage:** GetStorage + Hive
- **Real-time:** Socket.io Client
- **Maps:** Google Maps Flutter
- **Background Location:** geolocator + workmanager

---

## 2. Screen-by-Screen Specification

### 2.1 Authentication Module

#### Screen: Splash
| Element | Description |
|---------|-------------|
| Logo | SendIt Pilot logo centered |
| Logic | Check stored token → validate → route |
| Duration | 2 seconds max |
| Routes | → Login (no token) / Home (valid) / Verification Pending (pending status) |

**API Required:** None (local token check)

---

#### Screen: Phone Login
| Element | Description |
|---------|-------------|
| Country Code | Dropdown, default +91 |
| Phone Input | 10 digits, numeric keyboard |
| Send OTP Button | Disabled until valid phone |
| Terms Link | Opens Terms & Conditions |

**API Required:**
```
POST /api/v1/auth/pilot/send-otp
Body: { phone: "9876543210", countryCode: "+91" }
Response: { success: true, data: { otpId: "xxx", expiresAt: "..." } }
```

**Backend Status:** ✅ EXISTS

---

#### Screen: OTP Verification
| Element | Description |
|---------|-------------|
| OTP Input | 6-digit PIN input |
| Timer | 60 second countdown |
| Resend Button | Enabled after timer |
| Auto-submit | When 6 digits entered |

**API Required:**
```
POST /api/v1/auth/pilot/verify-otp
Body: { otpId: "xxx", otp: "123456", phone: "9876543210" }
Response: { 
  success: true, 
  data: { 
    token: "jwt...", 
    refreshToken: "...",
    pilot: { id, name, status, isNewUser },
    isNewUser: true/false
  } 
}
```

**Backend Status:** ✅ EXISTS

---

### 2.2 Registration Module (New Pilots)

#### Screen: Step 1 - Personal Details
| Field | Type | Validation | Required |
|-------|------|------------|----------|
| Full Name | Text | Min 2 chars | ✅ |
| Email | Email | Valid email format | ✅ |
| Date of Birth | Date Picker | 16+ years old | ✅ |
| Gender | Dropdown | MALE/FEMALE/OTHER | ❌ |
| Address | Textarea | Min 10 chars | ✅ |
| City | Text | - | ✅ |
| State | Dropdown | Indian states | ✅ |
| Pincode | Number | 6 digits | ✅ |
| Profile Photo | Camera/Gallery | Max 5MB, JPG/PNG | ✅ |

**API Required:**
```
PATCH /api/v1/pilots/profile
Body: { 
  name, email, dateOfBirth, gender, 
  address, city, state, pincode 
}
```

**Backend Status:** ✅ EXISTS (partial - needs address fields)

---

#### Screen: Step 2 - Vehicle Details
| Field | Type | Options | Required |
|-------|------|---------|----------|
| Vehicle Type | Radio | Cycle, EV Cycle, 2 Wheeler, 3 Wheeler, Truck | ✅ |
| Fuel Type | Dropdown | EV, Petrol, Diesel, CNG (based on vehicle) | Conditional |
| Registration No | Text | Format: XX-00-XX-0000 | ✅ (motorized) |
| Vehicle Model | Text | - | ❌ |
| Vehicle Color | Text | - | ❌ |

**API Required:**
```
POST /api/v1/pilots/vehicles
Body: { 
  vehicleTypeId: "uuid",
  registrationNo: "GJ-01-XX-1234",
  model: "Honda Activa",
  color: "Black"
}
```

**Backend Status:** ⚠️ NEEDS NEW ENDPOINT
- Current: No dedicated vehicle creation for pilots
- Vehicle model exists but no POST route for pilots

---

#### Screen: Step 3 - Document Upload
| Document | For Age | For Vehicle | Required |
|----------|---------|-------------|----------|
| ID Proof (Aadhaar) | All | All | ✅ |
| Driving License | 18+ | Motorized | ✅ |
| Vehicle RC | - | Motorized | ✅ |
| Vehicle Insurance | - | Motorized | ✅ |
| PUC Certificate | - | Motorized | ❌ |
| Parental Consent | 16-17 | EV Cycle only | ✅ |
| Profile Photo | All | All | ✅ |
| Vehicle Photo | - | All | ❌ |

**API Required:**
```
POST /api/v1/upload/pilot/documents
Content-Type: multipart/form-data
Fields: idProof, drivingLicense, vehicleRC, insurance, parentalConsent, etc.
Response: { success: true, data: { documents: [...] } }
```

**Backend Status:** ✅ EXISTS

---

#### Screen: Step 4 - Bank Details
| Field | Type | Validation | Required |
|-------|------|------------|----------|
| Account Holder Name | Text | Min 3 chars | ✅ |
| Bank Name | Dropdown/Text | - | ✅ |
| Account Number | Number | 9-18 digits | ✅ |
| Confirm Account | Number | Must match | ✅ |
| IFSC Code | Text | 11 chars, format check | ✅ |
| Bank Proof | Camera | Cancelled cheque/passbook | ✅ |

**API Required:**
```
POST /api/v1/pilots/bank-account
Body: { 
  accountName, bankName, accountNumber, ifscCode 
}
```

**Backend Status:** ⚠️ NEEDS NEW ENDPOINT
- BankAccount model exists
- No API endpoint to create/update

---

#### Screen: Verification Pending
| Element | Description |
|---------|-------------|
| Icon | Clock/Hourglass animation |
| Message | "Your application is under review" |
| Timeline | 24-48 hours estimate |
| Support | Contact info, chat option |
| Refresh | Pull to refresh status |

**API Required:**
```
GET /api/v1/pilots/profile
Check: pilot.status === "PENDING" | "APPROVED" | "REJECTED"
```

**Backend Status:** ✅ EXISTS

---

### 2.3 Dashboard Module

#### Screen: Home Dashboard
| Section | Elements |
|---------|----------|
| Header | Greeting, notification bell, menu |
| Online Toggle | Large switch with status text |
| Stats Cards | Today earnings, rides, hours |
| Active Vehicle | Type, number, battery (EV) |
| Quick Actions | Earnings, Wallet, Vehicles, Rewards |
| Map (when online) | Current location marker |

**APIs Required:**

1. **Get Profile & Stats:**
```
GET /api/v1/pilots/profile
Response: { pilot: { name, rating, totalDeliveries, totalEarnings, isOnline } }
```
**Backend Status:** ✅ EXISTS

2. **Toggle Online Status:**
```
PATCH /api/v1/pilots/status
Body: { isOnline: true/false }
```
**Backend Status:** ✅ EXISTS

3. **Update Location:**
```
PATCH /api/v1/pilots/location
Body: { lat: 23.0225, lng: 72.5714 }
```
**Backend Status:** ✅ EXISTS

4. **Get Today's Stats:**
```
GET /api/v1/pilots/earnings?period=today
Response: { earnings, rides, hours }
```
**Backend Status:** ⚠️ NEEDS ENHANCEMENT (add period filter, hours tracking)

5. **Get Active Vehicle:**
```
GET /api/v1/pilots/vehicles/active
Response: { vehicle: { type, registrationNo, ... } }
```
**Backend Status:** ❌ MISSING

---

### 2.4 Job Management Module

#### Screen: Incoming Job Popup
| Element | Description |
|---------|-------------|
| Fare | Large ₹ amount |
| Timer | 30 second countdown (circular) |
| Pickup | Distance, time, address |
| Drop | Distance, time, address |
| Package Info | Type, weight (if available) |
| Accept Button | Green, prominent |
| Decline Button | Red, secondary |

**APIs Required:**

1. **Get Pending Offers (polling/socket):**
```
GET /api/v1/matching/offers/pending
Response: { offers: [{ id, booking, expiresAt }] }
```
**Backend Status:** ✅ EXISTS

2. **Respond to Offer:**
```
POST /api/v1/matching/offers/{offerId}/respond
Body: { accept: true/false }
```
**Backend Status:** ✅ EXISTS

---

#### Screen: Active Job
| Section | Elements |
|---------|----------|
| Map | Full screen, route, markers |
| Navigation | Turn-by-turn overlay |
| Job Card | Order ID, status, customer contact |
| Status Actions | Context-based buttons |

**Status Flow & Actions:**

| Status | Action Button | Next Status |
|--------|---------------|-------------|
| ACCEPTED | "Navigate to Pickup" | - |
| ACCEPTED | "Arrived at Pickup" | ARRIVED_PICKUP |
| ARRIVED_PICKUP | "Collect Package" | PICKED_UP |
| PICKED_UP | "Start Delivery" | IN_TRANSIT |
| IN_TRANSIT | "Arrived at Drop" | ARRIVED_DROP |
| ARRIVED_DROP | "Complete Delivery" | DELIVERED |

**APIs Required:**

1. **Get Booking Details:**
```
GET /api/v1/bookings/{id}
```
**Backend Status:** ✅ EXISTS

2. **Update Booking Status:**
```
PATCH /api/v1/bookings/{id}/status
Body: { status: "PICKED_UP", lat: 23.02, lng: 72.57 }
```
**Backend Status:** ✅ EXISTS

3. **Upload Delivery Photo:**
```
POST /api/v1/upload/delivery-photo/{bookingId}
Content-Type: multipart/form-data
Field: photo
```
**Backend Status:** ✅ EXISTS

4. **Call Customer (opens dialer):**
- Get phone from booking.user.phone
**Backend Status:** ✅ (data available in booking)

---

### 2.5 Earnings & Wallet Module

#### Screen: Earnings Dashboard
| Section | Elements |
|---------|----------|
| Period Selector | Today, Week, Month, Custom |
| Summary | Total earnings, rides, hours, avg/ride |
| Chart | Bar chart of daily earnings |
| Ride List | Detailed breakdown per ride |

**APIs Required:**

1. **Get Earnings Summary:**
```
GET /api/v1/pilots/earnings?period=week&page=1&limit=20
Response: { 
  summary: { total, rides, hours, average },
  earnings: [...],
  meta: { page, limit, total }
}
```
**Backend Status:** ⚠️ NEEDS ENHANCEMENT
- Current: Returns list only
- Needed: Summary stats, period filter, hours tracking

---

#### Screen: Wallet
| Section | Elements |
|---------|----------|
| Balance | Large ₹ display |
| Actions | Add Money, Withdraw |
| History | Recent transactions |

**APIs Required:**

1. **Get Pilot Wallet Balance:**
```
GET /api/v1/pilots/wallet/balance
Response: { balance: 1500.00 }
```
**Backend Status:** ❌ MISSING (exists for users, not pilots)

2. **Get Pilot Transactions:**
```
GET /api/v1/pilots/wallet/transactions?page=1&limit=20
```
**Backend Status:** ❌ MISSING

3. **Withdraw Money:**
```
POST /api/v1/pilots/wallet/withdraw
Body: { amount: 1000, bankAccountId: "xxx" }
```
**Backend Status:** ❌ MISSING

---

### 2.6 Profile Module

#### Screen: My Vehicles
| Section | Elements |
|---------|----------|
| Vehicle List | Cards with details |
| Active Badge | On current vehicle |
| Add Vehicle | Button to add new |

**APIs Required:**

1. **List Pilot Vehicles:**
```
GET /api/v1/pilots/vehicles
Response: { vehicles: [...] }
```
**Backend Status:** ❌ MISSING

2. **Set Active Vehicle:**
```
PATCH /api/v1/pilots/vehicles/{id}/activate
```
**Backend Status:** ❌ MISSING

3. **Add Vehicle:**
```
POST /api/v1/pilots/vehicles
Body: { vehicleTypeId, registrationNo, model, color }
```
**Backend Status:** ❌ MISSING

---

#### Screen: My Documents
| Section | Elements |
|---------|----------|
| Document List | Type, status, expiry |
| Upload/Update | Per document |
| Status Badge | Verified/Pending/Rejected |

**APIs Required:**

1. **List Pilot Documents:**
```
GET /api/v1/pilots/documents
Response: { documents: [{ type, url, status, expiresAt }] }
```
**Backend Status:** ❌ MISSING

2. **Upload/Update Document:**
```
POST /api/v1/upload/pilot/documents
```
**Backend Status:** ✅ EXISTS

---

## 3. Backend API Mapping

### Existing APIs (Ready to Use)

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/auth/pilot/send-otp` | POST | Send OTP |
| `/auth/pilot/verify-otp` | POST | Verify OTP |
| `/pilots/profile` | GET | Get profile |
| `/pilots/profile` | PATCH | Update profile |
| `/pilots/status` | PATCH | Toggle online |
| `/pilots/location` | PATCH | Update location |
| `/pilots/earnings` | GET | Get earnings |
| `/pilots/bookings` | GET | Get bookings |
| `/bookings/{id}` | GET | Booking details |
| `/bookings/{id}/accept` | POST | Accept booking |
| `/bookings/{id}/status` | PATCH | Update status |
| `/matching/offers/pending` | GET | Pending offers |
| `/matching/offers/{id}/respond` | POST | Accept/decline |
| `/matching/jobs/available` | GET | Available jobs |
| `/upload/pilot/documents` | POST | Upload docs |
| `/upload/pilot/avatar` | POST | Upload avatar |
| `/upload/delivery-photo/{id}` | POST | Delivery photo |

---

## 4. Gap Analysis

### 🔴 Missing APIs (Must Build)

| # | Endpoint | Method | Priority | Description |
|---|----------|--------|----------|-------------|
| 1 | `/pilots/vehicles` | GET | HIGH | List pilot's vehicles |
| 2 | `/pilots/vehicles` | POST | HIGH | Add new vehicle |
| 3 | `/pilots/vehicles/{id}` | PATCH | MEDIUM | Update vehicle |
| 4 | `/pilots/vehicles/{id}/activate` | PATCH | HIGH | Set active vehicle |
| 5 | `/pilots/bank-account` | GET | HIGH | Get bank details |
| 6 | `/pilots/bank-account` | POST | HIGH | Add bank account |
| 7 | `/pilots/bank-account` | PATCH | MEDIUM | Update bank account |
| 8 | `/pilots/documents` | GET | HIGH | List documents |
| 9 | `/pilots/wallet/balance` | GET | HIGH | Get wallet balance |
| 10 | `/pilots/wallet/transactions` | GET | HIGH | Transaction history |
| 11 | `/pilots/wallet/withdraw` | POST | HIGH | Withdraw to bank |
| 12 | `/pilots/stats` | GET | MEDIUM | Dashboard stats (today/week) |

### 🟡 APIs Needing Enhancement

| # | Endpoint | Current | Needed |
|---|----------|---------|--------|
| 1 | `/pilots/profile` | Basic fields | Add address, city, state, pincode fields |
| 2 | `/pilots/earnings` | List only | Add summary stats, period filter |
| 3 | `/pilots/register` | Basic | Multi-step with vehicle + bank |

### 🟢 Socket Events (Verify Exist)

| Event | Direction | Description |
|-------|-----------|-------------|
| `pilot:online` | Client→Server | Pilot goes online |
| `pilot:offline` | Client→Server | Pilot goes offline |
| `pilot:location` | Client→Server | Location update |
| `job:new` | Server→Client | New job offer |
| `job:cancelled` | Server→Client | Job cancelled |
| `booking:status` | Server→Client | Status changed |

---

## 5. Database Schema

### Current Tables (Relevant)
- ✅ `pilots` - Pilot profile
- ✅ `vehicles` - Pilot vehicles
- ✅ `documents` - Uploaded documents
- ✅ `bank_accounts` - Bank details
- ✅ `bookings` - Orders/Jobs
- ✅ `earnings` - Earnings records
- ⚠️ `pilot_wallet` - MISSING (needs separate or use totalEarnings)

### Schema Updates Needed

```sql
-- Add to pilots table (if not exists)
ALTER TABLE pilots ADD COLUMN address TEXT;
ALTER TABLE pilots ADD COLUMN city VARCHAR(100);
ALTER TABLE pilots ADD COLUMN state VARCHAR(100);
ALTER TABLE pilots ADD COLUMN pincode VARCHAR(6);

-- Add pilot wallet table (optional, or use existing pattern)
CREATE TABLE pilot_wallets (
  id VARCHAR(255) PRIMARY KEY,
  pilot_id VARCHAR(255) UNIQUE REFERENCES pilots(id),
  balance DECIMAL(10,2) DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE pilot_wallet_transactions (
  id VARCHAR(255) PRIMARY KEY,
  pilot_id VARCHAR(255) REFERENCES pilots(id),
  type ENUM('CREDIT', 'DEBIT'),
  amount DECIMAL(10,2),
  balance_before DECIMAL(10,2),
  balance_after DECIMAL(10,2),
  description VARCHAR(255),
  reference_id VARCHAR(255),
  reference_type VARCHAR(50),
  status ENUM('PENDING', 'COMPLETED', 'FAILED'),
  created_at TIMESTAMP DEFAULT NOW()
);
```

---

## 6. Implementation Checklist

### Backend Work (Before App Development)

- [ ] Add address fields to Pilot model
- [ ] Create `/pilots/vehicles` CRUD endpoints
- [ ] Create `/pilots/bank-account` CRUD endpoints
- [ ] Create `/pilots/documents` GET endpoint
- [ ] Create `/pilots/wallet/*` endpoints
- [ ] Create `/pilots/stats` endpoint
- [ ] Enhance `/pilots/earnings` with summary
- [ ] Verify socket events for job assignment

### App Development Phases

#### Phase 1: Auth & Registration
- [ ] Splash screen
- [ ] Phone login
- [ ] OTP verification
- [ ] Registration Step 1 (Personal)
- [ ] Registration Step 2 (Vehicle)
- [ ] Registration Step 3 (Documents)
- [ ] Registration Step 4 (Bank)
- [ ] Verification pending screen

#### Phase 2: Dashboard
- [ ] Home dashboard UI
- [ ] Online/Offline toggle
- [ ] Location tracking service
- [ ] Stats display
- [ ] Active vehicle display

#### Phase 3: Jobs
- [ ] Job offer popup
- [ ] Accept/Decline flow
- [ ] Active job screen
- [ ] Navigation integration
- [ ] Status updates
- [ ] Delivery photo capture

#### Phase 4: Earnings & Wallet
- [ ] Earnings dashboard
- [ ] Wallet screen
- [ ] Withdrawal flow
- [ ] Transaction history

#### Phase 5: Profile
- [ ] Profile view/edit
- [ ] Vehicle management
- [ ] Document management
- [ ] Bank details
- [ ] Settings

---

## 7. Priority Matrix

| Task | Impact | Effort | Priority |
|------|--------|--------|----------|
| Vehicle CRUD APIs | High | Low | 🔴 P0 |
| Bank Account APIs | High | Low | 🔴 P0 |
| Pilot Wallet APIs | High | Medium | 🔴 P0 |
| Documents GET API | Medium | Low | 🟡 P1 |
| Stats API | Medium | Low | 🟡 P1 |
| Earnings Enhancement | Low | Low | 🟢 P2 |
| Address Fields | Low | Low | 🟢 P2 |

---

**Document Version:** 1.0  
**Last Updated:** February 3, 2026  
**Author:** Buddy (AI Assistant)
