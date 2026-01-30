# Admin Dashboard - Detailed Planning Document

## 1. Overview

The Admin Dashboard is a web-based control panel for managing the entire SendIt platform - users, pilots, orders, pricing, analytics, and system configuration.

**Platform:** Next.js 14+ (React) Web Application

## 2. Technology Stack

### Frontend
- **Framework:** Next.js 14+ (App Router)
- **Language:** TypeScript
- **UI Library:** Shadcn UI + Tailwind CSS
- **State Management:** React Context + TanStack Query
- **Forms:** React Hook Form + Zod validation
- **Tables:** TanStack Table
- **Charts:** Recharts
- **Maps:** Google Maps React

### Authentication
- NextAuth.js with JWT
- Role-based access control

## 3. User Roles

**Super Admin:** Full access  
**Admin:** User, pilot, order management  
**Support:** View-only with ticket handling

## 4. Key Modules

### 4.1 Dashboard Home (`/dashboard`)

**KPI Cards:**
- Total Users (with trend)
- Active Pilots (online count)
- Today's Orders (completed, in-progress, cancelled)
- Today's Revenue (with commission)

**Charts:**
- Order Volume Trend (30 days)
- Revenue Analytics
- Vehicle Distribution

**Quick Actions:**
- Verify pending pilots
- Resolve disputes
- Create coupon

### 4.2 User Management (`/dashboard/users`)

**Users Table Columns:**
- ID, Name, Phone, Email
- Registration Date
- Total Orders
- Wallet Balance
- Status (Active/Suspended)
- Actions

**Filters:**
- Status, Registration date, Wallet balance range

**User Details Page (`/dashboard/users/[id]`):**

**Tabs:**
1. **Profile** - Personal info, edit option
2. **Orders** - Order history
3. **Wallet** - Balance, transactions, manual adjustments
4. **Addresses** - Saved addresses with map
5. **Referrals** - Code, referred users, rewards
6. **Activity Log** - Login history, app usage

**API:**
```typescript
GET /api/v1/admin/users?page=1&limit=20&status=active&search=
GET /api/v1/admin/users/:id
PUT /api/v1/admin/users/:id/suspend
PUT /api/v1/admin/users/:id/wallet/adjust
```

### 4.3 Pilot Management (`/dashboard/pilots`)

**Status Tabs:**
- All, Pending Verification, Verified, Rejected, Suspended

**Pilots Table Columns:**
- ID, Name, Phone, Vehicle Type
- Verification Status, Documents Status
- Total Rides, Rating, Earnings
- Online Status, Actions

**Pilot Details Page (`/dashboard/pilots/[id]`):**

**Tabs:**
1. **Profile** - Personal details
2. **Verification** - Document review, approve/reject workflow
3. **Vehicles** - List of vehicles, documents per vehicle
4. **Performance** - Rides, ratings, revenue chart
5. **Earnings** - Total earnings, wallet, withdrawal requests
6. **Orders** - Order history

**Verification Workflow:**
- Review documents (preview, download)
- Approve all / Reject with reason
- Request re-upload
- Background check integration

**API:**
```typescript
GET /api/v1/admin/pilots?status=pending&page=1
PUT /api/v1/admin/pilots/:id/verify
{
  status: "approved",
  rejection_reason: "",
  documents: {...}
}
```

### 4.4 Order Management (`/dashboard/orders`)

**Real-Time Board View:**
- Columns by status (Pending, Assigned, In Transit, Delivered, Cancelled)
- Live updates via WebSocket

**Table View:**
- Order ID, User, Pilot, Route, Vehicle Type, Amount, Status, Date
- Filters: Date range, Status, Vehicle type, Payment method

**Order Details Page (`/dashboard/orders/[id]`):**
- Status timeline
- Map with route
- Pricing breakdown
- Payment info
- Photos (pickup/delivery)
- Actions: Cancel, Refund, Reassign driver

**Dispute Resolution:**
- Issue description
- Evidence
- Resolution options: Refund, Pay pilot, Partial refund, Close

**API:**
```typescript
GET /api/v1/admin/orders?status=active&date_from=&date_to=
PUT /api/v1/admin/orders/:id/cancel
POST /api/v1/admin/orders/:id/refund
```

### 4.5 Pricing Configuration (`/dashboard/pricing`)

**Vehicle Pricing Table:**
- Vehicle Type, Category, Base Fare, Per KM Rate
- Max Weight, Max Distance, Surge Multiplier
- Status, Actions

**Surge Pricing Rules:**
- Time-based (day, time range, multiplier)
- Demand-based (volume threshold)
- Geographic (area, multiplier)

**Tax & Commission:**
- CGST/SGST rates
- Platform commission %

**API:**
```typescript
GET /api/v1/admin/pricing
POST /api/v1/admin/pricing
PUT /api/v1/admin/pricing/:id
```

### 4.6 Coupon Management (`/dashboard/coupons`)

**Coupon Form:**
- Code, Description
- Discount type (Percentage/Fixed), Value
- Min order value, Max discount
- Usage limits (total, per user)
- Valid from/until dates
- Applicable vehicle types, user types
- Active status

**Coupon Analytics:**
- Total redemptions, Discount given, Revenue impact

**API:**
```typescript
GET /api/v1/admin/coupons
POST /api/v1/admin/coupons
PUT /api/v1/admin/coupons/:id
```

### 4.7 Analytics (`/dashboard/analytics`)

**Metrics:**
- Total Orders, Revenue, Commission
- Active Users/Pilots
- AOV, Cancellation Rate, Satisfaction

**Charts:**
1. Revenue Trend (line chart)
2. Order Volume (bar chart)
3. Vehicle Distribution (pie chart)
4. Geographic Heat Map
5. Peak Hours Heatmap
6. User Acquisition Funnel
7. Pilot Performance
8. Payment Methods Distribution

**Export:** PDF, Excel, Scheduled reports

**API:**
```typescript
GET /api/v1/admin/analytics?metric=revenue&from=&to=
```

### 4.8 Support (`/dashboard/support`)

**Ticket Table:**
- Ticket ID, User/Pilot, Category, Subject
- Status, Priority, Created Date, Assigned To

**Ticket Details:**
- Conversation thread
- Related order
- Attachments
- Status/assignment history
- Internal notes

**Actions:**
- Reply, Change status, Assign, Escalate, Close
- Canned responses

### 4.9 Notifications (`/dashboard/notifications`)

**Send Notification:**
- Target: All users, All pilots, Specific, Segment
- Type: Push, SMS, Email
- Title, Message, Link
- Schedule (now/later)

**History:**
- Past notifications
- Delivery stats (sent, delivered, opened)

### 4.10 Settings (`/dashboard/settings`)

**Tabs:**
1. **General** - Platform name, contact, operating hours, service areas
2. **Commission** - Rates, payment split, payout schedule
3. **Feature Flags** - Enable/disable features
4. **Payment Gateway** - API keys, webhooks
5. **Maps & Location** - Google Maps API, default location
6. **SMS & Email** - Gateway config, templates
7. **Admin Users** - Manage admin accounts, roles
8. **Backup & Logs** - Database backup, system logs

## 5. Real-Time Features

### WebSocket Integration
```typescript
socket.on('order:created', (order) => {
  queryClient.invalidateQueries(['orders']);
});

socket.on('order:status_changed', (order) => {
  // Update order board
});

socket.on('pilot:online', (pilot) => {
  // Update pilot count
});
```

## 6. Security

- NextAuth with JWT
- Role-based access control
- Session timeout (30 min)
- Audit logs for all actions
- IP whitelisting (optional)

## 7. Development Checklist

### Phase 1: Setup & Auth
- [ ] Initialize Next.js + TypeScript
- [ ] Setup Tailwind + Shadcn UI
- [ ] Configure NextAuth
- [ ] Login page + role-based routing

### Phase 2: Core Modules
- [ ] Dashboard with KPIs
- [ ] User management
- [ ] Pilot management + verification
- [ ] Order management

### Phase 3: Configuration
- [ ] Pricing configuration
- [ ] Coupon management
- [ ] Settings pages

### Phase 4: Analytics & Support
- [ ] Analytics dashboard with charts
- [ ] Support ticket system
- [ ] Notification system

### Phase 5: Advanced
- [ ] Real-time updates (WebSocket)
- [ ] Report exports
- [ ] Audit logs
- [ ] Admin user management

---

**Document Version:** 1.0  
**Last Updated:** 2026-01-29
