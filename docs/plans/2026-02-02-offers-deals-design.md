# Offers & Deals Feature Design

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Display dynamic promotional offers in the user app, sourced from the existing coupon system, with full admin management capabilities.

**Architecture:** Leverage existing backend coupon API. User app fetches available coupons and auto-generates attractive banners. Admin panel gets a dedicated Coupons page for CRUD operations.

**Tech Stack:** Flutter (user app), Next.js + shadcn/ui (admin), Express + Prisma (backend - existing)

---

## Architecture Overview

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Admin Panel │────▶│   Backend   │◀────│   User App  │
│  (Next.js)  │     │  (Express)  │     │  (Flutter)  │
└─────────────┘     └─────────────┘     └─────────────┘
      │                    │                    │
      ▼                    ▼                    ▼
 Create/Edit          PostgreSQL          Fetch & Display
  Coupons              (Prisma)            Offer Banners
```

**What exists:**
- Backend coupon API (CRUD + validate + available)
- Prisma Coupon model with all required fields
- Coupon validation logic

**What to build:**

| Component | Scope |
|-----------|-------|
| Admin Panel | New `/coupons` page with table, create/edit dialogs, usage stats |
| User App | Coupon repository, controller integration, dynamic banners, details bottom sheet |
| Backend | Add stats endpoint, add API methods to admin client |

**No database migrations required.**

---

## User App Implementation

### Files to Create/Modify

| File | Purpose |
|------|---------|
| `lib/app/data/models/coupon_model.dart` | Coupon data model |
| `lib/app/data/repositories/coupon_repository.dart` | API calls for coupons |
| `lib/app/modules/home/controllers/home_controller.dart` | Add coupon fetching |
| `lib/app/modules/home/views/main_view.dart` | Replace hardcoded offers with dynamic |
| `lib/app/modules/home/widgets/offer_details_sheet.dart` | Bottom sheet for offer details |
| `lib/app/core/constants/api_constants.dart` | Add coupon endpoints |

### Auto-Generated Banner Logic

```dart
// Title generation based on discount type
String get bannerTitle {
  if (discountType == DiscountType.percentage) {
    return '${discountValue.toInt()}% OFF';
  } else {
    return '₹${discountValue.toInt()} OFF';
  }
}

// Subtitle from description or min order
String get bannerSubtitle {
  if (description != null && description!.isNotEmpty) {
    return description!;
  }
  if (minOrderAmount != null && minOrderAmount! > 0) {
    return 'Min order ₹${minOrderAmount!.toInt()}';
  }
  return 'Limited time offer';
}

// Gradient colors - rotate through preset palette
static const List<List<Color>> gradientPalette = [
  [Color(0xFF667eea), Color(0xFF764ba2)], // Purple
  [Color(0xFFf093fb), Color(0xFFf5576c)], // Pink
  [Color(0xFF4facfe), Color(0xFF00f2fe)], // Blue
  [Color(0xFF43e97b), Color(0xFF38f9d7)], // Green
  [Color(0xFFfa709a), Color(0xFFfee140)], // Orange
];

List<Color> getBannerGradient(int index) {
  return gradientPalette[index % gradientPalette.length];
}

// Icon based on discount type or conditions
IconData get bannerIcon {
  if (discountType == DiscountType.percentage) {
    return Icons.percent;
  }
  return Icons.local_offer;
}
```

### Bottom Sheet Contents

- Offer title with discount badge
- Full description/terms
- Minimum order amount (if applicable)
- Maximum discount cap (if applicable)
- Valid until date (if set)
- Promo code display with copy button
- "Use Now" button → navigates to booking screen with code pre-filled

### Coupon Model

```dart
class CouponModel {
  final String id;
  final String code;
  final String? description;
  final DiscountType discountType;
  final double discountValue;
  final double? minOrderAmount;
  final double? maxDiscount;
  final DateTime? expiresAt;
  final bool isActive;
}

enum DiscountType { percentage, fixed }
```

---

## Admin Panel Implementation

### Files to Create/Modify

| File | Purpose |
|------|---------|
| `admin/src/app/coupons/page.tsx` | Main coupons management page |
| `admin/src/lib/api.ts` | Add coupon API methods |
| `admin/src/types/index.ts` | Add Coupon type definitions |
| `admin/src/components/layout/admin-layout.tsx` | Add Coupons to sidebar |

### Coupons Page Features

| Feature | Description |
|---------|-------------|
| Stats Cards | Total coupons, active coupons, total redemptions, total discount given |
| Table View | Code, discount, usage (count/limit), status, expiry, actions |
| Search & Filter | Search by code, filter by status (active/expired/all) |
| Create Dialog | Form with all coupon fields, Zod validation |
| Edit Dialog | Pre-filled form, same fields |
| Delete | Confirmation dialog, soft-delete (set isActive=false) |

### Table Columns

| Code | Discount | Usage | Min Order | Expires | Status | Actions |
|------|----------|-------|-----------|---------|--------|---------|
| FIRST50 | 50% | 12/100 | ₹200 | 2024-03-01 | Active | ••• |
| FLAT100 | ₹100 | 5/50 | ₹500 | - | Active | ••• |

### Create/Edit Form Fields

- Code (required, uppercase)
- Description (optional)
- Discount Type (PERCENTAGE / FIXED dropdown)
- Discount Value (required, number)
- Minimum Order Amount (optional, number)
- Maximum Discount (optional, for percentage type)
- Usage Limit (optional, total uses)
- Per User Limit (default: 1)
- Start Date (default: now)
- Expiry Date (optional)
- Active Status (toggle)

### Sidebar Navigation

Add "Coupons" with `Ticket` icon from lucide-react, positioned between "Bookings" and "Wallet".

---

## Backend Implementation

### Existing Endpoints (No Changes Needed)

| Endpoint | Method | Auth | Purpose |
|----------|--------|------|---------|
| `GET /coupons/available` | GET | User | Fetch available coupons |
| `POST /coupons/validate` | POST | User | Validate code & calculate discount |
| `GET /coupons` | GET | Admin | List all coupons with pagination |
| `GET /coupons/:id` | GET | Admin | Get coupon details |
| `POST /coupons` | POST | Admin | Create coupon |
| `PUT /coupons/:id` | PUT | Admin | Update coupon |
| `DELETE /coupons/:id` | DELETE | Admin | Delete coupon |

### New Endpoint: Coupon Stats

```typescript
// GET /admin/coupons/stats
// Response:
{
  success: true,
  data: {
    totalCoupons: number,
    activeCoupons: number,
    totalRedemptions: number,
    totalDiscountGiven: number
  }
}
```

### Admin API Client Additions

```typescript
// In admin/src/lib/api.ts
coupons: {
  list: (params?) => api.get('/coupons', { params }),
  get: (id: string) => api.get(`/coupons/${id}`),
  create: (data: CreateCouponDto) => api.post('/coupons', data),
  update: (id: string, data: UpdateCouponDto) => api.put(`/coupons/${id}`, data),
  delete: (id: string) => api.delete(`/coupons/${id}`),
  getStats: () => api.get('/admin/coupons/stats'),
}
```

---

## Implementation Order

1. **Backend** - Add stats endpoint (15 min)
2. **Admin Panel** - Add API methods, types, sidebar link (30 min)
3. **Admin Panel** - Create Coupons page with full CRUD (2-3 hours)
4. **User App** - Create coupon model and repository (30 min)
5. **User App** - Integrate with home controller (30 min)
6. **User App** - Replace hardcoded banners with dynamic (30 min)
7. **User App** - Create offer details bottom sheet (1 hour)
8. **Testing** - End-to-end flow testing (30 min)

---

## Success Criteria

- [ ] Admin can create, edit, delete coupons from admin panel
- [ ] Admin can see coupon usage statistics
- [ ] User app displays available coupons as offer banners
- [ ] Banners auto-generate title/subtitle/colors from coupon data
- [ ] Tapping banner shows details bottom sheet
- [ ] User can copy promo code from bottom sheet
- [ ] "Use Now" navigates to booking with code pre-applied
- [ ] Expired/inactive coupons don't appear in user app
