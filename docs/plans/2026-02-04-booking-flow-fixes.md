# Booking Flow Fixes Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Fix the complete booking flow from package creation to delivery completion across user_app, pilot_app, and backend.

**Architecture:** Event-driven booking flow with Socket.IO for real-time updates, proper payment processing before pilot assignment, and stateful job offer management.

**Tech Stack:** Node.js/Express/TypeScript backend, Flutter/Dart mobile apps, Socket.IO, Prisma ORM

---

## Phase 1: Backend - Auto-Assignment Implementation (Critical)

### Task 1.1: Implement Auto-Assignment Trigger in Booking Service

**Files:**
- Modify: `backend/src/services/booking.service.ts:150-170`

**Step 1: Read the current createBooking method**
Review the TODO comments and understand the current flow.

**Step 2: Add auto-assignment call after booking creation**

After line 156 (after booking is created), add:
```typescript
// Trigger pilot matching asynchronously
this.triggerPilotMatching(booking.id, {
  pickupLat: data.pickupAddress.lat,
  pickupLng: data.pickupAddress.lng,
  vehicleType: data.vehicleType,
});

// Notify user of booking confirmation
await this.notifyUserBookingCreated(booking.id, userId);
```

**Step 3: Add the triggerPilotMatching method**

```typescript
private async triggerPilotMatching(
  bookingId: string,
  location: { pickupLat: number; pickupLng: number; vehicleType: string }
): Promise<void> {
  try {
    const matchingService = new MatchingService();
    const nearbyPilots = await matchingService.findNearbyPilots(
      location.pickupLat,
      location.pickupLng,
      5, // 5km radius
      location.vehicleType
    );

    if (nearbyPilots.length > 0) {
      // Send job offer to nearest pilot first
      await matchingService.sendJobOffer(bookingId, nearbyPilots[0].id);
    } else {
      // No pilots available - notify user
      await this.notifyUserNoPilots(bookingId);
    }
  } catch (error) {
    console.error('Pilot matching failed:', error);
    // Don't fail the booking creation, just log
  }
}
```

**Step 4: Add user notification method**

```typescript
private async notifyUserBookingCreated(bookingId: string, userId: string): Promise<void> {
  const io = getSocketIO();
  io.to(`user:${userId}`).emit('booking:created', {
    bookingId,
    message: 'Your booking has been created. Finding a pilot...',
  });
}

private async notifyUserNoPilots(bookingId: string): Promise<void> {
  const booking = await prisma.booking.findUnique({
    where: { id: bookingId },
    select: { userId: true },
  });

  if (booking) {
    const io = getSocketIO();
    io.to(`user:${booking.userId}`).emit('booking:no_pilots', {
      bookingId,
      message: 'No pilots available nearby. We will notify you when one becomes available.',
    });
  }
}
```

**Step 5: Run linting and verify no errors**
```bash
cd backend && npm run lint
```

**Step 6: Commit**
```bash
git add backend/src/services/booking.service.ts
git commit -m "feat(booking): implement auto-assignment trigger after booking creation"
```

---

### Task 1.2: Implement Job Offer Timeout and Cascade

**Files:**
- Modify: `backend/src/services/matching.service.ts`

**Step 1: Update sendJobOffer to handle timeout cascade**

After line 95 (in sendJobOffer), update the timeout logic:
```typescript
async sendJobOffer(bookingId: string, pilotId: string): Promise<void> {
  const booking = await prisma.booking.findUnique({
    where: { id: bookingId },
    include: { pickupAddress: true, dropAddress: true },
  });

  if (!booking) throw new Error('Booking not found');

  // Store offer with timestamp
  this.jobOffers.set(bookingId, {
    pilotId,
    expiresAt: Date.now() + 30000, // 30 seconds
    attemptCount: (this.jobOffers.get(bookingId)?.attemptCount || 0) + 1,
  });

  // Send to pilot via socket
  const io = getSocketIO();
  io.to(`pilot:${pilotId}`).emit('job:new_offer', {
    bookingId,
    pickup: booking.pickupAddress,
    drop: booking.dropAddress,
    fare: booking.fare,
    distance: booking.distance,
    expiresIn: 30,
  });

  // Set timeout for auto-rejection
  setTimeout(() => this.handleOfferTimeout(bookingId), 30000);
}

private async handleOfferTimeout(bookingId: string): Promise<void> {
  const offer = this.jobOffers.get(bookingId);
  if (!offer) return; // Already accepted or cancelled

  // Check if offer still pending (not accepted)
  const booking = await prisma.booking.findUnique({
    where: { id: bookingId },
    select: { status: true },
  });

  if (booking?.status !== 'PENDING') return; // Already handled

  // Remove expired offer
  this.jobOffers.delete(bookingId);

  // Try next pilot if attempts < 5
  if (offer.attemptCount < 5) {
    const nearbyPilots = await this.findNearbyPilots(
      // Get from booking...
    );

    // Find next available pilot (not the one who timed out)
    const nextPilot = nearbyPilots.find(p => p.id !== offer.pilotId);
    if (nextPilot) {
      await this.sendJobOffer(bookingId, nextPilot.id);
      return;
    }
  }

  // No more pilots or max attempts - notify user
  await this.notifyBookingFailed(bookingId);
}
```

**Step 2: Run tests**
```bash
cd backend && npm run test
```

**Step 3: Commit**
```bash
git add backend/src/services/matching.service.ts
git commit -m "feat(matching): implement job offer timeout cascade to next pilot"
```

---

### Task 1.3: Add Socket Room Management for Users

**Files:**
- Modify: `backend/src/services/socket.service.ts`

**Step 1: Find socket connection handler and add user room join**

In the connection handler, add:
```typescript
socket.on('user:join', (userId: string) => {
  socket.join(`user:${userId}`);
  console.log(`User ${userId} joined their room`);
});

socket.on('user:leave', (userId: string) => {
  socket.leave(`user:${userId}`);
});
```

**Step 2: Commit**
```bash
git add backend/src/services/socket.service.ts
git commit -m "feat(socket): add user room management for booking notifications"
```

---

## Phase 2: User App - Socket Integration

### Task 2.1: Add User Socket Room Join

**Files:**
- Modify: `user_app/lib/app/services/socket_service.dart`

**Step 1: Add user room join after connection**

In the `connect` method, after successful connection:
```dart
void _joinUserRoom() {
  final userId = _storageService.getUserId();
  if (userId != null) {
    _socket?.emit('user:join', userId);
    AppLogger.socket('Joined user room: $userId');
  }
}
```

**Step 2: Call _joinUserRoom after socket connects**

**Step 3: Add booking event listeners**

```dart
void _setupBookingListeners() {
  _socket?.on('booking:created', (data) {
    AppLogger.socket('Booking created: $data');
    _bookingController?.onBookingCreated(data);
  });

  _socket?.on('booking:pilot_assigned', (data) {
    AppLogger.socket('Pilot assigned: $data');
    _bookingController?.onPilotAssigned(data);
  });

  _socket?.on('booking:no_pilots', (data) {
    AppLogger.socket('No pilots available: $data');
    _bookingController?.onNoPilotsAvailable(data);
  });

  _socket?.on('booking:status_update', (data) {
    AppLogger.socket('Booking status update: $data');
    _bookingController?.onStatusUpdate(data);
  });
}
```

**Step 4: Commit**
```bash
git add user_app/lib/app/services/socket_service.dart
git commit -m "feat(user-app): add socket room join and booking event listeners"
```

---

### Task 2.2: Update Booking Controller for Real-time Updates

**Files:**
- Modify: `user_app/lib/app/modules/booking/controllers/booking_controller.dart`

**Step 1: Add callback methods for socket events**

```dart
void onBookingCreated(dynamic data) {
  final bookingId = data['bookingId'];
  isSearchingPilot.value = true;
  Get.snackbar('Booking Created', 'Finding a pilot for you...');
}

void onPilotAssigned(dynamic data) {
  isSearchingPilot.value = false;
  final pilotData = data['pilot'];
  assignedPilot.value = PilotModel.fromJson(pilotData);
  currentBookingStatus.value = BookingStatus.accepted;
  Get.snackbar('Pilot Found', '${pilotData['name']} is on the way!');
}

void onNoPilotsAvailable(dynamic data) {
  isSearchingPilot.value = false;
  Get.snackbar(
    'No Pilots Available',
    'We will notify you when a pilot becomes available.',
    duration: const Duration(seconds: 5),
  );
}

void onStatusUpdate(dynamic data) {
  final status = data['status'];
  currentBookingStatus.value = BookingStatus.values.firstWhere(
    (s) => s.name.toUpperCase() == status,
    orElse: () => currentBookingStatus.value,
  );
}
```

**Step 2: Commit**
```bash
git add user_app/lib/app/modules/booking/controllers/booking_controller.dart
git commit -m "feat(user-app): add real-time booking update handlers"
```

---

## Phase 3: Payment Flow Fix

### Task 3.1: Move Payment Validation Before Booking Creation

**Files:**
- Modify: `backend/src/services/booking.service.ts`

**Step 1: Add payment validation at start of createBooking**

Before creating the booking, add:
```typescript
// Validate payment based on payment method
if (data.paymentMethod === 'WALLET') {
  const wallet = await prisma.wallet.findUnique({
    where: { userId },
  });

  if (!wallet || wallet.balance < data.fare) {
    throw new Error('Insufficient wallet balance');
  }

  // Hold the amount (deduct but mark as held)
  await prisma.wallet.update({
    where: { userId },
    data: {
      balance: { decrement: data.fare },
      heldAmount: { increment: data.fare },
    },
  });
}
// For CASH and ONLINE, no pre-validation needed
```

**Step 2: Add rollback on booking failure**

Wrap booking creation in try-catch and rollback held amount on failure.

**Step 3: Commit**
```bash
git add backend/src/services/booking.service.ts
git commit -m "feat(booking): validate and hold wallet payment before booking creation"
```

---

### Task 3.2: Add Coupon Validation

**Files:**
- Modify: `backend/src/services/booking.service.ts`

**Step 1: Add coupon validation method**

```typescript
private async validateAndApplyCoupon(
  couponCode: string | undefined,
  fare: number,
  userId: string
): Promise<{ discount: number; finalFare: number }> {
  if (!couponCode) {
    return { discount: 0, finalFare: fare };
  }

  const coupon = await prisma.coupon.findFirst({
    where: {
      code: couponCode,
      isActive: true,
      expiresAt: { gte: new Date() },
      usageLimit: { gt: 0 },
    },
  });

  if (!coupon) {
    throw new Error('Invalid or expired coupon code');
  }

  // Check if user already used this coupon
  const existingUse = await prisma.couponUsage.findFirst({
    where: { couponId: coupon.id, userId },
  });

  if (existingUse) {
    throw new Error('You have already used this coupon');
  }

  // Calculate discount
  let discount = 0;
  if (coupon.discountType === 'PERCENTAGE') {
    discount = (fare * coupon.discountValue) / 100;
    if (coupon.maxDiscount) {
      discount = Math.min(discount, coupon.maxDiscount);
    }
  } else {
    discount = coupon.discountValue;
  }

  return {
    discount,
    finalFare: fare - discount,
  };
}
```

**Step 2: Call validation in createBooking before creating record**

**Step 3: Record coupon usage after booking created**

**Step 4: Commit**
```bash
git add backend/src/services/booking.service.ts
git commit -m "feat(booking): add coupon validation and discount application"
```

---

## Phase 4: Pilot App - Job Acceptance Flow

### Task 4.1: Fix Job Offer Timer Display

**Files:**
- Modify: `pilot_app/lib/app/modules/jobs/controllers/jobs_controller.dart`

**Step 1: Ensure timer starts when job offer received**

Verify the timer initialization in `onNewJobOffer`:
```dart
void onNewJobOffer(dynamic data) {
  currentJobOffer.value = JobOffer.fromJson(data);
  _startOfferTimer(data['expiresIn'] ?? 30);
}

void _startOfferTimer(int seconds) {
  offerTimeRemaining.value = seconds;
  _offerTimer?.cancel();
  _offerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
    if (offerTimeRemaining.value > 0) {
      offerTimeRemaining.value--;
    } else {
      timer.cancel();
      _handleOfferExpired();
    }
  });
}

void _handleOfferExpired() {
  currentJobOffer.value = null;
  Get.snackbar('Offer Expired', 'The job offer has expired');
}
```

**Step 2: Commit**
```bash
git add pilot_app/lib/app/modules/jobs/controllers/jobs_controller.dart
git commit -m "fix(pilot-app): ensure job offer timer starts correctly"
```

---

### Task 4.2: Add Job Acceptance API Call

**Files:**
- Modify: `pilot_app/lib/app/modules/jobs/controllers/jobs_controller.dart`

**Step 1: Implement acceptJob method**

```dart
Future<void> acceptJob() async {
  if (currentJobOffer.value == null) return;

  try {
    isLoading.value = true;
    _offerTimer?.cancel();

    final response = await _jobRepository.acceptJob(
      currentJobOffer.value!.bookingId,
    );

    if (response.success) {
      activeJob.value = response.data;
      currentJobOffer.value = null;
      Get.offNamed(Routes.ACTIVE_JOB);
    } else {
      Get.snackbar('Error', response.message ?? 'Failed to accept job');
    }
  } catch (e) {
    AppLogger.error('JobsController', 'Failed to accept job', e);
    Get.snackbar('Error', 'Failed to accept job. Please try again.');
  } finally {
    isLoading.value = false;
  }
}
```

**Step 2: Commit**
```bash
git add pilot_app/lib/app/modules/jobs/controllers/jobs_controller.dart
git commit -m "feat(pilot-app): implement job acceptance with API call"
```

---

## Phase 5: OTP Verification

### Task 5.1: Add OTP Verification for Pickup

**Files:**
- Modify: `backend/src/services/booking.service.ts`

**Step 1: Add OTP verification in status update**

```typescript
async updateBookingStatus(
  bookingId: string,
  pilotId: string,
  status: BookingStatus,
  otp?: string
): Promise<Booking> {
  const booking = await prisma.booking.findUnique({
    where: { id: bookingId },
  });

  if (!booking) throw new Error('Booking not found');
  if (booking.pilotId !== pilotId) throw new Error('Unauthorized');

  // OTP required for PICKED_UP status
  if (status === 'PICKED_UP') {
    if (!otp) throw new Error('OTP required for pickup confirmation');
    if (booking.pickupOtp !== otp) throw new Error('Invalid OTP');
  }

  // OTP required for DELIVERED status
  if (status === 'DELIVERED') {
    if (!otp) throw new Error('OTP required for delivery confirmation');
    if (booking.deliveryOtp !== otp) throw new Error('Invalid OTP');
  }

  return prisma.booking.update({
    where: { id: bookingId },
    data: { status },
  });
}
```

**Step 2: Commit**
```bash
git add backend/src/services/booking.service.ts
git commit -m "feat(booking): add OTP verification for pickup and delivery"
```

---

### Task 5.2: Add OTP Input in Pilot App

**Files:**
- Modify: `pilot_app/lib/app/modules/jobs/views/active_job_view.dart`

**Step 1: Add OTP input dialog for pickup/delivery confirmation**

```dart
Future<void> _showOtpDialog(String action) async {
  final otpController = TextEditingController();

  final result = await Get.dialog<String>(
    AlertDialog(
      title: Text('Enter OTP for $action'),
      content: TextField(
        controller: otpController,
        keyboardType: TextInputType.number,
        maxLength: 6,
        decoration: const InputDecoration(
          hintText: 'Enter 6-digit OTP',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Get.back(result: otpController.text),
          child: const Text('Verify'),
        ),
      ],
    ),
  );

  if (result != null && result.length == 6) {
    controller.updateJobStatus(otp: result);
  }
}
```

**Step 2: Commit**
```bash
git add pilot_app/lib/app/modules/jobs/views/active_job_view.dart
git commit -m "feat(pilot-app): add OTP input dialog for pickup/delivery verification"
```

---

## Phase 6: Testing & Validation

### Task 6.1: Test Complete Flow

**Steps:**
1. Create a booking in user_app
2. Verify booking created notification received
3. Verify pilot receives job offer in pilot_app
4. Accept job in pilot_app
5. Verify user sees pilot assigned
6. Update status through each step with OTP verification
7. Complete delivery
8. Verify payment settled

### Task 6.2: Add Error Handling for Edge Cases

- Handle network disconnection during booking
- Handle app backgrounding during job offer
- Handle payment failure scenarios
- Handle pilot cancellation

---

## Summary

| Phase | Tasks | Priority | Impact |
|-------|-------|----------|--------|
| 1 | Auto-assignment | Critical | Enables entire flow |
| 2 | User socket | High | Real-time updates |
| 3 | Payment flow | High | Correct payment handling |
| 4 | Pilot job flow | High | Pilot can accept jobs |
| 5 | OTP verification | Medium | Security compliance |
| 6 | Testing | Medium | Quality assurance |

**Estimated Implementation:** 15-20 tasks across 6 phases
