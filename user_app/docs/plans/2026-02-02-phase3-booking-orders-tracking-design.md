# SendIt User App - Phase 3 Design Document

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Implement booking flow, order management, and real-time tracking with full experience features.

**Architecture:** Three parallel modules (Booking, Orders, Tracking) with shared services layer (Location, Socket, Maps, Payment). GetX state management with repository pattern.

**Tech Stack:** Flutter, GetX, Google Maps, Socket.io, Razorpay (placeholder), Geolocator

---

## Current Status (Pre-Phase 3)

### Completed Modules (45% Overall)
| Module | Status | API Integration |
|--------|--------|-----------------|
| Authentication | 100% ✅ | Connected |
| Profile Management | 100% ✅ | Connected |
| Address Management | 100% ✅ | Connected |
| Wallet | 100% ✅ | Connected |
| Home Dashboard | 30% ⏳ | Placeholder |

### Phase 3 Scope
| Module | Status | Priority |
|--------|--------|----------|
| Booking Flow | 0% → 100% | Critical |
| Order History | 0% → 100% | Critical |
| Real-time Tracking | 0% → 100% | Critical |

---

## 1. Architecture Overview

### Module Structure
```
Phase 3 Implementation
├── BOOKING MODULE (New)
│   ├── BookingController
│   ├── LocationService (Geolocation + Maps)
│   ├── PriceCalculationService
│   └── Views: CreateBooking → VehicleSelect → Payment → Confirmation
│
├── ORDERS MODULE (New)
│   ├── OrdersController
│   ├── Views: OrdersList → OrderDetails
│   └── Filters: All | Active | Completed | Cancelled
│
└── TRACKING MODULE (New)
    ├── TrackingController
    ├── SocketService (Real-time)
    ├── Views: LiveTrackingView (Map + Status + Driver)
    └── Features: ETA, Route Polyline, Driver Chat/Call
```

### Shared Services
- `LocationService` - Geolocation + Geocoding + Place search
- `SocketService` - Socket.io connection management
- `PaymentService` - Razorpay placeholder + Wallet integration
- `MapsService` - Google Maps controller utilities

### API Endpoints
- Booking: create, calculate-price, cancel
- Vehicles: get types
- Orders: list, details, track
- Socket events: driver-location, status-update, eta-update

---

## 2. Booking Flow Design (Hybrid - 4 Screens)

### Screen 1: Create Booking (Quick Entry)
```
┌─────────────────────────────────────────────────────────────────┐
│  📍 Pickup Location          [Select / Use Current Location]    │
│  📍 Drop Location            [Select from saved / Search]       │
│  📦 Package Type             [Dropdown: parcel, food, etc.]     │
│  📝 Package Description      [Optional text input]              │
│                    [ Continue → ]                               │
└─────────────────────────────────────────────────────────────────┘
```

### Screen 2: Vehicle Selection
```
┌─────────────────────────────────────────────────────────────────┐
│  ┌──────────┐ ┌──────────┐ ┌──────────┐                        │
│  │ 🏍️ Bike  │ │ 🚗 Car   │ │ 🚚 Van   │  ← Horizontal scroll   │
│  │ ₹49 base │ │ ₹99 base │ │ ₹199 base│                        │
│  │ 2kg max  │ │ 10kg max │ │ 50kg max │                        │
│  └──────────┘ └──────────┘ └──────────┘                        │
│  Distance: 5.2 km │ Est. Time: 25 min                          │
│  Total Price: ₹89 (base ₹49 + ₹8/km × 5km)                     │
│                    [ Select & Continue → ]                      │
└─────────────────────────────────────────────────────────────────┘
```

### Screen 3: Review & Payment
```
┌─────────────────────────────────────────────────────────────────┐
│  Booking Summary (pickup, drop, package, vehicle)               │
│  Payment Method:                                                │
│   ○ Wallet (Balance: ₹500) ✓ Sufficient                        │
│   ○ Cash on Delivery                                            │
│   ○ UPI (Razorpay) [Placeholder]                               │
│  💰 Apply Coupon [Enter code]                                   │
│                    [ Confirm Booking ₹89 → ]                    │
└─────────────────────────────────────────────────────────────────┘
```

### Screen 4: Finding Driver
```
┌─────────────────────────────────────────────────────────────────┐
│                    🔍                                           │
│            "Finding nearby drivers..."                          │
│                [Cancel Booking]                                 │
│  → Auto-navigates to Tracking Screen when driver accepts        │
└─────────────────────────────────────────────────────────────────┘
```

### BookingController State
```dart
// Observables
final pickupAddress = Rx<AddressModel?>(null);
final dropAddress = Rx<AddressModel?>(null);
final selectedPackageType = PackageType.parcel.obs;
final packageDescription = ''.obs;
final selectedVehicle = Rx<VehicleTypeModel?>(null);
final calculatedPrice = 0.0.obs;
final estimatedDistance = 0.0.obs;
final estimatedDuration = 0.obs; // minutes
final selectedPaymentMethod = PaymentMethod.wallet.obs;
final couponCode = ''.obs;
final bookingState = BookingState.idle.obs; // idle, calculating, booking, finding
```

---

## 3. Real-time Tracking Design (Full Experience)

### Tracking Screen Layout
```
┌─────────────────────────────────────────────────────────────────┐
│  ORDER #12345                              [←] Back to Orders   │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────────────┐│
│  │                    GOOGLE MAP VIEW                          ││
│  │         (Full width, ~50% screen height)                    ││
│  │    📍 Pickup ─────── 🛵 Driver ─────── 📍 Drop             ││
│  │         ◉──────────────●───────────────◎                   ││
│  │              (Route Polyline in primary color)              ││
│  └─────────────────────────────────────────────────────────────┘│
│  ┌─────────────────────────────────────────────────────────────┐│
│  │  ⏱️ ETA: 12 mins │ 📏 2.3 km away                          ││
│  └─────────────────────────────────────────────────────────────┘│
│  ┌─────────────────────────────────────────────────────────────┐│
│  │  STATUS: 🟢 PICKED UP - On the way to drop location        ││
│  │  ◉ Accepted → ◉ Arrived Pickup → ◉ Picked Up → ○ In Transit││
│  └─────────────────────────────────────────────────────────────┘│
├─────────────────────────────────────────────────────────────────┤
│  DRIVER INFO                                                    │
│  ┌────────┐  Rajesh Kumar           ⭐ 4.8                     │
│  │  👤    │  Honda Activa • GJ-01-XX-1234                      │
│  │ Avatar │  📞 Call          💬 Chat                          │
│  └────────┘                                                     │
├─────────────────────────────────────────────────────────────────┤
│  DELIVERY OTP: [ 4 ] [ 5 ] [ 2 ] [ 1 ]  ← Show when near drop  │
└─────────────────────────────────────────────────────────────────┘
```

### Socket Events
```dart
class SocketEvents {
  static const driverLocationUpdate = 'driver:location';    // {lat, lng, heading}
  static const statusUpdate = 'booking:status';             // {bookingId, status, timestamp}
  static const etaUpdate = 'booking:eta';                   // {bookingId, eta, distance}
  static const driverAssigned = 'booking:driver-assigned';  // {bookingId, pilot: {...}}
  static const bookingCompleted = 'booking:completed';      // {bookingId, summary}
  static const bookingCancelled = 'booking:cancelled';      // {bookingId, reason}
}
```

### TrackingController State
```dart
final booking = Rx<BookingModel?>(null);
final driverLocation = Rx<LatLng?>(null);
final driverHeading = 0.0.obs;
final currentEta = 0.obs;
final currentDistance = 0.0.obs;
final routePolyline = <LatLng>[].obs;
final isConnected = false.obs;

void connectToTracking(String bookingId);
void disconnectTracking();
void centerOnDriver();
void callDriver();
void openChat();
```

---

## 4. Order History Design (Simple List)

### Orders List Screen
```
┌─────────────────────────────────────────────────────────────────┐
│  My Orders                                          [🔍 Search] │
├─────────────────────────────────────────────────────────────────┤
│  FILTER: [All ▼]  [Active]  [Completed]  [Cancelled]           │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────────────┐│
│  │ 🟢 IN TRANSIT                           Today, 2:30 PM     ││
│  │ 📍 Vastrapur → 📍 Satellite                                ││
│  │ 📦 Parcel • 🏍️ Bike                                        ││
│  │ ₹89                                    [ Track Order → ]   ││
│  └─────────────────────────────────────────────────────────────┘│
│  ┌─────────────────────────────────────────────────────────────┐│
│  │ ✅ DELIVERED                            Yesterday, 5:15 PM ││
│  │ 📍 SG Highway → 📍 Prahlad Nagar                           ││
│  │ 📦 Food • 🏍️ Bike                                          ││
│  │ ₹65                         [ View Details ] [ Rebook → ]  ││
│  └─────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────┘
```

### Order Details Screen
- Full location details with pickup/drop times
- Package information
- Driver details with rating
- Payment breakdown
- Rate delivery + Rebook options

### OrdersController State
```dart
final orders = <BookingModel>[].obs;
final isLoading = false.obs;
final selectedFilter = OrderFilter.all.obs;
final currentPage = 1.obs;
final hasMorePages = true.obs;
final selectedOrder = Rx<BookingModel?>(null);

enum OrderFilter { all, active, completed, cancelled }

Future<void> fetchOrders({bool refresh = false});
Future<void> loadMoreOrders();
void filterOrders(OrderFilter filter);
Future<void> rebookOrder(BookingModel order);
```

---

## 5. Services Layer

### LocationService
```dart
class LocationService extends GetxService {
  final currentLocation = Rx<Position?>(null);
  final permissionGranted = false.obs;

  Future<Position?> getCurrentLocation();
  Future<bool> requestPermission();
  Future<List<PlaceSuggestion>> searchPlaces(String query);
  Future<AddressModel> getAddressFromCoordinates(double lat, double lng);
  Future<LatLng> getCoordinatesFromAddress(String address);
  Future<double> calculateDistance(LatLng from, LatLng to);
  Future<RouteInfo> getRouteInfo(LatLng from, LatLng to);
}
```

### SocketService
```dart
class SocketService extends GetxService {
  final isConnected = false.obs;
  final connectionError = Rx<String?>(null);

  Future<void> connect(String token);
  void disconnect();
  void joinBookingRoom(String bookingId);
  void leaveBookingRoom(String bookingId);

  Stream<DriverLocation> onDriverLocationUpdate();
  Stream<BookingStatus> onStatusUpdate();
  Stream<EtaUpdate> onEtaUpdate();
  Stream<PilotInfo> onDriverAssigned();
}
```

### PaymentService (Placeholder Ready)
```dart
class PaymentService extends GetxService {
  Future<bool> checkWalletBalance(double amount);
  Future<PaymentResult> payWithWallet(double amount, String bookingId);
  PaymentResult markCashPayment(String bookingId);

  // Razorpay Placeholder
  Future<PaymentResult> initiateRazorpay({
    required double amount,
    required String bookingId,
    required String description,
  }) async {
    throw UnimplementedError('Razorpay integration pending');
  }
}
```

### MapsService
```dart
class MapsService extends GetxService {
  List<LatLng> decodePolyline(String encoded);
  BitmapDescriptor getPickupMarker();
  BitmapDescriptor getDropMarker();
  BitmapDescriptor getDriverMarker(double heading);
  CameraUpdate fitBounds(LatLng point1, LatLng point2, {double padding = 50});
  String? getMapStyle(bool isDarkMode);
}
```

---

## 6. API Integration

### New Endpoints
```dart
class ApiConstants {
  // Booking
  static const String createBooking = '/bookings';
  static const String calculatePrice = '/bookings/calculate-price';
  static const String getBooking = '/bookings/{id}';
  static const String cancelBooking = '/bookings/{id}/cancel';

  // Vehicles
  static const String vehicleTypes = '/vehicles/types';

  // Orders
  static const String getOrders = '/bookings';
  static const String getOrderDetails = '/bookings/{id}';

  // Rating
  static const String rateDelivery = '/bookings/{id}/rate';
}
```

### BookingRepository
```dart
class BookingRepository {
  Future<PriceCalculation> calculatePrice({...});
  Future<BookingModel> createBooking(CreateBookingRequest request);
  Future<BookingModel> getBooking(String id);
  Future<void> cancelBooking(String id, {String? reason});
  Future<ApiResponse<List<BookingModel>>> getOrders({...});
  Future<List<VehicleTypeModel>> getVehicleTypes();
  Future<void> rateDelivery(String bookingId, int rating, {String? review});
}
```

---

## 7. File Structure

```
lib/app/
├── data/
│   └── repositories/
│       └── booking_repository.dart        # NEW
│
├── modules/
│   ├── booking/
│   │   ├── bindings/booking_binding.dart
│   │   ├── controllers/booking_controller.dart
│   │   └── views/
│   │       ├── create_booking_view.dart
│   │       ├── vehicle_selection_view.dart
│   │       ├── payment_view.dart
│   │       └── finding_driver_view.dart
│   │
│   ├── orders/
│   │   ├── bindings/orders_binding.dart
│   │   ├── controllers/orders_controller.dart
│   │   └── views/
│   │       ├── orders_view.dart
│   │       └── order_details_view.dart
│   │
│   └── tracking/
│       ├── bindings/tracking_binding.dart
│       ├── controllers/tracking_controller.dart
│       └── views/tracking_view.dart
│
├── services/
│   ├── location_service.dart
│   ├── socket_service.dart
│   ├── maps_service.dart
│   └── payment_service.dart
│
└── routes/app_pages.dart                  # Update routes
```

---

## 8. Implementation Order

### Week 1: Foundation
**Track A - Services Layer:**
- LocationService (geolocation + geocoding)
- MapsService (markers, polylines)
- SocketService (connection setup)

**Track B - Repository + Models:**
- BookingRepository
- PriceCalculation model

**Track C - Basic UI Shells:**
- Create booking screens (navigation flow)
- Orders list screen (empty state)
- Tracking screen (map placeholder)

### Week 2: Core Features
**Track A - Booking Flow:**
- CreateBookingView with location picker
- VehicleSelectionView with price calculation
- PaymentView with wallet integration

**Track B - Orders:**
- OrdersController with pagination
- OrdersView with filters
- OrderDetailsView

**Track C - Tracking:**
- TrackingController with socket events
- Live map with driver marker
- Status updates + ETA

### Week 3: Polish & Integration
- FindingDriverView animation
- Razorpay placeholder UI
- Rebook functionality
- Rate delivery flow
- Error handling & edge cases
- Testing & bug fixes

---

## 9. Payment Methods

| Method | Status | Implementation |
|--------|--------|----------------|
| Wallet | ✅ Ready | Use existing WalletController |
| Cash on Delivery | ✅ Ready | Mark as COD, no processing |
| UPI (Razorpay) | 🔧 Placeholder | UI ready, SDK pending |

---

## 10. Success Criteria

- [ ] User can create booking with pickup/drop locations
- [ ] User can select vehicle type and see calculated price
- [ ] User can pay via wallet or mark as COD
- [ ] User sees "finding driver" animation
- [ ] User receives real-time driver location updates
- [ ] User can see ETA and route on map
- [ ] User can call/chat with driver
- [ ] User can view order history with filters
- [ ] User can view detailed order information
- [ ] User can rebook previous orders
- [ ] User can rate completed deliveries

---

**Document Created:** February 2, 2026
**Author:** Claude (brainstorming session)
**Status:** Approved for Implementation
