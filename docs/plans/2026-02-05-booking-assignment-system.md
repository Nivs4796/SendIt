# Booking-to-Pilot Assignment System Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Implement complete booking-to-pilot automatic assignment flow with 30-second offer timeout, cascade to next pilot, 2-minute search window, and full real-time updates across user app, pilot app, and admin.

**Architecture:** Event-driven system using Socket.IO for real-time communication. When user creates booking, backend automatically finds nearby pilots, sends job offers sequentially with 30-second timeouts, cascades to next pilot on reject/timeout, and notifies user of all status changes. After 2 minutes with no acceptance, user can retry or cancel.

**Tech Stack:** Node.js/Express/TypeScript backend, Flutter/Dart mobile apps (GetX), Socket.IO, Prisma ORM, PostgreSQL

---

## System Flow Diagram

```
User Creates Booking
        │
        ▼
┌───────────────────┐
│ Backend: Booking  │
│   Created         │
└─────────┬─────────┘
          │
          ▼
┌───────────────────┐
│ Start Assignment  │
│   Queue           │
└─────────┬─────────┘
          │
          ▼
┌───────────────────┐     ┌─────────────────┐
│ Find Nearby       │────▶│ No Pilots Found │────▶ Notify User
│ Available Pilots  │     └─────────────────┘
└─────────┬─────────┘
          │ Pilots Found
          ▼
┌───────────────────┐
│ Send Offer to     │
│ Best Pilot        │
└─────────┬─────────┘
          │
          ▼
    ┌─────────────────────────────────────┐
    │         30 Second Timer             │
    └───────────┬───────────┬─────────────┘
                │           │
         Accept │           │ Reject/Timeout
                ▼           ▼
    ┌───────────────┐   ┌───────────────────┐
    │ Assign to     │   │ More Pilots       │
    │ Pilot         │   │ Available?        │
    └───────┬───────┘   └─────────┬─────────┘
            │                     │
            ▼               Yes   │   No
    ┌───────────────┐       ┌─────┴─────┐
    │ Notify User   │       │           ▼
    │ + Update      │   ┌───┴───┐   ┌───────────────┐
    │ Booking       │   │ Loop  │   │ 2 Min Timer   │
    └───────────────┘   └───────┘   │ Expired?      │
                                    └───────┬───────┘
                                            │
                                    Yes     │   No
                                    ┌───────┴───────┐
                                    ▼               ▼
                            ┌───────────────┐  Continue
                            │ Notify User   │  Searching
                            │ No Pilots     │
                            └───────────────┘
```

---

## Phase 1: Backend - Assignment Queue Service (NEW)

### Task 1.1: Create Assignment Queue Service

**Files:**
- Create: `backend/src/services/assignment-queue.service.ts`

**Step 1: Create the assignment queue service file**

```typescript
// backend/src/services/assignment-queue.service.ts
import prisma from '../config/database'
import logger from '../config/logger'
import { emitToUser, emitToPilot, emitToAdmin } from '../socket'
import { findAvailablePilots, createJobOffer } from './matching.service'
import { BookingStatus } from '@prisma/client'

// Configuration
const ASSIGNMENT_CONFIG = {
  OFFER_TIMEOUT_MS: 30 * 1000,        // 30 seconds per pilot
  MAX_SEARCH_TIME_MS: 2 * 60 * 1000,  // 2 minutes total search
  MAX_RETRY_ATTEMPTS: 10,              // Max pilots to try
  SEARCH_RADIUS_KM: 5,                 // Initial search radius
  MAX_RADIUS_KM: 15,                   // Maximum search radius
}

// Types
interface AssignmentJob {
  bookingId: string
  userId: string
  pickupLat: number
  pickupLng: number
  vehicleTypeId: string
  startedAt: Date
  currentPilotIndex: number
  triedPilotIds: Set<string>
  offerTimer: NodeJS.Timeout | null
  searchTimer: NodeJS.Timeout | null
  status: 'searching' | 'offered' | 'assigned' | 'failed' | 'cancelled'
}

// In-memory queue (use Redis in production for multi-instance)
const assignmentQueue = new Map<string, AssignmentJob>()

/**
 * Start the assignment process for a booking
 */
export async function startAssignment(bookingId: string): Promise<void> {
  // Get booking details
  const booking = await prisma.booking.findUnique({
    where: { id: bookingId },
    include: {
      pickupAddress: true,
      user: { select: { id: true, name: true } },
    },
  })

  if (!booking) {
    logger.error(`Assignment failed: Booking ${bookingId} not found`)
    return
  }

  if (booking.status !== BookingStatus.PENDING) {
    logger.warn(`Assignment skipped: Booking ${bookingId} is not pending`)
    return
  }

  // Create assignment job
  const job: AssignmentJob = {
    bookingId,
    userId: booking.userId,
    pickupLat: booking.pickupAddress.lat,
    pickupLng: booking.pickupAddress.lng,
    vehicleTypeId: booking.vehicleTypeId,
    startedAt: new Date(),
    currentPilotIndex: 0,
    triedPilotIds: new Set(),
    offerTimer: null,
    searchTimer: null,
    status: 'searching',
  }

  assignmentQueue.set(bookingId, job)

  // Notify user that search has started
  emitToUser(booking.userId, 'booking:search_started', {
    bookingId,
    message: 'Finding a driver for you...',
  })

  // Start the 2-minute overall search timer
  job.searchTimer = setTimeout(() => {
    handleSearchTimeout(bookingId)
  }, ASSIGNMENT_CONFIG.MAX_SEARCH_TIME_MS)

  logger.info(`Assignment started for booking ${bookingId}`)

  // Start finding pilots
  await findAndOfferToNextPilot(bookingId)
}

/**
 * Find next available pilot and send offer
 */
async function findAndOfferToNextPilot(bookingId: string): Promise<void> {
  const job = assignmentQueue.get(bookingId)
  if (!job || job.status === 'cancelled' || job.status === 'assigned') {
    return
  }

  // Check if max attempts reached
  if (job.triedPilotIds.size >= ASSIGNMENT_CONFIG.MAX_RETRY_ATTEMPTS) {
    handleNoPilotsAvailable(bookingId, 'Maximum retry attempts reached')
    return
  }

  // Find available pilots
  const pilots = await findAvailablePilots(
    job.pickupLat,
    job.pickupLng,
    job.vehicleTypeId,
    ASSIGNMENT_CONFIG.SEARCH_RADIUS_KM
  )

  // Filter out already tried pilots
  const availablePilots = pilots.filter(p => !job.triedPilotIds.has(p.id))

  if (availablePilots.length === 0) {
    // Try with larger radius
    const expandedPilots = await findAvailablePilots(
      job.pickupLat,
      job.pickupLng,
      job.vehicleTypeId,
      ASSIGNMENT_CONFIG.MAX_RADIUS_KM
    )

    const expandedAvailable = expandedPilots.filter(p => !job.triedPilotIds.has(p.id))

    if (expandedAvailable.length === 0) {
      handleNoPilotsAvailable(bookingId, 'No pilots available in your area')
      return
    }

    // Use first pilot from expanded search
    await sendOfferToPilot(bookingId, expandedAvailable[0].id)
    return
  }

  // Send offer to best available pilot
  await sendOfferToPilot(bookingId, availablePilots[0].id)
}

/**
 * Send job offer to specific pilot
 */
async function sendOfferToPilot(bookingId: string, pilotId: string): Promise<void> {
  const job = assignmentQueue.get(bookingId)
  if (!job || job.status === 'cancelled') return

  try {
    // Mark pilot as tried
    job.triedPilotIds.add(pilotId)
    job.status = 'offered'

    // Create the offer (this sends socket event to pilot)
    await createJobOffer(bookingId, pilotId)

    // Notify user about which pilot received the offer
    emitToUser(job.userId, 'booking:offer_sent', {
      bookingId,
      pilotNumber: job.triedPilotIds.size,
      message: `Offer sent to driver ${job.triedPilotIds.size}...`,
    })

    // Start 30-second timeout for this offer
    job.offerTimer = setTimeout(() => {
      handleOfferTimeout(bookingId, pilotId)
    }, ASSIGNMENT_CONFIG.OFFER_TIMEOUT_MS)

    logger.info(`Offer sent to pilot ${pilotId} for booking ${bookingId}`)
  } catch (error) {
    logger.error(`Failed to send offer to pilot ${pilotId}:`, error)
    // Try next pilot
    job.status = 'searching'
    await findAndOfferToNextPilot(bookingId)
  }
}

/**
 * Handle offer timeout (pilot didn't respond in 30 seconds)
 */
async function handleOfferTimeout(bookingId: string, pilotId: string): Promise<void> {
  const job = assignmentQueue.get(bookingId)
  if (!job || job.status === 'assigned' || job.status === 'cancelled') return

  logger.info(`Offer timeout for pilot ${pilotId} on booking ${bookingId}`)

  // Notify the pilot that their offer expired
  emitToPilot(pilotId, 'offer:expired', { bookingId })

  // Notify user
  emitToUser(job.userId, 'booking:offer_expired', {
    bookingId,
    message: 'Driver did not respond. Finding another driver...',
  })

  // Clear offer timer
  if (job.offerTimer) {
    clearTimeout(job.offerTimer)
    job.offerTimer = null
  }

  job.status = 'searching'

  // Find and offer to next pilot
  await findAndOfferToNextPilot(bookingId)
}

/**
 * Handle pilot accepting the job
 */
export async function handlePilotAccepted(bookingId: string, pilotId: string): Promise<void> {
  const job = assignmentQueue.get(bookingId)
  if (!job) return

  // Clear all timers
  if (job.offerTimer) clearTimeout(job.offerTimer)
  if (job.searchTimer) clearTimeout(job.searchTimer)

  job.status = 'assigned'

  // Get pilot details for notification
  const pilot = await prisma.pilot.findUnique({
    where: { id: pilotId },
    select: { id: true, name: true, phone: true, avatar: true, rating: true },
  })

  // Notify user
  emitToUser(job.userId, 'booking:driver_assigned', {
    bookingId,
    pilot: {
      id: pilot?.id,
      name: pilot?.name,
      phone: pilot?.phone,
      avatar: pilot?.avatar,
      rating: pilot?.rating,
    },
    message: `${pilot?.name} has accepted your booking!`,
  })

  // Notify admin dashboard
  emitToAdmin('booking:assigned', {
    bookingId,
    pilotId,
    pilotName: pilot?.name,
  })

  // Clean up
  assignmentQueue.delete(bookingId)

  logger.info(`Booking ${bookingId} assigned to pilot ${pilotId}`)
}

/**
 * Handle pilot declining the job
 */
export async function handlePilotDeclined(bookingId: string, pilotId: string): Promise<void> {
  const job = assignmentQueue.get(bookingId)
  if (!job || job.status === 'assigned' || job.status === 'cancelled') return

  logger.info(`Pilot ${pilotId} declined booking ${bookingId}`)

  // Clear offer timer
  if (job.offerTimer) {
    clearTimeout(job.offerTimer)
    job.offerTimer = null
  }

  // Notify user
  emitToUser(job.userId, 'booking:offer_declined', {
    bookingId,
    message: 'Driver declined. Finding another driver...',
  })

  job.status = 'searching'

  // Find and offer to next pilot
  await findAndOfferToNextPilot(bookingId)
}

/**
 * Handle 2-minute search timeout
 */
function handleSearchTimeout(bookingId: string): void {
  const job = assignmentQueue.get(bookingId)
  if (!job || job.status === 'assigned') return

  logger.warn(`Search timeout for booking ${bookingId}`)

  // Clear offer timer if exists
  if (job.offerTimer) clearTimeout(job.offerTimer)

  job.status = 'failed'

  // Notify user with retry option
  emitToUser(job.userId, 'booking:search_timeout', {
    bookingId,
    message: 'No drivers available at the moment. Would you like to try again?',
    canRetry: true,
    canCancel: true,
  })

  // Notify admin
  emitToAdmin('booking:search_timeout', {
    bookingId,
    triedPilots: job.triedPilotIds.size,
  })

  // Don't delete from queue yet - user might retry
}

/**
 * Handle no pilots available
 */
function handleNoPilotsAvailable(bookingId: string, reason: string): void {
  const job = assignmentQueue.get(bookingId)
  if (!job) return

  logger.warn(`No pilots available for booking ${bookingId}: ${reason}`)

  // Clear timers
  if (job.offerTimer) clearTimeout(job.offerTimer)
  if (job.searchTimer) clearTimeout(job.searchTimer)

  job.status = 'failed'

  // Notify user
  emitToUser(job.userId, 'booking:no_pilots', {
    bookingId,
    message: reason,
    canRetry: true,
    canCancel: true,
  })

  // Notify admin
  emitToAdmin('booking:no_pilots', {
    bookingId,
    reason,
    triedPilots: job.triedPilotIds.size,
  })
}

/**
 * User requests retry after timeout/failure
 */
export async function retryAssignment(bookingId: string): Promise<void> {
  const job = assignmentQueue.get(bookingId)

  if (job) {
    // Reset the job
    job.startedAt = new Date()
    job.triedPilotIds.clear()
    job.currentPilotIndex = 0
    job.status = 'searching'

    // Start new search timer
    job.searchTimer = setTimeout(() => {
      handleSearchTimeout(bookingId)
    }, ASSIGNMENT_CONFIG.MAX_SEARCH_TIME_MS)

    // Notify user
    emitToUser(job.userId, 'booking:search_started', {
      bookingId,
      message: 'Searching for drivers again...',
    })

    await findAndOfferToNextPilot(bookingId)
  } else {
    // Job was cleaned up, restart fresh
    await startAssignment(bookingId)
  }
}

/**
 * Cancel assignment (user cancelled booking)
 */
export function cancelAssignment(bookingId: string): void {
  const job = assignmentQueue.get(bookingId)
  if (!job) return

  logger.info(`Assignment cancelled for booking ${bookingId}`)

  // Clear all timers
  if (job.offerTimer) clearTimeout(job.offerTimer)
  if (job.searchTimer) clearTimeout(job.searchTimer)

  job.status = 'cancelled'

  // Clean up
  assignmentQueue.delete(bookingId)
}

/**
 * Get current assignment status for a booking
 */
export function getAssignmentStatus(bookingId: string): {
  isSearching: boolean
  triedPilots: number
  status: string
  elapsedMs: number
} | null {
  const job = assignmentQueue.get(bookingId)
  if (!job) return null

  return {
    isSearching: job.status === 'searching' || job.status === 'offered',
    triedPilots: job.triedPilotIds.size,
    status: job.status,
    elapsedMs: Date.now() - job.startedAt.getTime(),
  }
}
```

**Step 2: Verify syntax**

Run: `cd backend && npx tsc --noEmit src/services/assignment-queue.service.ts`
Expected: No errors

**Step 3: Commit**

```bash
git add backend/src/services/assignment-queue.service.ts
git commit -m "feat(backend): add assignment queue service for pilot matching"
```

---

### Task 1.2: Integrate Assignment Queue with Booking Service

**Files:**
- Modify: `backend/src/services/booking.service.ts`

**Step 1: Import and call assignment queue after booking creation**

Add at top of file:
```typescript
import { startAssignment, cancelAssignment } from './assignment-queue.service'
```

**Step 2: Modify createBooking function**

After line 155 (after tracking history created), replace TODO comments with:
```typescript
  // Start automatic pilot assignment
  // This runs asynchronously - don't await
  startAssignment(booking.id).catch(error => {
    logger.error(`Failed to start assignment for booking ${booking.id}:`, error)
  })

  // Emit booking created event to user
  emitToUser(userId, 'booking:created', {
    bookingId: booking.id,
    bookingNumber: booking.bookingNumber,
    status: booking.status,
    message: 'Booking created! Finding a driver...',
  })
```

**Step 3: Modify cancelBooking function**

After line 462 (before return), add:
```typescript
  // Cancel any ongoing assignment
  cancelAssignment(bookingId)
```

**Step 4: Run linting**

Run: `cd backend && npm run lint`
Expected: No errors

**Step 5: Commit**

```bash
git add backend/src/services/booking.service.ts
git commit -m "feat(backend): integrate assignment queue with booking creation"
```

---

### Task 1.3: Update Matching Service Response Handler

**Files:**
- Modify: `backend/src/services/matching.service.ts`

**Step 1: Import assignment queue handlers**

Add at top:
```typescript
import { handlePilotAccepted, handlePilotDeclined } from './assignment-queue.service'
```

**Step 2: Modify respondToJobOffer to notify assignment queue**

After line 431 (after offer.status = 'ACCEPTED'), add:
```typescript
    // Notify assignment queue
    await handlePilotAccepted(offer.bookingId, pilotId)
```

After line 439 (after offer.status = 'DECLINED'), add:
```typescript
    // Notify assignment queue to try next pilot
    await handlePilotDeclined(offer.bookingId, pilotId)
```

**Step 3: Run tests**

Run: `cd backend && npm run test`
Expected: All tests pass

**Step 4: Commit**

```bash
git add backend/src/services/matching.service.ts
git commit -m "feat(backend): connect matching service to assignment queue"
```

---

### Task 1.4: Add API Endpoint for Retry Assignment

**Files:**
- Modify: `backend/src/routes/booking.routes.ts`
- Modify: `backend/src/controllers/booking.controller.ts`

**Step 1: Add retry endpoint to routes**

```typescript
// POST /bookings/:id/retry-assignment
router.post('/:id/retry-assignment', authenticate, bookingController.retryAssignment)
```

**Step 2: Add controller method**

```typescript
export const retryAssignment = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { id } = req.params
    const userId = req.user!.id

    // Verify booking belongs to user and is still pending
    const booking = await prisma.booking.findFirst({
      where: { id, userId, status: 'PENDING' },
    })

    if (!booking) {
      throw new AppError('Booking not found or not pending', 404)
    }

    // Retry assignment
    await retryAssignmentService(id)

    res.json({
      success: true,
      message: 'Searching for drivers again...',
    })
  } catch (error) {
    next(error)
  }
}
```

**Step 3: Commit**

```bash
git add backend/src/routes/booking.routes.ts backend/src/controllers/booking.controller.ts
git commit -m "feat(backend): add retry assignment API endpoint"
```

---

## Phase 2: Backend - Socket Event Types

### Task 2.1: Add New Socket Event Types

**Files:**
- Modify: `backend/src/socket/types.ts`

**Step 1: Add new events to ServerToClientEvents**

```typescript
// Add to ServerToClientEvents interface
export interface ServerToClientEvents {
  // ... existing events ...

  // Assignment flow events (User)
  'booking:created': (data: BookingCreatedPayload) => void
  'booking:search_started': (data: SearchStatusPayload) => void
  'booking:offer_sent': (data: OfferSentPayload) => void
  'booking:offer_expired': (data: SearchStatusPayload) => void
  'booking:offer_declined': (data: SearchStatusPayload) => void
  'booking:driver_assigned': (data: DriverAssignedPayload) => void
  'booking:no_pilots': (data: NoPilotsPayload) => void
  'booking:search_timeout': (data: SearchTimeoutPayload) => void
}

// Add new payload types
export interface BookingCreatedPayload {
  bookingId: string
  bookingNumber: string
  status: string
  message: string
}

export interface SearchStatusPayload {
  bookingId: string
  message: string
}

export interface OfferSentPayload {
  bookingId: string
  pilotNumber: number
  message: string
}

export interface DriverAssignedPayload {
  bookingId: string
  pilot: {
    id: string
    name: string
    phone: string
    avatar: string | null
    rating: number
  }
  message: string
}

export interface NoPilotsPayload {
  bookingId: string
  message: string
  canRetry: boolean
  canCancel: boolean
}

export interface SearchTimeoutPayload {
  bookingId: string
  message: string
  canRetry: boolean
  canCancel: boolean
}
```

**Step 2: Commit**

```bash
git add backend/src/socket/types.ts
git commit -m "feat(backend): add socket event types for assignment flow"
```

---

## Phase 3: User App - Socket Integration

### Task 3.1: Add Assignment Events to Socket Service

**Files:**
- Modify: `user_app/lib/app/services/socket_service.dart`

**Step 1: Add stream controllers for assignment events**

```dart
// Add to class fields
final _searchStartedController = StreamController<Map<String, dynamic>>.broadcast();
final _offerSentController = StreamController<Map<String, dynamic>>.broadcast();
final _driverAssignedController = StreamController<DriverAssignedData>.broadcast();
final _noPilotsController = StreamController<Map<String, dynamic>>.broadcast();
final _searchTimeoutController = StreamController<Map<String, dynamic>>.broadcast();

// Add getters
Stream<Map<String, dynamic>> get searchStartedStream => _searchStartedController.stream;
Stream<Map<String, dynamic>> get offerSentStream => _offerSentController.stream;
Stream<DriverAssignedData> get driverAssignedStream => _driverAssignedController.stream;
Stream<Map<String, dynamic>> get noPilotsStream => _noPilotsController.stream;
Stream<Map<String, dynamic>> get searchTimeoutStream => _searchTimeoutController.stream;
```

**Step 2: Add event listeners in _setupEventListeners**

```dart
// Assignment events
_socket?.on('booking:search_started', (data) {
  if (data != null) {
    _searchStartedController.add(Map<String, dynamic>.from(data));
  }
});

_socket?.on('booking:offer_sent', (data) {
  if (data != null) {
    _offerSentController.add(Map<String, dynamic>.from(data));
  }
});

_socket?.on('booking:driver_assigned', (data) {
  if (data != null) {
    _driverAssignedController.add(DriverAssignedData.fromJson(data));
  }
});

_socket?.on('booking:no_pilots', (data) {
  if (data != null) {
    _noPilotsController.add(Map<String, dynamic>.from(data));
  }
});

_socket?.on('booking:search_timeout', (data) {
  if (data != null) {
    _searchTimeoutController.add(Map<String, dynamic>.from(data));
  }
});
```

**Step 3: Add DriverAssignedData class**

```dart
class DriverAssignedData {
  final String bookingId;
  final String pilotId;
  final String pilotName;
  final String pilotPhone;
  final String? pilotAvatar;
  final double pilotRating;
  final String message;

  DriverAssignedData({
    required this.bookingId,
    required this.pilotId,
    required this.pilotName,
    required this.pilotPhone,
    this.pilotAvatar,
    required this.pilotRating,
    required this.message,
  });

  factory DriverAssignedData.fromJson(Map<String, dynamic> json) {
    final pilot = json['pilot'] as Map<String, dynamic>? ?? {};
    return DriverAssignedData(
      bookingId: json['bookingId'] as String,
      pilotId: pilot['id'] as String? ?? '',
      pilotName: pilot['name'] as String? ?? 'Driver',
      pilotPhone: pilot['phone'] as String? ?? '',
      pilotAvatar: pilot['avatar'] as String?,
      pilotRating: (pilot['rating'] as num?)?.toDouble() ?? 0.0,
      message: json['message'] as String? ?? '',
    );
  }
}
```

**Step 4: Dispose controllers in onClose**

```dart
@override
void onClose() {
  _searchStartedController.close();
  _offerSentController.close();
  _driverAssignedController.close();
  _noPilotsController.close();
  _searchTimeoutController.close();
  // ... existing cleanup
  super.onClose();
}
```

**Step 5: Commit**

```bash
git add user_app/lib/app/services/socket_service.dart
git commit -m "feat(user-app): add socket events for assignment flow"
```

---

### Task 3.2: Update Finding Driver View with Real-time Status

**Files:**
- Modify: `user_app/lib/app/modules/booking/views/finding_driver_view.dart`

**Step 1: Add subscription for all assignment events**

```dart
// Add to class fields
StreamSubscription<Map<String, dynamic>>? _offerSentSubscription;
StreamSubscription<Map<String, dynamic>>? _noPilotsSubscription;
StreamSubscription<Map<String, dynamic>>? _searchTimeoutSubscription;

// Add state variables
String _statusMessage = 'Finding a driver for you...';
int _pilotsTriedCount = 0;
bool _showRetryOptions = false;
```

**Step 2: Setup listeners in initState**

```dart
void _listenForAssignmentEvents() {
  // Existing driver assigned listener...

  _offerSentSubscription = _socketService.offerSentStream.listen((data) {
    if (mounted && data['bookingId'] == _bookingController.currentBooking.value?.id) {
      setState(() {
        _pilotsTriedCount = data['pilotNumber'] as int? ?? _pilotsTriedCount;
        _statusMessage = data['message'] as String? ?? _statusMessage;
      });
    }
  });

  _noPilotsSubscription = _socketService.noPilotsStream.listen((data) {
    if (mounted && data['bookingId'] == _bookingController.currentBooking.value?.id) {
      setState(() {
        _statusMessage = data['message'] as String? ?? 'No drivers available';
        _showRetryOptions = data['canRetry'] as bool? ?? true;
      });
    }
  });

  _searchTimeoutSubscription = _socketService.searchTimeoutStream.listen((data) {
    if (mounted && data['bookingId'] == _bookingController.currentBooking.value?.id) {
      setState(() {
        _statusMessage = data['message'] as String? ?? 'Search timed out';
        _showRetryOptions = data['canRetry'] as bool? ?? true;
      });
    }
  });
}
```

**Step 3: Add retry functionality**

```dart
Future<void> _retrySearch() async {
  setState(() {
    _showRetryOptions = false;
    _statusMessage = 'Searching again...';
    _searchDuration = 0;
    _pilotsTriedCount = 0;
  });

  try {
    await _bookingController.retryAssignment();
  } catch (e) {
    setState(() {
      _statusMessage = 'Failed to retry. Please try again.';
      _showRetryOptions = true;
    });
  }
}
```

**Step 4: Update UI to show retry buttons**

```dart
// In build method, add retry UI when _showRetryOptions is true
if (_showRetryOptions)
  Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      children: [
        AppButton.primary(
          text: 'Try Again',
          onPressed: _retrySearch,
          icon: Icons.refresh_rounded,
        ),
        const SizedBox(height: 12),
        AppButton.outline(
          text: 'Cancel Booking',
          onPressed: _showCancelDialog,
          borderColor: AppColors.error,
          textColor: AppColors.error,
        ),
      ],
    ),
  )
```

**Step 5: Dispose new subscriptions**

```dart
@override
void dispose() {
  _offerSentSubscription?.cancel();
  _noPilotsSubscription?.cancel();
  _searchTimeoutSubscription?.cancel();
  // ... existing cleanup
  super.dispose();
}
```

**Step 6: Commit**

```bash
git add user_app/lib/app/modules/booking/views/finding_driver_view.dart
git commit -m "feat(user-app): add real-time status updates during driver search"
```

---

### Task 3.3: Add Retry Method to Booking Repository

**Files:**
- Modify: `user_app/lib/app/data/repositories/booking_repository.dart`

**Step 1: Add retryAssignment method**

```dart
/// Retry driver assignment for a pending booking
Future<ApiResponse<void>> retryAssignment(String bookingId) async {
  try {
    final response = await _apiClient.post(
      '/bookings/$bookingId/retry-assignment',
    );

    return ApiResponse(
      success: response.data['success'] == true,
      message: response.data['message'],
    );
  } on DioException catch (e) {
    throw ApiException.fromDioError(e);
  }
}
```

**Step 2: Add retryAssignment to BookingController**

```dart
/// Retry finding a driver
Future<void> retryAssignment() async {
  if (currentBooking.value == null) return;

  try {
    bookingState.value = BookingState.findingDriver;
    await _bookingRepository.retryAssignment(currentBooking.value!.id);
  } catch (e) {
    _showError('Failed to retry: ${e.toString()}');
    rethrow;
  }
}
```

**Step 3: Commit**

```bash
git add user_app/lib/app/data/repositories/booking_repository.dart
git add user_app/lib/app/modules/booking/controllers/booking_controller.dart
git commit -m "feat(user-app): add retry assignment functionality"
```

---

## Phase 4: Pilot App - Job Offer Handling

### Task 4.1: Update Jobs Controller for Timeout Display

**Files:**
- Modify: `pilot_app/lib/app/modules/jobs/controllers/jobs_controller.dart`

**Step 1: Add countdown timer for offer**

```dart
// Add to class fields
Timer? _offerCountdownTimer;
final offerRemainingSeconds = 0.obs;

// Add method to start countdown
void _startOfferCountdown(JobOffer offer) {
  _offerCountdownTimer?.cancel();
  offerRemainingSeconds.value = offer.remainingSeconds;

  _offerCountdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
    if (offerRemainingSeconds.value > 0) {
      offerRemainingSeconds.value--;
    } else {
      timer.cancel();
      // Auto-handle expired offer
      if (currentOffer.value?.bookingId == offer.bookingId) {
        _handleOfferExpired(offer.bookingId);
      }
    }
  });
}
```

**Step 2: Call countdown when showing offer**

In `_handleBookingOffer`, after adding to queue:
```dart
// Start countdown timer
_startOfferCountdown(offer);
```

**Step 3: Update dispose**

```dart
@override
void onClose() {
  _offerCountdownTimer?.cancel();
  _locationTimer?.cancel();
  super.onClose();
}
```

**Step 4: Commit**

```bash
git add pilot_app/lib/app/modules/jobs/controllers/jobs_controller.dart
git commit -m "feat(pilot-app): add countdown timer for job offers"
```

---

### Task 4.2: Update Job Offer Popup with Countdown

**Files:**
- Modify: `pilot_app/lib/app/modules/jobs/widgets/job_offer_popup.dart`

**Step 1: Add countdown display to popup**

```dart
// Add countdown timer display
Obx(() {
  final remaining = jobsController.offerRemainingSeconds.value;
  final progress = remaining / 30.0; // 30 seconds total

  return Column(
    children: [
      // Circular progress indicator
      Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 4,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation(
                remaining <= 10 ? Colors.red : Colors.green,
              ),
            ),
          ),
          Text(
            '$remaining',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: remaining <= 10 ? Colors.red : null,
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Text(
        'seconds to respond',
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 12,
        ),
      ),
    ],
  );
})
```

**Step 2: Commit**

```bash
git add pilot_app/lib/app/modules/jobs/widgets/job_offer_popup.dart
git commit -m "feat(pilot-app): add countdown timer display to job offer popup"
```

---

## Phase 5: Admin Dashboard Events (Optional)

### Task 5.1: Add Admin Socket Events for Monitoring

**Files:**
- Modify: `backend/src/socket/handlers/admin.handler.ts`

**Step 1: Add assignment monitoring events**

```typescript
// Admin can listen to assignment events for monitoring
socket.on('admin:subscribe_assignments', () => {
  if (socket.data.user.type !== 'admin') return
  socket.join('admin:assignments')
  logger.info('Admin subscribed to assignment events')
})
```

**Step 2: Emit assignment events to admin room**

The assignment-queue.service.ts already emits to admin. This task ensures admins can monitor:
- Total pending bookings
- Active assignments
- Failed assignments
- Success rate

**Step 3: Commit**

```bash
git add backend/src/socket/handlers/admin.handler.ts
git commit -m "feat(backend): add admin socket events for assignment monitoring"
```

---

## Phase 6: Testing & Validation

### Task 6.1: Manual Test Flow

**Test Scenario 1: Successful Assignment**
1. User creates booking in user_app
2. Verify "Finding Driver" screen shows with timer
3. Go online in pilot_app
4. Verify job offer popup appears with 30s countdown
5. Accept the job
6. Verify user_app navigates to tracking screen
7. Verify pilot_app navigates to active job screen

**Test Scenario 2: Pilot Rejects**
1. User creates booking
2. Pilot rejects the offer
3. Verify user sees "Finding another driver..." message
4. Verify offer goes to next pilot

**Test Scenario 3: Offer Timeout**
1. User creates booking
2. Pilot doesn't respond for 30 seconds
3. Verify offer expires and goes to next pilot
4. Verify user sees pilot count increment

**Test Scenario 4: No Pilots Available**
1. Ensure no pilots are online
2. User creates booking
3. Verify user sees "No drivers available" after search
4. Verify retry button appears
5. Tap retry, verify search restarts

**Test Scenario 5: Search Timeout**
1. User creates booking
2. All pilots reject/timeout within 2 minutes
3. Verify user sees "Search timed out" message
4. Verify retry and cancel buttons appear

**Test Scenario 6: User Cancels During Search**
1. User creates booking
2. While searching, user cancels
3. Verify booking is cancelled
4. Verify assignment queue is cleaned up

### Task 6.2: Add Logging for Debugging

Ensure all critical points have logging:
- Booking created
- Assignment started
- Pilot found/not found
- Offer sent
- Offer accepted/declined/expired
- Assignment completed/failed

---

---

## Phase 7: UI Improvements - Pilot App (CRITICAL)

The pilot app has significant theme compliance issues that break dark mode.

### Task 7.1: Fix Active Job View Theme Compliance

**Files:**
- Modify: `pilot_app/lib/app/modules/jobs/views/active_job_view.dart`

**Step 1: Fix scaffold background color (Line 23)**

Replace:
```dart
backgroundColor: Colors.grey.shade100,
```
With:
```dart
backgroundColor: theme.scaffoldBackgroundColor,
```

And add `final theme = Theme.of(context);` at the start of build method.

**Step 2: Fix AppBar colors (Lines 99-100)**

Replace:
```dart
backgroundColor: AppColors.primary,
foregroundColor: Colors.white,
```
With:
```dart
backgroundColor: theme.colorScheme.primary,
foregroundColor: theme.colorScheme.onPrimary,
```

**Step 3: Fix text style colors throughout**

Replace all instances of:
```dart
color: Colors.grey.shade600,
```
With:
```dart
color: theme.colorScheme.onSurfaceVariant,
```

**Step 4: Fix divider colors (Lines 337-341)**

Replace:
```dart
color: Colors.grey.shade300,
```
With:
```dart
color: theme.dividerColor,
```

**Step 5: Fix card backgrounds**

Add theme-aware styling to all Card widgets:
```dart
Card(
  color: theme.cardColor,
  elevation: theme.brightness == Brightness.dark ? 0 : 1,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
    side: theme.brightness == Brightness.dark
        ? BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.15))
        : BorderSide.none,
  ),
  child: ...
)
```

**Step 6: Fix bottom action container (Lines 594-605)**

Replace:
```dart
color: Colors.white,
```
With:
```dart
color: theme.cardColor,
```

**Step 7: Fix hardcoded semantic colors**

Replace all `Colors.green`, `Colors.blue`, `Colors.orange`, `Colors.red` with theme-aware alternatives:
```dart
// Use these semantic colors from theme
final successColor = theme.brightness == Brightness.dark
    ? const Color(0xFF34D399)
    : AppColors.success;
final infoColor = theme.brightness == Brightness.dark
    ? const Color(0xFF60A5FA)
    : AppColors.info;
final warningColor = theme.brightness == Brightness.dark
    ? const Color(0xFFFBBF24)
    : AppColors.warning;
final errorColor = theme.brightness == Brightness.dark
    ? const Color(0xFFF87171)
    : AppColors.error;
```

**Step 8: Fix COD card styling (Lines 540-591)**

Replace hardcoded orange colors with theme-aware warning colors:
```dart
Widget _buildCodCard(BuildContext context, JobModel job) {
  final theme = Theme.of(context);
  final warningColor = theme.brightness == Brightness.dark
      ? const Color(0xFFFBBF24)
      : AppColors.warning;

  return Card(
    color: warningColor.withValues(alpha: 0.1),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: warningColor.withValues(alpha: 0.3)),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: warningColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.payments, color: warningColor, size: 24),
          ),
          // ... rest unchanged but use warningColor
        ],
      ),
    ),
  );
}
```

**Step 9: Commit**

```bash
git add pilot_app/lib/app/modules/jobs/views/active_job_view.dart
git commit -m "fix(pilot-app): make active job view fully theme-aware for dark mode"
```

---

### Task 7.2: Fix Job Offer Popup Theme Compliance

**Files:**
- Modify: `pilot_app/lib/app/modules/jobs/widgets/job_offer_popup.dart`

**Step 1: Fix dialog container (Lines 84-95)**

Replace:
```dart
decoration: BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(20),
  ...
)
```
With:
```dart
decoration: BoxDecoration(
  color: theme.cardColor,
  borderRadius: BorderRadius.circular(20),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withValues(alpha: theme.brightness == Brightness.dark ? 0.4 : 0.2),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
  ],
)
```

**Step 2: Fix timer header (Lines 136-194)**

Make the header gradient theme-aware:
```dart
Widget _buildTimerHeader(BuildContext context) {
  final theme = Theme.of(context);
  final isUrgent = _remainingSeconds <= 10;
  final headerColor = isUrgent
      ? (theme.brightness == Brightness.dark ? const Color(0xFFF87171) : AppColors.error)
      : theme.colorScheme.primary;

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 16),
    decoration: BoxDecoration(
      color: headerColor,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
    ),
    child: ...
  );
}
```

**Step 3: Fix info card colors (Lines 221-253)**

Pass theme to the method and use theme-aware colors:
```dart
Widget _buildInfoCard(BuildContext context, {
  required IconData icon,
  required String label,
  required String value,
  required Color color,
}) {
  final theme = Theme.of(context);

  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withValues(alpha: 0.2)),
    ),
    child: Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.h3.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    ),
  );
}
```

**Step 4: Fix package info container (Lines 323-343)**

Replace:
```dart
color: Colors.grey.shade100,
```
With:
```dart
color: theme.colorScheme.surfaceContainerHighest,
```

**Step 5: Fix dotted line painter (Lines 383-406)**

Make color theme-aware:
```dart
class _DottedLinePainter extends CustomPainter {
  final Color color;
  _DottedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    // ... rest unchanged
  }
}

// Usage:
CustomPaint(
  painter: _DottedLinePainter(color: theme.dividerColor),
)
```

**Step 6: Commit**

```bash
git add pilot_app/lib/app/modules/jobs/widgets/job_offer_popup.dart
git commit -m "fix(pilot-app): make job offer popup fully theme-aware"
```

---

### Task 7.3: Fix Job Status Stepper Theme Compliance

**Files:**
- Modify: `pilot_app/lib/app/modules/jobs/widgets/job_status_stepper.dart`

**Step 1: Add theme parameter**

```dart
class JobStatusStepper extends StatelessWidget {
  final JobStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Use theme.colorScheme.primary instead of AppColors.primary
    // Use theme.dividerColor instead of Colors.grey.shade300
    // Use theme.colorScheme.onSurfaceVariant instead of Colors.grey.shade600
  }
}
```

**Step 2: Commit**

```bash
git add pilot_app/lib/app/modules/jobs/widgets/job_status_stepper.dart
git commit -m "fix(pilot-app): make job status stepper theme-aware"
```

---

## Phase 8: UI Improvements - User App

### Task 8.1: Fix Finding Driver View Minor Issues

**Files:**
- Modify: `user_app/lib/app/modules/booking/views/finding_driver_view.dart`

**Step 1: Fix hardcoded AppColors in cancel button (Line 268)**

Replace:
```dart
AppButton.outline(
  text: 'Cancel Booking',
  onPressed: _showCancelDialog,
  borderColor: AppColors.error,
  textColor: AppColors.error,
  icon: Icons.close_rounded,
)
```
With:
```dart
AppButton.outline(
  text: 'Cancel Booking',
  onPressed: _showCancelDialog,
  borderColor: theme.brightness == Brightness.dark
      ? const Color(0xFFF87171)
      : AppColors.error,
  textColor: theme.brightness == Brightness.dark
      ? const Color(0xFFF87171)
      : AppColors.error,
  icon: Icons.close_rounded,
)
```

**Step 2: Fix location marker colors (Lines 411-423)**

Use semantic colors that work in both themes.

**Step 3: Commit**

```bash
git add user_app/lib/app/modules/booking/views/finding_driver_view.dart
git commit -m "fix(user-app): improve theme compliance in finding driver view"
```

---

### Task 8.2: Fix Tracking View Minor Issues

**Files:**
- Modify: `user_app/lib/app/modules/tracking/views/tracking_view.dart`

**Step 1: Fix hardcoded colors in call button (Lines 664-677)**

Replace:
```dart
color: AppColors.successLight,
```
With:
```dart
color: theme.brightness == Brightness.dark
    ? const Color(0xFF34D399).withValues(alpha: 0.2)
    : AppColors.successLight,
```

**Step 2: Fix info icon container (Lines 373-383)**

Use theme-aware colors for the distance card.

**Step 3: Commit**

```bash
git add user_app/lib/app/modules/tracking/views/tracking_view.dart
git commit -m "fix(user-app): improve theme compliance in tracking view"
```

---

## Phase 9: Shared UI Components

### Task 9.1: Fix Text Styles for Dark Mode

**Files:**
- Modify: `pilot_app/lib/app/core/theme/app_text_styles.dart`
- Modify: `user_app/lib/app/core/theme/app_text_styles.dart`

**Issue:** All text styles hardcode `AppColors.textPrimary` which doesn't adapt to dark mode.

**Solution:** Remove hardcoded colors from text styles and let the theme handle it:

```dart
// BEFORE (problematic)
static TextStyle h1 = const TextStyle(
  fontSize: 32,
  fontWeight: FontWeight.bold,
  color: AppColors.textPrimary, // ❌ Always black
);

// AFTER (correct)
static TextStyle h1 = const TextStyle(
  fontSize: 32,
  fontWeight: FontWeight.bold,
  // No color - let theme handle it
);
```

**Alternative:** Create a helper method:
```dart
static TextStyle h1WithColor(BuildContext context) {
  final scheme = AppColorScheme.of(context);
  return TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: scheme.textPrimary,
  );
}
```

**Step 2: Commit**

```bash
git add pilot_app/lib/app/core/theme/app_text_styles.dart
git add user_app/lib/app/core/theme/app_text_styles.dart
git commit -m "fix(theme): remove hardcoded text colors for dark mode support"
```

---

## Summary

| Phase | Tasks | Description |
|-------|-------|-------------|
| 1 | 1.1-1.4 | Backend Assignment Queue Service |
| 2 | 2.1 | Socket Event Types |
| 3 | 3.1-3.3 | User App Socket Integration |
| 4 | 4.1-4.2 | Pilot App Countdown Timer |
| 5 | 5.1 | Admin Monitoring (Optional) |
| 6 | 6.1-6.2 | Testing & Validation |
| **7** | **7.1-7.3** | **Pilot App UI Fixes (CRITICAL)** |
| **8** | **8.1-8.2** | **User App UI Fixes** |
| **9** | **9.1** | **Shared Theme Fixes** |

**Key Socket Events:**

| Event | Direction | Description |
|-------|-----------|-------------|
| `booking:created` | Server→User | Booking created, search starting |
| `booking:search_started` | Server→User | Search has begun |
| `booking:offer_sent` | Server→User | Offer sent to pilot N |
| `booking:offer` | Server→Pilot | New job offer |
| `offer:expired` | Server→Pilot | Offer timed out |
| `booking:driver_assigned` | Server→User | Driver accepted |
| `booking:no_pilots` | Server→User | No drivers available |
| `booking:search_timeout` | Server→User | 2-minute search expired |

**Configuration Parameters:**
- Offer timeout: 30 seconds
- Search timeout: 2 minutes
- Max retry attempts: 10 pilots
- Initial search radius: 5km
- Max search radius: 15km
