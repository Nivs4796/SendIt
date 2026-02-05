# SendIt System Architecture & Flow Documentation

> Complete technical documentation for the SendIt delivery platform covering User App, Pilot App, and Backend communication.

## Table of Contents

1. [System Overview](#system-overview)
2. [High-Level Architecture](#high-level-architecture)
3. [Technology Stack](#technology-stack)
4. [Complete Booking Flow](#complete-booking-flow)
5. [Socket Events Reference](#socket-events-reference)
6. [REST API Endpoints](#rest-api-endpoints)
7. [Assignment Queue Logic](#assignment-queue-logic)
8. [Data Models](#data-models)
9. [Status Flow](#status-flow)
10. [Error Handling](#error-handling)

---

## System Overview

SendIt is a delivery platform consisting of three main components:

| Component | Technology | Purpose |
|-----------|------------|---------|
| **User App** | Flutter/Dart | Customers create bookings, track deliveries |
| **Pilot App** | Flutter/Dart | Drivers receive jobs, update delivery status |
| **Backend** | Node.js/Express | API server, business logic, real-time communication |
| **Database** | PostgreSQL | Persistent data storage |

---

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              SENDIT SYSTEM ARCHITECTURE                          │
└─────────────────────────────────────────────────────────────────────────────────┘

    ┌──────────────┐                                         ┌──────────────┐
    │   USER APP   │                                         │  PILOT APP   │
    │   (Flutter)  │                                         │   (Flutter)  │
    └──────┬───────┘                                         └──────┬───────┘
           │                                                        │
           │  HTTP REST API                         HTTP REST API   │
           │  (Authentication, Bookings,            (Authentication,│
           │   Addresses, Wallet, etc.)              Jobs, Earnings) │
           │                                                        │
           │         Socket.IO (Real-time)    Socket.IO (Real-time) │
           │         (Tracking, Status,       (Job Offers, Status,  │
           │          Notifications)           Location Updates)    │
           │                                                        │
           ▼                                                        ▼
    ┌─────────────────────────────────────────────────────────────────────┐
    │                         BACKEND (Node.js/Express)                    │
    │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌────────────┐  │
    │  │   REST API  │  │  Socket.IO  │  │  Services   │  │   Prisma   │  │
    │  │   Routes    │  │   Server    │  │   Layer     │  │    ORM     │  │
    │  └─────────────┘  └─────────────┘  └─────────────┘  └────────────┘  │
    └─────────────────────────────────────────────────────────────────────┘
                                       │
                                       ▼
                            ┌─────────────────┐
                            │   PostgreSQL    │
                            │    Database     │
                            └─────────────────┘
```

### Communication Protocols

| Protocol | Use Case | Direction |
|----------|----------|-----------|
| **REST API (HTTP)** | CRUD operations, authentication, data fetching | App → Backend |
| **Socket.IO** | Real-time updates, location tracking, notifications | Bidirectional |
| **JWT Tokens** | Authentication & authorization | In headers |

---

## Technology Stack

### User App (Flutter)
```yaml
Framework: Flutter 3.x
Language: Dart
State Management: GetX
HTTP Client: Dio
WebSocket: socket_io_client
Maps: google_maps_flutter
Local Storage: GetStorage
```

### Pilot App (Flutter)
```yaml
Framework: Flutter 3.x
Language: Dart
State Management: GetX
HTTP Client: Dio
WebSocket: socket_io_client
Maps: google_maps_flutter
Location: geolocator
Local Storage: GetStorage
```

### Backend (Node.js)
```yaml
Runtime: Node.js 18+
Framework: Express.js
Language: TypeScript
ORM: Prisma
Database: PostgreSQL
WebSocket: Socket.IO
Authentication: JWT
Validation: Zod
```

---

## Complete Booking Flow

### Phase 1: Booking Creation

```
USER APP                          BACKEND
────────                          ───────

┌─────────────────┐
│ 1. User selects │
│    pickup &     │
│    drop address │
└────────┬────────┘
         │
         │ POST /addresses (if new address)
         ├──────────────────────────────────►┌─────────────────┐
         │                                   │ Save address    │
         │◄──────────────────────────────────│ Return addressId│
         │                                   └─────────────────┘
         │
┌────────┴────────┐
│ 2. User selects │
│    vehicle type │
│    & package    │
└────────┬────────┘
         │
         │ POST /bookings/calculate-price
         ├──────────────────────────────────►┌─────────────────┐
         │  { vehicleTypeId,                 │ Calculate:      │
         │    pickupAddressId,               │ - Distance (km) │
         │    dropAddressId }                │ - Base fare     │
         │                                   │ - Per km charge │
         │◄──────────────────────────────────│ - Total amount  │
         │  { distance, baseFare,            └─────────────────┘
         │    perKmRate, totalAmount }
         │
┌────────┴────────┐
│ 3. User reviews │
│    & confirms   │
└────────┬────────┘
         │
         │ POST /bookings
         ├──────────────────────────────────►┌─────────────────┐
         │  { vehicleTypeId,                 │ - Create booking│
         │    pickupAddressId,               │ - Status=PENDING│
         │    dropAddressId,                 │ - Deduct wallet │
         │    packageType,                   │ - Start assign  │
         │    paymentMethod }                └────────┬────────┘
         │                                            │
         │   Socket: 'booking:created'                │
         │◄───────────────────────────────────────────┤
         │                                            │
┌────────┴────────┐                                   │
│ Navigate to     │                                   │
│ FindingDriver   │                                   │
└─────────────────┘                                   │
```

### Phase 2: Driver Assignment

```
USER APP                          BACKEND                           PILOT APP
────────                          ───────                           ─────────

                              ┌─────────────────────────┐
                              │  ASSIGNMENT QUEUE       │
                              │  Finds pilots within    │
                              │  5km, sorts by distance │
                              └────────────┬────────────┘
                                           │
    Socket: 'booking:search_started'       │
◄──────────────────────────────────────────┤
    { bookingId, message }                 │
                                           │
┌─────────────────┐                        │
│ UI: "Searching  │                        │
│ for drivers..." │                        │
└────────┬────────┘                        │
         │                                 ▼
         │                    ┌─────────────────────────┐
         │                    │ Send offer to Pilot #1  │
         │                    │ (30 second timeout)     │
         │                    └────────────┬────────────┘
         │                                 │
    Socket: 'booking:offer_sent'           │    Socket: 'pilot:job-offer'
◄──────────────────────────────────────────┼─────────────────────────────────►
    { pilotNumber: 1 }                     │    { bookingId, fare, pickup,    ┌─────────────┐
                                           │      drop, distance, timeout }   │ Job Offer   │
┌─────────────────┐                        │                                  │ Popup 30s   │
│ UI: "Contacting │                        │                                  │ countdown   │
│ driver #1"      │                        │                                  └──────┬──────┘
└────────┬────────┘                        │                                         │
         │                                 │                              ┌──────────┴──────────┐
         │                                 │                              ▼                     ▼
         │                                 │                         [ACCEPT]             [DECLINE]
         │                                 │                              │                     │
```

#### Scenario A: Pilot Accepts

```
         │                                 │                              │
         │                    ┌────────────┴────────────┐                 │
         │                    │ - Assign pilot          │◄────────────────┘
         │                    │ - Status = ACCEPTED     │  POST /matching/accept
         │                    │ - Clear assignment queue│
         │                    └────────────┬────────────┘
         │                                 │
    Socket: 'booking:driver_assigned'      │    Socket: 'pilot:job-assigned'
◄──────────────────────────────────────────┼─────────────────────────────────►
    { pilot: { id, name, phone,            │    { bookingId, pickup, drop,    ┌─────────────┐
      rating, vehicle } }                  │      userInfo }                  │ Navigate to │
                                           │                                  │ ActiveJob   │
┌─────────────────┐                        │                                  └─────────────┘
│ Navigate to     │
│ Tracking Screen │
└─────────────────┘
```

#### Scenario B: Pilot Declines or Timeout

```
         │                                 │                                        │
         │                    ┌────────────┴────────────┐                           │
         │                    │ Pilot declined/timeout  │◄──────────────────────────┘
         │                    │ Try next pilot in queue │
         │                    └────────────┬────────────┘
         │                                 │
    Socket: 'booking:offer_sent'           │    Socket: 'pilot:job-offer'
◄──────────────────────────────────────────┼─────────────────────────────────►
    { pilotNumber: 2 }                     │    (to next pilot)
                                           │
┌─────────────────┐                        │
│ UI: "Contacting │                        │
│ driver #2"      │                        │
└─────────────────┘                        │
                                           │
         (Repeat until accepted or 2-minute timeout)
```

#### Scenario C: No Pilots Found / Search Timeout

```
         │                    ┌────────────────────────┐
         │                    │ 2 minutes elapsed OR   │
         │                    │ all pilots exhausted   │
         │                    └────────────┬───────────┘
         │                                 │
    Socket: 'booking:search_timeout'       │
    OR 'booking:no_pilots'                 │
◄──────────────────────────────────────────┤
    { canRetry: true, canCancel: true }    │
                                           │
┌─────────────────┐                        │
│ UI: "No drivers │                        │
│ found"          │                        │
│ [Retry] [Cancel]│                        │
└────────┬────────┘                        │
         │                                 │
         │ If Retry clicked:               │
         │ POST /bookings/{id}/retry-assignment
         ├────────────────────────────────►│
         │                                 │ Restart assignment
         │                                 │ with expanded radius
```

### Phase 3: Live Tracking & Delivery

```
USER APP                          BACKEND                           PILOT APP
────────                          ───────                           ─────────

┌─────────────────┐                                         ┌─────────────────┐
│ Tracking Screen │                                         │ Active Job View │
└────────┬────────┘                                         └────────┬────────┘
         │                                                           │
         │ Socket: join('booking:{id}')                              │ Socket: join('booking:{id}')
         ├───────────────────────────────────────────────────────────┤
         │                                                           │
         │                                                           │
         │                 PILOT LOCATION UPDATES                    │
         │                 ══════════════════════                    │
         │                                                           │
         │                                           ┌───────────────┴───────────────┐
         │                                           │ Location broadcasts every 5s  │
         │                                           └───────────────┬───────────────┘
         │                                                           │
         │                                                           │ Socket: 'pilot:location'
         │                              ┌─────────────────────────────┤
         │                              │ Store & broadcast           │
         │                              └─────────────┬───────────────┘
         │                                            │
    Socket: 'driver:location'                         │
◄─────────────────────────────────────────────────────┤
    { lat, lng, heading }                             │
                                                      │
┌─────────────────┐                                   │
│ Update map:     │                                   │
│ - Driver marker │                                   │
│ - Route line    │                                   │
│ - ETA display   │                                   │
└─────────────────┘                                   │
         │                                            │
         │                 STATUS UPDATES                                │
         │                 ══════════════                                │
         │                                                               │
         │                                           ┌───────────────────┴───────────┐
         │                                           │ Pilot updates status:         │
         │                                           │ ARRIVED_PICKUP → PICKED_UP    │
         │                                           │ → IN_TRANSIT → ARRIVED_DROP   │
         │                                           │ → DELIVERED                   │
         │                                           └───────────────┬───────────────┘
         │                                                           │
         │                                                           │ PATCH /bookings/{id}/status
         │                              ┌─────────────────────────────┤
         │                              │ Update booking status       │
         │                              └─────────────┬───────────────┘
         │                                            │
    Socket: 'booking:status'                          │    Socket: 'booking:status'
◄─────────────────────────────────────────────────────┼─────────────────────────────────►
    { status: 'PICKED_UP' }                           │
                                                      │
┌─────────────────┐                                   │                ┌────────────────┐
│ Update status   │                                   │                │ Update stepper │
│ indicator       │                                   │                │ to next step   │
└─────────────────┘                                   │                └────────────────┘
         │                                            │
         │                 DELIVERY COMPLETION                          │
         │                 ════════════════════                          │
         │                                                              │
         │                                           ┌──────────────────┴───────────────┐
         │                                           │ Pilot marks DELIVERED            │
         │                                           └───────────────┬──────────────────┘
         │                              ┌─────────────────────────────┤
         │                              │ - Finalize booking          │
         │                              │ - Credit pilot earnings     │
         │                              │ - Send notifications        │
         │                              └─────────────┬───────────────┘
         │                                            │
    Socket: 'booking:completed'                       │    Socket: 'booking:completed'
◄─────────────────────────────────────────────────────┼─────────────────────────────────►
                                                      │
┌─────────────────┐                                   │                ┌────────────────┐
│ Show completion │                                   │                │ Show earnings  │
│ & rating screen │                                   │                │ summary        │
└─────────────────┘                                   │                └────────────────┘
```

---

## Socket Events Reference

### Backend → User App Events

| Event | Payload | Description |
|-------|---------|-------------|
| `booking:created` | `{ bookingId, bookingNumber, status, message }` | Booking successfully created |
| `booking:search_started` | `{ bookingId, message }` | Driver search initiated |
| `booking:offer_sent` | `{ bookingId, pilotNumber, message }` | Offer sent to a pilot |
| `booking:offer_expired` | `{ bookingId, pilotNumber }` | Pilot didn't respond in time |
| `booking:offer_declined` | `{ bookingId, pilotNumber }` | Pilot declined the offer |
| `booking:driver_assigned` | `{ bookingId, pilot: { id, name, phone, rating, vehicle } }` | Driver accepted the job |
| `booking:no_pilots` | `{ bookingId, message, canRetry, canCancel }` | No pilots available |
| `booking:search_timeout` | `{ bookingId, message, canRetry, canCancel }` | 2-minute search timeout |
| `driver:location` | `{ bookingId, lat, lng, heading, timestamp }` | Real-time driver location |
| `booking:status` | `{ bookingId, status, timestamp }` | Booking status changed |
| `booking:eta` | `{ bookingId, etaMinutes, distanceKm }` | Updated ETA |
| `booking:completed` | `{ bookingId }` | Delivery completed |
| `booking:cancelled` | `{ bookingId, reason, cancelledBy }` | Booking cancelled |

### Backend → Pilot App Events

| Event | Payload | Description |
|-------|---------|-------------|
| `pilot:job-offer` | `{ bookingId, fare, distance, pickup, drop, packageType, timeout }` | New job offer |
| `pilot:job-assigned` | `{ bookingId, pickup, drop, user, fare }` | Job assigned after acceptance |
| `pilot:offer-cancelled` | `{ bookingId, reason }` | User cancelled during search |
| `booking:status` | `{ bookingId, status }` | Status confirmation |
| `booking:completed` | `{ bookingId, earnings }` | Job completed |
| `booking:cancelled` | `{ bookingId, reason }` | Booking cancelled |

### App → Backend Events

| Event | Payload | From | Description |
|-------|---------|------|-------------|
| `booking:join` | `{ bookingId }` | Both | Join booking room for updates |
| `booking:leave` | `{ bookingId }` | Both | Leave booking room |
| `pilot:location` | `{ lat, lng, heading, bookingId }` | Pilot | Location update |
| `pilot:online` | `{ pilotId, lat, lng }` | Pilot | Go online for jobs |
| `pilot:offline` | `{ pilotId }` | Pilot | Go offline |

---

## REST API Endpoints

### Authentication Endpoints

#### User Authentication
```
POST   /auth/send-otp
       Body: { phone: "+91XXXXXXXXXX" }
       Response: { success: true, message: "OTP sent" }

POST   /auth/verify-otp
       Body: { phone: "+91XXXXXXXXXX", otp: "123456" }
       Response: { success: true, data: { token, user } }

POST   /auth/register
       Body: { phone, name, email }
       Response: { success: true, data: { token, user } }
```

#### Pilot Authentication
```
POST   /pilot/auth/send-otp
POST   /pilot/auth/verify-otp
POST   /pilot/auth/register
       Body: { phone, name, vehicleType, vehicleNumber, documents... }
```

### User App Endpoints

#### Addresses
```
GET    /addresses              - Get all user addresses
POST   /addresses              - Create new address
       Body: { label, address, landmark, city, state, pincode, lat, lng }
PUT    /addresses/:id          - Update address
DELETE /addresses/:id          - Delete address
```

#### Bookings
```
POST   /bookings/calculate-price
       Body: { vehicleTypeId, pickupAddressId, dropAddressId }
       Response: { distance, baseFare, perKmRate, totalAmount }

POST   /bookings
       Body: { vehicleTypeId, pickupAddressId, dropAddressId,
               packageType, packageDescription, paymentMethod, couponCode }
       Response: { booking: { id, bookingNumber, status, ... } }

GET    /bookings/my-bookings?page=1&limit=10&status=PENDING
GET    /bookings/:id
POST   /bookings/:id/cancel
       Body: { reason: "User cancelled" }
POST   /bookings/:id/retry-assignment
POST   /bookings/:id/rate
       Body: { rating: 5, review: "Great service!" }
```

#### Wallet
```
GET    /wallet/balance
GET    /wallet/transactions?page=1&limit=10
POST   /wallet/add-funds
       Body: { amount: 500 }
```

#### Vehicles
```
GET    /vehicles/types
       Response: { types: [{ id, name, description, baseRate, perKmRate, icon }] }
```

### Pilot App Endpoints

#### Jobs
```
GET    /pilot/jobs/active      - Get current active job
GET    /pilot/jobs/history     - Get completed jobs
POST   /matching/accept/:offerId
POST   /matching/decline/:offerId
       Body: { reason: "Too far" }
```

#### Booking Status (Pilot)
```
PATCH  /bookings/:id/status
       Body: { status: "ARRIVED_PICKUP", lat: 12.9716, lng: 77.5946 }
```

#### Earnings
```
GET    /pilot/earnings         - Get earnings summary
GET    /pilot/earnings/history?from=2024-01-01&to=2024-01-31
```

#### Profile
```
GET    /pilot/profile
PUT    /pilot/profile
POST   /pilot/documents        - Upload documents (multipart/form-data)
PUT    /pilot/status
       Body: { status: "ONLINE" | "OFFLINE" }
```

---

## Assignment Queue Logic

### Configuration

```typescript
const ASSIGNMENT_CONFIG = {
  OFFER_TIMEOUT_MS: 30 * 1000,      // 30 seconds per pilot
  MAX_SEARCH_TIME_MS: 2 * 60 * 1000, // 2 minutes total
  MAX_RETRY_ATTEMPTS: 10,            // Max pilots to try
  SEARCH_RADIUS_KM: 5,               // Initial search radius
  MAX_RADIUS_KM: 15,                 // Expanded radius on retry
}
```

### Algorithm Flow

```
                    startAssignment(bookingId)
                              │
                              ▼
                 ┌────────────────────────┐
                 │ 1. Get booking details │
                 │    & pickup location   │
                 └───────────┬────────────┘
                             │
                             ▼
                 ┌────────────────────────┐
                 │ 2. Query nearby pilots │
                 │    WHERE:              │
                 │    - distance <= 5km   │
                 │    - status = ONLINE   │
                 │    - vehicle matches   │
                 │    - not on active job │
                 │    ORDER BY distance   │
                 └───────────┬────────────┘
                             │
              ┌──────────────┴──────────────┐
              │                             │
              ▼                             ▼
     ┌────────────────┐           ┌────────────────┐
     │ Pilots found   │           │ No pilots      │
     └───────┬────────┘           └───────┬────────┘
             │                            │
             ▼                            ▼
     ┌────────────────┐           Emit 'booking:no_pilots'
     │ Start 2-min    │           Return
     │ search timer   │
     └───────┬────────┘
             │
             ▼
    ┌─────────────────────────────────────────┐
    │         PILOT OFFER LOOP                │
    │                                         │
    │  for (pilot of sortedPilots) {          │
    │    1. Create job offer record           │
    │    2. Emit 'pilot:job-offer' to pilot   │
    │    3. Emit 'booking:offer_sent' to user │
    │    4. Start 30-second timeout           │
    │    5. Wait for response:                │
    │       - ACCEPTED → complete assignment  │
    │       - DECLINED → try next pilot       │
    │       - TIMEOUT  → try next pilot       │
    │  }                                      │
    │                                         │
    │  If all pilots exhausted:               │
    │    Emit 'booking:search_timeout'        │
    └─────────────────────────────────────────┘
```

### Pilot Selection Query

```sql
SELECT p.*,
       ST_Distance(
         ST_MakePoint(p.current_lng, p.current_lat),
         ST_MakePoint(:pickupLng, :pickupLat)
       ) as distance
FROM pilots p
JOIN vehicles v ON v.pilot_id = p.id
WHERE p.status = 'ONLINE'
  AND p.is_verified = true
  AND v.vehicle_type_id = :vehicleTypeId
  AND p.id NOT IN (SELECT pilot_id FROM bookings WHERE status IN ('ACCEPTED', 'PICKED_UP', 'IN_TRANSIT'))
  AND ST_DWithin(
    ST_MakePoint(p.current_lng, p.current_lat),
    ST_MakePoint(:pickupLng, :pickupLat),
    :radiusKm * 1000
  )
ORDER BY distance ASC
LIMIT 10;
```

---

## Data Models

### Core Entities

```
┌──────────────────────────────────────────────────────────────────────────────────┐
│                              DATABASE SCHEMA                                      │
└──────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
│      User       │       │     Booking     │       │      Pilot      │
├─────────────────┤       ├─────────────────┤       ├─────────────────┤
│ id              │───┐   │ id              │   ┌───│ id              │
│ phone           │   │   │ bookingNumber   │   │   │ phone           │
│ name            │   │   │ userId ─────────┼───┘   │ name            │
│ email           │   │   │ pilotId ────────┼───────│ status          │
│ walletBalance   │   │   │ pickupAddressId │       │ currentLat      │
│ createdAt       │   │   │ dropAddressId   │       │ currentLng      │
│ updatedAt       │   │   │ vehicleTypeId   │       │ rating          │
└─────────────────┘   │   │ status          │       │ totalDeliveries │
                      │   │ fare            │       │ isVerified      │
┌─────────────────┐   │   │ distance        │       └─────────────────┘
│    Address      │   │   │ paymentMethod   │
├─────────────────┤   │   │ packageType     │       ┌─────────────────┐
│ id              │   │   │ createdAt       │       │   VehicleType   │
│ userId ─────────┼───┘   │ acceptedAt      │       ├─────────────────┤
│ label           │       │ completedAt     │       │ id              │
│ address         │       └─────────────────┘       │ name            │
│ landmark        │                                 │ description     │
│ city            │       ┌─────────────────┐       │ baseRate        │
│ state           │       │   Transaction   │       │ perKmRate       │
│ pincode         │       ├─────────────────┤       │ icon            │
│ lat             │       │ id              │       └─────────────────┘
│ lng             │       │ userId          │
│ isDefault       │       │ pilotId         │       ┌─────────────────┐
└─────────────────┘       │ bookingId       │       │     Vehicle     │
                          │ type            │       ├─────────────────┤
                          │ amount          │       │ id              │
                          │ status          │       │ pilotId         │
                          │ createdAt       │       │ vehicleTypeId   │
                          └─────────────────┘       │ registrationNo  │
                                                    │ model           │
                                                    │ color           │
                                                    └─────────────────┘
```

### Booking Status Enum

```typescript
enum BookingStatus {
  PENDING       = 'PENDING',        // Created, finding driver
  ACCEPTED      = 'ACCEPTED',       // Driver assigned
  ARRIVED_PICKUP = 'ARRIVED_PICKUP', // Driver at pickup
  PICKED_UP     = 'PICKED_UP',      // Package collected
  IN_TRANSIT    = 'IN_TRANSIT',     // On the way
  ARRIVED_DROP  = 'ARRIVED_DROP',   // At delivery location
  DELIVERED     = 'DELIVERED',      // Completed
  CANCELLED     = 'CANCELLED',      // Cancelled
}
```

### Pilot Status Enum

```typescript
enum PilotStatus {
  ONLINE  = 'ONLINE',   // Available for jobs
  OFFLINE = 'OFFLINE',  // Not available
  BUSY    = 'BUSY',     // On active delivery
}
```

---

## Status Flow

### Booking Status Transitions

```
                              ┌─────────────────┐
                              │     PENDING     │
                              │ (Finding Driver)│
                              └────────┬────────┘
                                       │
                    ┌──────────────────┼──────────────────┐
                    │                  │                  │
                    ▼                  ▼                  ▼
           ┌───────────────┐  ┌───────────────┐  ┌───────────────┐
           │   CANCELLED   │  │   ACCEPTED    │  │  (No Driver)  │
           │ (User/System) │  │(Driver Found) │  │ Return to     │
           └───────────────┘  └───────┬───────┘  │ Pending/Cancel│
                                      │          └───────────────┘
                                      ▼
                              ┌───────────────┐
                              │ARRIVED_PICKUP │
                              │ (At Pickup)   │
                              └───────┬───────┘
                                      │
                                      ▼
                              ┌───────────────┐
                              │   PICKED_UP   │
                              │(Has Package)  │
                              └───────┬───────┘
                                      │
                                      ▼
                              ┌───────────────┐
                              │  IN_TRANSIT   │
                              │ (On The Way)  │
                              └───────┬───────┘
                                      │
                                      ▼
                              ┌───────────────┐
                              │ ARRIVED_DROP  │
                              │(At Delivery)  │
                              └───────┬───────┘
                                      │
                                      ▼
                              ┌───────────────┐
                              │   DELIVERED   │
                              │  (Complete)   │
                              └───────────────┘
```

### Valid Status Transitions

| Current Status | Can Transition To |
|----------------|-------------------|
| PENDING | ACCEPTED, CANCELLED |
| ACCEPTED | ARRIVED_PICKUP, CANCELLED |
| ARRIVED_PICKUP | PICKED_UP, CANCELLED |
| PICKED_UP | IN_TRANSIT |
| IN_TRANSIT | ARRIVED_DROP |
| ARRIVED_DROP | DELIVERED |
| DELIVERED | (final state) |
| CANCELLED | (final state) |

---

## Error Handling

### API Error Response Format

```json
{
  "success": false,
  "message": "Human-readable error message",
  "error": {
    "code": "ERROR_CODE",
    "details": {}
  }
}
```

### Common Error Codes

| Code | HTTP Status | Description |
|------|-------------|-------------|
| `VALIDATION_ERROR` | 400 | Invalid request data |
| `UNAUTHORIZED` | 401 | Missing/invalid token |
| `FORBIDDEN` | 403 | No permission |
| `NOT_FOUND` | 404 | Resource not found |
| `CONFLICT` | 409 | Resource conflict |
| `INSUFFICIENT_BALANCE` | 400 | Wallet balance too low |
| `BOOKING_NOT_CANCELLABLE` | 400 | Cannot cancel at this status |
| `PILOT_NOT_AVAILABLE` | 400 | Pilot busy/offline |
| `RATE_LIMIT_EXCEEDED` | 429 | Too many requests |
| `INTERNAL_ERROR` | 500 | Server error |

### Socket Error Events

```typescript
// Connection errors
socket.on('connect_error', (error) => {
  // Handle connection failure
});

// Authentication errors
socket.on('error', (data) => {
  // { code: 'AUTH_ERROR', message: 'Invalid token' }
});
```

---

## File Structure

### Backend

```
backend/
├── src/
│   ├── controllers/          # Request handlers
│   │   ├── auth.controller.ts
│   │   ├── booking.controller.ts
│   │   └── ...
│   ├── services/             # Business logic
│   │   ├── booking.service.ts
│   │   ├── matching.service.ts
│   │   ├── assignment-queue.service.ts
│   │   └── ...
│   ├── routes/               # API routes
│   ├── middleware/           # Auth, validation, etc.
│   ├── socket/               # Socket.IO handlers
│   │   ├── index.ts
│   │   └── types.ts
│   ├── validators/           # Zod schemas
│   └── utils/                # Helpers
├── prisma/
│   └── schema.prisma         # Database schema
└── package.json
```

### User App

```
user_app/
├── lib/
│   ├── app/
│   │   ├── core/             # Theme, constants, widgets
│   │   ├── data/
│   │   │   ├── models/       # Data models
│   │   │   ├── providers/    # API client
│   │   │   └── repositories/ # Data repositories
│   │   ├── modules/          # Feature modules
│   │   │   ├── auth/
│   │   │   ├── booking/
│   │   │   ├── tracking/
│   │   │   └── wallet/
│   │   ├── routes/           # Navigation
│   │   └── services/         # Socket, location, etc.
│   └── main.dart
└── pubspec.yaml
```

### Pilot App

```
pilot_app/
├── lib/
│   ├── app/
│   │   ├── core/             # Theme, constants, widgets
│   │   ├── data/
│   │   │   ├── models/
│   │   │   ├── providers/
│   │   │   └── repositories/
│   │   ├── modules/          # Feature modules
│   │   │   ├── auth/
│   │   │   ├── jobs/
│   │   │   ├── earnings/
│   │   │   └── profile/
│   │   ├── routes/
│   │   └── services/         # Socket, location, etc.
│   └── main.dart
└── pubspec.yaml
```

---

## Quick Reference

### Key Timeouts

| Operation | Timeout | Description |
|-----------|---------|-------------|
| Pilot Offer | 30 seconds | Time for pilot to accept/decline |
| Driver Search | 2 minutes | Total search time before timeout |
| Location Update | 5 seconds | Pilot location broadcast interval |
| Socket Reconnect | 5 attempts | Auto-reconnect attempts |

### Key URLs

```
API Base URL:      https://api.sendit.com/api/v1
Socket URL:        wss://api.sendit.com
```

### Authentication Header

```
Authorization: Bearer <jwt_token>
```

---

*Document Version: 1.0*
*Last Updated: February 2025*
