# Testing Strategy & QA Plan

## 1. Overview

Comprehensive testing strategy covering unit tests, integration tests, E2E tests, and performance testing across all platform components.

---

## 2. Testing Pyramid

```
           ╱╲
          ╱E2E╲         ~10% - Manual + Automated
         ╱──────╲
        ╱ Integr.╲       ~30% - API + Integration
       ╱──────────╲
      ╱    Unit     ╲    ~60% - Unit Tests
     ╱──────────────╲
```

**Target Coverage:**
- Unit Tests: 80%+ coverage
- Integration Tests: Key user flows
- E2E Tests: Critical paths
- Performance Tests: Load & stress testing

---

## 3. Backend Testing

### 3.1 Unit Tests (Jest + Supertest)

**Coverage Requirements:** 80%+

**Test Structure:**
```typescript
// tests/unit/services/pricing.service.test.ts
import { PricingService } from '../../src/services/pricing.service';

describe('PricingService', () => {
  let pricingService: PricingService;
  
  beforeEach(() => {
    pricingService = new PricingService();
  });
  
  describe('calculateFare', () => {
    it('should calculate basic fare correctly', async () => {
      const params = {
        vehicleType: '2_wheeler',
        distanceKm: 5,
        durationMins: 15,
        pickupLat: 23.0225,
        pickupLng: 72.5714,
        isScheduled: false
      };
      
      const fare = await pricingService.calculateFare(params);
      
      expect(fare.base_fare).toBe(54);
      expect(fare.distance_fare).toBe(25);
      expect(fare.surge_multiplier).toBe(1.0);
      expect(fare.total).toBeGreaterThan(0);
    });
    
    it('should apply surge pricing correctly', async () => {
      // Test implementation
    });
    
    it('should handle minimum fare', async () => {
      // Test implementation
    });
  });
});
```

**Areas to Test:**
- [ ] Authentication (OTP generation, validation)
- [ ] Order creation & validation
- [ ] Pricing calculation
- [ ] Driver matching algorithm
- [ ] Payment processing
- [ ] Wallet operations
- [ ] Coupon validation
- [ ] Referral logic

### 3.2 Integration Tests

**Test Structure:**
```typescript
// tests/integration/orders.test.ts
import request from 'supertest';
import app from '../../src/app';
import { setupTestDB, teardownTestDB } from '../helpers/db';

describe('Orders API Integration', () => {
  beforeAll(async () => {
    await setupTestDB();
  });
  
  afterAll(async () => {
    await teardownTestDB();
  });
  
  describe('POST /api/v1/orders/estimate', () => {
    it('should return price estimate for valid request', async () => {
      const response = await request(app)
        .post('/api/v1/orders/estimate')
        .set('Authorization', `Bearer ${validToken}`)
        .send({
          pickup_lat: 23.0225,
          pickup_lng: 72.5714,
          drop_lat: 23.0395,
          drop_lng: 72.5661,
          vehicle_type: '2_wheeler',
          service_type: 'goods'
        });
      
      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.estimate).toHaveProperty('total');
    });
    
    it('should return error for invalid coordinates', async () => {
      // Test implementation
    });
  });
  
  describe('POST /api/v1/orders', () => {
    it('should create order successfully', async () => {
      // Test implementation
    });
    
    it('should fail without authentication', async () => {
      // Test implementation
    });
  });
});
```

**Integration Test Scenarios:**
- [ ] Complete order flow (create → assign → complete)
- [ ] Payment flow (wallet, card, cash)
- [ ] Coupon application
- [ ] Referral completion
- [ ] Driver matching
- [ ] Real-time updates (Socket.io)

### 3.3 Database Tests

```typescript
// tests/integration/database.test.ts
describe('Database Operations', () => {
  it('should create user correctly', async () => {
    const user = await db.users.create({
      phone: '9484707535',
      name: 'Test User'
    });
    
    expect(user.id).toBeDefined();
    expect(user.referral_code).toHaveLength(6);
  });
  
  it('should find drivers within radius', async () => {
    // Seed test data
    await seedDrivers();
    
    const drivers = await driverMatchingService.findEligibleDrivers({
      pickupLat: 23.0225,
      pickupLng: 72.5714,
      vehicleType: '2_wheeler'
    });
    
    expect(drivers.length).toBeGreaterThan(0);
  });
});
```

---

## 4. Mobile App Testing (Flutter)

### 4.1 Widget Tests

```dart
// test/widgets/order_card_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sendit_user/widgets/order_card.dart';

void main() {
  testWidgets('OrderCard displays order information', (WidgetTester tester) async {
    final order = Order(
      id: 'test-id',
      orderNumber: 'ORD-123',
      pickupAddress: 'Test Pickup',
      dropAddress: 'Test Drop',
      totalAmount: 94.40,
      status: 'completed',
    );
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OrderCard(order: order),
        ),
      ),
    );
    
    expect(find.text('ORD-123'), findsOneWidget);
    expect(find.text('₹94.40'), findsOneWidget);
    expect(find.text('Test Pickup'), findsOneWidget);
  });
}
```

### 4.2 Integration Tests

```dart
// integration_test/booking_flow_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sendit_user/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Booking Flow', () {
    testWidgets('Complete booking flow', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // Login
      await tester.enterText(find.byKey(Key('phone_input')), '9484707535');
      await tester.tap(find.text('Send OTP'));
      await tester.pumpAndSettle();
      
      // Enter OTP
      await tester.enterText(find.byKey(Key('otp_input')), '123456');
      await tester.pumpAndSettle();
      
      // Select pickup location
      await tester.tap(find.text('Pickup Location'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(Key('location_search')), 'Ahmedabad');
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();
      
      // Select drop location
      // Select vehicle
      // Review and book
      // Assert order created
      
      expect(find.text('Finding Driver'), findsOneWidget);
    });
  });
}
```

### 4.3 Unit Tests (Services)

```dart
// test/services/api_client_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sendit_user/services/api_client.dart';

void main() {
  group('ApiClient', () {
    test('should handle successful response', () async {
      final apiClient = ApiClient();
      final response = await apiClient.get('/test');
      
      expect(response.success, true);
    });
    
    test('should handle error response', () async {
      // Test implementation
    });
  });
}
```

### 4.4 Mobile Test Coverage

| Category | Test Count | Priority |
|----------|------------|----------|
| **Widgets** | 50+ | High |
| **State Management** | 30+ | High |
| **API Services** | 40+ | High |
| **Business Logic** | 25+ | Medium |
| **Navigation** | 15+ | Medium |
| **UI/UX** | Manual | High |

---

## 5. E2E Testing

### 5.1 Critical User Journeys

#### Journey 1: Complete Order Flow (User)
```
1. User opens app
2. Login with OTP
3. Select pickup location
4. Select drop location
5. Choose vehicle type
6. Review booking
7. Apply coupon
8. Make payment
9. Wait for driver assignment
10. Track order
11. Order delivered
12. Rate driver
13. View order history
```

**Expected Result:** Order created, driver assigned, completed successfully

#### Journey 2: Pilot Job Acceptance
```
1. Pilot logs in
2. Goes online
3. Receives job notification
4. Accepts job
5. Navigates to pickup
6. Collects package
7. Navigates to drop
8. Completes delivery
9. Receives payment
10. Check wallet balance
```

**Expected Result:** Job completed, earnings credited

### 5.2 Automation (Selenium/Appium)

```javascript
// e2e/user_booking.spec.js
describe('User Booking Flow', () => {
  it('should complete booking successfully', async () => {
    // Launch app
    await driver.launchApp();
    
    // Login
    await element(by.id('phone_input')).typeText('9484707535');
    await element(by.text('Send OTP')).tap();
    await waitFor(element(by.id('otp_input'))).toBeVisible();
    
    await element(by.id('otp_input')).typeText('123456');
    await waitFor(element(by.text('Home'))).toBeVisible();
    
    // Select locations
    await element(by.text('Pickup Location')).tap();
    await element(by.id('location_search')).typeText('Ahmedabad Station');
    await element(by.text('Confirm')).tap();
    
    // Continue with flow...
    
    // Assert
    await expect(element(by.text('Finding Driver'))).toBeVisible();
  });
});
```

---

## 6. Performance Testing

### 6.1 Load Testing (Artillery/K6)

**Scenarios to Test:**

#### Scenario 1: Order Creation Load
```yaml
# artillery-load-test.yml
config:
  target: 'https://api.sendit.co'
  phases:
    - duration: 60
      arrivalRate: 10  # 10 users/sec
      name: Warm up
    - duration: 120
      arrivalRate: 50  # 50 users/sec
      name: Sustained load
    - duration: 60
      arrivalRate: 100 # 100 users/sec
      name: Spike

scenarios:
  - name: Create Order
    flow:
      - post:
          url: '/api/v1/auth/send-otp'
          json:
            phone: '{{ $randomString() }}'
      - post:
          url: '/api/v1/orders/estimate'
          headers:
            Authorization: 'Bearer {{ token }}'
          json:
            pickup_lat: 23.0225
            pickup_lng: 72.5714
            drop_lat: 23.0395
            drop_lng: 72.5661
            vehicle_type: '2_wheeler'
```

Run: `artillery run artillery-load-test.yml`

#### Scenario 2: Real-time Updates (Socket.io)
- 1000 concurrent connections
- Location updates every 5 seconds
- Measure latency and throughput

**Performance Benchmarks:**

| Metric | Target | Acceptable |
|--------|--------|------------|
| **API Response Time** | < 200ms (p95) | < 500ms |
| **Order Creation** | < 1s | < 2s |
| **Driver Matching** | < 5s | < 10s |
| **Database Queries** | < 100ms | < 200ms |
| **Socket Latency** | < 100ms | < 300ms |

### 6.2 Stress Testing

```typescript
// k6-stress-test.js
import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
  stages: [
    { duration: '2m', target: 100 },   // Ramp up
    { duration: '5m', target: 100 },   // Stay at 100 users
    { duration: '2m', target: 500 },   // Spike to 500
    { duration: '5m', target: 500 },   // Stay at 500
    { duration: '2m', target: 0 },     // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'], // 95% < 500ms
    http_req_failed: ['rate<0.01'],    // < 1% failures
  },
};

export default function () {
  let response = http.post('https://api.sendit.co/api/v1/orders/estimate', {
    pickup_lat: 23.0225,
    pickup_lng: 72.5714,
    drop_lat: 23.0395,
    drop_lng: 72.5661,
    vehicle_type: '2_wheeler',
  });
  
  check(response, {
    'status is 200': (r) => r.status === 200,
    'response time < 500ms': (r) => r.timings.duration < 500,
  });
  
  sleep(1);
}
```

---

## 7. Security Testing

### 7.1 OWASP Top 10 Checklist

- [ ] **SQL Injection:** Parameterized queries, ORM
- [ ] **XSS:** Input sanitization, CSP headers
- [ ] **Broken Authentication:** JWT, session management
- [ ] **Sensitive Data Exposure:** Encryption (TLS, at-rest)
- [ ] **XML External Entities:** N/A (JSON API)
- [ ] **Broken Access Control:** RBAC, authorization checks
- [ ] **Security Misconfiguration:** Helmet.js, CORS
- [ ] **Insecure Deserialization:** Input validation
- [ ] **Using Components with Known Vulnerabilities:** `npm audit`
- [ ] **Insufficient Logging & Monitoring:** Winston, Sentry

### 7.2 Penetration Testing

**Tools:**
- OWASP ZAP
- Burp Suite
- nmap, sqlmap

**Tests:**
- API endpoint fuzzing
- JWT token manipulation
- Rate limiting bypass attempts
- IDOR (Insecure Direct Object Reference)
- CSRF protection
- File upload vulnerabilities

### 7.3 Security Audit Commands

```bash
# Check dependencies for vulnerabilities
npm audit
npm audit fix

# Static code analysis
npm install -g eslint-plugin-security
eslint --ext .ts src/

# Check for secrets in code
npm install -g git-secrets
git secrets --scan
```

---

## 8. Manual Testing Checklist

### 8.1 User App

**Authentication:**
- [ ] Phone OTP login
- [ ] OTP resend (60s cooldown)
- [ ] Invalid OTP error
- [ ] Profile setup (new users)
- [ ] Logout

**Booking Flow:**
- [ ] Location selection (search, current location, saved)
- [ ] Multiple stops
- [ ] Vehicle selection (all types)
- [ ] Scheduled pickup
- [ ] Coupon validation
- [ ] Wallet payment
- [ ] Card payment
- [ ] Cash payment
- [ ] Order creation

**Active Order:**
- [ ] Driver assignment notification
- [ ] Live tracking
- [ ] Driver info (call, chat)
- [ ] Status updates
- [ ] Order cancellation
- [ ] Rating & feedback

**Other Features:**
- [ ] Order history
- [ ] Wallet (add money, transactions)
- [ ] Saved addresses
- [ ] Referral program
- [ ] Notifications
- [ ] Help & support

### 8.2 Pilot App

**Registration:**
- [ ] Phone OTP login
- [ ] Personal details
- [ ] Vehicle details
- [ ] Document upload
- [ ] Bank details
- [ ] Verification status

**Job Management:**
- [ ] Online/offline toggle
- [ ] Incoming job notification
- [ ] Job acceptance
- [ ] Navigation to pickup
- [ ] Package collection (photo)
- [ ] Navigation to drop
- [ ] Delivery completion (photo)
- [ ] COD collection

**Earnings:**
- [ ] Wallet balance
- [ ] Transaction history
- [ ] Withdrawal request
- [ ] Earnings dashboard

### 8.3 Admin Dashboard

- [ ] Admin login (email/password)
- [ ] User management (list, view, suspend)
- [ ] Pilot verification workflow
- [ ] Order monitoring (real-time board)
- [ ] Pricing configuration
- [ ] Coupon management
- [ ] Analytics dashboards
- [ ] Support tickets

---

## 9. Test Data Management

### 9.1 Test Users

```json
{
  "test_users": [
    {
      "phone": "+919900000001",
      "otp": "111111",
      "name": "Test User 1",
      "role": "user"
    },
    {
      "phone": "+919900000002",
      "otp": "222222",
      "name": "Test Pilot 1",
      "role": "pilot"
    }
  ]
}
```

### 9.2 Seed Data Script

```typescript
// scripts/seed-test-data.ts
async function seedTestData() {
  // Create test users
  await createTestUsers();
  
  // Create test pilots
  await createTestPilots();
  
  // Create pricing data
  await seedVehiclePricing();
  
  // Create test coupons
  await createTestCoupons();
  
  console.log('Test data seeded successfully');
}
```

---

## 10. CI/CD Testing Pipeline

```yaml
# .github/workflows/test.yml
name: Test Suite

on: [push, pull_request]

jobs:
  backend-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Setup Node
        uses: actions/setup-node@v2
        with:
          node-version: '18'
      - name: Install dependencies
        run: npm install
      - name: Run unit tests
        run: npm run test:unit
      - name: Run integration tests
        run: npm run test:integration
      - name: Upload coverage
        uses: codecov/codecov-action@v2
  
  mobile-tests:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v2
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
      - name: Run tests
        run: flutter test
      - name: Run integration tests
        run: flutter drive --target=test_driver/app.dart
```

---

## 11. Bug Reporting Template

```markdown
## Bug Report

**Title:** [Brief description]

**Environment:**
- Platform: [iOS/Android/Web/Backend]
- Version: [App/API version]
- Device: [iPhone 14, Pixel 7, etc.]

**Steps to Reproduce:**
1. Step 1
2. Step 2
3. Step 3

**Expected Behavior:**
[What should happen]

**Actual Behavior:**
[What actually happens]

**Screenshots/Videos:**
[If applicable]

**Logs:**
```
[Error logs if available]
```

**Priority:** [P0-Critical / P1-High / P2-Medium / P3-Low]
```

---

## 12. Test Execution Schedule

### Phase 1 (MVP):
- Week 1-8: Unit tests during development
- Week 9: Integration testing
- Week 10: E2E + manual testing
- Before launch: Security audit

### Phase 2:
- Regression testing (all Phase 1 tests)
- New feature tests
- Performance testing

### Ongoing:
- Daily: Unit tests (CI/CD)
- Weekly: Integration tests
- Monthly: Performance + security tests
- Quarterly: Full regression + penetration testing

---

**Document Version:** 1.0  
**Last Updated:** 2026-01-29  
**Status:** Ready for Implementation
