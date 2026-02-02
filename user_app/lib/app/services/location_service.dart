import 'dart:math' show cos, sqrt, asin, pi;

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../core/constants/app_constants.dart';

class LocationService extends GetxService {
  // Observable state
  final Rx<Position?> currentLocation = Rx<Position?>(null);
  final RxBool permissionGranted = false.obs;
  final RxBool isLoading = false.obs;

  // Default location (Ahmedabad)
  LatLng get defaultLocation => const LatLng(
        AppConstants.defaultLat,
        AppConstants.defaultLng,
      );

  /// Initialize the service and check permissions
  Future<LocationService> init() async {
    await checkPermission();
    if (permissionGranted.value) {
      await getCurrentLocation();
    }
    return this;
  }

  /// Check and request location permission
  Future<bool> checkPermission() async {
    isLoading.value = true;

    try {
      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        permissionGranted.value = false;
        return false;
      }

      // Check permission status
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        // Request permission
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          permissionGranted.value = false;
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Permission denied forever - user needs to enable from settings
        permissionGranted.value = false;
        return false;
      }

      // Permission granted
      permissionGranted.value = true;
      return true;
    } catch (e) {
      permissionGranted.value = false;
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Get the current device position
  Future<Position?> getCurrentLocation() async {
    isLoading.value = true;

    try {
      // Ensure permission is granted
      if (!permissionGranted.value) {
        final hasPermission = await checkPermission();
        if (!hasPermission) {
          return null;
        }
      }

      // Get current position with high accuracy
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      currentLocation.value = position;
      return position;
    } catch (e) {
      // Return cached location if available
      return currentLocation.value;
    } finally {
      isLoading.value = false;
    }
  }

  /// Get address from coordinates (reverse geocoding)
  Future<String?> getAddressFromCoordinates(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        return _formatAddress(placemark);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get coordinates from address (forward geocoding)
  Future<LatLng?> getCoordinatesFromAddress(String address) async {
    try {
      final locations = await locationFromAddress(address);

      if (locations.isNotEmpty) {
        final location = locations.first;
        return LatLng(location.latitude, location.longitude);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Calculate distance between two points using Haversine formula
  /// Returns distance in kilometers
  double calculateDistance(LatLng from, LatLng to) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    final double lat1 = from.latitude * pi / 180;
    final double lat2 = to.latitude * pi / 180;
    final double dLat = (to.latitude - from.latitude) * pi / 180;
    final double dLng = (to.longitude - from.longitude) * pi / 180;

    final double a = _haversine(dLat) + cos(lat1) * cos(lat2) * _haversine(dLng);
    final double c = 2 * asin(sqrt(a));

    return earthRadius * c;
  }

  /// Helper function for Haversine formula
  double _haversine(double angle) {
    return (1 - cos(angle)) / 2;
  }

  /// Format placemark into readable address string
  String _formatAddress(Placemark placemark) {
    final parts = <String>[];

    if (placemark.name?.isNotEmpty == true &&
        placemark.name != placemark.street) {
      parts.add(placemark.name!);
    }
    if (placemark.street?.isNotEmpty == true) {
      parts.add(placemark.street!);
    }
    if (placemark.subLocality?.isNotEmpty == true) {
      parts.add(placemark.subLocality!);
    }
    if (placemark.locality?.isNotEmpty == true) {
      parts.add(placemark.locality!);
    }
    if (placemark.postalCode?.isNotEmpty == true) {
      parts.add(placemark.postalCode!);
    }

    return parts.join(', ');
  }

  /// Get current LatLng or default location
  LatLng get currentLatLng {
    if (currentLocation.value != null) {
      return LatLng(
        currentLocation.value!.latitude,
        currentLocation.value!.longitude,
      );
    }
    return defaultLocation;
  }

  /// Open device location settings
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Open app settings for permission management
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  /// Stream location updates
  Stream<Position> getLocationStream({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10,
  }) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
      ),
    );
  }
}
