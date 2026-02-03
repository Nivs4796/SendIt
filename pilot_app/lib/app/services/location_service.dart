import 'dart:async';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';

/// Location data model
class LocationData {
  final double lat;
  final double lng;
  final double? heading;
  final double? speed;
  final double? accuracy;
  final DateTime timestamp;

  LocationData({
    required this.lat,
    required this.lng,
    this.heading,
    this.speed,
    this.accuracy,
    required this.timestamp,
  });

  factory LocationData.fromPosition(Position position) {
    return LocationData(
      lat: position.latitude,
      lng: position.longitude,
      heading: position.heading,
      speed: position.speed,
      accuracy: position.accuracy,
      timestamp: position.timestamp,
    );
  }

  Map<String, dynamic> toJson() => {
    'lat': lat,
    'lng': lng,
    if (heading != null) 'heading': heading,
    if (speed != null) 'speed': speed,
  };
}

/// Permission status for location
enum LocationPermissionStatus {
  granted,
  denied,
  deniedForever,
  serviceDisabled,
}

/// Service for managing GPS location tracking
class LocationService extends GetxService {
  // Current location
  final currentLocation = Rxn<LocationData>();
  
  // Permission status
  final permissionStatus = LocationPermissionStatus.denied.obs;
  
  // Tracking state
  final isTracking = false.obs;
  
  // Stream subscription
  StreamSubscription<Position>? _positionSubscription;
  
  // Callback for location updates
  Function(LocationData)? onLocationUpdate;

  /// Initialize service
  Future<LocationService> init() async {
    await checkPermission();
    return this;
  }

  /// Check and request location permission
  Future<LocationPermissionStatus> checkPermission() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      permissionStatus.value = LocationPermissionStatus.serviceDisabled;
      return permissionStatus.value;
    }

    // Check permission
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      permissionStatus.value = LocationPermissionStatus.denied;
    } else if (permission == LocationPermission.deniedForever) {
      permissionStatus.value = LocationPermissionStatus.deniedForever;
    } else {
      permissionStatus.value = LocationPermissionStatus.granted;
    }

    return permissionStatus.value;
  }

  /// Request location permission
  Future<bool> requestPermission() async {
    final status = await checkPermission();
    return status == LocationPermissionStatus.granted;
  }

  /// Open app settings for permission
  Future<bool> openSettings() async {
    return await Geolocator.openAppSettings();
  }

  /// Open location settings
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Get current location once
  Future<LocationData?> getCurrentLocation() async {
    if (permissionStatus.value != LocationPermissionStatus.granted) {
      final granted = await requestPermission();
      if (!granted) return null;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      final location = LocationData.fromPosition(position);
      currentLocation.value = location;
      return location;
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  /// Start continuous location tracking
  Future<bool> startTracking() async {
    if (isTracking.value) return true;

    if (permissionStatus.value != LocationPermissionStatus.granted) {
      final granted = await requestPermission();
      if (!granted) return false;
    }

    try {
      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // Update every 10 meters
        ),
      ).listen(
        (Position position) {
          final location = LocationData.fromPosition(position);
          currentLocation.value = location;
          onLocationUpdate?.call(location);
        },
        onError: (error) {
          print('Location stream error: $error');
        },
      );

      isTracking.value = true;
      print('Location tracking started');
      return true;
    } catch (e) {
      print('Error starting location tracking: $e');
      return false;
    }
  }

  /// Stop location tracking
  void stopTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    isTracking.value = false;
    print('Location tracking stopped');
  }

  /// Calculate distance between two points (in meters)
  double calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  /// Calculate bearing between two points
  double calculateBearing(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.bearingBetween(startLat, startLng, endLat, endLng);
  }

  @override
  void onClose() {
    stopTracking();
    super.onClose();
  }
}
