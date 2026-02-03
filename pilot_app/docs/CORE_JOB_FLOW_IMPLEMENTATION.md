# Core Job Flow Implementation Plan

> **Goal**: Build complete job management from receiving offers to delivery completion
> **Approach**: Production-ready with all edge cases handled

---

## 1. Components to Build

### Services
- `SocketService` - WebSocket connection management
- `LocationService` - GPS tracking with background support

### Repositories  
- `JobRepository` - Job API calls (accept, decline, status update, photo upload)

### Controllers
- `JobController` - Global job state management (active jobs, incoming offers)

### Widgets
- `JobOfferPopup` - Incoming job modal with countdown
- `ActiveJobCard` - Job info card for home screen
- `JobStatusStepper` - Visual status progression

### Screens
- `ActiveJobScreen` - Full job management with map & actions

---

## 2. WebSocket Events (Backend ↔ App)

### App → Backend (Emit)
| Event | Data | When |
|-------|------|------|
| `pilot:online` | `{ vehicleId }` | Toggle online |
| `pilot:offline` | - | Toggle offline |
| `pilot:location` | `{ lat, lng, heading, speed }` | Every 5 sec when online |

### Backend → App (Listen)
| Event | Data | Action |
|-------|------|--------|
| `booking:offer` | `{ bookingId, pickupAddress, dropAddress, distance, totalAmount, packageType, expiresAt }` | Show popup |
| `offer:expired` | `{ bookingId }` | Remove popup |
| `booking:status` | `{ bookingId, status, ... }` | Update UI |
| `notification` | `{ title, body, type, data }` | Show notification |
| `error` | `{ code, message }` | Handle error |

---

## 3. Job Status Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                         JOB LIFECYCLE                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  [OFFER RECEIVED] ──30s timer──> [AUTO-DECLINED]               │
│        │                                                        │
│        ▼ Accept                                                 │
│  [ASSIGNED] ────────> [NAVIGATING_TO_PICKUP]                   │
│                              │                                  │
│                              ▼ Arrived                          │
│                       [ARRIVED_AT_PICKUP]                       │
│                              │                                  │
│                              ▼ Collect + Photo (optional)       │
│                       [PACKAGE_COLLECTED]                       │
│                              │                                  │
│                              ▼ Start delivery                   │
│                         [IN_TRANSIT]                            │
│                              │                                  │
│                              ▼ Arrived                          │
│                       [ARRIVED_AT_DROP]                         │
│                              │                                  │
│                              ▼ Deliver + Photo (required)       │
│                         [DELIVERED] ✓                           │
│                                                                 │
│  ──── Any active state can transition to [CANCELLED] ────      │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 4. Edge Cases to Handle

### Connection
- [ ] No internet → Queue actions, sync when online
- [ ] WebSocket disconnect → Auto-reconnect with backoff
- [ ] App killed while online → Backend grace period (30s)
- [ ] Token expired → Refresh or re-login

### Job Offers
- [ ] Multiple offers at once → Queue, show one at a time
- [ ] Offer received while app in background → Push notification + sound
- [ ] Accept failed (already taken) → Show error, remove offer
- [ ] Countdown reaches 0 → Auto-decline, remove popup

### Active Job
- [ ] Customer cancels mid-delivery → Notify pilot, update UI
- [ ] Pilot cancels → Confirm dialog, API call, return to home
- [ ] GPS signal lost → Show warning, use last known location
- [ ] Photo upload fails → Retry queue, allow manual retry
- [ ] COD amount mismatch → Allow pilot to report issue

### Navigation
- [ ] Google Maps not installed → Fallback to in-app map
- [ ] Location permission denied → Show settings prompt
- [ ] Background location denied → Warn, allow foreground only

---

## 5. File Structure

```
lib/app/
├── services/
│   ├── socket_service.dart        # NEW - WebSocket management
│   └── location_service.dart      # NEW - GPS tracking
│
├── data/
│   └── repositories/
│       └── job_repository.dart    # NEW - Job API calls
│
├── modules/
│   └── jobs/
│       ├── bindings/
│       │   └── jobs_binding.dart
│       ├── controllers/
│       │   └── jobs_controller.dart   # Global job state
│       ├── views/
│       │   └── active_job_view.dart   # Active job screen
│       └── widgets/
│           ├── job_offer_popup.dart   # Incoming job modal
│           ├── job_info_card.dart     # Job details card
│           ├── job_status_stepper.dart
│           ├── job_action_button.dart
│           └── delivery_photo_capture.dart
│
└── core/
    └── constants/
        └── socket_events.dart     # NEW - Event constants
```

---

## 6. API Endpoints Used

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/bookings/:id/accept` | POST | Accept job offer |
| `/bookings/:id/status` | PATCH | Update job status |
| `/bookings/:id` | GET | Get job details |
| `/pilots/bookings` | GET | Get pilot's jobs (active/history) |
| `/upload/document` | POST | Upload delivery photo |

---

## 7. Implementation Order

### Step 1: Socket Service (Foundation)
- Connect/disconnect logic
- Auto-reconnect with exponential backoff
- Event listeners setup
- Token refresh handling

### Step 2: Job Repository
- Accept/decline job
- Update status
- Upload photo
- Get job details
- Get jobs list

### Step 3: Jobs Controller
- Incoming offers queue
- Active job state
- Job history
- Integration with socket events

### Step 4: Location Service
- Foreground tracking
- Background tracking (when online)
- Permission handling
- Battery optimization

### Step 5: Job Offer Popup
- Countdown timer
- Accept/decline actions
- Multiple offers queue
- Animations

### Step 6: Active Job Screen
- Map with route
- Status stepper
- Action buttons per status
- Customer contact
- Photo capture
- COD handling

### Step 7: Integration
- Home screen updates
- Push notifications
- Background handling

---

## 8. Dependencies Needed

```yaml
# Already have
socket_io_client: ^2.0.3+1
geolocator: ^10.1.0
image_picker: ^1.0.4

# May need to add
google_maps_flutter: ^2.5.0      # For in-app map
url_launcher: ^6.2.1             # For external navigation
permission_handler: ^11.1.0      # Location permissions
audioplayers: ^5.2.1             # Job offer sound
vibration: ^1.8.4                # Haptic feedback
```

---

## 9. Testing Checklist

- [ ] Go online/offline toggle
- [ ] Receive job offer popup
- [ ] Accept job → navigates to active job
- [ ] Decline job → popup closes
- [ ] Offer timeout → auto-decline
- [ ] All status transitions work
- [ ] Photo capture & upload
- [ ] COD collection flow
- [ ] Cancel job with confirmation
- [ ] Customer call button
- [ ] Navigate button opens maps
- [ ] Background location updates
- [ ] Reconnect after disconnect
- [ ] Handle customer cancellation
- [ ] Error states for all API calls

---

**Ready to implement!**
