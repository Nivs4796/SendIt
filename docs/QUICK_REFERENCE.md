# SendIt Quick Reference Card

> Quick lookup for developers working on SendIt

---

## Socket Events Cheatsheet

### User App Listens To:
```dart
// Assignment Flow
'booking:created'          // Booking created successfully
'booking:search_started'   // Driver search began
'booking:offer_sent'       // Offer sent to pilot #N
'booking:driver_assigned'  // Driver accepted!
'booking:no_pilots'        // No drivers available
'booking:search_timeout'   // 2-minute timeout

// Tracking Flow
'driver:location'          // { lat, lng, heading }
'booking:status'           // Status changed
'booking:eta'              // ETA updated
'booking:completed'        // Delivery done
'booking:cancelled'        // Booking cancelled
```

### Pilot App Listens To:
```dart
'pilot:job-offer'          // New job offer (30s to respond)
'pilot:job-assigned'       // Job confirmed
'pilot:offer-cancelled'    // User cancelled
'booking:status'           // Status update
'booking:completed'        // Job done
```

### Apps Emit:
```dart
'booking:join'             // Join booking room
'booking:leave'            // Leave booking room
'pilot:location'           // Pilot location update
'pilot:online'             // Go online
'pilot:offline'            // Go offline
```

---

## Booking Status Flow

```
PENDING → ACCEPTED → ARRIVED_PICKUP → PICKED_UP → IN_TRANSIT → ARRIVED_DROP → DELIVERED
    ↓         ↓            ↓
CANCELLED  CANCELLED   CANCELLED
```

| Status | User Sees | Pilot Action |
|--------|-----------|--------------|
| PENDING | "Finding driver..." | - |
| ACCEPTED | Driver info, tracking | Navigate to pickup |
| ARRIVED_PICKUP | "Driver arrived" | Tap "Arrived" |
| PICKED_UP | "Package collected" | Tap "Picked Up" |
| IN_TRANSIT | Live tracking | Driving |
| ARRIVED_DROP | "Driver at destination" | Tap "Arrived" |
| DELIVERED | Rating screen | Tap "Delivered" |

---

## API Endpoints Quick List

### User App
```
POST /auth/send-otp              # Login
POST /auth/verify-otp            # Verify OTP
POST /bookings/calculate-price   # Get price
POST /bookings                   # Create booking
POST /bookings/:id/cancel        # Cancel
POST /bookings/:id/retry-assignment  # Retry search
GET  /bookings/my-bookings       # List bookings
GET  /wallet/balance             # Get balance
GET  /vehicles/types             # Vehicle options
```

### Pilot App
```
POST /pilot/auth/send-otp        # Login
POST /pilot/auth/verify-otp      # Verify OTP
POST /matching/accept/:id        # Accept job
POST /matching/decline/:id       # Decline job
PATCH /bookings/:id/status       # Update status
GET  /pilot/jobs/active          # Current job
GET  /pilot/earnings             # Earnings
PUT  /pilot/status               # Online/Offline
```

---

## Key Configuration Values

| Config | Value | Description |
|--------|-------|-------------|
| Offer Timeout | 30 seconds | Time for pilot to respond |
| Search Timeout | 2 minutes | Total driver search time |
| Initial Radius | 5 km | First search radius |
| Max Radius | 15 km | Expanded radius on retry |
| Max Pilots | 10 | Maximum pilots to try |
| Location Interval | 5 seconds | Pilot location broadcast |

---

## Common Patterns

### Create Booking (User App)
```dart
// 1. Calculate price
final price = await bookingRepo.calculatePrice(
  vehicleTypeId: vehicle.id,
  pickupAddressId: pickup.id,
  dropAddressId: drop.id,
);

// 2. Create booking
final booking = await bookingRepo.createBooking(
  CreateBookingRequest(
    vehicleTypeId: vehicle.id,
    pickupAddressId: pickup.id,
    dropAddressId: drop.id,
    paymentMethod: 'WALLET',
  ),
);

// 3. Join socket room
socketService.joinBookingRoom(booking.id);

// 4. Listen for driver assignment
socketService.driverAssignedStream.listen((data) {
  if (data.bookingId == booking.id) {
    // Navigate to tracking
  }
});
```

### Accept Job (Pilot App)
```dart
// 1. Listen for job offers
socketService.jobOfferStream.listen((offer) {
  showJobOfferPopup(offer);
});

// 2. Accept offer
await matchingRepo.acceptOffer(offer.id);

// 3. Job assigned event received
socketService.jobAssignedStream.listen((job) {
  navigateToActiveJob(job);
});
```

### Update Status (Pilot App)
```dart
// Update booking status
await bookingRepo.updateStatus(
  bookingId: currentJob.bookingId,
  status: BookingStatus.PICKED_UP,
  lat: currentLocation.latitude,
  lng: currentLocation.longitude,
);
```

---

## Debugging Tips

### Socket Connection
```dart
// Check connection status
print('Connected: ${socketService.isConnected}');
print('Error: ${socketService.connectionError}');

// Enable socket logging
socket.onAny((event, data) {
  print('[Socket] $event: $data');
});
```

### API Debugging
```dart
// Add interceptor to ApiClient
dio.interceptors.add(LogInterceptor(
  requestBody: true,
  responseBody: true,
));
```

### Common Issues

| Issue | Check |
|-------|-------|
| Socket not connecting | Token valid? URL correct? |
| No job offers | Pilot online? Vehicle type matches? |
| Location not updating | Location permission? Service running? |
| Payment failing | Wallet balance? Payment method? |

---

## File Locations

### User App Key Files
```
lib/app/services/socket_service.dart      # Socket handling
lib/app/modules/booking/controllers/      # Booking logic
lib/app/modules/tracking/views/           # Tracking UI
lib/app/data/repositories/booking_repo    # API calls
```

### Pilot App Key Files
```
lib/app/services/socket_service.dart      # Socket handling
lib/app/modules/jobs/controllers/         # Job logic
lib/app/modules/jobs/views/active_job     # Active job UI
lib/app/services/location_service.dart    # Location tracking
```

### Backend Key Files
```
src/services/assignment-queue.service.ts  # Driver matching
src/services/booking.service.ts           # Booking logic
src/services/matching.service.ts          # Offer handling
src/socket/index.ts                       # Socket events
```

---

## Testing Checklist

### Booking Flow
- [ ] User can create booking
- [ ] Price calculation works
- [ ] Wallet deduction works
- [ ] Socket events received
- [ ] Driver search shows progress
- [ ] Retry works after timeout

### Assignment Flow
- [ ] Pilot receives job offer
- [ ] 30-second timeout works
- [ ] Accept assigns driver
- [ ] Decline tries next pilot
- [ ] User notified of assignment

### Tracking Flow
- [ ] Map shows driver location
- [ ] Location updates real-time
- [ ] Status changes reflect in UI
- [ ] ETA updates work
- [ ] Delivery completion works

### Edge Cases
- [ ] No pilots available
- [ ] User cancels during search
- [ ] Pilot goes offline mid-delivery
- [ ] Network disconnection handling
- [ ] App backgrounding

---

*Quick Reference v1.0 - February 2025*
