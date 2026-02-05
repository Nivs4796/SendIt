# SendIt Pilot App - Production Ready Implementation Plan

## Current State Analysis

### ✅ Working (Connected to Backend)
1. **Auth Flow** - Login, OTP verification, logout
2. **Home Dashboard** - Pilot profile, online status toggle
3. **Jobs** - Active job view, job offers, status updates
4. **Wallet** - Balance, transactions, withdrawal (API calls ready)
5. **Vehicles** - List vehicles, vehicle types (API calls ready)
6. **Earnings** - Today/week earnings display (API calls ready)

### 🔄 Partially Done (Has Mock Data)
1. **Notifications** - UI ready, using mock data
2. **Rewards** - UI ready, using mock data
3. **Profile** - UI ready, some API calls

### ❌ Missing Screens (Coming Soon)
1. **Documents** - View/upload documents
2. **Bank Details** - Manage bank accounts
3. **Job History** - Past deliveries list
4. **Help & Support** - FAQs, contact support
5. **Add/Edit Vehicle** - Add new vehicle form
6. **Withdrawal Screen** - Proper withdrawal flow

---

## Implementation Tasks

### Phase 1: Missing Core Screens

#### 1.1 Documents Module
**Files to create:**
- `lib/app/modules/documents/bindings/documents_binding.dart`
- `lib/app/modules/documents/controllers/documents_controller.dart`
- `lib/app/modules/documents/views/documents_view.dart`

**Features:**
- List all documents (DL, RC, Insurance, Aadhaar, PAN, etc.)
- Show verification status for each
- Upload/re-upload functionality
- Document preview

**API Endpoints needed:**
- GET `/pilots/documents` - List documents
- POST `/pilots/documents` - Upload document
- DELETE `/pilots/documents/:id` - Remove document

#### 1.2 Bank Details Module
**Files to create:**
- `lib/app/modules/bank/bindings/bank_binding.dart`
- `lib/app/modules/bank/controllers/bank_controller.dart`
- `lib/app/modules/bank/views/bank_details_view.dart`
- `lib/app/modules/bank/views/add_bank_view.dart`

**Features:**
- List bank accounts
- Add new bank account (IFSC lookup)
- Set primary account
- Delete account

**API Endpoints needed:**
- GET `/pilots/bank-accounts` - List accounts
- POST `/pilots/bank-accounts` - Add account
- PATCH `/pilots/bank-accounts/:id` - Update/set primary
- DELETE `/pilots/bank-accounts/:id` - Remove account

#### 1.3 Job History Module
**Files to create:**
- `lib/app/modules/history/bindings/history_binding.dart`
- `lib/app/modules/history/controllers/history_controller.dart`
- `lib/app/modules/history/views/history_view.dart`
- `lib/app/modules/history/views/job_detail_view.dart`

**Features:**
- List completed/cancelled jobs
- Filter by date range
- Job details with map route
- Earnings breakdown per job

**API Endpoints:** Already exists - `/pilots/bookings?status=completed`

#### 1.4 Help & Support Module
**Files to create:**
- `lib/app/modules/support/bindings/support_binding.dart`
- `lib/app/modules/support/controllers/support_controller.dart`
- `lib/app/modules/support/views/help_view.dart`
- `lib/app/modules/support/views/faq_view.dart`
- `lib/app/modules/support/views/contact_support_view.dart`

**Features:**
- FAQ categories
- Search FAQs
- Contact options (call, email, chat)
- Raise ticket

**API Endpoints needed:**
- GET `/support/faqs` - Get FAQs
- POST `/support/tickets` - Create ticket

---

### Phase 2: Connect Mock Data to Backend

#### 2.1 Notifications - Real API Integration
**Changes:**
- Create notifications repository
- Add API calls for notifications
- Implement push notification handling

**API Endpoints needed:**
- GET `/pilots/notifications` - List notifications
- PATCH `/pilots/notifications/:id/read` - Mark as read
- POST `/pilots/notification-settings` - Update settings

#### 2.2 Rewards - Real API Integration
**Changes:**
- Create rewards repository
- Connect to backend for:
  - Referral code generation
  - Referral tracking
  - Points & achievements
  - Reward claiming

**API Endpoints needed:**
- GET `/pilots/referral` - Get referral info
- GET `/pilots/rewards` - Get available rewards
- POST `/pilots/rewards/:id/claim` - Claim reward
- GET `/pilots/achievements` - Get achievements

---

### Phase 3: Enhanced Features

#### 3.1 Add/Edit Vehicle Flow
**Files to create:**
- `lib/app/modules/vehicles/views/add_vehicle_view.dart`
- `lib/app/modules/vehicles/views/edit_vehicle_view.dart`

**Features:**
- Select vehicle type
- Enter vehicle details (number, model, etc.)
- Upload RC document
- Set as active vehicle

#### 3.2 Withdrawal Flow Enhancement
**Files to create:**
- `lib/app/modules/wallet/views/withdraw_view.dart`

**Features:**
- Select bank account
- Enter amount
- Show fees (if any)
- Confirm withdrawal
- Show processing status

#### 3.3 Settings Screen
**Files to create:**
- `lib/app/modules/settings/bindings/settings_binding.dart`
- `lib/app/modules/settings/controllers/settings_controller.dart`
- `lib/app/modules/settings/views/settings_view.dart`

**Features:**
- Language selection
- Dark mode toggle
- Notification preferences
- Privacy settings

---

### Phase 4: Polish & Production

#### 4.1 Error Handling
- Global error handler
- Network error UI
- Retry mechanisms
- Offline mode support

#### 4.2 Loading States
- Skeleton loaders
- Pull-to-refresh everywhere
- Proper loading indicators

#### 4.3 Analytics & Logging
- Event tracking setup
- Crash reporting
- Performance monitoring

---

## API Constants to Add

```dart
// Documents
static const String pilotDocuments = '/pilots/documents';

// Bank Accounts  
static const String bankAccounts = '/pilots/bank-accounts';
static String bankAccount(String id) => '/pilots/bank-accounts/$id';

// Notifications
static const String notifications = '/pilots/notifications';
static String notificationRead(String id) => '/pilots/notifications/$id/read';
static const String notificationSettings = '/pilots/notification-settings';

// Rewards & Referrals
static const String referral = '/pilots/referral';
static const String rewards = '/pilots/rewards';
static String claimReward(String id) => '/pilots/rewards/$id/claim';
static const String achievements = '/pilots/achievements';

// Support
static const String faqs = '/support/faqs';
static const String supportTickets = '/support/tickets';
```

---

## Route Updates Needed

Add to `app_pages.dart`:
- `/profile/documents` → DocumentsView
- `/profile/bank` → BankDetailsView
- `/bank/add` → AddBankView
- `/jobs/history` → HistoryView
- `/job/:id` → JobDetailView
- `/help` → HelpView
- `/support/faqs` → FAQView
- `/support/contact` → ContactSupportView
- `/vehicles/add` → AddVehicleView
- `/vehicles/:id/edit` → EditVehicleView
- `/wallet/withdraw` → WithdrawView
- `/settings` → SettingsView

---

## Priority Order

1. **Documents** (Critical for compliance)
2. **Bank Details** (Critical for withdrawals)
3. **Job History** (Core feature)
4. **Withdrawal Flow** (Core feature)
5. **Notifications API** (Replace mock)
6. **Rewards API** (Replace mock)
7. **Help & Support** (Important)
8. **Settings** (Nice to have)
9. **Add Vehicle** (Edge case)

---

## Estimated Time
- Phase 1 (Core screens): 3-4 hours
- Phase 2 (API integration): 2-3 hours
- Phase 3 (Enhanced features): 2-3 hours
- Phase 4 (Polish): 1-2 hours

**Total: ~10-12 hours of work**
