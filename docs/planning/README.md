# SendIt Platform - Quick Reference Guide

## 📁 Planning Documents Index

### Core Planning
1. **[implementation_plan.md](/.gemini/antigravity/brain/66914c4c-548c-4ba6-8896-69de219f6903/implementation_plan.md)** - High-level technical strategy
2. **[task.md](/.gemini/antigravity/brain/66914c4c-548c-4ba6-8896-69de219f6903/task.md)** - Overall task breakdown

### Module-Specific Planning
3. **[backend-api-plan.md](backend-api-plan.md)** - Database schema, API endpoints, real-time features
4. **[user-app-plan.md](user-app-plan.md)** - User mobile app (screens, flows, components)
5. **[pilot-app-plan.md](pilot-app-plan.md)** - Pilot mobile app (registration, jobs, earnings)
6. **[admin-dashboard-plan.md](admin-dashboard-plan.md)** - Admin web dashboard (management, analytics)
7. **[website-plan.md](website-plan.md)** - Marketing website (SEO, pages, lead gen)

### Roadmap
8. **[phase-roadmap.md](phase-roadmap.md)** - Week-by-week implementation plan

### Development Standards
9. **[RULES.md](../RULES.md)** - Universal coding standards, naming conventions, security protocols
10. **[skill-agents/](../skill-agents/)** - Platform expert profiles with best practices
11. **[SUPERPOWERS_GUIDE.md](../SUPERPOWERS_GUIDE.md)** - Claude Code Superpowers workflow guide
12. **[START_IMPLEMENTATION.md](../START_IMPLEMENTATION.md)** - Step-by-step setup commands

---

## 🏗️ Technology Stack

| Component | Technology |
|-----------|------------|
| **Mobile Apps** | Flutter + Dart |
| **Backend API** | Node.js + Express + TypeScript |
| **Database** | PostgreSQL + Redis |
| **Admin Dashboard** | Next.js + Tailwind CSS |
| **Website** | Next.js + Tailwind CSS |
| **Real-time** | Socket.io |
| **Maps** | Google Maps API |
| **Payments** | Razorpay |
| **SMS** | MSG91 / Twilio |
| **Notifications** | Firebase Cloud Messaging |

---

## 🗄️ Core Database Tables

1. **users** - Customer accounts
2. **pilots** - Delivery partner accounts
3. **vehicles** - Pilot vehicles with documents
4. **vehicle_pricing** - Pricing by vehicle type
5. **orders** - All delivery orders
6. **addresses** - Saved user addresses
7. **transactions** - Financial transactions
8. **referrals** - Referral tracking
9. **reward_points** - Points system
10. **coupons** - Discount coupons
11. **coupon_usage** - Coupon redemptions
12. **notifications** - In-app notifications

---

## 🔌 Key API Endpoints

### Authentication
- `POST /api/v1/auth/send-otp` - Send OTP
- `POST /api/v1/auth/verify-otp` - Verify OTP & login

### Orders (User)
- `POST /api/v1/orders/estimate` - Get price estimate
- `POST /api/v1/orders` - Create order
- `GET /api/v1/orders` - List orders
- `GET /api/v1/orders/:id` - Order details
- `PUT /api/v1/orders/:id/cancel` - Cancel order

### Jobs (Pilot)
- `PUT /api/v1/pilots/online-status` - Go online/offline
- `PUT /api/v1/pilots/location` - Update location
- `GET /api/v1/pilots/jobs/available` - Get available jobs
- `PUT /api/v1/pilots/jobs/:id/accept` - Accept job
- `PUT /api/v1/pilots/jobs/:id/status` - Update job status

### Admin
- `GET /api/v1/admin/users` - List users
- `GET /api/v1/admin/pilots` - List pilots
- `PUT /api/v1/admin/pilots/:id/verify` - Verify pilot
- `GET /api/v1/admin/orders` - List orders
- `GET /api/v1/admin/analytics` - Analytics data

---

## 📱 User App - Key Screens

### Onboarding & Auth
1. Splash Screen
2. Phone Login
3. OTP Verification
4. Profile Setup

### Booking Flow
5. Home Screen
6. Pickup Location Selection
7. Drop Location Selection
8. Vehicle Selection
9. Review Booking
10. Finding Driver
11. Order Tracking
12. Delivery Complete

### Other Screens
13. Orders List
14. Order Details
15. Wallet
16. Add Money
17. Profile
18. Referral Program
19. Saved Addresses
20. Notifications

---

## 🚗 Pilot App - Key Screens

### Registration
1. Welcome
2. Phone Login
3. Registration Form (Personal, Vehicle, Documents, Bank)
4. Verification Pending

### Job Management
5. Dashboard (Online/Offline)
6. Incoming Job Request (Popup)
7. Active Job Screen
8. Job Completion

### Earnings & Profile
9. My Wallet
10. Earnings Dashboard
11. My Vehicles
12. Rewards & Referrals
13. Profile & Settings
14. Bank Details
15. Documents

---

## 💼 Admin Dashboard - Key Modules

1. **Dashboard** - KPIs, charts, recent activity
2. **Users** - User management, details, wallet
3. **Pilots** - Pilot management, verification workflow
4. **Orders** - Order monitoring, details, disputes
5. **Pricing** - Vehicle pricing, surge rules
6. **Coupons** - Coupon management, analytics
7. **Analytics** - Revenue, orders, performance metrics
8. **Support** - Ticket management
9. **Notifications** - Send push/SMS/email
10. **Settings** - Platform configuration

---

## 🌐 Website - Key Pages

### Public Pages
1. Homepage (Hero, Services, How It Works, Download)
2. About Us
3. Services (Detailed)
4. Pricing (Calculator + Table)
5. Become a Pilot
6. Blog (Listing + Posts)
7. Contact

### Legal Pages
8. Terms & Conditions (User)
9. Terms & Conditions (Pilot)
10. Privacy Policy (User)
11. Privacy Policy (Pilot)
12. Refund & Cancellation Policy

---

## 🚀 Implementation Phases

### Phase 1: MVP (8-10 weeks)
- Basic booking and delivery flow
- Single vehicle type (2-wheeler)
- User & Pilot apps
- Admin dashboard basics
- Cash & online payment

**Goal:** Launch functional platform

### Phase 2: Extended Features (4-6 weeks)
- Multiple vehicle types
- Scheduled deliveries
- Wallet system
- Referral program
- Coupons

**Goal:** Feature parity with competitors

### Phase 3: Advanced Features (4-6 weeks)
- EV Cycle delivery
- Teenage pilot program
- Advanced analytics
- Business API
- Marketing website

**Goal:** Unique differentiators & scale

**Total Timeline:** 22 weeks (~5.5 months)

---

## 🎯 Success Metrics

### MVP (Week 10)
- 100+ users
- 50+ pilots
- 500+ orders
- < 1% crash rate
- > 4.0 rating

### Phase 2 (Week 16)
- 500+ users
- 200+ pilots
- 5,000+ orders
- 20% wallet adoption

### Phase 3 (Week 22)
- 2,000+ users
- 500+ pilots
- 20,000+ orders
- 10+ API partners
- Profitability

---

## 🔥 Unique Features

1. **Multiple Vehicle Types** - Cycle to Trucks
2. **EV Cycle Delivery** - Eco-friendly option
3. **Teen Pilot Program** - Ages 16-18 with parental consent
4. **Scheduled Pickups** - Book in advance
5. **Multiple Stops** - Bulk deliveries
6. **Passenger Rides** - 2-wheeler & auto rides
7. **Photo Proof** - Pickup & delivery photos
8. **Wallet System** - Promotional credits
9. **Referral Rewards** - For users & pilots

---

## 📋 Development Checklist Quick Links

**Backend:** [backend-api-plan.md#development-checklist](backend-api-plan.md)  
**User App:** [user-app-plan.md#development-checklist](user-app-plan.md)  
**Pilot App:** [pilot-app-plan.md#development-checklist](pilot-app-plan.md)  
**Admin:** [admin-dashboard-plan.md#development-checklist](admin-dashboard-plan.md)  
**Website:** [website-plan.md#development-checklist](website-plan.md)  
**Roadmap:** [phase-roadmap.md](phase-roadmap.md)

---

## 👥 Recommended Team (MVP)

- 1 Backend Developer (Node.js, APIs)
- 1 Mobile Developer (React Native)
- 1 Full-Stack Developer (Admin + support)
- 1 QA Engineer
- 1 DevOps Engineer (Part-time)
- 1 UI/UX Designer (Part-time)

---

## 🔐 Security Checklist

- [ ] JWT authentication with refresh tokens
- [ ] HTTPS/TLS everywhere
- [ ] Input validation (all endpoints)
- [ ] SQL injection prevention
- [ ] XSS protection
- [ ] Rate limiting
- [ ] CORS configuration
- [ ] PCI DSS compliance (payments)
- [ ] Data encryption at rest
- [ ] Audit logs
- [ ] Role-based access control
- [ ] 2FA for admin (optional)

---

## 📞 Contact & Support

**Email:** support@drop-it.co  
**Phone:** +91 94847 07535  
**Operating Hours:** 8:00 AM - 10:00 PM IST

---

**Document Version:** 1.0  
**Last Updated:** 2026-01-29  
**Status:** Ready for review and implementation

---

## Getting Started

To begin implementation:

1. ✅ **Review** all planning documents
2. ✅ **Approve** the high-level implementation plan
3. **Setup** development environment
4. **Start** with Phase 1 - Week 1 tasks (Backend setup)
5. **Follow** the [phase-roadmap.md](phase-roadmap.md) week-by-week

**Next Steps:** Review implementation_plan.md and provide feedback before proceeding to execution phase.
