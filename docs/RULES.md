# SendIt Platform - Development Rules & Standards

## 📋 Overview

This document defines the **universal rules and standards** that apply across all platforms (Website, Admin Dashboard, Backend API, Mobile Apps) to ensure consistency, quality, and alignment.

---

## 🎯 Core Principles

### 1. **Single Source of Truth**
- All API contracts defined in `backend-api-plan.md`
- Database schema is the definitive data model
- Cross-platform types must match exactly

### 2. **Consistency First**
- Same naming conventions across all platforms
- Unified error codes and messages
- Consistent date/time formats
- Uniform status values

### 3. **Security by Default**
- Authentication required on all protected routes
- Input validation on client AND server
- Never trust client-side data
- Secrets never in code

### 4. **Performance Matters**
- Page load < 3 seconds
- API response < 500ms (p95)
- Mobile app startup < 3 seconds
- 60 FPS animations

### 5. **User Experience Paramount**
- Loading states always visible
- Error messages user-friendly
- Offline handling graceful
- Accessibility compliant

---

## 🔗 Cross-Platform Alignment

### API Contract Enforcement

> **Rule:** All platforms MUST use identical API request/response formats.

#### ✅ Example: Create Order API

**Backend API Definition:**
```typescript
// POST /api/v1/orders
interface CreateOrderRequest {
  pickup_location: {
    lat: number;
    lng: number;
    address: string;
  };
  drop_location: {
    lat: number;
    lng: number;
    address: string;
  };
  vehicle_type: 'bike' | 'auto' | 'mini_truck' | 'ev_cycle';
  payment_method: 'wallet' | 'card' | 'upi' | 'cash';
  coupon_code?: string;
  scheduled_at?: string; // ISO 8601
}

interface CreateOrderResponse {
  success: boolean;
  data?: {
    id: string;
    user_id: string;
    status: string;
    fare: number;
    created_at: string;
  };
  error?: {
    message: string;
    code: string;
  };
}
```

**Frontend (Admin Dashboard) MUST match:**
```typescript
// Exact same structure
const createOrder = async (data: CreateOrderRequest): Promise<CreateOrderResponse> => {
  return apiClient.post('/orders', data);
};
```

**Mobile App (Flutter) MUST match:**
```dart
class CreateOrderRequest {
  final Location pickupLocation;
  final Location dropLocation;
  final String vehicleType;
  final String paymentMethod;
  final String? couponCode;
  final DateTime? scheduledAt;
  
  Map<String, dynamic> toJson() {
    return {
      'pickup_location': pickupLocation.toJson(),
      'drop_location': dropLocation.toJson(),
      'vehicle_type': vehicleType,
      'payment_method': paymentMethod,
      if (couponCode != null) 'coupon_code': couponCode,
      if (scheduledAt != null) 'scheduled_at': scheduledAt!.toIso8601String(),
    };
  }
}
```

---

## 📐 Naming Conventions

### Database (PostgreSQL)
- **Tables:** `snake_case`, plural (e.g., `users`, `orders`, `pilots`)
- **Columns:** `snake_case` (e.g., `user_id`, `created_at`, `pickup_location_lat`)
- **Primary Keys:** `id` (UUID)
- **Foreign Keys:** `{table_singular}_id` (e.g., `user_id`, `pilot_id`)
- **Timestamps:** `created_at`, `updated_at`
- **Boolean:** Prefix with `is_` or `has_` (e.g., `is_active`, `has_verified`)

### Backend API (Node.js/TypeScript)
- **Files:** `camelCase.ts` or `kebab-case.ts` (e.g., `orderController.ts` or `order-controller.ts`)
- **Classes:** `PascalCase` (e.g., `OrderService`, `UserRepository`)
- **Functions:** `camelCase` (e.g., `createOrder`, `validateCoupon`)
- **Constants:** `UPPER_SNAKE_CASE` (e.g., `MAX_RETRY_COUNT`, `DEFAULT_PAGE_SIZE`)
- **Interfaces:** `PascalCase` with `I` prefix optional (e.g., `Order`, `IOrderService`)
- **Enums:** `PascalCase` (e.g., `OrderStatus`, `PaymentMethod`)

### Frontend (Next.js/React)
- **Components:** `PascalCase` (e.g., `OrderCard`, `UserTable`)
- **Files:** Match component name (e.g., `OrderCard.tsx`)
- **Props:** `camelCase` (e.g., `onOrderClick`, `isLoading`)
- **State:** `camelCase` (e.g., `isModalOpen`, `selectedUser`)
- **Hooks:** Prefix with `use` (e.g., `useAuth`, `useOrders`)
- **Utils:** `camelCase` (e.g., `formatDate`, `calculateFare`)

### Mobile (Flutter/Dart)
- **Files:** `snake_case.dart` (e.g., `order_card.dart`, `home_screen.dart`)
- **Classes:** `PascalCase` (e.g., `OrderCard`, `HomeScreen`)
- **Functions:** `camelCase` (e.g., `createOrder`, `validateInput`)
- **Variables:** `camelCase` (e.g., `orderId`, `isLoading`)
- **Constants:** `lowerCamelCase` or `UPPER_SNAKE_CASE` (e.g., `kPrimaryColor`, `API_URL`)
- **Private:** Prefix with `_` (e.g., `_buildHeader()`, `_apiClient`)

---

## 🎨 Standard Values (Must Match Across Platforms)

### Order Statuses
```
pending
searching_driver
assigned
picked_up
in_transit
delivered
cancelled
no_driver_found
```

### Vehicle Types
```
bike
auto
mini_truck
ev_cycle
```

### Payment Methods
```
wallet
card
upi
cash
razorpay
```

### User/Pilot Status
```
active
suspended
deleted
pending_verification
```

### Error Codes (Backend → Frontend/Mobile)
```
UNAUTHORIZED
TOKEN_EXPIRED
VALIDATION_ERROR
INSUFFICIENT_BALANCE
ORDER_NOT_FOUND
USER_NOT_FOUND
PILOT_NOT_FOUND
COUPON_INVALID
PAYMENT_FAILED
INTERNAL_ERROR
```

---

## 🔐 Security Standards

### Authentication

#### ✅ Rule: JWT Token Structure
**ALL platforms must handle tokens consistently:**

**Backend generates:**
```typescript
const accessToken = jwt.sign(
  { userId: user.id, role: user.role },
  process.env.JWT_SECRET!,
  { expiresIn: '24h' }
);

const refreshToken = jwt.sign(
  { userId: user.id },
  process.env.JWT_REFRESH_SECRET!,
  { expiresIn: '7d' }
);
```

**Frontend stores:**
```typescript
// localStorage (web) or SecureStorage (mobile)
localStorage.setItem('accessToken', token);
localStorage.setItem('refreshToken', refreshToken);
```

**Frontend sends:**
```typescript
headers: {
  'Authorization': `Bearer ${accessToken}`
}
```

**Backend verifies:**
```typescript
const token = req.headers.authorization?.replace('Bearer ', '');
const decoded = jwt.verify(token, process.env.JWT_SECRET!);
req.user = decoded;
```

### Input Validation

#### ✅ Rule: Validate on BOTH client and server

**Client-side (immediate UX feedback):**
```typescript
// React Hook Form + Zod
const schema = z.object({
  email: z.string().email('Invalid email'),
  phone: z.string().regex(/^[0-9]{10}$/, 'Invalid phone number')
});
```

**Server-side (security):**
```typescript
// Express middleware
app.post('/orders', validate(createOrderSchema), orderController.create);
```

### Password Security

#### ✅ Rule: bcrypt with 12 rounds minimum

```typescript
// Backend ONLY
import bcrypt from 'bcryptjs';

const hashedPassword = await bcrypt.hash(password, 12);
const isValid = await bcrypt.compare(inputPassword, storedHash);
```

> **⚠️ NEVER send passwords to client. NEVER log passwords.**

---

## 📊 Data Format Standards

### Dates & Times

#### ✅ Rule: Always use ISO 8601 in APIs

**Backend sends:**
```json
{
  "created_at": "2026-01-29T17:00:00.000Z",
  "scheduled_at": "2026-01-30T10:00:00+05:30"
}
```

**Frontend displays:**
```typescript
// Use date-fns or dayjs
import { format } from 'date-fns';

const displayDate = format(new Date(order.created_at), 'dd MMM yyyy, hh:mm a');
// Output: "29 Jan 2026, 05:00 PM"
```

**Mobile displays:**
```dart
import 'package:intl/intl.dart';

final displayDate = DateFormat('dd MMM yyyy, hh:mm a').format(order.createdAt);
```

### Currency

#### ✅ Rule: Store as decimal, display with currency symbol

**Backend (Database):**
```sql
fare DECIMAL(10, 2)  -- 10 digits total, 2 after decimal
```

**Backend (API):**
```json
{
  "fare": 150.50,
  "discount": 20.00,
  "final_amount": 130.50
}
```

**Frontend display:**
```typescript
const formatted = `₹${amount.toFixed(2)}`;
// Output: "₹150.50"
```

### Phone Numbers

#### ✅ Rule: Store with country code, display formatted

**Backend (Database):**
```sql
phone VARCHAR(15)          -- "9876543210"
country_code VARCHAR(5)    -- "+91"
```

**Display:**
```
+91 98765 43210  (with spaces for readability)
```

---

## 🏗️ Architecture Rules

### API Endpoint Structure

#### ✅ Rule: RESTful conventions

```
GET    /api/v1/orders           # List orders
POST   /api/v1/orders           # Create order
GET    /api/v1/orders/:id       # Get single order
PATCH  /api/v1/orders/:id       # Update order
DELETE /api/v1/orders/:id       # Delete order

GET    /api/v1/users/:id/orders # User's orders
POST   /api/v1/orders/:id/cancel # Custom actions
```

### Database Relationships

#### ✅ Rule: Use UUIDs for IDs, proper constraints

```sql
CREATE TABLE orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  pilot_id UUID REFERENCES pilots(id) ON DELETE SET NULL,
  ...
);

CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_pilot_id ON orders(pilot_id);
CREATE INDEX idx_orders_status ON orders(status);
```

### Error Handling

#### ✅ Rule: Standardized error response

**Backend ALWAYS returns:**
```json
{
  "success": false,
  "error": {
    "message": "User-friendly error message",
    "code": "ERROR_CODE",
    "field": "email"  // Optional, for validation errors
  }
}
```

**Frontend ALWAYS displays:**
```typescript
if (!response.success) {
  toast.error(response.error.message);
  // OR
  setError(response.error.message);
}
```

---

## 🧪 Testing Requirements

### Code Coverage Minimums

- **Backend:** 80% coverage (unit + integration)
- **Frontend:** 70% coverage (unit + component)
- **Mobile:** 70% coverage (unit + widget)

### Required Tests

#### Backend
- [ ] Unit tests for services
- [ ] Integration tests for API endpoints
- [ ] Database migration tests
- [ ] Load tests (k6) for critical endpoints

#### Frontend (Web)
- [ ] Component tests (React Testing Library)
- [ ] User flow tests (Playwright/Cypress)
- [ ] Accessibility tests (axe-core)

#### Mobile
- [ ] Unit tests for business logic
- [ ] Widget tests for UI components
- [ ] Integration tests for key flows

---

## 📱 Mobile-Specific Rules

### Platform Consistency

#### ✅ Rule: Same UX on iOS and Android, different native feel

**Same:**
- Functionality
- Screen layouts
- Colors & branding
- Navigation flow

**Different:**
- Navigation patterns (iOS: Tab bar bottom, Android: Bottom nav)
- Button styles (iOS: rounded, Android: Material)
- Typography (iOS: SF Pro, Android: Roboto)

### Performance

#### ✅ Rule: Must maintain 60 FPS

```dart
// ❌ BAD: Expensive operation in build
@override
Widget build(BuildContext context) {
  final data = expensiveCalculation(); // Rebuilds every frame!
  return Text(data);
}

// ✅ GOOD: Cache or compute once
@override
Widget build(BuildContext context) {
  final data = useMemoized(() => expensiveCalculation());
  return Text(data);
}
```

---

## 🚀 Deployment Rules

### Environment Variables

#### ✅ Rule: Never commit secrets

**Required `.env` structure:**
```bash
# Backend .env
NODE_ENV=development
PORT=5000
DATABASE_URL=postgresql://...
REDIS_URL=redis://...
JWT_SECRET=xxx
RAZORPAY_KEY_ID=xxx
RAZORPAY_KEY_SECRET=xxx
AWS_ACCESS_KEY=xxx
AWS_SECRET_KEY=xxx
```

**Frontend `.env.local`:**
```bash
NEXT_PUBLIC_API_URL=http://localhost:5000/api/v1
NEXT_PUBLIC_SOCKET_URL=http://localhost:5000
NEXT_PUBLIC_GOOGLE_MAPS_KEY=xxx
```

**Mobile (Dart-define):**
```bash
flutter run --dart-define=API_URL=http://localhost:5000/api/v1
```

### Version Control

#### ✅ Rule: Semantic Versioning

```
v1.0.0 - Initial release
v1.1.0 - New features (backward compatible)
v1.1.1 - Bug fixes
v2.0.0 - Breaking changes
```

### Git Commit Messages

#### ✅ Rule: Conventional Commits

```
feat: Add driver matching algorithm
fix: Resolve payment webhook timeout
docs: Update API documentation
refactor: Improve order service structure
test: Add integration tests for orders API
chore: Update dependencies
```

---

## 📋 Code Review Checklist

### Universal Checks (All Platforms)

- [ ] **Functionality:** Feature works as expected
- [ ] **Naming:** Follows platform conventions
- [ ] **Types:** Strongly typed (TypeScript/Dart)
- [ ] **Error Handling:** Try-catch blocks present
- [ ] **Validation:** Input validated
- [ ] **Security:** No secrets, no SQL injection risk
- [ ] **Performance:** No obvious performance issues
- [ ] **Tests:** Tests included/updated
- [ ] **Documentation:** Complex logic documented
- [ ] **Logging:** Appropriate logging added

### Platform-Specific

#### Backend
- [ ] Database transactions used where needed
- [ ] Indexes created for queries
- [ ] Rate limiting applied
- [ ] API versioned (/api/v1/)

#### Frontend (Web)
- [ ] Server components used by default
- [ ] Images optimized (next/image)
- [ ] SEO meta tags present
- [ ] Accessibility labels added

#### Mobile
- [ ] Null safety respected
- [ ] Const constructors used
- [ ] Dispose called in StatefulWidgets
- [ ] Platform differences handled

---

## 🎯 Success Criteria

### Before Merging PR

- [ ] All tests passing (CI/CD)
- [ ] Code review approved (2 reviewers)
- [ ] Linting passed (ESLint/Dart analyze)
- [ ] No console.log or print statements
- [ ] Documentation updated
- [ ] Database migrations tested
- [ ] API alignment verified (if API change)

### Before Deployment

- [ ] Staging environment tested
- [ ] Load test passed (if backend change)
- [ ] Mobile app tested on both platforms
- [ ] SEO check passed (if web change)
- [ ] Error monitoring configured
- [ ] Rollback plan documented

---

## 🔍 Monitoring & Observability

### Required Metrics

**Backend:**
- API response times (p50, p95, p99)
- Error rates by endpoint
- Database query performance
- Background job success rate

**Frontend:**
- Page load times
- Time to Interactive (TTI)
- Bounce rate
- Conversion rate

**Mobile:**
- App startup time
- Screen render time
- Crash-free rate (> 99.5%)
- API success rate

### Logging Standards

```typescript
// ✅ GOOD: Structured logging
logger.info('Order created', {
  orderId: order.id,
  userId: user.id,
  amount: order.fare
});

logger.error('Payment failed', {
  orderId: order.id,
  error: err.message,
  code: err.code
});

// ❌ BAD: Unstructured
console.log('Order created');
console.log(order); // Too much data
```

---

## 🚨 Breaking Change Protocol

### When Making Breaking Changes

1. **Document the change** in CHANGELOG.md
2. **Version the API** (e.g., /api/v2/ endpoint)
3. **Notify all teams** via Slack/Email
4. **Update all clients** (web, mobile, admin)
5. **Deprecation period** - Support old version for 1 month
6. **Migration guide** provided

### Example

```
❌ BREAKING: Renamed 'pickup_location' to 'pickup'
   Old clients will break immediately

✅ NON-BREAKING: Add new '/api/v2/orders' endpoint
   Support /api/v1/orders for 30 days
   Provide migration guide
```

---

## 📚 Enforcement

### Automated Checks (CI/CD)

- ✅ Linting (ESLint, Dart analyze)
- ✅ Type checking (TypeScript strict mode)
- ✅ Unit tests pass
- ✅ Integration tests pass
- ✅ Code coverage > threshold
- ✅ No secrets in code (git-secrets)
- ✅ Dependency vulnerability scan

### Manual Checks (Code Review)

- ✅ API alignment verified
- ✅ Naming conventions followed
- ✅ Error handling present
- ✅ Performance considered
- ✅ Security reviewed

---

**Document Version:** 1.0  
**Last Updated:** 2026-01-29  
**Status:** Active - All developers must follow

**Violation Consequences:**
- PR rejected
- Deployment blocked
- Re-review required

**Questions?** Contact Tech Lead or Architecture Team
