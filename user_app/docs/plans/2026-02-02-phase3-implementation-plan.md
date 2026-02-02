# Phase 3 Implementation Plan - Booking, Orders & Tracking

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Implement complete booking flow, order management, and real-time tracking with live maps, driver info, and chat/call features.

**Architecture:** Three parallel modules (Booking, Orders, Tracking) with shared services layer (Location, Socket, Maps, Payment). GetX state management following existing repository pattern.

**Tech Stack:** Flutter, GetX, Google Maps, Socket.io, Geolocator, Razorpay (placeholder)

---

## Pre-Implementation Checklist

- [ ] Ensure Google Maps API key is configured in `android/app/src/main/AndroidManifest.xml`
- [ ] Ensure Google Maps API key is configured in `ios/Runner/AppDelegate.swift`
- [ ] Backend booking APIs are available at `/bookings/*`
- [ ] Backend socket server is running at `ws://172.16.17.55:5000`

---

## Task Overview

| Track | Tasks | Files |
|-------|-------|-------|
| **A: Services** | 1-4 | 4 new services |
| **B: Repository** | 5-6 | 1 repository, 1 model |
| **C: Booking Module** | 7-14 | 1 controller, 4 views, 1 binding |
| **D: Orders Module** | 15-19 | 1 controller, 2 views, 1 binding |
| **E: Tracking Module** | 20-24 | 1 controller, 1 view, 1 binding |
| **F: Integration** | 25-27 | Routes, home updates |

---

## Track A: Services Layer

### Task 1: Create LocationService

**Files:**
- Create: `lib/app/services/location_service.dart`

**Step 1: Create the service file**

```dart
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../core/constants/app_constants.dart';
import '../data/models/address_model.dart';

class LocationService extends GetxService {
  // State
  final currentLocation = Rx<Position?>(null);
  final permissionGranted = false.obs;
  final isLoading = false.obs;

  /// Initialize service and check permissions
  Future<LocationService> init() async {
    await checkPermission();
    return this;
  }

  /// Check and request location permission
  Future<bool> checkPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      permissionGranted.value = false;
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        permissionGranted.value = false;
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      permissionGranted.value = false;
      return false;
    }

    permissionGranted.value = true;
    return true;
  }

  /// Get current device location
  Future<Position?> getCurrentLocation() async {
    try {
      isLoading.value = true;

      final hasPermission = await checkPermission();
      if (!hasPermission) return null;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      currentLocation.value = position;
      return position;
    } catch (e) {
      print('Error getting location: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// Get address from coordinates (reverse geocoding)
  Future<String?> getAddressFromCoordinates(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return '${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea} ${place.postalCode}';
      }
      return null;
    } catch (e) {
      print('Error getting address: $e');
      return null;
    }
  }

  /// Get coordinates from address (forward geocoding)
  Future<LatLng?> getCoordinatesFromAddress(String address) async {
    try {
      final locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return LatLng(locations.first.latitude, locations.first.longitude);
      }
      return null;
    } catch (e) {
      print('Error getting coordinates: $e');
      return null;
    }
  }

  /// Calculate distance between two points in kilometers
  double calculateDistance(LatLng from, LatLng to) {
    final distanceInMeters = Geolocator.distanceBetween(
      from.latitude,
      from.longitude,
      to.latitude,
      to.longitude,
    );
    return distanceInMeters / 1000; // Convert to km
  }

  /// Get default location (Ahmedabad)
  LatLng get defaultLocation => const LatLng(
    AppConstants.defaultLat,
    AppConstants.defaultLng,
  );
}
```

**Step 2: Verify file created**

Run: `ls -la lib/app/services/`
Expected: `location_service.dart` exists

**Step 3: Commit**

```bash
git add lib/app/services/location_service.dart
git commit -m "feat(services): add LocationService for geolocation and geocoding"
```

---

### Task 2: Create SocketService

**Files:**
- Create: `lib/app/services/socket_service.dart`

**Step 1: Create the service file**

```dart
import 'dart:async';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../core/constants/api_constants.dart';
import '../core/constants/app_constants.dart';
import '../services/storage_service.dart';

/// Socket event data classes
class DriverLocationData {
  final String bookingId;
  final LatLng location;
  final double heading;
  final DateTime timestamp;

  DriverLocationData({
    required this.bookingId,
    required this.location,
    required this.heading,
    required this.timestamp,
  });

  factory DriverLocationData.fromJson(Map<String, dynamic> json) {
    return DriverLocationData(
      bookingId: json['bookingId'] ?? '',
      location: LatLng(
        (json['lat'] ?? 0).toDouble(),
        (json['lng'] ?? 0).toDouble(),
      ),
      heading: (json['heading'] ?? 0).toDouble(),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }
}

class EtaUpdateData {
  final String bookingId;
  final int etaMinutes;
  final double distanceKm;

  EtaUpdateData({
    required this.bookingId,
    required this.etaMinutes,
    required this.distanceKm,
  });

  factory EtaUpdateData.fromJson(Map<String, dynamic> json) {
    return EtaUpdateData(
      bookingId: json['bookingId'] ?? '',
      etaMinutes: json['eta'] ?? 0,
      distanceKm: (json['distance'] ?? 0).toDouble(),
    );
  }
}

class StatusUpdateData {
  final String bookingId;
  final BookingStatus status;
  final DateTime timestamp;

  StatusUpdateData({
    required this.bookingId,
    required this.status,
    required this.timestamp,
  });

  factory StatusUpdateData.fromJson(Map<String, dynamic> json) {
    return StatusUpdateData(
      bookingId: json['bookingId'] ?? '',
      status: _parseStatus(json['status']),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }

  static BookingStatus _parseStatus(String? value) {
    switch (value?.toUpperCase()) {
      case 'ACCEPTED': return BookingStatus.accepted;
      case 'ARRIVED_PICKUP': return BookingStatus.arrivedPickup;
      case 'PICKED_UP': return BookingStatus.pickedUp;
      case 'IN_TRANSIT': return BookingStatus.inTransit;
      case 'ARRIVED_DROP': return BookingStatus.arrivedDrop;
      case 'DELIVERED': return BookingStatus.delivered;
      case 'CANCELLED': return BookingStatus.cancelled;
      default: return BookingStatus.pending;
    }
  }
}

class SocketService extends GetxService {
  io.Socket? _socket;

  // State
  final isConnected = false.obs;
  final connectionError = Rx<String?>(null);

  // Stream controllers for events
  final _driverLocationController = StreamController<DriverLocationData>.broadcast();
  final _statusUpdateController = StreamController<StatusUpdateData>.broadcast();
  final _etaUpdateController = StreamController<EtaUpdateData>.broadcast();
  final _driverAssignedController = StreamController<Map<String, dynamic>>.broadcast();
  final _bookingCompletedController = StreamController<String>.broadcast();
  final _bookingCancelledController = StreamController<Map<String, dynamic>>.broadcast();

  // Public streams
  Stream<DriverLocationData> get onDriverLocation => _driverLocationController.stream;
  Stream<StatusUpdateData> get onStatusUpdate => _statusUpdateController.stream;
  Stream<EtaUpdateData> get onEtaUpdate => _etaUpdateController.stream;
  Stream<Map<String, dynamic>> get onDriverAssigned => _driverAssignedController.stream;
  Stream<String> get onBookingCompleted => _bookingCompletedController.stream;
  Stream<Map<String, dynamic>> get onBookingCancelled => _bookingCancelledController.stream;

  /// Connect to socket server
  Future<void> connect() async {
    if (_socket != null && _socket!.connected) return;

    final token = StorageService.instance.token;
    if (token == null) {
      connectionError.value = 'No auth token available';
      return;
    }

    try {
      _socket = io.io(
        ApiConstants.socketUrl,
        io.OptionBuilder()
            .setTransports(['websocket'])
            .setAuth({'token': token})
            .enableAutoConnect()
            .enableReconnection()
            .setReconnectionAttempts(5)
            .setReconnectionDelay(1000)
            .build(),
      );

      _setupListeners();
      _socket!.connect();
    } catch (e) {
      connectionError.value = 'Failed to connect: $e';
      isConnected.value = false;
    }
  }

  void _setupListeners() {
    _socket!.onConnect((_) {
      print('Socket connected');
      isConnected.value = true;
      connectionError.value = null;
    });

    _socket!.onDisconnect((_) {
      print('Socket disconnected');
      isConnected.value = false;
    });

    _socket!.onConnectError((error) {
      print('Socket connection error: $error');
      connectionError.value = error.toString();
      isConnected.value = false;
    });

    // Driver location updates
    _socket!.on('driver:location', (data) {
      if (data != null) {
        _driverLocationController.add(DriverLocationData.fromJson(data));
      }
    });

    // Booking status updates
    _socket!.on('booking:status', (data) {
      if (data != null) {
        _statusUpdateController.add(StatusUpdateData.fromJson(data));
      }
    });

    // ETA updates
    _socket!.on('booking:eta', (data) {
      if (data != null) {
        _etaUpdateController.add(EtaUpdateData.fromJson(data));
      }
    });

    // Driver assigned
    _socket!.on('booking:driver-assigned', (data) {
      if (data != null) {
        _driverAssignedController.add(Map<String, dynamic>.from(data));
      }
    });

    // Booking completed
    _socket!.on('booking:completed', (data) {
      if (data != null && data['bookingId'] != null) {
        _bookingCompletedController.add(data['bookingId']);
      }
    });

    // Booking cancelled
    _socket!.on('booking:cancelled', (data) {
      if (data != null) {
        _bookingCancelledController.add(Map<String, dynamic>.from(data));
      }
    });
  }

  /// Join a booking room to receive updates
  void joinBookingRoom(String bookingId) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('join:booking', {'bookingId': bookingId});
    }
  }

  /// Leave a booking room
  void leaveBookingRoom(String bookingId) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('leave:booking', {'bookingId': bookingId});
    }
  }

  /// Disconnect from socket server
  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    isConnected.value = false;
  }

  @override
  void onClose() {
    disconnect();
    _driverLocationController.close();
    _statusUpdateController.close();
    _etaUpdateController.close();
    _driverAssignedController.close();
    _bookingCompletedController.close();
    _bookingCancelledController.close();
    super.onClose();
  }
}
```

**Step 2: Commit**

```bash
git add lib/app/services/socket_service.dart
git commit -m "feat(services): add SocketService for real-time tracking events"
```

---

### Task 3: Create MapsService

**Files:**
- Create: `lib/app/services/maps_service.dart`

**Step 1: Create the service file**

```dart
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapsService extends GetxService {
  BitmapDescriptor? _pickupMarker;
  BitmapDescriptor? _dropMarker;
  BitmapDescriptor? _driverMarker;

  /// Initialize markers
  Future<MapsService> init() async {
    await _loadMarkers();
    return this;
  }

  Future<void> _loadMarkers() async {
    // Use default markers for now, can be customized with assets
    _pickupMarker = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    _dropMarker = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    _driverMarker = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
  }

  /// Get pickup location marker
  BitmapDescriptor get pickupMarker =>
      _pickupMarker ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);

  /// Get drop location marker
  BitmapDescriptor get dropMarker =>
      _dropMarker ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);

  /// Get driver marker
  BitmapDescriptor get driverMarker =>
      _driverMarker ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);

  /// Decode polyline string to list of LatLng points
  List<LatLng> decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }

  /// Create camera bounds to fit both points
  LatLngBounds getBounds(LatLng point1, LatLng point2) {
    final south = point1.latitude < point2.latitude ? point1.latitude : point2.latitude;
    final north = point1.latitude > point2.latitude ? point1.latitude : point2.latitude;
    final west = point1.longitude < point2.longitude ? point1.longitude : point2.longitude;
    final east = point1.longitude > point2.longitude ? point1.longitude : point2.longitude;

    return LatLngBounds(
      southwest: LatLng(south, west),
      northeast: LatLng(north, east),
    );
  }

  /// Get camera update to fit bounds with padding
  CameraUpdate fitBounds(LatLng point1, LatLng point2, {double padding = 80}) {
    final bounds = getBounds(point1, point2);
    return CameraUpdate.newLatLngBounds(bounds, padding);
  }

  /// Get camera update to focus on a single location
  CameraUpdate focusOnLocation(LatLng location, {double zoom = 15}) {
    return CameraUpdate.newLatLngZoom(location, zoom);
  }

  /// Get map style for dark mode (returns null for default light style)
  String? getMapStyle(bool isDarkMode) {
    if (!isDarkMode) return null;

    // Dark map style JSON
    return '''
    [
      {"elementType": "geometry", "stylers": [{"color": "#242f3e"}]},
      {"elementType": "labels.text.stroke", "stylers": [{"color": "#242f3e"}]},
      {"elementType": "labels.text.fill", "stylers": [{"color": "#746855"}]},
      {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#17263c"}]},
      {"featureType": "water", "elementType": "labels.text.fill", "stylers": [{"color": "#515c6d"}]},
      {"featureType": "road", "elementType": "geometry", "stylers": [{"color": "#38414e"}]},
      {"featureType": "road", "elementType": "geometry.stroke", "stylers": [{"color": "#212a37"}]},
      {"featureType": "road.highway", "elementType": "geometry", "stylers": [{"color": "#746855"}]},
      {"featureType": "poi", "elementType": "labels.text.fill", "stylers": [{"color": "#d59563"}]}
    ]
    ''';
  }

  /// Create a simple polyline between two points
  Polyline createRoutePolyline({
    required String id,
    required List<LatLng> points,
    required Color color,
    int width = 5,
  }) {
    return Polyline(
      polylineId: PolylineId(id),
      points: points,
      color: color,
      width: width,
      patterns: [],
    );
  }
}
```

**Step 2: Commit**

```bash
git add lib/app/services/maps_service.dart
git commit -m "feat(services): add MapsService for Google Maps utilities"
```

---

### Task 4: Create PaymentService

**Files:**
- Create: `lib/app/services/payment_service.dart`

**Step 1: Create the service file**

```dart
import 'package:get/get.dart';
import '../core/constants/app_constants.dart';
import '../data/repositories/wallet_repository.dart';

/// Payment result model
class PaymentResult {
  final bool success;
  final String? transactionId;
  final String? errorMessage;
  final PaymentMethod method;
  final double amount;

  PaymentResult({
    required this.success,
    this.transactionId,
    this.errorMessage,
    required this.method,
    required this.amount,
  });
}

class PaymentService extends GetxService {
  final WalletRepository _walletRepository = WalletRepository();

  // State
  final isProcessing = false.obs;
  final selectedMethod = PaymentMethod.wallet.obs;

  /// Check if wallet has sufficient balance
  Future<Map<String, dynamic>> checkWalletBalance(double amount) async {
    try {
      final response = await _walletRepository.checkBalance(amount);
      if (response.success && response.data != null) {
        return response.data!;
      }
      return {
        'hasSufficientBalance': false,
        'currentBalance': 0.0,
        'requiredAmount': amount,
        'shortfall': amount,
      };
    } catch (e) {
      return {
        'hasSufficientBalance': false,
        'currentBalance': 0.0,
        'requiredAmount': amount,
        'shortfall': amount,
        'error': e.toString(),
      };
    }
  }

  /// Process payment with wallet
  Future<PaymentResult> payWithWallet({
    required double amount,
    required String bookingId,
  }) async {
    try {
      isProcessing.value = true;

      // First check balance
      final balanceCheck = await checkWalletBalance(amount);
      if (balanceCheck['hasSufficientBalance'] != true) {
        return PaymentResult(
          success: false,
          errorMessage: 'Insufficient wallet balance. You need ₹${balanceCheck['shortfall']?.toStringAsFixed(2)} more.',
          method: PaymentMethod.wallet,
          amount: amount,
        );
      }

      // Note: Actual wallet deduction happens on backend during booking creation
      // This is just a pre-check
      return PaymentResult(
        success: true,
        transactionId: 'wallet_$bookingId',
        method: PaymentMethod.wallet,
        amount: amount,
      );
    } catch (e) {
      return PaymentResult(
        success: false,
        errorMessage: e.toString(),
        method: PaymentMethod.wallet,
        amount: amount,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  /// Process cash on delivery (no actual processing needed)
  PaymentResult markCashPayment({
    required double amount,
    required String bookingId,
  }) {
    return PaymentResult(
      success: true,
      transactionId: 'cod_$bookingId',
      method: PaymentMethod.cash,
      amount: amount,
    );
  }

  /// Process UPI payment via Razorpay (PLACEHOLDER)
  Future<PaymentResult> initiateRazorpay({
    required double amount,
    required String bookingId,
    required String description,
  }) async {
    // TODO: Integrate Razorpay SDK
    // For now, return placeholder error
    return PaymentResult(
      success: false,
      errorMessage: 'UPI payment coming soon! Please use Wallet or Cash for now.',
      method: PaymentMethod.upi,
      amount: amount,
    );
  }

  /// Unified payment processing
  Future<PaymentResult> processPayment({
    required PaymentMethod method,
    required double amount,
    required String bookingId,
    String? description,
  }) async {
    switch (method) {
      case PaymentMethod.wallet:
        return payWithWallet(amount: amount, bookingId: bookingId);
      case PaymentMethod.cash:
        return markCashPayment(amount: amount, bookingId: bookingId);
      case PaymentMethod.upi:
        return initiateRazorpay(
          amount: amount,
          bookingId: bookingId,
          description: description ?? 'SendIt Booking',
        );
      default:
        return PaymentResult(
          success: false,
          errorMessage: 'Payment method not supported',
          method: method,
          amount: amount,
        );
    }
  }

  /// Set selected payment method
  void setPaymentMethod(PaymentMethod method) {
    selectedMethod.value = method;
  }
}
```

**Step 2: Commit**

```bash
git add lib/app/services/payment_service.dart
git commit -m "feat(services): add PaymentService with wallet and Razorpay placeholder"
```

---

## Track B: Repository & Models

### Task 5: Create PriceCalculation Model

**Files:**
- Create: `lib/app/data/models/price_calculation_model.dart`

**Step 1: Create the model file**

```dart
class PriceCalculationModel {
  final double distance;
  final int estimatedDuration; // in minutes
  final double baseFare;
  final double distanceFare;
  final double taxes;
  final double totalAmount;
  final String? currency;

  PriceCalculationModel({
    required this.distance,
    required this.estimatedDuration,
    required this.baseFare,
    required this.distanceFare,
    this.taxes = 0,
    required this.totalAmount,
    this.currency = 'INR',
  });

  factory PriceCalculationModel.fromJson(Map<String, dynamic> json) {
    return PriceCalculationModel(
      distance: (json['distance'] ?? 0).toDouble(),
      estimatedDuration: json['estimatedDuration'] ?? 0,
      baseFare: (json['baseFare'] ?? 0).toDouble(),
      distanceFare: (json['distanceFare'] ?? 0).toDouble(),
      taxes: (json['taxes'] ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'INR',
    );
  }

  String get distanceDisplay => '${distance.toStringAsFixed(1)} km';
  String get durationDisplay => '$estimatedDuration min';
  String get totalDisplay => '₹${totalAmount.toStringAsFixed(0)}';
  String get baseFareDisplay => '₹${baseFare.toStringAsFixed(0)}';
  String get distanceFareDisplay => '₹${distanceFare.toStringAsFixed(0)}';
  String get taxesDisplay => '₹${taxes.toStringAsFixed(0)}';
}

class CreateBookingRequest {
  final double pickupLat;
  final double pickupLng;
  final String pickupAddress;
  final String? pickupLandmark;
  final double dropLat;
  final double dropLng;
  final String dropAddress;
  final String? dropLandmark;
  final String vehicleTypeId;
  final String packageType;
  final String? packageDescription;
  final double? packageWeight;
  final String paymentMethod;
  final String? couponCode;
  final DateTime? scheduledAt;

  CreateBookingRequest({
    required this.pickupLat,
    required this.pickupLng,
    required this.pickupAddress,
    this.pickupLandmark,
    required this.dropLat,
    required this.dropLng,
    required this.dropAddress,
    this.dropLandmark,
    required this.vehicleTypeId,
    required this.packageType,
    this.packageDescription,
    this.packageWeight,
    required this.paymentMethod,
    this.couponCode,
    this.scheduledAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'pickupLat': pickupLat,
      'pickupLng': pickupLng,
      'pickupAddress': pickupAddress,
      if (pickupLandmark != null) 'pickupLandmark': pickupLandmark,
      'dropLat': dropLat,
      'dropLng': dropLng,
      'dropAddress': dropAddress,
      if (dropLandmark != null) 'dropLandmark': dropLandmark,
      'vehicleTypeId': vehicleTypeId,
      'packageType': packageType.toUpperCase(),
      if (packageDescription != null) 'packageDescription': packageDescription,
      if (packageWeight != null) 'packageWeight': packageWeight,
      'paymentMethod': paymentMethod.toUpperCase(),
      if (couponCode != null) 'couponCode': couponCode,
      if (scheduledAt != null) 'scheduledAt': scheduledAt!.toIso8601String(),
    };
  }
}
```

**Step 2: Commit**

```bash
git add lib/app/data/models/price_calculation_model.dart
git commit -m "feat(models): add PriceCalculationModel and CreateBookingRequest"
```

---

### Task 6: Create BookingRepository

**Files:**
- Create: `lib/app/data/repositories/booking_repository.dart`

**Step 1: Create the repository file**

```dart
import '../models/api_response.dart';
import '../models/booking_model.dart';
import '../models/vehicle_type_model.dart';
import '../models/price_calculation_model.dart';
import '../providers/api_client.dart';
import '../../core/constants/api_constants.dart';

class BookingRepository {
  final ApiClient _apiClient = ApiClient();

  /// Get all vehicle types
  /// GET /vehicles/types
  Future<ApiResponse<List<VehicleTypeModel>>> getVehicleTypes() async {
    final response = await _apiClient.get(ApiConstants.vehicleTypes);

    final apiResponse = ApiResponse<List<dynamic>>.fromJson(
      response.data,
      (data) => data as List<dynamic>,
    );

    if (apiResponse.success && apiResponse.data != null) {
      final vehicles = apiResponse.data!
          .map((json) => VehicleTypeModel.fromJson(json))
          .toList();

      return ApiResponse(
        success: true,
        message: apiResponse.message,
        data: vehicles,
      );
    }

    return ApiResponse(
      success: false,
      message: apiResponse.message ?? 'Failed to get vehicle types',
    );
  }

  /// Calculate price for a booking
  /// POST /bookings/calculate-price
  /// Body: { pickupLat, pickupLng, dropLat, dropLng, vehicleTypeId }
  Future<ApiResponse<PriceCalculationModel>> calculatePrice({
    required double pickupLat,
    required double pickupLng,
    required double dropLat,
    required double dropLng,
    required String vehicleTypeId,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.calculatePrice,
      data: {
        'pickupLat': pickupLat,
        'pickupLng': pickupLng,
        'dropLat': dropLat,
        'dropLng': dropLng,
        'vehicleTypeId': vehicleTypeId,
      },
    );

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (data) => data as Map<String, dynamic>,
    );

    if (apiResponse.success && apiResponse.data != null) {
      return ApiResponse(
        success: true,
        message: apiResponse.message,
        data: PriceCalculationModel.fromJson(apiResponse.data!),
      );
    }

    return ApiResponse(
      success: false,
      message: apiResponse.message ?? 'Failed to calculate price',
    );
  }

  /// Create a new booking
  /// POST /bookings
  Future<ApiResponse<BookingModel>> createBooking(CreateBookingRequest request) async {
    final response = await _apiClient.post(
      ApiConstants.bookings,
      data: request.toJson(),
    );

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (data) => data as Map<String, dynamic>,
    );

    if (apiResponse.success && apiResponse.data != null) {
      return ApiResponse(
        success: true,
        message: apiResponse.message,
        data: BookingModel.fromJson(apiResponse.data!),
      );
    }

    return ApiResponse(
      success: false,
      message: apiResponse.message ?? 'Failed to create booking',
    );
  }

  /// Get booking by ID
  /// GET /bookings/{id}
  Future<ApiResponse<BookingModel>> getBooking(String id) async {
    final response = await _apiClient.get('${ApiConstants.bookings}/$id');

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (data) => data as Map<String, dynamic>,
    );

    if (apiResponse.success && apiResponse.data != null) {
      return ApiResponse(
        success: true,
        message: apiResponse.message,
        data: BookingModel.fromJson(apiResponse.data!),
      );
    }

    return ApiResponse(
      success: false,
      message: apiResponse.message ?? 'Failed to get booking',
    );
  }

  /// Get user's bookings (orders) with pagination
  /// GET /bookings/my-bookings?page=1&limit=10&status=active
  Future<ApiResponse<List<BookingModel>>> getMyBookings({
    int page = 1,
    int limit = 10,
    String? status, // 'active', 'completed', 'cancelled'
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };

    if (status != null && status.isNotEmpty && status != 'all') {
      queryParams['status'] = status;
    }

    final response = await _apiClient.get(
      ApiConstants.myBookings,
      queryParameters: queryParams,
    );

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (data) => data as Map<String, dynamic>,
    );

    if (apiResponse.success && apiResponse.data != null) {
      final bookingsData = apiResponse.data!['bookings'] as List<dynamic>?;
      final bookings = bookingsData
              ?.map((json) => BookingModel.fromJson(json))
              .toList() ??
          [];

      return ApiResponse(
        success: true,
        message: apiResponse.message,
        data: bookings,
        meta: apiResponse.meta,
      );
    }

    return ApiResponse(
      success: false,
      message: apiResponse.message ?? 'Failed to get bookings',
    );
  }

  /// Cancel a booking
  /// POST /bookings/{id}/cancel
  Future<ApiResponse<BookingModel>> cancelBooking(String id, {String? reason}) async {
    final response = await _apiClient.post(
      '${ApiConstants.bookings}/$id/cancel',
      data: {
        if (reason != null) 'reason': reason,
      },
    );

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (data) => data as Map<String, dynamic>,
    );

    if (apiResponse.success && apiResponse.data != null) {
      return ApiResponse(
        success: true,
        message: apiResponse.message,
        data: BookingModel.fromJson(apiResponse.data!),
      );
    }

    return ApiResponse(
      success: false,
      message: apiResponse.message ?? 'Failed to cancel booking',
    );
  }

  /// Rate a completed delivery
  /// POST /bookings/{id}/rate
  Future<ApiResponse<void>> rateDelivery(
    String bookingId, {
    required int rating,
    String? review,
  }) async {
    final response = await _apiClient.post(
      '${ApiConstants.bookings}/$bookingId/rate',
      data: {
        'rating': rating,
        if (review != null) 'review': review,
      },
    );

    final apiResponse = ApiResponse<dynamic>.fromJson(
      response.data,
      (data) => data,
    );

    return ApiResponse(
      success: apiResponse.success,
      message: apiResponse.message,
    );
  }
}
```

**Step 2: Commit**

```bash
git add lib/app/data/repositories/booking_repository.dart
git commit -m "feat(repository): add BookingRepository for booking CRUD operations"
```

---

## Track C: Booking Module

### Task 7: Create BookingBinding

**Files:**
- Create: `lib/app/modules/booking/bindings/booking_binding.dart`

**Step 1: Create the binding file**

```dart
import 'package:get/get.dart';
import '../controllers/booking_controller.dart';

class BookingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BookingController>(() => BookingController());
  }
}
```

**Step 2: Commit**

```bash
git add lib/app/modules/booking/bindings/booking_binding.dart
git commit -m "feat(booking): add BookingBinding"
```

---

### Task 8: Create BookingController

**Files:**
- Create: `lib/app/modules/booking/controllers/booking_controller.dart`

**Step 1: Create the controller file**

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/address_model.dart';
import '../../../data/models/vehicle_type_model.dart';
import '../../../data/models/price_calculation_model.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../../data/providers/api_exceptions.dart';
import '../../../services/location_service.dart';
import '../../../services/payment_service.dart';
import '../../../routes/app_routes.dart';

enum BookingState { idle, loadingVehicles, calculatingPrice, creatingBooking, findingDriver }

class BookingController extends GetxController {
  final BookingRepository _bookingRepository = BookingRepository();
  late final LocationService _locationService;
  late final PaymentService _paymentService;

  // Form controllers
  late TextEditingController pickupController;
  late TextEditingController dropController;
  late TextEditingController packageDescriptionController;

  // Observable state
  final bookingState = BookingState.idle.obs;
  final errorMessage = ''.obs;

  // Location state
  final pickupLocation = Rx<LatLng?>(null);
  final dropLocation = Rx<LatLng?>(null);
  final pickupAddress = ''.obs;
  final dropAddress = ''.obs;
  final pickupLandmark = ''.obs;
  final dropLandmark = ''.obs;

  // Package state
  final selectedPackageType = PackageType.parcel.obs;
  final packageDescription = ''.obs;

  // Vehicle state
  final vehicleTypes = <VehicleTypeModel>[].obs;
  final selectedVehicle = Rx<VehicleTypeModel?>(null);

  // Price state
  final priceCalculation = Rx<PriceCalculationModel?>(null);

  // Payment state
  final selectedPaymentMethod = PaymentMethod.wallet.obs;
  final walletBalance = 0.0.obs;
  final hasSufficientBalance = false.obs;

  // Coupon state
  final couponCode = ''.obs;
  final couponDiscount = 0.0.obs;

  // Created booking
  final currentBooking = Rx<BookingModel?>(null);

  // Getters
  bool get isLoading => bookingState.value != BookingState.idle;
  bool get canProceedToVehicle =>
      pickupLocation.value != null && dropLocation.value != null;
  bool get canProceedToPayment =>
      selectedVehicle.value != null && priceCalculation.value != null;

  double get finalAmount {
    final base = priceCalculation.value?.totalAmount ?? 0;
    return base - couponDiscount.value;
  }

  String get finalAmountDisplay => '₹${finalAmount.toStringAsFixed(0)}';

  @override
  void onInit() {
    super.onInit();
    pickupController = TextEditingController();
    dropController = TextEditingController();
    packageDescriptionController = TextEditingController();

    // Get services
    _locationService = Get.find<LocationService>();
    _paymentService = Get.find<PaymentService>();

    // Load initial data
    _loadVehicleTypes();
    _checkWalletBalance();
  }

  @override
  void onClose() {
    pickupController.dispose();
    dropController.dispose();
    packageDescriptionController.dispose();
    super.onClose();
  }

  /// Load available vehicle types
  Future<void> _loadVehicleTypes() async {
    try {
      bookingState.value = BookingState.loadingVehicles;
      errorMessage.value = '';

      final response = await _bookingRepository.getVehicleTypes();

      if (response.success && response.data != null) {
        vehicleTypes.value = response.data!;
        if (vehicleTypes.isNotEmpty) {
          selectedVehicle.value = vehicleTypes.first;
        }
      } else {
        errorMessage.value = response.message ?? 'Failed to load vehicles';
      }
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'Something went wrong';
    } finally {
      bookingState.value = BookingState.idle;
    }
  }

  /// Check wallet balance
  Future<void> _checkWalletBalance() async {
    final result = await _paymentService.checkWalletBalance(0);
    walletBalance.value = result['currentBalance'] ?? 0.0;
  }

  /// Set pickup location from current position
  Future<void> useCurrentLocationAsPickup() async {
    final position = await _locationService.getCurrentLocation();
    if (position != null) {
      pickupLocation.value = LatLng(position.latitude, position.longitude);

      final address = await _locationService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (address != null) {
        pickupAddress.value = address;
        pickupController.text = address;
      }
    }
  }

  /// Set pickup location manually
  void setPickupLocation(LatLng location, String address, {String? landmark}) {
    pickupLocation.value = location;
    pickupAddress.value = address;
    pickupController.text = address;
    if (landmark != null) pickupLandmark.value = landmark;
  }

  /// Set drop location manually
  void setDropLocation(LatLng location, String address, {String? landmark}) {
    dropLocation.value = location;
    dropAddress.value = address;
    dropController.text = address;
    if (landmark != null) dropLandmark.value = landmark;
  }

  /// Set from saved address
  void setFromSavedAddress(AddressModel address, {required bool isPickup}) {
    final location = LatLng(address.lat, address.lng);
    if (isPickup) {
      setPickupLocation(location, address.fullAddress, landmark: address.landmark);
    } else {
      setDropLocation(location, address.fullAddress, landmark: address.landmark);
    }
  }

  /// Select package type
  void selectPackageType(PackageType type) {
    selectedPackageType.value = type;
  }

  /// Select vehicle type and calculate price
  Future<void> selectVehicle(VehicleTypeModel vehicle) async {
    selectedVehicle.value = vehicle;
    await calculatePrice();
  }

  /// Calculate price for selected route and vehicle
  Future<void> calculatePrice() async {
    if (pickupLocation.value == null ||
        dropLocation.value == null ||
        selectedVehicle.value == null) {
      return;
    }

    try {
      bookingState.value = BookingState.calculatingPrice;
      errorMessage.value = '';

      final response = await _bookingRepository.calculatePrice(
        pickupLat: pickupLocation.value!.latitude,
        pickupLng: pickupLocation.value!.longitude,
        dropLat: dropLocation.value!.latitude,
        dropLng: dropLocation.value!.longitude,
        vehicleTypeId: selectedVehicle.value!.id,
      );

      if (response.success && response.data != null) {
        priceCalculation.value = response.data!;
        _updatePaymentEligibility();
      } else {
        errorMessage.value = response.message ?? 'Failed to calculate price';
        _showError(errorMessage.value);
      }
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      _showError(e.message);
    } catch (e) {
      errorMessage.value = 'Something went wrong';
      _showError(errorMessage.value);
    } finally {
      bookingState.value = BookingState.idle;
    }
  }

  /// Update payment eligibility based on wallet balance
  void _updatePaymentEligibility() {
    hasSufficientBalance.value = walletBalance.value >= finalAmount;
  }

  /// Select payment method
  void selectPaymentMethod(PaymentMethod method) {
    selectedPaymentMethod.value = method;
  }

  /// Apply coupon code
  Future<void> applyCoupon(String code) async {
    // TODO: Implement coupon validation API
    couponCode.value = code;
    // For now, no discount
    couponDiscount.value = 0;
    _updatePaymentEligibility();
  }

  /// Create booking
  Future<void> createBooking() async {
    if (!canProceedToPayment) {
      _showError('Please complete all booking details');
      return;
    }

    try {
      bookingState.value = BookingState.creatingBooking;
      errorMessage.value = '';

      final request = CreateBookingRequest(
        pickupLat: pickupLocation.value!.latitude,
        pickupLng: pickupLocation.value!.longitude,
        pickupAddress: pickupAddress.value,
        pickupLandmark: pickupLandmark.value.isNotEmpty ? pickupLandmark.value : null,
        dropLat: dropLocation.value!.latitude,
        dropLng: dropLocation.value!.longitude,
        dropAddress: dropAddress.value,
        dropLandmark: dropLandmark.value.isNotEmpty ? dropLandmark.value : null,
        vehicleTypeId: selectedVehicle.value!.id,
        packageType: selectedPackageType.value.name,
        packageDescription: packageDescriptionController.text.isNotEmpty
            ? packageDescriptionController.text
            : null,
        paymentMethod: selectedPaymentMethod.value.name,
        couponCode: couponCode.value.isNotEmpty ? couponCode.value : null,
      );

      final response = await _bookingRepository.createBooking(request);

      if (response.success && response.data != null) {
        currentBooking.value = response.data!;
        bookingState.value = BookingState.findingDriver;

        // Navigate to finding driver screen
        Get.toNamed(Routes.findingDriver);
      } else {
        errorMessage.value = response.message ?? 'Failed to create booking';
        _showError(errorMessage.value);
        bookingState.value = BookingState.idle;
      }
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      _showError(e.message);
      bookingState.value = BookingState.idle;
    } catch (e) {
      errorMessage.value = 'Something went wrong';
      _showError(errorMessage.value);
      bookingState.value = BookingState.idle;
    }
  }

  /// Cancel current booking
  Future<void> cancelBooking({String? reason}) async {
    if (currentBooking.value == null) return;

    try {
      final response = await _bookingRepository.cancelBooking(
        currentBooking.value!.id,
        reason: reason,
      );

      if (response.success) {
        currentBooking.value = null;
        bookingState.value = BookingState.idle;
        Get.back();
        _showSuccess('Booking cancelled');
      } else {
        _showError(response.message ?? 'Failed to cancel booking');
      }
    } catch (e) {
      _showError('Failed to cancel booking');
    }
  }

  /// Reset booking state for new booking
  void resetBooking() {
    pickupLocation.value = null;
    dropLocation.value = null;
    pickupAddress.value = '';
    dropAddress.value = '';
    pickupLandmark.value = '';
    dropLandmark.value = '';
    pickupController.clear();
    dropController.clear();
    packageDescriptionController.clear();
    selectedPackageType.value = PackageType.parcel;
    selectedVehicle.value = vehicleTypes.isNotEmpty ? vehicleTypes.first : null;
    priceCalculation.value = null;
    selectedPaymentMethod.value = PaymentMethod.wallet;
    couponCode.value = '';
    couponDiscount.value = 0.0;
    currentBooking.value = null;
    bookingState.value = BookingState.idle;
    errorMessage.value = '';
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  void _showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }
}
```

**Step 2: Commit**

```bash
git add lib/app/modules/booking/controllers/booking_controller.dart
git commit -m "feat(booking): add BookingController with full booking flow logic"
```

---

*Plan continues in Part 2...*

---

**Note:** This plan is split into multiple parts due to size. Part 2 will contain:
- Tasks 9-14: Booking Views (CreateBookingView, VehicleSelectionView, PaymentView, FindingDriverView)
- Tasks 15-19: Orders Module
- Tasks 20-24: Tracking Module
- Tasks 25-27: Integration (Routes, Home updates)

Run: `git log --oneline -5` to verify commits so far.
