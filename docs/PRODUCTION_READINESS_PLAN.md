# SendIt - Production Readiness Plan

**Created:** February 4, 2026  
**Author:** Buddy (AI Assistant)  
**Goal:** Complete all components for production deployment

---

## 📊 Current Status Overview

| Component | Progress | Status |
|-----------|----------|--------|
| **Backend API** | 75% | 🟡 Missing pilot-specific endpoints |
| **Database Schema** | 95% | 🟢 Almost complete |
| **Pilot App (Flutter)** | 85% | 🟡 UI done, needs backend integration |
| **User App (Flutter)** | 80% | 🟡 Core done, missing payments/push |
| **Admin Dashboard** | 90% | 🟢 Most features working |
| **Website** | 40% | 🔴 Basic scaffold only |

---

## 🔴 CRITICAL GAPS (Must Fix)

### 1. Backend - Missing Pilot Endpoints

**These endpoints are called by the Pilot App but DON'T EXIST in backend:**

```
# PILOT DOCUMENTS (Needed for registration & verification)
GET    /pilots/documents           - List pilot's uploaded documents
POST   /pilots/documents           - Upload new document (multipart)
PUT    /pilots/documents/:id       - Re-upload/update document
DELETE /pilots/documents/:id       - Delete document

# PILOT BANK ACCOUNTS (Needed for withdrawals)
GET    /pilots/bank-accounts       - List pilot's bank accounts
POST   /pilots/bank-accounts       - Add new bank account
DELETE /pilots/bank-accounts/:id   - Delete bank account
PATCH  /pilots/bank-accounts/:id/primary - Set as primary account

# PILOT WALLET (Separate from User wallet)
GET    /wallet/pilot/balance       - Get pilot wallet balance
GET    /wallet/pilot/transactions  - Get pilot transaction history
POST   /wallet/pilot/withdraw      - Request withdrawal to bank

# PILOT NOTIFICATIONS
GET    /pilots/notifications       - List pilot notifications
PATCH  /pilots/notifications/:id/read - Mark notification as read
PATCH  /pilots/notifications/read-all - Mark all as read
DELETE /pilots/notifications/:id   - Delete notification
PATCH  /pilots/notification-settings - Update notification preferences

# REWARDS & REFERRALS
GET    /pilots/referral           - Get pilot's referral code & stats
GET    /pilots/rewards            - Get available rewards
POST   /pilots/rewards/:id/claim  - Claim a reward
GET    /pilots/achievements       - Get pilot achievements

# SUPPORT
GET    /support/faqs              - Get FAQ list
POST   /support/tickets           - Create support ticket
GET    /support/contact           - Get contact info

# JOB HISTORY (Enhanced)
GET    /pilots/bookings/history   - Get past jobs with filters
       Query params: status, dateFrom, dateTo, page, limit

# UTILITY
GET    /utils/ifsc                - IFSC code lookup (for bank)
```

**Priority: HIGH** - Pilot app crashes or shows errors without these

---

### 2. Backend - Schema Additions Needed

```prisma
# Add to schema.prisma:

# Multiple bank accounts per pilot (currently only 1)
model BankAccount {
  id            String    @id @default(cuid())
  pilotId       String    // Remove @unique to allow multiple
  accountName   String
  accountNumber String
  ifscCode      String
  bankName      String
  branchName    String?
  isPrimary     Boolean   @default(false)
  isVerified    Boolean   @default(false)
  createdAt     DateTime  @default(now())
  updatedAt     DateTime  @updatedAt

  pilot         Pilot     @relation(fields: [pilotId], references: [id])

  @@map("bank_accounts")
}

# Support Tickets
model SupportTicket {
  id          String    @id @default(cuid())
  pilotId     String?
  userId      String?
  subject     String
  description String
  category    String    // ACCOUNT, PAYMENT, TECHNICAL, OTHER
  status      String    @default("OPEN") // OPEN, IN_PROGRESS, RESOLVED, CLOSED
  priority    String    @default("MEDIUM") // LOW, MEDIUM, HIGH
  createdAt   DateTime  @default(now())
  updatedAt   DateTime  @updatedAt
  resolvedAt  DateTime?

  @@map("support_tickets")
}

# FAQs
model FAQ {
  id        String    @id @default(cuid())
  question  String
  answer    String
  category  String    // GENERAL, PAYMENT, DELIVERY, ACCOUNT
  order     Int       @default(0)
  isActive  Boolean   @default(true)
  createdAt DateTime  @default(now())
  updatedAt DateTime  @updatedAt

  @@map("faqs")
}

# Referrals
model Referral {
  id            String    @id @default(cuid())
  referrerId    String    // Pilot who referred
  referredId    String?   // Pilot who was referred
  referralCode  String    @unique
  status        String    @default("PENDING") // PENDING, COMPLETED, EXPIRED
  bonusAmount   Float     @default(0)
  completedAt   DateTime?
  createdAt     DateTime  @default(now())

  @@map("referrals")
}

# Achievements/Rewards
model Achievement {
  id          String    @id @default(cuid())
  name        String
  description String
  icon        String?
  requirement String    // JSON criteria
  reward      Float     @default(0)
  isActive    Boolean   @default(true)
  createdAt   DateTime  @default(now())

  @@map("achievements")
}

model PilotAchievement {
  id            String    @id @default(cuid())
  pilotId       String
  achievementId String
  earnedAt      DateTime  @default(now())
  claimed       Boolean   @default(false)
  claimedAt     DateTime?

  @@unique([pilotId, achievementId])
  @@map("pilot_achievements")
}
```

---

### 3. User App - Missing Features

| Feature | Priority | Est. Effort | Notes |
|---------|----------|-------------|-------|
| Razorpay Integration | **HIGH** | 2-3 days | Payment gateway |
| Push Notifications (FCM) | **HIGH** | 1-2 days | Order updates |
| Call Driver | MEDIUM | 0.5 day | phone_call package |
| Scheduled Pickups | MEDIUM | 1 day | Date/time picker |
| Order Rating/Review | MEDIUM | 1 day | Post-delivery |
| Referral Program | LOW | 1-2 days | Share & earn |

---

### 4. Pilot App - Backend Integration

| Module | Frontend Status | Backend Status | Gap |
|--------|-----------------|----------------|-----|
| Auth | ✅ Complete | ✅ Complete | None |
| Registration | ✅ Complete | ✅ Complete | None |
| Dashboard | ✅ Complete | ✅ Complete | None |
| Jobs | ✅ Complete | ✅ Complete | None |
| Active Job | ✅ Complete | ✅ Complete | None |
| Earnings | ✅ Complete | ✅ Complete | None |
| Wallet | ✅ Frontend | ❌ Missing | Need pilot wallet endpoints |
| Withdraw | ✅ Frontend | ❌ Missing | Need withdrawal endpoint |
| Documents | ✅ Frontend | ❌ Missing | Need CRUD endpoints |
| Bank | ✅ Frontend | ❌ Missing | Need bank account endpoints |
| History | ✅ Frontend | ⚠️ Partial | Need history filters |
| Notifications | ✅ Frontend | ❌ Missing | Need pilot notifications |
| Rewards | ✅ Frontend | ❌ Missing | Need rewards system |
| Support | ✅ Frontend | ❌ Missing | Need support endpoints |

---

## 🟡 IMPORTANT GAPS

### 5. Admin Dashboard - Missing Pages

| Feature | Status | Notes |
|---------|--------|-------|
| Support Tickets | ❌ Missing | View/respond to tickets |
| FAQs Management | ❌ Missing | CRUD for FAQs |
| Notifications Broadcast | ❌ Missing | Send to all users/pilots |
| Document Verification | ✅ Exists | In pilots section |
| Withdrawal Requests | ❌ Missing | Approve pilot withdrawals |

---

### 6. Security & Production Config

| Item | Status | Action Needed |
|------|--------|---------------|
| Environment Variables | ⚠️ Hardcoded | Move to .env files |
| API Rate Limiting | ✅ Exists | Review limits |
| Input Validation | ✅ Exists | Good |
| JWT Refresh | ✅ Exists | Good |
| CORS Config | ⚠️ Dev mode | Restrict origins |
| File Upload Limits | ⚠️ Review | 5MB reasonable? |
| Error Handling | ✅ Good | Good |
| Logging | ✅ Exists | Add production logger |

---

### 7. Testing Coverage

| Component | Unit Tests | E2E Tests |
|-----------|------------|-----------|
| Backend | ⚠️ Partial | ❌ None |
| User App | ❌ None | ❌ None |
| Pilot App | ❌ None | ❌ None |
| Admin | ❌ None | ❌ None |

---

## 📋 IMPLEMENTATION PLAN

### Phase 1: Backend Critical Endpoints (3-4 days)

**Day 1-2: Documents & Bank**
```
1. Create documents.routes.ts
   - GET /pilots/documents
   - POST /pilots/documents (with multer)
   - PUT /pilots/documents/:id
   - DELETE /pilots/documents/:id

2. Create bank.routes.ts  
   - GET /pilots/bank-accounts
   - POST /pilots/bank-accounts
   - DELETE /pilots/bank-accounts/:id
   - PATCH /pilots/bank-accounts/:id/primary

3. Add IFSC lookup utility
   - GET /utils/ifsc?code=XXX
```

**Day 2-3: Wallet & Notifications**
```
1. Extend wallet.routes.ts for pilots
   - GET /wallet/pilot/balance
   - GET /wallet/pilot/transactions
   - POST /wallet/pilot/withdraw

2. Create notifications.routes.ts
   - GET /pilots/notifications
   - PATCH /pilots/notifications/:id/read
   - PATCH /pilots/notifications/read-all
   - PATCH /pilots/notification-settings
```

**Day 3-4: Support & Rewards**
```
1. Create support.routes.ts
   - GET /support/faqs
   - POST /support/tickets
   - GET /support/contact

2. Create rewards.routes.ts
   - GET /pilots/referral
   - GET /pilots/rewards
   - POST /pilots/rewards/:id/claim
   - GET /pilots/achievements

3. Enhance booking history
   - Add filters to GET /pilots/bookings
```

---

### Phase 2: User App Completion (3-4 days)

**Day 1-2: Payment Integration**
```
1. Razorpay SDK integration
2. Payment flow UI updates
3. Payment verification callback
4. Refund handling
```

**Day 2-3: Push Notifications**
```
1. Firebase setup (iOS & Android)
2. FCM token registration
3. Background notification handling
4. Notification tap handling
```

**Day 3-4: Polish**
```
1. Call driver functionality
2. Order rating/review screen
3. Error handling improvements
4. Loading states refinement
```

---

### Phase 3: Pilot App Integration (2-3 days)

**Day 1-2: Connect to Real APIs**
```
1. Documents module → real API
2. Bank module → real API
3. Wallet/Withdraw → real API
4. Notifications → real API
```

**Day 2-3: Testing & Polish**
```
1. Rewards module → real API
2. Support module → real API
3. End-to-end flow testing
4. Bug fixes
```

---

### Phase 4: Admin Dashboard (2 days)

```
1. Support tickets management page
2. FAQ management page
3. Withdrawal approval page
4. Push notification broadcast
```

---

### Phase 5: Production Deployment (2-3 days)

```
1. Environment configuration
2. Database migration (prod)
3. SSL certificates
4. Domain setup
5. App store preparation
6. Final testing
```

---

## 📅 Timeline Summary

| Phase | Duration | Completion |
|-------|----------|------------|
| Phase 1: Backend Endpoints | 4 days | Day 4 |
| Phase 2: User App | 4 days | Day 8 |
| Phase 3: Pilot App | 3 days | Day 11 |
| Phase 4: Admin | 2 days | Day 13 |
| Phase 5: Deployment | 3 days | Day 16 |
| **Total** | **~16 days** | ~3 weeks |

---

## ✅ Success Criteria

### Pilot App
- [ ] Pilot can register with all documents
- [ ] Pilot can manage bank accounts
- [ ] Pilot can go online and receive jobs
- [ ] Pilot can complete deliveries with photo proof
- [ ] Pilot can view earnings and withdraw
- [ ] Pilot can view notifications
- [ ] Pilot can access help/support

### User App
- [ ] User can create booking with payment
- [ ] User receives real-time tracking
- [ ] User gets push notifications
- [ ] User can rate/review delivery
- [ ] User can manage wallet

### Admin
- [ ] Admin can verify pilots/documents
- [ ] Admin can manage bookings
- [ ] Admin can handle support tickets
- [ ] Admin can send notifications
- [ ] Admin can approve withdrawals

---

## 🚀 Recommended Next Steps

1. **Start with Backend** - Pilot app is blocked without these APIs
2. **Prioritize pilot wallet/bank** - Earnings is core to driver retention
3. **Then user payments** - Revenue depends on this
4. **Finally polish & deploy**

---

**Questions for Big Bro:**
1. Do you want to use Razorpay or another payment gateway?
2. Should withdrawals be auto-approved or need admin approval?
3. What's the minimum withdrawal amount?
4. Do you want Firebase or another push notification service?

---

*Last Updated: February 4, 2026*
