# Real-Time Tracking Design

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add Socket.io real-time tracking for pilot locations, booking status updates, and live admin dashboard.

**Architecture:** Room-based Socket.io server integrated with existing Express app, sharing JWT authentication and HTTP server.

**Tech Stack:** Socket.io 4.7.x, existing Express 5, JWT auth, Prisma

---

## 1. Architecture Overview

### Server Integration

Socket.io runs alongside Express, sharing the same HTTP server on port 5000:
- Reuses existing JWT authentication
- Shares rate limiting and logging infrastructure
- Single deployment, no additional ports

### Room-Based Architecture

```
Rooms:
├── booking:{bookingId}     → User + Pilot for a specific booking
├── pilot:{pilotId}         → Pilot's personal channel (new offers, updates)
├── user:{userId}           → User's personal channel (notifications)
└── admin:dashboard         → Admin live stats
```

### Event Flow

1. Pilot sends location → Server validates → Broadcasts to booking room + stores in DB
2. Booking status changes → Server broadcasts to booking room + user room
3. New booking created → Server broadcasts to nearby online pilots
4. Stats change → Server broadcasts to admin dashboard

---

## 2. Socket Events Specification

### Client → Server Events

| Event | Sender | Payload | Description |
|-------|--------|---------|-------------|
| `pilot:location` | Pilot | `{lat, lng, heading?, speed?}` | Hybrid: 50m move OR 10s fallback |
| `pilot:online` | Pilot | `{vehicleId}` | Go online for deliveries |
| `pilot:offline` | Pilot | - | Go offline |
| `booking:subscribe` | User | `{bookingId}` | Join booking room for tracking |
| `booking:unsubscribe` | User | `{bookingId}` | Leave booking room |
| `admin:subscribe` | Admin | - | Join admin dashboard room |

### Server → Client Events

| Event | Receivers | Payload | Description |
|-------|-----------|---------|-------------|
| `location:update` | Booking room | `{lat, lng, heading, speed, timestamp}` | Pilot location broadcast |
| `booking:status` | Booking room + User | `{bookingId, status, timestamp}` | Status change |
| `booking:offer` | Pilot | `{booking details, expiresAt}` | New delivery offer |
| `offer:expired` | Pilot | `{bookingId}` | Offer timeout |
| `dashboard:stats` | Admin | `{activeBookings, onlinePilots, ...}` | Live dashboard stats |
| `notification` | User/Pilot | `{title, body, type, data}` | Push notification |

---

## 3. Authentication & Connection

### JWT Authentication on Connect

```typescript
// Client connects with token
socket = io('http://localhost:5000', {
  auth: { token: 'Bearer eyJhbG...' }
})
```

### Server Validation

1. Extract JWT from `socket.handshake.auth.token`
2. Verify using existing `config.jwtSecret`
3. Decode user type: `user`, `pilot`, or `admin`
4. Attach to socket: `socket.data = { userId, userType, ... }`
5. Auto-join personal room: `user:{id}` or `pilot:{id}`

### Connection States

- **Connected** → Authenticated, in personal room
- **Disconnected** → If pilot, mark `isOnline: false` after 30s grace period
- **Reconnected** → Restore room subscriptions automatically

### Rate Limiting

- Location updates: Max 1 per second per pilot
- Subscription requests: Max 10 per minute per client
- Uses existing error code `ERR_1003`

---

## 4. Hybrid Location Tracking

### Pilot App Logic (Client-Side)

```
lastSentLocation = null
lastSentTime = 0

onLocationChange(newLocation):
  distance = calculateDistance(lastSentLocation, newLocation)
  timeSinceLastSend = now() - lastSentTime

  shouldSend = false
  if distance >= 50 meters:        // Movement threshold
    shouldSend = true
  else if timeSinceLastSend >= 10s: // Fallback interval
    shouldSend = true

  if shouldSend:
    socket.emit('pilot:location', newLocation)
    lastSentLocation = newLocation
    lastSentTime = now()
```

### Server-Side Processing

1. Receive `pilot:location` event
2. Validate pilot has active booking (or is online)
3. Update `Pilot.currentLat/Lng/lastLocationAt` in DB
4. If active booking exists:
   - Update `Booking.currentLat/Lng`
   - Add entry to `TrackingHistory`
   - Broadcast `location:update` to `booking:{id}` room
5. Throttle: Ignore if <1s since last update

### Battery Optimization

- When no active delivery: Stop location updates entirely
- Server detects stale pilots (no update >60s while online) → marks offline

---

## 5. File Structure

### New Files

```
src/
├── socket/
│   ├── index.ts           # Socket.io server setup & auth middleware
│   ├── handlers/
│   │   ├── pilot.handler.ts    # pilot:location, pilot:online/offline
│   │   ├── booking.handler.ts  # booking:subscribe/unsubscribe, status
│   │   └── admin.handler.ts    # admin:subscribe, dashboard stats
│   ├── rooms.ts           # Room management utilities
│   └── types.ts           # Socket event types & interfaces
```

### Modified Files

| File | Changes |
|------|---------|
| `src/index.ts` | Create HTTP server, attach Socket.io |
| `src/services/booking.service.ts` | Emit status changes via socket |
| `src/services/matching.service.ts` | Emit new offers to pilots |
| `package.json` | Add `socket.io` dependency |

### Dependencies

```json
{
  "socket.io": "^4.7.5"
}
```

---

## 6. Implementation Tasks

### Phase 1: Core Socket Setup
1. Install socket.io dependency
2. Create `src/socket/types.ts` with event interfaces
3. Create `src/socket/index.ts` with server setup and JWT auth middleware
4. Modify `src/index.ts` to use HTTP server with Socket.io

### Phase 2: Pilot Handlers
5. Create `src/socket/rooms.ts` with room utilities
6. Create `src/socket/handlers/pilot.handler.ts`
   - `pilot:online` / `pilot:offline` events
   - `pilot:location` with hybrid throttling
   - Disconnect grace period (30s)

### Phase 3: Booking & User Handlers
7. Create `src/socket/handlers/booking.handler.ts`
   - `booking:subscribe` / `booking:unsubscribe`
   - Status change broadcasts
8. Modify `src/services/booking.service.ts` to emit socket events

### Phase 4: Admin & Matching
9. Create `src/socket/handlers/admin.handler.ts`
   - `admin:subscribe` for dashboard
   - Live stats broadcasting
10. Modify `src/services/matching.service.ts` to emit offers to pilots

### Phase 5: Testing
11. Create socket integration tests
12. Test with multiple concurrent connections
