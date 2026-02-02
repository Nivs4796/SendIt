import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Service for Google Maps utilities including markers, polylines, and camera controls
class MapsService extends GetxService {
  // Custom markers
  BitmapDescriptor? _pickupMarker;
  BitmapDescriptor? _dropMarker;
  BitmapDescriptor? _driverMarker;

  /// Initialize the maps service and load custom markers
  Future<MapsService> init() async {
    await _loadMarkers();
    return this;
  }

  /// Load custom marker icons
  Future<void> _loadMarkers() async {
    _pickupMarker = BitmapDescriptor.defaultMarkerWithHue(
      BitmapDescriptor.hueGreen,
    );
    _dropMarker = BitmapDescriptor.defaultMarkerWithHue(
      BitmapDescriptor.hueRed,
    );
    _driverMarker = BitmapDescriptor.defaultMarkerWithHue(
      BitmapDescriptor.hueAzure,
    );
  }

  /// Green marker for pickup locations
  BitmapDescriptor get pickupMarker =>
      _pickupMarker ??
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);

  /// Red marker for drop/destination locations
  BitmapDescriptor get dropMarker =>
      _dropMarker ??
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);

  /// Azure marker for driver locations
  BitmapDescriptor get driverMarker =>
      _driverMarker ??
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);

  /// Decode a Google encoded polyline string to a list of LatLng points
  ///
  /// The algorithm decodes the compressed format used by Google's Polyline Algorithm.
  /// Reference: https://developers.google.com/maps/documentation/utilities/polylinealgorithm
  List<LatLng> decodePolyline(String encoded) {
    final List<LatLng> points = [];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      // Decode latitude
      int shift = 0;
      int result = 0;
      int byte;

      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1F) << shift;
        shift += 5;
      } while (byte >= 0x20);

      lat += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      // Decode longitude
      shift = 0;
      result = 0;

      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1F) << shift;
        shift += 5;
      } while (byte >= 0x20);

      lng += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      // Convert to decimal degrees
      points.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return points;
  }

  /// Get LatLngBounds that encompasses two points
  LatLngBounds getBounds(LatLng point1, LatLng point2) {
    final double southLat =
        point1.latitude < point2.latitude ? point1.latitude : point2.latitude;
    final double northLat =
        point1.latitude > point2.latitude ? point1.latitude : point2.latitude;
    final double westLng =
        point1.longitude < point2.longitude ? point1.longitude : point2.longitude;
    final double eastLng =
        point1.longitude > point2.longitude ? point1.longitude : point2.longitude;

    return LatLngBounds(
      southwest: LatLng(southLat, westLng),
      northeast: LatLng(northLat, eastLng),
    );
  }

  /// Create a CameraUpdate that fits both points with optional padding
  CameraUpdate fitBounds(
    LatLng point1,
    LatLng point2, {
    double padding = 50.0,
  }) {
    final bounds = getBounds(point1, point2);
    return CameraUpdate.newLatLngBounds(bounds, padding);
  }

  /// Create a CameraUpdate that focuses on a single location with optional zoom
  CameraUpdate focusOnLocation(LatLng location, {double zoom = 15.0}) {
    return CameraUpdate.newLatLngZoom(location, zoom);
  }

  /// Get map style JSON for dark mode
  /// Returns null for light mode (uses default Google Maps style)
  String? getMapStyle(bool isDarkMode) {
    if (!isDarkMode) return null;

    return '''
[
  {
    "elementType": "geometry",
    "stylers": [{"color": "#1d2c4d"}]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#8ec3b9"}]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [{"color": "#1a3646"}]
  },
  {
    "featureType": "administrative.country",
    "elementType": "geometry.stroke",
    "stylers": [{"color": "#4b6878"}]
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#64779e"}]
  },
  {
    "featureType": "administrative.province",
    "elementType": "geometry.stroke",
    "stylers": [{"color": "#4b6878"}]
  },
  {
    "featureType": "landscape.man_made",
    "elementType": "geometry.stroke",
    "stylers": [{"color": "#334e87"}]
  },
  {
    "featureType": "landscape.natural",
    "elementType": "geometry",
    "stylers": [{"color": "#023e58"}]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [{"color": "#283d6a"}]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#6f9ba5"}]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.stroke",
    "stylers": [{"color": "#1d2c4d"}]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry.fill",
    "stylers": [{"color": "#023e58"}]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#3C7680"}]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [{"color": "#304a7d"}]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#98a5be"}]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.stroke",
    "stylers": [{"color": "#1d2c4d"}]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [{"color": "#2c6675"}]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.stroke",
    "stylers": [{"color": "#255763"}]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#b0d5ce"}]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.stroke",
    "stylers": [{"color": "#023e58"}]
  },
  {
    "featureType": "transit",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#98a5be"}]
  },
  {
    "featureType": "transit",
    "elementType": "labels.text.stroke",
    "stylers": [{"color": "#1d2c4d"}]
  },
  {
    "featureType": "transit.line",
    "elementType": "geometry.fill",
    "stylers": [{"color": "#283d6a"}]
  },
  {
    "featureType": "transit.station",
    "elementType": "geometry",
    "stylers": [{"color": "#3a4762"}]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [{"color": "#0e1626"}]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#4e6d70"}]
  }
]
''';
  }

  /// Create a Polyline object for displaying routes on the map
  Polyline createRoutePolyline({
    required String id,
    required List<LatLng> points,
    Color color = const Color(0xFF10B981), // Primary emerald color
    int width = 5,
  }) {
    return Polyline(
      polylineId: PolylineId(id),
      points: points,
      color: color,
      width: width,
      patterns: const [],
      jointType: JointType.round,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
    );
  }

  /// Create a dashed polyline pattern for route alternatives
  Polyline createDashedRoutePolyline({
    required String id,
    required List<LatLng> points,
    Color color = const Color(0xFF64748B), // Grey color for alternatives
    int width = 4,
  }) {
    return Polyline(
      polylineId: PolylineId(id),
      points: points,
      color: color,
      width: width,
      patterns: [
        PatternItem.dash(20),
        PatternItem.gap(10),
      ],
      jointType: JointType.round,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
    );
  }

  /// Calculate the center point between two locations
  LatLng getCenter(LatLng point1, LatLng point2) {
    return LatLng(
      (point1.latitude + point2.latitude) / 2,
      (point1.longitude + point2.longitude) / 2,
    );
  }

  /// Calculate approximate distance between two points in meters
  /// Uses Haversine formula for accurate Earth-surface calculations
  double calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371000; // Earth's radius in meters

    final double lat1Rad = point1.latitude * (math.pi / 180);
    final double lat2Rad = point2.latitude * (math.pi / 180);
    final double deltaLat =
        (point2.latitude - point1.latitude) * (math.pi / 180);
    final double deltaLng =
        (point2.longitude - point1.longitude) * (math.pi / 180);

    final double a = (math.sin(deltaLat / 2) * math.sin(deltaLat / 2)) +
        (math.cos(lat1Rad) *
            math.cos(lat2Rad) *
            math.sin(deltaLng / 2) *
            math.sin(deltaLng / 2));
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  /// Calculate appropriate zoom level based on distance between two points
  double calculateZoomLevel(LatLng point1, LatLng point2) {
    final distance = calculateDistance(point1, point2);

    // Approximate zoom levels based on distance
    if (distance < 500) return 16.0;
    if (distance < 1000) return 15.0;
    if (distance < 2000) return 14.0;
    if (distance < 5000) return 13.0;
    if (distance < 10000) return 12.0;
    if (distance < 20000) return 11.0;
    if (distance < 50000) return 10.0;
    return 9.0;
  }
}
