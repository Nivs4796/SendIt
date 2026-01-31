# Booking Details Page with Live Tracking

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Convert booking "View Details" from dialog to full page with live map tracking of pilot and route.

**Architecture:** Next.js dynamic route `/bookings/[id]` with Leaflet map, Socket.io real-time updates, and glassmorphism styling.

**Tech Stack:** Next.js 16, React 19, Leaflet, react-leaflet, Socket.io-client, TanStack Query

---

## Task 1: Install Leaflet Dependencies

**Files:**
- Modify: `admin/package.json`

**Steps:**
1. Install leaflet and react-leaflet packages
2. Install types for TypeScript support

```bash
cd admin && npm install leaflet react-leaflet && npm install -D @types/leaflet
```

---

## Task 2: Create Booking Details Page Structure

**Files:**
- Create: `admin/src/app/bookings/[id]/page.tsx`

**Implementation:**
- Dynamic route for booking details
- Fetch booking data using React Query
- Display booking information in glass cards
- Include map component placeholder
- Add back button to return to bookings list

---

## Task 3: Create Map Component for Tracking

**Files:**
- Create: `admin/src/components/booking/tracking-map.tsx`

**Implementation:**
- Leaflet map with OpenStreetMap tiles
- Custom markers for pickup (green), dropoff (red), pilot (blue)
- Polyline for route between pickup and dropoff
- Auto-fit bounds to show all markers
- Real-time pilot location update support

---

## Task 4: Create Booking Info Cards Component

**Files:**
- Create: `admin/src/components/booking/booking-info.tsx`

**Implementation:**
- Glass-styled info cards for:
  - Booking status and ID
  - Pickup/Dropoff addresses
  - Distance, duration, pricing
  - Payment details
  - Customer information
  - Pilot information (if assigned)
- Status badge with colors
- Timeline of booking events

---

## Task 5: Add Admin Booking Tracking Socket Support

**Files:**
- Modify: `admin/src/lib/socket.tsx`

**Implementation:**
- Add `booking:location` event listener for pilot location updates
- Add method to subscribe to specific booking tracking
- Add method to unsubscribe from booking tracking

---

## Task 6: Update Bookings List to Link to Details Page

**Files:**
- Modify: `admin/src/app/bookings/page.tsx`

**Implementation:**
- Change "View Details" from opening dialog to navigating to `/bookings/[id]`
- Remove or simplify the view dialog (keep cancel and assign dialogs)

---

## Task 7: Add Backend Support for Admin Booking Tracking

**Files:**
- Modify: `backend/src/socket/handlers/admin.handler.ts`

**Implementation:**
- Add `admin:booking:subscribe` event to join booking room
- Add `admin:booking:unsubscribe` event to leave booking room
- Broadcast pilot location to admin subscribers

---

## Task 8: Build and Test

**Steps:**
1. Build admin app
2. Test booking details page navigation
3. Verify map displays correctly
4. Test real-time location updates (if pilot available)

---

## UI Design Notes

**Page Layout:**
```
+------------------------------------------+
| ← Back to Bookings    Booking #abc123    |
+------------------------------------------+
|                                          |
|  +------------------+  +---------------+ |
|  |                  |  | Status Card   | |
|  |      MAP         |  +---------------+ |
|  |   (Live Track)   |  | Address Card  | |
|  |                  |  +---------------+ |
|  +------------------+  | Pricing Card  | |
|                        +---------------+ |
|  +------------------+  | Customer Card | |
|  | Pilot Info Card  |  +---------------+ |
|  +------------------+  | Actions       | |
+------------------------------------------+
```

**Map Features:**
- Green marker: Pickup location
- Red marker: Dropoff location
- Blue marker: Pilot current location (animated pulse)
- Dashed line: Route from pickup to dropoff
- Auto-center on pilot when tracking active
