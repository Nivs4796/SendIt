# Pilot App Implementation Roadmap

> Based on `pilot-app-plan.md` (926 lines of specs)

## Overview

| Attribute | Value |
|-----------|-------|
| **App Name** | SendIt Pilot - Deliver & Earn |
| **Platform** | Flutter (iOS & Android) |
| **State Mgmt** | GetX (matching user_app) |
| **Est. Duration** | 6-8 weeks |

---

## Phase 1: Foundation (Week 1)

### 1.1 Project Setup
- [ ] Create `pilot_app/` Flutter project
- [ ] Mirror `user_app` folder structure (core/, models/, modules/, etc.)
- [ ] Configure GetX, Dio, shared packages
- [ ] Setup app theming (dark mode primary, green accent)
- [ ] Configure environment configs (dev/staging/prod)

### 1.2 Shared Code Extraction
- [ ] Extract common code from `user_app` to `shared/` package:
  - API client & interceptors
  - Auth service & token management
  - Theme & design tokens
  - Common widgets (buttons, inputs, cards)
  - Models (User, Address, etc.)

### 1.3 Navigation & Routing
- [ ] Setup GetX routing
- [ ] Define route constants
- [ ] Implement route guards (auth, verification status)

**Deliverable:** Empty app shell with navigation skeleton

---

## Phase 2: Authentication & Registration (Week 2)

### 2.1 Auth Flow (Reuse from user_app)
- [ ] Phone input screen
- [ ] OTP verification screen
- [ ] Auth controller & repository

### 2.2 Pilot Registration (NEW)
- [ ] **Step 1:** Personal details form
  - Name, email, DOB, address, profile photo
  - Age validation (16+ for EV Cycle, 18+ for motorized)
- [ ] **Step 2:** Vehicle details form
  - Vehicle type selector (Cycle/EV Cycle/2W/3W/Truck)
  - Fuel type conditional (CNG/Petrol/Diesel/EV)
  - Vehicle number, model
- [ ] **Step 3:** Document upload
  - Dynamic docs based on age & vehicle type
  - Camera/gallery picker
  - Upload progress & status
- [ ] **Step 4:** Bank details form
  - Account info + cancelled cheque upload

### 2.3 Verification Pending Screen
- [ ] Status display with polling
- [ ] Push notification on approval/rejection

**API Endpoints:**
```
POST /api/v1/pilots/register
GET  /api/v1/pilots/verification-status
```

**Deliverable:** Complete onboarding flow

---

## Phase 3: Dashboard & Online/Offline (Week 3)

### 3.1 Home Dashboard
- [ ] Greeting header with pilot name
- [ ] **Online/Offline toggle** (prominent switch)
- [ ] Stats cards (Today/Week earnings, hours, rides)
- [ ] Active vehicle display with battery % (EV)
- [ ] Quick action buttons (Earnings, Vehicles, Wallet, Rewards)
- [ ] "Missed orders" value when offline

### 3.2 Location Service
- [ ] Geolocator integration
- [ ] Background location tracking (when online)
- [ ] Location permission handling
- [ ] Battery-efficient tracking modes

### 3.3 WebSocket Connection
- [ ] Socket.IO client setup
- [ ] Connect when online, disconnect when offline
- [ ] Emit location updates
- [ ] Listen for job assignments

**API/WebSocket:**
```
PUT  /api/v1/pilots/online-status
WS   pilot:location (emit)
WS   job:new (listen)
```

**Deliverable:** Functional dashboard with online/offline state

---

## Phase 4: Job Management (Week 4)

### 4.1 Incoming Job Popup
- [ ] Modal overlay design
- [ ] Job details (fare, pickup/drop, distance, ETA)
- [ ] 30-second countdown timer
- [ ] Accept/Decline buttons
- [ ] Auto-decline on timeout
- [ ] Sound/vibration alert

### 4.2 Active Job Screen
- [ ] Full-screen map with route
- [ ] Bottom sheet with job info
- [ ] Status progression:
  ```
  Assigned → Navigating → Arrived at Pickup → 
  Package Collected → In Transit → Arrived at Drop → Delivered
  ```
- [ ] Status update buttons
- [ ] Customer contact (call/chat)
- [ ] Navigate button (opens Google Maps)

### 4.3 Photo Capture
- [ ] Camera integration for:
  - Package pickup (optional)
  - Delivery proof (required)
- [ ] Preview & retake
- [ ] Upload to backend

### 4.4 COD Collection
- [ ] Amount display
- [ ] "Collected Cash" confirmation

**API Endpoints:**
```
PUT  /api/v1/pilots/jobs/:id/accept
PUT  /api/v1/pilots/jobs/:id/decline
PUT  /api/v1/pilots/jobs/:id/status
POST /api/v1/pilots/jobs/:id/photos
```

**Deliverable:** Complete single-job flow

---

## Phase 5: Earnings & Wallet (Week 5)

### 5.1 Wallet Screen
- [ ] Balance display
- [ ] Quick actions (Add/Withdraw/Bank/Rewards)
- [ ] Transaction history list
- [ ] Transaction detail view

### 5.2 Add Money
- [ ] Amount presets + custom input
- [ ] Payment gateway integration (Razorpay)
- [ ] Success/failure handling

### 5.3 Withdraw Money
- [ ] Amount input with validation
- [ ] Bank account selector
- [ ] Withdrawal request flow
- [ ] Processing status tracking

### 5.4 Earnings Dashboard
- [ ] Period selector (Today/Week/Month/Custom)
- [ ] Summary cards
- [ ] Earnings chart (fl_chart)
- [ ] Ride-wise breakdown list
- [ ] Export report (PDF)

**API Endpoints:**
```
GET  /api/v1/pilots/wallet
GET  /api/v1/pilots/wallet/transactions
POST /api/v1/pilots/wallet/add-money
POST /api/v1/pilots/wallet/withdraw
GET  /api/v1/pilots/earnings
```

**Deliverable:** Complete financial management

---

## Phase 6: Vehicles & Profile (Week 6)

### 6.1 My Vehicles
- [ ] Vehicle list with active indicator
- [ ] Vehicle card (type, number, status, EV badge)
- [ ] Switch active vehicle
- [ ] Add new vehicle flow
- [ ] Document status per vehicle

### 6.2 Profile Management
- [ ] View/edit personal info
- [ ] Profile photo update
- [ ] Bank details management
- [ ] Document renewal alerts

### 6.3 Settings
- [ ] Notification preferences
- [ ] Language selection
- [ ] Help & Support
- [ ] Terms & Privacy
- [ ] Logout

**API Endpoints:**
```
GET  /api/v1/pilots/vehicles
POST /api/v1/pilots/vehicles
PUT  /api/v1/pilots/vehicles/:id/activate
GET  /api/v1/pilots/profile
PUT  /api/v1/pilots/profile
```

**Deliverable:** Complete profile & vehicle management

---

## Phase 7: Advanced Features (Week 7)

### 7.1 Multiple Jobs
- [ ] Accept multiple jobs simultaneously
- [ ] Jobs list view
- [ ] Route optimization algorithm
- [ ] Combined route display

### 7.2 Rewards & Referrals
- [ ] Referral code display & share
- [ ] Referral progress tracking
- [ ] Reward points display
- [ ] Redemption flow

### 7.3 Notifications
- [ ] Firebase Cloud Messaging setup
- [ ] Local notifications
- [ ] Notification categories (Job/Earnings/Documents/System)
- [ ] Notification center screen

### 7.4 Push Notification Handlers
```
job_request      → Show job popup
job_cancelled    → Update active jobs
payment_received → Show toast, refresh wallet
document_expiry  → Show alert
```

**Deliverable:** Production-ready feature set

---

## Phase 8: Polish & Launch (Week 8)

### 8.1 Performance
- [ ] Battery optimization for location tracking
- [ ] Efficient WebSocket reconnection
- [ ] Image compression for uploads
- [ ] Lazy loading for lists

### 8.2 Offline Support
- [ ] Cache pilot profile
- [ ] Cache vehicle details
- [ ] Queue status updates when offline
- [ ] Sync on reconnection

### 8.3 Testing
- [ ] Unit tests for controllers
- [ ] Widget tests for key screens
- [ ] Integration tests for critical flows
- [ ] Real device testing (Android + iOS)

### 8.4 Launch Prep
- [ ] App Store assets (screenshots, description)
- [ ] Play Store listing
- [ ] Beta testing with real pilots
- [ ] Analytics integration (Firebase/Mixpanel)

**Deliverable:** App ready for store submission

---

## Backend API Requirements

### New Endpoints Needed

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/pilots/register` | POST | Full registration with docs |
| `/pilots/verification-status` | GET | Check approval status |
| `/pilots/online-status` | PUT | Toggle online/offline |
| `/pilots/jobs/:id/accept` | PUT | Accept job |
| `/pilots/jobs/:id/decline` | PUT | Decline job |
| `/pilots/jobs/:id/status` | PUT | Update job status |
| `/pilots/jobs/:id/photos` | POST | Upload delivery photo |
| `/pilots/vehicles` | GET/POST | List/add vehicles |
| `/pilots/vehicles/:id/activate` | PUT | Set active vehicle |
| `/pilots/wallet` | GET | Wallet balance |
| `/pilots/wallet/transactions` | GET | Transaction history |
| `/pilots/wallet/withdraw` | POST | Request withdrawal |
| `/pilots/earnings` | GET | Earnings summary |
| `/pilots/referrals` | GET/POST | Referral management |

### WebSocket Events

| Event | Direction | Purpose |
|-------|-----------|---------|
| `pilot:location` | Emit | Send location updates |
| `pilot:online` | Emit | Notify online status |
| `job:new` | Listen | Receive job requests |
| `job:cancelled` | Listen | Job cancelled by user |
| `job:update` | Listen | Job status changed |

---

## Dependencies

```yaml
# pilot_app/pubspec.yaml (key additions)
dependencies:
  # Maps & Location
  google_maps_flutter: ^2.5.0
  geolocator: ^10.1.0
  background_location: ^0.0.1
  
  # Real-time
  socket_io_client: ^2.0.3
  
  # Camera & Files
  image_picker: ^1.0.4
  
  # Charts
  fl_chart: ^0.65.0
  
  # Background
  workmanager: ^0.5.2
  
  # Notifications
  firebase_messaging: ^14.7.0
  flutter_local_notifications: ^16.1.0
```

---

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| Background location battery drain | Adaptive tracking frequency, significant changes when idle |
| WebSocket disconnections | Auto-reconnect with exponential backoff |
| Photo upload failures | Retry queue, offline storage |
| Complex registration flow | Save progress, allow resume |

---

## Success Metrics

- [ ] Registration completion rate > 80%
- [ ] Job acceptance rate > 70%
- [ ] App crash rate < 0.5%
- [ ] Location accuracy within 50m
- [ ] Battery usage < 5%/hour when online

---

**Document Version:** 1.0  
**Created:** 2026-02-03  
**Based on:** pilot-app-plan.md
