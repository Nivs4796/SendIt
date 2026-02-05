# SendIt Production Code Completion Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Complete all code implementation with static/placeholder configurations, fix bugs, and make architecture ready for production credentials.

**Architecture:** Backend (Node.js/Express/Prisma) + Flutter Apps (Pilot & User with GetX) + PostgreSQL. All 3rd-party configs use environment variables with sensible static fallbacks for development.

**Tech Stack:** TypeScript, Flutter/Dart, Prisma ORM, PostgreSQL, Socket.io

**Status:** Code completion phase - NO production credentials yet. Use static placeholders that can be swapped later.

---

## Phase 1: Backend Code Fixes (Critical Bugs)

### Task 1.1: Fix CORS Configuration

**Files:**
- Modify: `backend/src/app.ts:27-39`

**Step 1: Update CORS to be environment-aware**

```typescript
// Replace lines 27-39 with:
const isProduction = config.nodeEnv === 'production';

app.use(cors({
  origin: (origin, callback) => {
    // Allow requests with no origin (mobile apps, Postman, etc.)
    if (!origin) return callback(null, true)

    // In development, allow all origins
    if (!isProduction) return callback(null, true)

    // In production, check against allowed origins
    if (allowedOrigins.includes(origin)) {
      callback(null, true)
    } else {
      callback(new Error('Not allowed by CORS'))
    }
  },
  credentials: true,
}))
```

**Step 2: Test the change**

```bash
cd backend && npm run dev
# Open another terminal
curl -H "Origin: http://evil.com" http://localhost:5000/api/v1/health -v
# Should work in development
```

**Step 3: Commit**

```bash
git add backend/src/app.ts
git commit -m "fix(backend): make CORS environment-aware for production"
```

---

### Task 1.2: Add Production Safety Guard for OTP (Keep Dev Bypass)

**Files:**
- Modify: `backend/src/services/auth.service.ts`

**Note:** Keep static OTP `111111` for development testing. Only add production safety guard.

**Step 1: Ensure development OTP bypass has clear documentation**

The existing code should have clear comments:

```typescript
// ============================================
// DEVELOPMENT OTP BYPASS
// Static OTP: 111111 - ONLY works when NODE_ENV=development
// In production, actual SMS OTP is required
// ============================================
const isDevOTP = config.nodeEnv === 'development' && otp === '111111'
```

**Step 2: Add production safety check (optional - for when SMS is configured)**

```typescript
// When ready for production, uncomment this guard:
// if (config.nodeEnv === 'production' && !config.smsApiKey) {
//   throw new AppError('SMS service not configured for production', 500)
// }
```

**Step 3: Commit (if changes made)**

```bash
git add backend/src/services/auth.service.ts
git commit -m "docs(auth): clarify development OTP bypass documentation"
```

---

### Task 1.3: Add Rate Limiter to Payment Routes

**Files:**
- Modify: `backend/src/routes/payment.routes.ts`
- Modify: `backend/src/middleware/rateLimiter.ts`

**Step 1: Add payment-specific rate limiter**

In `backend/src/middleware/rateLimiter.ts`, add:

```typescript
// Payment verification - strict limit (5 attempts per 15 minutes)
export const paymentVerifyLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5,
  message: {
    success: false,
    message: 'Too many payment verification attempts. Please try again later.',
  },
  standardHeaders: true,
  legacyHeaders: false,
})

// Payment order creation - moderate limit (20 per hour)
export const paymentCreateLimiter = rateLimit({
  windowMs: 60 * 60 * 1000,
  max: 20,
  message: {
    success: false,
    message: 'Too many payment requests. Please try again later.',
  },
  standardHeaders: true,
  legacyHeaders: false,
})
```

**Step 2: Apply to payment routes**

In `backend/src/routes/payment.routes.ts`:

```typescript
import { paymentVerifyLimiter, paymentCreateLimiter } from '../middleware/rateLimiter'

// Add to verify route
router.post(
  '/verify',
  authenticate,
  authorize('user'),
  paymentVerifyLimiter,  // ADD THIS
  validate(verifyPaymentSchema),
  paymentController.verifyPayment
)

// Add to create-order route
router.post(
  '/create-order',
  authenticate,
  authorize('user'),
  paymentCreateLimiter,  // ADD THIS
  validate(createOrderSchema),
  paymentController.createOrder
)
```

**Step 3: Commit**

```bash
git add backend/src/middleware/rateLimiter.ts backend/src/routes/payment.routes.ts
git commit -m "feat(security): add rate limiting to payment endpoints"
```

---

### Task 1.4: Fix File Upload Path Validation

**Files:**
- Modify: `backend/src/controllers/upload.controller.ts`

**Step 1: Add path validation helper**

```typescript
// Add at the top of the file
const ALLOWED_UPLOAD_FOLDERS = ['documents', 'avatars', 'delivery-photos', 'vehicles', 'pilots', 'users']

const isValidFilename = (filename: string): boolean => {
  // Only allow alphanumeric, dash, underscore, and dot
  // Filename must be at least 10 chars (includes extension)
  return /^[a-zA-Z0-9._-]{10,}$/.test(filename)
}

const isValidFolder = (folder: string): boolean => {
  return ALLOWED_UPLOAD_FOLDERS.includes(folder)
}
```

**Step 2: Update deleteUploadedFile method**

```typescript
async deleteUploadedFile(req: Request, res: Response, next: NextFunction) {
  try {
    const { folder, filename } = req.params

    // Validate folder
    if (!isValidFolder(folder)) {
      throw new ValidationError('Invalid upload folder')
    }

    // Validate filename (prevent path traversal)
    if (!isValidFilename(filename)) {
      throw new ValidationError('Invalid filename format')
    }

    // Ensure no path traversal attempts
    if (filename.includes('..') || filename.includes('/') || filename.includes('\\')) {
      throw new ValidationError('Invalid filename')
    }

    const filePath = path.join(process.cwd(), 'uploads', folder, filename)

    // Verify the resolved path is still within uploads directory
    const uploadsDir = path.join(process.cwd(), 'uploads')
    if (!filePath.startsWith(uploadsDir)) {
      throw new ValidationError('Invalid file path')
    }

    // ... rest of delete logic
  } catch (error) {
    next(error)
  }
}
```

**Step 3: Commit**

```bash
git add backend/src/controllers/upload.controller.ts
git commit -m "fix(security): add path validation to prevent traversal attacks"
```

---

## Phase 2: Database Schema Fixes

### Task 2.1: Convert Float to Decimal for Monetary Fields

**Files:**
- Modify: `backend/prisma/schema.prisma`

**Step 1: Update User model**

```prisma
model User {
  // ... other fields
  walletBalance Decimal   @default(0) @db.Decimal(10, 2)
  // ... rest
}
```

**Step 2: Update Pilot model**

```prisma
model Pilot {
  // ... other fields
  totalEarnings   Decimal     @default(0) @db.Decimal(10, 2)
  // ... rest
}
```

**Step 3: Update Booking model**

```prisma
model Booking {
  // ... other fields
  baseFare          Decimal   @db.Decimal(10, 2)
  distanceFare      Decimal   @db.Decimal(10, 2)
  taxes             Decimal   @default(0) @db.Decimal(10, 2)
  discount          Decimal   @default(0) @db.Decimal(10, 2)
  totalAmount       Decimal   @db.Decimal(10, 2)
  // ... rest
}
```

**Step 4: Update Payment model**

```prisma
model Payment {
  // ... other fields
  amount          Decimal   @db.Decimal(10, 2)
  // ... rest
}
```

**Step 5: Update Earning model**

```prisma
model Earning {
  // ... other fields
  amount      Decimal     @db.Decimal(10, 2)
  // ... rest
}
```

**Step 6: Update VehicleType model**

```prisma
model VehicleType {
  // ... other fields
  basePrice       Decimal   @db.Decimal(10, 2)
  pricePerKm      Decimal   @db.Decimal(10, 2)
  // ... rest
}
```

**Step 7: Update WalletTransaction model**

```prisma
model WalletTransaction {
  // ... other fields
  amount        Decimal           @db.Decimal(10, 2)
  balanceBefore Decimal           @db.Decimal(10, 2)
  balanceAfter  Decimal           @db.Decimal(10, 2)
  // ... rest
}
```

**Step 8: Update Coupon model**

```prisma
model Coupon {
  // ... other fields
  discountValue   Decimal   @db.Decimal(10, 2)
  minOrderAmount  Decimal?  @db.Decimal(10, 2)
  maxDiscount     Decimal?  @db.Decimal(10, 2)
  // ... rest
}
```

**Step 9: Run migration**

```bash
cd backend
npx prisma migrate dev --name convert_float_to_decimal
```

**Step 10: Commit**

```bash
git add backend/prisma/schema.prisma backend/prisma/migrations/
git commit -m "fix(db): convert Float to Decimal for monetary precision"
```

---

### Task 2.2: Add Missing Database Indexes

**Files:**
- Modify: `backend/prisma/schema.prisma`

**Step 1: Add indexes to User model**

```prisma
model User {
  // ... existing fields and relations

  @@index([isActive])
  @@index([createdAt])
  @@map("users")
}
```

**Step 2: Add indexes to Pilot model**

```prisma
model Pilot {
  // ... existing fields and relations

  @@index([status])
  @@index([isActive])
  @@index([isOnline])
  @@index([createdAt])
  @@map("pilots")
}
```

**Step 3: Add indexes to Booking model**

```prisma
model Booking {
  // ... existing fields and relations

  @@index([userId])
  @@index([pilotId])
  @@index([status])
  @@index([createdAt])
  @@index([paymentStatus])
  @@map("bookings")
}
```

**Step 4: Add indexes to Payment model**

```prisma
model Payment {
  // ... existing fields and relations

  @@index([status])
  @@index([createdAt])
  @@map("payments")
}
```

**Step 5: Add indexes to Earning model**

```prisma
model Earning {
  // ... existing fields and relations

  @@index([pilotId])
  @@index([status])
  @@index([createdAt])
  @@map("earnings")
}
```

**Step 6: Add indexes to WalletTransaction model**

```prisma
model WalletTransaction {
  // ... existing fields and relations

  @@index([userId])
  @@index([status])
  @@index([createdAt])
  @@map("wallet_transactions")
}
```

**Step 7: Run migration**

```bash
cd backend
npx prisma migrate dev --name add_performance_indexes
```

**Step 8: Commit**

```bash
git add backend/prisma/schema.prisma backend/prisma/migrations/
git commit -m "perf(db): add indexes for frequently queried fields"
```

---

### Task 2.3: Add Missing Foreign Key Relations

**Files:**
- Modify: `backend/prisma/schema.prisma`

**Step 1: Fix SupportTicket relations**

```prisma
model SupportTicket {
  id          String    @id @default(cuid())
  pilotId     String?
  userId      String?
  subject     String
  description String
  category    String    @default("GENERAL")
  status      String    @default("OPEN")
  priority    String    @default("MEDIUM")
  createdAt   DateTime  @default(now())
  updatedAt   DateTime  @updatedAt
  resolvedAt  DateTime?

  // Add relations
  pilot       Pilot?    @relation(fields: [pilotId], references: [id], onDelete: Cascade)
  user        User?     @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@index([pilotId])
  @@index([userId])
  @@index([status])
  @@map("support_tickets")
}
```

**Step 2: Add to User model**

```prisma
model User {
  // ... existing fields
  supportTickets  SupportTicket[]
  // ... rest
}
```

**Step 3: Add to Pilot model**

```prisma
model Pilot {
  // ... existing fields
  supportTickets  SupportTicket[]
  // ... rest
}
```

**Step 4: Fix WalletTransaction relation**

```prisma
model WalletTransaction {
  id            String            @id @default(cuid())
  userId        String
  // ... other fields

  // Add relation
  user          User              @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@index([userId])
  @@map("wallet_transactions")
}
```

**Step 5: Add to User model**

```prisma
model User {
  // ... existing fields
  walletTransactions  WalletTransaction[]
  // ... rest
}
```

**Step 6: Run migration**

```bash
cd backend
npx prisma migrate dev --name add_missing_relations
```

**Step 7: Commit**

```bash
git add backend/prisma/schema.prisma backend/prisma/migrations/
git commit -m "fix(db): add missing foreign key relations"
```

---

## Phase 3: Flutter Apps - Environment Configuration

### Task 3.1: Create Environment Configuration System for Pilot App

**Files:**
- Create: `pilot_app/lib/app/core/config/app_config.dart`
- Modify: `pilot_app/lib/app/core/constants/api_constants.dart`

**Step 1: Create app config**

```dart
// pilot_app/lib/app/core/config/app_config.dart

/// App configuration with environment support
///
/// Usage:
/// 1. For development: Use default values (current IP)
/// 2. For staging: Set via --dart-define or flutter_dotenv
/// 3. For production: Set via --dart-define at build time
///
/// Build commands:
/// - Dev: flutter run
/// - Staging: flutter run --dart-define=ENV=staging --dart-define=API_URL=https://staging-api.sendit.com
/// - Prod: flutter build --dart-define=ENV=production --dart-define=API_URL=https://api.sendit.com
class AppConfig {
  AppConfig._();

  /// Current environment
  static const String environment = String.fromEnvironment(
    'ENV',
    defaultValue: 'development',
  );

  /// API Base URL - override via --dart-define=API_URL=https://your-api.com
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://172.16.17.55:5000/api/v1', // Development default
  );

  /// Socket URL - override via --dart-define=SOCKET_URL=https://your-socket.com
  static const String socketUrl = String.fromEnvironment(
    'SOCKET_URL',
    defaultValue: 'http://172.16.17.55:5000', // Development default
  );

  /// Google Maps API Key (static placeholder - replace at build time)
  static const String googleMapsKey = String.fromEnvironment(
    'GOOGLE_MAPS_KEY',
    defaultValue: 'YOUR_GOOGLE_MAPS_KEY_HERE', // Placeholder
  );

  /// Razorpay Key (static placeholder - replace at build time)
  static const String razorpayKey = String.fromEnvironment(
    'RAZORPAY_KEY',
    defaultValue: 'rzp_test_PLACEHOLDER', // Placeholder for testing
  );

  /// Check if running in development
  static bool get isDevelopment => environment == 'development';

  /// Check if running in staging
  static bool get isStaging => environment == 'staging';

  /// Check if running in production
  static bool get isProduction => environment == 'production';

  /// Enable debug features
  static bool get enableDebugFeatures => !isProduction;

  /// Enable mock data fallback (development only)
  static bool get enableMockData => isDevelopment;
}
```

**Step 2: Update ApiConstants to use AppConfig**

```dart
// pilot_app/lib/app/core/constants/api_constants.dart

import '../config/app_config.dart';

/// API Constants for Pilot App
class ApiConstants {
  ApiConstants._();

  // Base URLs - now using AppConfig
  static String get baseUrl => AppConfig.apiUrl;
  static String get socketUrl => AppConfig.socketUrl;

  // ... rest of the file stays the same
}
```

**Step 3: Commit**

```bash
git add pilot_app/lib/app/core/config/app_config.dart pilot_app/lib/app/core/constants/api_constants.dart
git commit -m "feat(pilot): add environment configuration system"
```

---

### Task 3.2: Create Environment Configuration System for User App

**Files:**
- Create: `user_app/lib/app/core/config/app_config.dart`
- Modify: `user_app/lib/app/core/constants/api_constants.dart`

**Step 1: Create app config (same as pilot app)**

```dart
// user_app/lib/app/core/config/app_config.dart

/// App configuration with environment support
class AppConfig {
  AppConfig._();

  static const String environment = String.fromEnvironment(
    'ENV',
    defaultValue: 'development',
  );

  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://172.16.17.55:5000/api/v1',
  );

  static const String socketUrl = String.fromEnvironment(
    'SOCKET_URL',
    defaultValue: 'http://172.16.17.55:5000',
  );

  static const String googleMapsKey = String.fromEnvironment(
    'GOOGLE_MAPS_KEY',
    defaultValue: 'YOUR_GOOGLE_MAPS_KEY_HERE',
  );

  static const String razorpayKey = String.fromEnvironment(
    'RAZORPAY_KEY',
    defaultValue: 'rzp_test_PLACEHOLDER',
  );

  static bool get isDevelopment => environment == 'development';
  static bool get isStaging => environment == 'staging';
  static bool get isProduction => environment == 'production';
  static bool get enableDebugFeatures => !isProduction;
  static bool get enableMockData => isDevelopment;
}
```

**Step 2: Update ApiConstants**

```dart
// user_app/lib/app/core/constants/api_constants.dart

import '../config/app_config.dart';

class ApiConstants {
  ApiConstants._();

  static String get baseUrl => AppConfig.apiUrl;
  static String get socketUrl => AppConfig.socketUrl;

  // ... rest stays the same
}
```

**Step 3: Commit**

```bash
git add user_app/lib/app/core/config/app_config.dart user_app/lib/app/core/constants/api_constants.dart
git commit -m "feat(user): add environment configuration system"
```

---

### Task 3.3: Update Razorpay Service to Use Config

**Files:**
- Modify: `user_app/lib/app/services/razorpay_service.dart`

**Step 1: Update to use AppConfig**

```dart
import '../core/config/app_config.dart';

class RazorpayService extends GetxService {
  // Remove hardcoded key
  // static const String _razorpayKey = 'rzp_test_1DP5mmOlF5G5ag';

  // Use config instead
  static String get _razorpayKey => AppConfig.razorpayKey;

  // ... rest of the service
}
```

**Step 2: Commit**

```bash
git add user_app/lib/app/services/razorpay_service.dart
git commit -m "fix(payment): use environment config for Razorpay key"
```

---

## Phase 4: Fix Null Safety & Memory Leaks

### Task 4.1: Fix Unsafe Bang Operators in Pilot App

**Files:**
- Modify: `pilot_app/lib/app/modules/wallet/controllers/wallet_controller.dart`
- Modify: `pilot_app/lib/app/modules/registration/controllers/registration_controller.dart`
- Modify: `pilot_app/lib/app/modules/history/controllers/history_controller.dart`

**Step 1: Fix wallet_controller.dart**

Replace unsafe bang operators:

```dart
// Before:
bankAccountId: selectedBankAccount.value!.id,

// After:
bankAccountId: selectedBankAccount.value?.id ?? '',

// Add null check before operations
if (selectedBankAccount.value == null) {
  Get.snackbar('Error', 'Please select a bank account');
  return;
}
```

**Step 2: Fix registration_controller.dart**

```dart
// Before:
dateOfBirth.value!

// After:
final dob = dateOfBirth.value;
if (dob == null) {
  Get.snackbar('Error', 'Please select date of birth');
  return;
}
// Use dob instead of dateOfBirth.value!
```

**Step 3: Fix history_controller.dart**

```dart
// Before:
startDate.value!
endDate.value!

// After:
final start = startDate.value;
final end = endDate.value;
if (start == null || end == null) {
  Get.snackbar('Error', 'Please select date range');
  return;
}
```

**Step 4: Commit**

```bash
git add pilot_app/lib/app/modules/*/controllers/*.dart
git commit -m "fix(pilot): replace unsafe bang operators with null-safe code"
```

---

### Task 4.2: Fix Timer Disposal in Jobs Controller

**Files:**
- Modify: `pilot_app/lib/app/modules/jobs/controllers/jobs_controller.dart`

**Step 1: Add timer cleanup in onClose**

```dart
class JobsController extends GetxController {
  Timer? _locationTimer;
  Timer? _refreshTimer;

  // ... existing code

  @override
  void onClose() {
    // Cancel all timers
    _locationTimer?.cancel();
    _refreshTimer?.cancel();

    // Cancel any subscriptions
    // _subscription?.cancel();

    super.onClose();
  }
}
```

**Step 2: Commit**

```bash
git add pilot_app/lib/app/modules/jobs/controllers/jobs_controller.dart
git commit -m "fix(pilot): add timer disposal to prevent memory leaks"
```

---

### Task 4.3: Add onClose to All Controllers Missing It

**Files:**
- Modify: `pilot_app/lib/app/modules/home/controllers/home_controller.dart`
- Modify: `pilot_app/lib/app/modules/wallet/controllers/wallet_controller.dart`

**Step 1: Add onClose to home_controller.dart**

```dart
@override
void onClose() {
  // Cancel any active timers or subscriptions
  // Add cleanup for any resources
  super.onClose();
}
```

**Step 2: Add onClose to wallet_controller.dart**

```dart
@override
void onClose() {
  // Cleanup resources
  super.onClose();
}
```

**Step 3: Commit**

```bash
git add pilot_app/lib/app/modules/*/controllers/*.dart
git commit -m "fix(pilot): add onClose cleanup to all controllers"
```

---

## Phase 5: Disable Mock Data in Production

### Task 5.1: Guard Mock Data with Environment Check

**Files:**
- Modify: `pilot_app/lib/app/modules/home/controllers/home_controller.dart`
- Modify: `pilot_app/lib/app/data/repositories/wallet_repository.dart`

**Step 1: Update home_controller.dart**

```dart
import '../../core/config/app_config.dart';

// Replace mock data loading with:
void _loadMockStats() {
  // Only load mock data in development
  if (!AppConfig.enableMockData) {
    // In production, show error state instead
    hasError.value = true;
    errorMessage.value = 'Unable to load data. Please try again.';
    return;
  }

  // Development mock data
  todayEarnings.value = EarningsModel(
    totalEarnings: 980.0,
    totalHours: 4.5,
    totalRides: 8,
    period: 'today',
  );
}
```

**Step 2: Update wallet_repository.dart**

```dart
import '../core/config/app_config.dart';

// Wrap mock data methods:
List<WalletTransactionModel> _getMockTransactions() {
  if (!AppConfig.enableMockData) {
    return []; // Return empty in non-dev environments
  }

  // Return mock data only in development
  return [
    // ... mock data
  ];
}
```

**Step 3: Commit**

```bash
git add pilot_app/lib/app/modules/*/controllers/*.dart pilot_app/lib/app/data/repositories/*.dart
git commit -m "fix(pilot): guard mock data with environment check"
```

---

## Phase 6: Fix Integration Mismatches

### Task 6.1: Align Auth Response Field Names

**Files:**
- Modify: `backend/src/controllers/auth.controller.ts`

**Step 1: Standardize pilot login response**

```typescript
// In pilot login handler, change:
formatResponse(true, result.message, {
  accessToken: result.accessToken,  // Changed from 'token' to 'accessToken'
  refreshToken: result.refreshToken,
  pilot: result.user,
  isNewUser: result.isNewUser,
})
```

**Step 2: Verify user login uses same format**

```typescript
// User login should also use:
formatResponse(true, result.message, {
  accessToken: result.accessToken,
  refreshToken: result.refreshToken,
  user: result.user,
  isNewUser: result.isNewUser,
})
```

**Step 3: Commit**

```bash
git add backend/src/controllers/auth.controller.ts
git commit -m "fix(api): standardize auth response to use accessToken"
```

---

### Task 6.2: Update Pilot App to Parse Correct Auth Response

**Files:**
- Modify: `pilot_app/lib/app/data/repositories/auth_repository.dart`

**Step 1: Ensure parsing uses accessToken**

```dart
// In login/verify methods:
final token = response.data['data']['accessToken'] as String?;
final refreshToken = response.data['data']['refreshToken'] as String?;

if (token == null) {
  return ApiResponse.error('Authentication failed');
}
```

**Step 2: Commit**

```bash
git add pilot_app/lib/app/data/repositories/auth_repository.dart
git commit -m "fix(pilot): parse accessToken from auth response"
```

---

### Task 6.3: Align PilotStatus Enum

**Files:**
- Modify: `pilot_app/lib/app/data/models/pilot_model.dart`

**Step 1: Update enum to match backend**

```dart
enum PilotStatus {
  pending('PENDING'),
  approved('APPROVED'),   // Changed from 'active'
  rejected('REJECTED'),   // Added
  suspended('SUSPENDED'),
  ;

  final String value;
  const PilotStatus(this.value);

  static PilotStatus fromString(String value) {
    return PilotStatus.values.firstWhere(
      (e) => e.value.toLowerCase() == value.toLowerCase(),
      orElse: () => PilotStatus.pending,
    );
  }
}
```

**Step 2: Commit**

```bash
git add pilot_app/lib/app/data/models/pilot_model.dart
git commit -m "fix(pilot): align PilotStatus enum with backend"
```

---

### Task 6.4: Align JobStatus Enum

**Files:**
- Modify: `pilot_app/lib/app/data/models/job_model.dart`

**Step 1: Update JobStatus to match backend BookingStatus**

```dart
enum JobStatus {
  pending('PENDING'),
  accepted('ACCEPTED'),           // Backend: ACCEPTED
  arrivedPickup('ARRIVED_PICKUP'),
  pickedUp('PICKED_UP'),
  inTransit('IN_TRANSIT'),
  arrivedDrop('ARRIVED_DROP'),
  delivered('DELIVERED'),
  cancelled('CANCELLED'),
  ;

  final String value;
  const JobStatus(this.value);

  static JobStatus fromString(String value) {
    return JobStatus.values.firstWhere(
      (e) => e.value.toLowerCase() == value.toLowerCase().replaceAll('_', ''),
      orElse: () => JobStatus.pending,
    );
  }

  /// Display name for UI
  String get displayName {
    switch (this) {
      case JobStatus.pending: return 'Pending';
      case JobStatus.accepted: return 'Accepted';
      case JobStatus.arrivedPickup: return 'Arrived at Pickup';
      case JobStatus.pickedUp: return 'Picked Up';
      case JobStatus.inTransit: return 'In Transit';
      case JobStatus.arrivedDrop: return 'Arrived at Drop';
      case JobStatus.delivered: return 'Delivered';
      case JobStatus.cancelled: return 'Cancelled';
    }
  }
}
```

**Step 2: Commit**

```bash
git add pilot_app/lib/app/data/models/job_model.dart
git commit -m "fix(pilot): align JobStatus enum with backend BookingStatus"
```

---

## Phase 7: Remove Debug Logging

### Task 7.1: Remove Print Statements from Socket Service

**Files:**
- Modify: `user_app/lib/app/services/socket_service.dart`

**Step 1: Replace print with conditional debug**

```dart
import '../core/config/app_config.dart';

// Add debug helper
void _debugLog(String message) {
  if (AppConfig.enableDebugFeatures) {
    debugPrint('[SocketService] $message');
  }
}

// Replace all print() calls:
// Before: print('[SocketService] Connected');
// After: _debugLog('Connected');
```

**Step 2: Commit**

```bash
git add user_app/lib/app/services/socket_service.dart
git commit -m "fix(user): replace print statements with conditional debug logging"
```

---

### Task 7.2: Add Debug Logging Helper to Pilot App

**Files:**
- Create: `pilot_app/lib/app/core/utils/logger.dart`
- Update services to use it

**Step 1: Create logger utility**

```dart
// pilot_app/lib/app/core/utils/logger.dart

import 'package:flutter/foundation.dart';
import '../config/app_config.dart';

/// App logger with environment-aware logging
class AppLogger {
  AppLogger._();

  static void debug(String tag, String message) {
    if (AppConfig.enableDebugFeatures) {
      debugPrint('[$tag] $message');
    }
  }

  static void error(String tag, String message, [Object? error, StackTrace? stackTrace]) {
    // Always log errors, but with more detail in development
    if (AppConfig.enableDebugFeatures) {
      debugPrint('[$tag] ERROR: $message');
      if (error != null) debugPrint('Error: $error');
      if (stackTrace != null) debugPrint('Stack: $stackTrace');
    } else {
      // In production, you'd send to crash reporting service
      debugPrint('[$tag] ERROR: $message');
    }
  }

  static void info(String tag, String message) {
    if (AppConfig.enableDebugFeatures) {
      debugPrint('[$tag] INFO: $message');
    }
  }
}
```

**Step 2: Commit**

```bash
git add pilot_app/lib/app/core/utils/logger.dart
git commit -m "feat(pilot): add environment-aware logging utility"
```

---

## Phase 8: Create Backend .env.example

### Task 8.1: Create Environment Template

**Files:**
- Create: `backend/.env.example`

**Step 1: Create .env.example**

```env
# Server Configuration
PORT=5000
NODE_ENV=development

# Database
DATABASE_URL=postgresql://user:password@localhost:5432/sendit_db

# JWT Configuration
JWT_SECRET=your-super-secret-key-change-in-production
JWT_EXPIRES_IN=7d
JWT_REFRESH_SECRET=your-refresh-secret-key
JWT_REFRESH_EXPIRES_IN=30d

# OTP Configuration
OTP_EXPIRY_MINUTES=5

# SMS Gateway (Configure when ready)
SMS_API_KEY=
SMS_SENDER_ID=SENDIT

# Google Maps (Configure when ready)
GOOGLE_MAPS_API_KEY=

# Razorpay Payment Gateway (Configure when ready)
RAZORPAY_KEY_ID=
RAZORPAY_KEY_SECRET=

# Cloudinary File Upload (Configure when ready)
CLOUDINARY_CLOUD_NAME=
CLOUDINARY_API_KEY=
CLOUDINARY_API_SECRET=

# Firebase Push Notifications (Configure when ready)
FIREBASE_PROJECT_ID=
FIREBASE_PRIVATE_KEY=
FIREBASE_CLIENT_EMAIL=

# App URLs
APP_URL=http://localhost:5000
CLIENT_URL=http://localhost:3000

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX=100
```

**Step 2: Add to .gitignore if not already**

```bash
# Ensure .env is ignored but .env.example is tracked
echo ".env" >> backend/.gitignore
```

**Step 3: Commit**

```bash
git add backend/.env.example backend/.gitignore
git commit -m "docs(backend): add .env.example template for configuration"
```

---

## Summary: What's Ready After This Plan

### ✅ Completed After All Tasks:

1. **Backend Security**
   - CORS environment-aware
   - Rate limiting on payment routes
   - File upload path validation
   - Production safety guards

2. **Database**
   - Decimal for all money fields
   - Performance indexes
   - Foreign key relations

3. **Flutter Apps**
   - Environment configuration system
   - API URLs configurable via build args
   - Razorpay key from config
   - Null-safe code
   - No memory leaks
   - Mock data disabled in production

4. **Integration**
   - Auth response standardized
   - Enums aligned
   - Debug logging controlled

### 📝 Configuration Ready For (add credentials later):
- `RAZORPAY_KEY_ID` / `RAZORPAY_KEY_SECRET`
- `SMS_API_KEY`
- `FIREBASE_*` credentials
- `CLOUDINARY_*` credentials
- Production `DATABASE_URL`
- Production `JWT_SECRET`

### ✅ Already Configured:
- `GOOGLE_MAPS_API_KEY` - Working

### 🚀 How to Deploy Later:

**Backend:**
```bash
# Set environment variables in your hosting platform
NODE_ENV=production
DATABASE_URL=your-production-db-url
JWT_SECRET=your-production-secret
# ... other credentials
```

**Flutter Apps:**
```bash
# Build with production config
flutter build apk \
  --dart-define=ENV=production \
  --dart-define=API_URL=https://api.sendit.com \
  --dart-define=SOCKET_URL=https://api.sendit.com \
  --dart-define=RAZORPAY_KEY=rzp_live_YOURKEY \
  --dart-define=GOOGLE_MAPS_KEY=YOUR_MAPS_KEY
```

---

**Plan complete and saved to `docs/plans/2026-02-04-production-code-completion.md`.**

**Two execution options:**

1. **Subagent-Driven (this session)** - I dispatch fresh subagent per task, review between tasks, fast iteration

2. **Parallel Session (separate)** - Open new session with executing-plans, batch execution with checkpoints

**Which approach?**
