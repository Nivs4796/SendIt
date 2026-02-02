import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/models/booking_model.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../../data/providers/api_exceptions.dart';
import '../../../services/socket_service.dart';
import '../../../services/maps_service.dart';
import '../../../core/constants/app_constants.dart';

/// Controller for real-time delivery tracking
class TrackingController extends GetxController {
  final BookingRepository _bookingRepository = BookingRepository();
  final SocketService _socketService = Get.find<SocketService>();
  final MapsService _mapsService = Get.find<MapsService>();

  // Map controller
  GoogleMapController? mapController;

  // Observable state
  final booking = Rx<BookingModel?>(null);
  final isLoading = true.obs;
  final errorMessage = ''.obs;
  final driverLocation = Rx<LatLng?>(null);
  final driverHeading = 0.0.obs;
  final currentEta = 0.obs; // minutes
  final currentDistance = 0.0.obs; // km
  final routePolyline = <LatLng>[].obs;
  final isConnected = false.obs;
  final markers = Rx<Set<Marker>>({});

  // Booking ID from navigation arguments
  String? _bookingId;

  // Stream subscriptions for socket events
  StreamSubscription<DriverLocationData>? _locationSubscription;
  StreamSubscription<StatusUpdateData>? _statusSubscription;
  StreamSubscription<EtaUpdateData>? _etaSubscription;
  StreamSubscription<String>? _completedSubscription;
  StreamSubscription<BookingCancelledData>? _cancelledSubscription;

  // Getters for display formatting
  String get etaDisplay {
    if (currentEta.value <= 0) return 'Calculating...';
    if (currentEta.value == 1) return '1 min';
    return '${currentEta.value} mins';
  }

  String get distanceDisplay {
    if (currentDistance.value <= 0) return 'Calculating...';
    if (currentDistance.value < 1) {
      return '${(currentDistance.value * 1000).toInt()} m';
    }
    return '${currentDistance.value.toStringAsFixed(1)} km';
  }

  @override
  void onInit() {
    super.onInit();
    // Get booking ID from navigation arguments
    _bookingId = Get.arguments?['bookingId'] as String?;

    if (_bookingId == null || _bookingId!.isEmpty) {
      errorMessage.value = 'Invalid booking ID';
      isLoading.value = false;
      return;
    }

    _loadBooking();
    _connectToTracking();
  }

  @override
  void onClose() {
    _disconnectTracking();
    mapController?.dispose();
    super.onClose();
  }

  /// Load booking details from API
  Future<void> _loadBooking() async {
    if (_bookingId == null) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _bookingRepository.getBooking(_bookingId!);

      if (response.success && response.data != null) {
        booking.value = response.data;
        _updateMarkers();

        // Initialize driver location from booking if available
        if (response.data!.currentLat != null &&
            response.data!.currentLng != null) {
          driverLocation.value = LatLng(
            response.data!.currentLat!,
            response.data!.currentLng!,
          );
          _updateDriverMarker();
        }
      } else {
        errorMessage.value = response.message ?? 'Failed to load booking';
        Get.snackbar(
          'Error',
          errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      Get.snackbar(
        'Error',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } on NetworkException {
      errorMessage.value = 'No internet connection';
      Get.snackbar(
        'Error',
        'No internet connection',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      errorMessage.value = 'Something went wrong';
      Get.snackbar(
        'Error',
        'Something went wrong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Connect to socket and setup tracking listeners
  Future<void> _connectToTracking() async {
    if (_bookingId == null) return;

    try {
      // Connect to socket if not already connected
      await _socketService.connect();

      // Join booking room for updates
      _socketService.joinBookingRoom(_bookingId!);

      // Listen for connection status
      ever(_socketService.isConnected, (bool connected) {
        isConnected.value = connected;
      });
      isConnected.value = _socketService.isConnected.value;

      // Setup event listeners
      _locationSubscription =
          _socketService.driverLocationStream.listen(_handleLocationUpdate);

      _statusSubscription =
          _socketService.statusUpdateStream.listen(_handleStatusUpdate);

      _etaSubscription =
          _socketService.etaUpdateStream.listen(_handleEtaUpdate);

      _completedSubscription =
          _socketService.bookingCompletedStream.listen(_handleBookingCompleted);

      _cancelledSubscription =
          _socketService.bookingCancelledStream.listen(_handleBookingCancelled);
    } catch (e) {
      print('[TrackingController] Error connecting to tracking: $e');
      isConnected.value = false;
    }
  }

  /// Disconnect from tracking and cleanup
  void _disconnectTracking() {
    // Cancel all subscriptions
    _locationSubscription?.cancel();
    _statusSubscription?.cancel();
    _etaSubscription?.cancel();
    _completedSubscription?.cancel();
    _cancelledSubscription?.cancel();

    // Leave booking room
    if (_bookingId != null) {
      _socketService.leaveBookingRoom(_bookingId!);
    }
  }

  /// Handle driver location updates from socket
  void _handleLocationUpdate(DriverLocationData data) {
    if (data.bookingId != _bookingId) return;

    driverLocation.value = data.location;
    driverHeading.value = data.heading;
    _updateDriverMarker();
  }

  /// Handle booking status updates from socket
  void _handleStatusUpdate(StatusUpdateData data) {
    if (data.bookingId != _bookingId) return;
    _updateStatus(data.status);
  }

  /// Handle ETA updates from socket
  void _handleEtaUpdate(EtaUpdateData data) {
    if (data.bookingId != _bookingId) return;

    currentEta.value = data.etaMinutes;
    currentDistance.value = data.distanceKm;
  }

  /// Handle booking completion
  void _handleBookingCompleted(String bookingId) {
    if (bookingId != _bookingId) return;
    _showCompletionDialog();
  }

  /// Handle booking cancellation
  void _handleBookingCancelled(BookingCancelledData data) {
    if (data.bookingId != _bookingId) return;
    _showCancellationDialog(data.reason);
  }

  /// Update booking status and refresh data
  Future<void> _updateStatus(BookingStatus status) async {
    // Check for terminal states
    if (status == BookingStatus.delivered) {
      _showCompletionDialog();
      return;
    }

    if (status == BookingStatus.cancelled) {
      _showCancellationDialog(null);
      return;
    }

    // Refresh booking to get latest data
    await refreshBooking();
  }

  /// Create/update markers for pickup, drop, and driver
  void _updateMarkers() {
    final currentBooking = booking.value;
    if (currentBooking == null) return;

    final newMarkers = <Marker>{};

    // Pickup marker
    if (currentBooking.pickupAddress != null) {
      newMarkers.add(
        Marker(
          markerId: const MarkerId('pickup'),
          position: LatLng(
            currentBooking.pickupAddress!.lat,
            currentBooking.pickupAddress!.lng,
          ),
          icon: _mapsService.pickupMarker,
          infoWindow: InfoWindow(
            title: 'Pickup',
            snippet: currentBooking.pickupAddress!.shortAddress,
          ),
        ),
      );
    }

    // Drop marker
    if (currentBooking.dropAddress != null) {
      newMarkers.add(
        Marker(
          markerId: const MarkerId('drop'),
          position: LatLng(
            currentBooking.dropAddress!.lat,
            currentBooking.dropAddress!.lng,
          ),
          icon: _mapsService.dropMarker,
          infoWindow: InfoWindow(
            title: 'Drop-off',
            snippet: currentBooking.dropAddress!.shortAddress,
          ),
        ),
      );
    }

    // Add driver marker if available
    if (driverLocation.value != null) {
      newMarkers.add(
        Marker(
          markerId: const MarkerId('driver'),
          position: driverLocation.value!,
          icon: _mapsService.driverMarker,
          rotation: driverHeading.value,
          anchor: const Offset(0.5, 0.5),
          flat: true,
          infoWindow: InfoWindow(
            title: currentBooking.pilot?.name ?? 'Driver',
            snippet: currentBooking.pilot?.vehicleNumber ?? '',
          ),
        ),
      );
    }

    markers.value = newMarkers;
  }

  /// Update only the driver marker position
  void _updateDriverMarker() {
    final currentMarkers = Set<Marker>.from(markers.value);

    // Remove existing driver marker
    currentMarkers.removeWhere((m) => m.markerId.value == 'driver');

    // Add updated driver marker
    if (driverLocation.value != null) {
      currentMarkers.add(
        Marker(
          markerId: const MarkerId('driver'),
          position: driverLocation.value!,
          icon: _mapsService.driverMarker,
          rotation: driverHeading.value,
          anchor: const Offset(0.5, 0.5),
          flat: true,
          infoWindow: InfoWindow(
            title: booking.value?.pilot?.name ?? 'Driver',
            snippet: booking.value?.pilot?.vehicleNumber ?? '',
          ),
        ),
      );
    }

    markers.value = currentMarkers;
  }

  /// Called when map is created
  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _fitBoundsToRoute();
  }

  /// Fit camera bounds to show entire route
  void _fitBoundsToRoute() {
    final currentBooking = booking.value;
    if (currentBooking == null || mapController == null) return;

    if (currentBooking.pickupAddress != null &&
        currentBooking.dropAddress != null) {
      final pickup = LatLng(
        currentBooking.pickupAddress!.lat,
        currentBooking.pickupAddress!.lng,
      );
      final drop = LatLng(
        currentBooking.dropAddress!.lat,
        currentBooking.dropAddress!.lng,
      );

      final cameraUpdate = _mapsService.fitBounds(pickup, drop, padding: 80.0);
      mapController!.animateCamera(cameraUpdate);
    }
  }

  /// Center map on driver location
  void centerOnDriver() {
    if (driverLocation.value == null || mapController == null) {
      Get.snackbar(
        'Info',
        'Driver location not available',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final cameraUpdate = _mapsService.focusOnLocation(
      driverLocation.value!,
      zoom: 16.0,
    );
    mapController!.animateCamera(cameraUpdate);
  }

  /// Call the driver
  Future<void> callDriver() async {
    final pilot = booking.value?.pilot;
    if (pilot == null || pilot.phone.isEmpty) {
      Get.snackbar(
        'Error',
        'Driver phone number not available',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final phoneUri = Uri(scheme: 'tel', path: pilot.phone);

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        Get.snackbar(
          'Error',
          'Unable to make phone call',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to initiate call',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Open chat with driver (placeholder)
  void openChat() {
    Get.snackbar(
      'Coming Soon',
      'Chat feature will be available soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Show delivery completion dialog
  void _showCompletionDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Delivery Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Your package has been delivered successfully.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Booking: ${booking.value?.bookingNumber ?? ''}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              Get.back(); // Go back from tracking screen
            },
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              // Navigate to rate delivery (placeholder)
              Get.snackbar(
                'Coming Soon',
                'Rating feature will be available soon',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Rate Delivery'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// Show booking cancellation dialog
  void _showCancellationDialog(String? reason) {
    Get.dialog(
      AlertDialog(
        title: const Text('Booking Cancelled'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cancel,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              reason?.isNotEmpty == true
                  ? 'Your booking has been cancelled.\n\nReason: $reason'
                  : 'Your booking has been cancelled.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              Get.back(); // Go back from tracking screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// Refresh booking data from API
  Future<void> refreshBooking() async {
    if (_bookingId == null) return;

    try {
      final response = await _bookingRepository.getBooking(_bookingId!);

      if (response.success && response.data != null) {
        booking.value = response.data;
        _updateMarkers();

        // Check for terminal states
        if (response.data!.status == BookingStatus.delivered) {
          _showCompletionDialog();
        } else if (response.data!.status == BookingStatus.cancelled) {
          _showCancellationDialog(response.data!.cancelReason);
        }
      }
    } catch (e) {
      print('[TrackingController] Error refreshing booking: $e');
    }
  }
}
