import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../theme/app_colors.dart';

/// A reusable map widget for showing delivery routes
class DeliveryMap extends StatefulWidget {
  /// Pickup location coordinates
  final LatLng? pickupLocation;
  
  /// Drop location coordinates
  final LatLng? dropLocation;
  
  /// Current pilot location (updates in real-time)
  final LatLng? pilotLocation;
  
  /// Whether to show the route line
  final bool showRoute;
  
  /// Whether to track pilot location in real-time
  final bool trackPilot;
  
  /// Map height
  final double height;
  
  /// Callback when map is ready
  final Function(GoogleMapController)? onMapCreated;
  
  /// Custom pickup marker icon
  final BitmapDescriptor? pickupIcon;
  
  /// Custom drop marker icon
  final BitmapDescriptor? dropIcon;
  
  /// Custom pilot marker icon
  final BitmapDescriptor? pilotIcon;

  const DeliveryMap({
    super.key,
    this.pickupLocation,
    this.dropLocation,
    this.pilotLocation,
    this.showRoute = true,
    this.trackPilot = false,
    this.height = 250,
    this.onMapCreated,
    this.pickupIcon,
    this.dropIcon,
    this.pilotIcon,
  });

  @override
  State<DeliveryMap> createState() => _DeliveryMapState();
}

class _DeliveryMapState extends State<DeliveryMap> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  StreamSubscription<Position>? _positionSubscription;
  LatLng? _currentPilotLocation;

  @override
  void initState() {
    super.initState();
    _currentPilotLocation = widget.pilotLocation;
    _updateMarkers();
    if (widget.showRoute) {
      _updateRoute();
    }
    if (widget.trackPilot) {
      _startLocationTracking();
    }
  }

  @override
  void didUpdateWidget(DeliveryMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.pickupLocation != widget.pickupLocation ||
        oldWidget.dropLocation != widget.dropLocation ||
        oldWidget.pilotLocation != widget.pilotLocation) {
      _updateMarkers();
      if (widget.showRoute) {
        _updateRoute();
      }
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  void _startLocationTracking() async {
    final hasPermission = await _checkLocationPermission();
    if (!hasPermission) return;

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    ).listen((Position position) {
      setState(() {
        _currentPilotLocation = LatLng(position.latitude, position.longitude);
        _updateMarkers();
      });
      
      // Animate camera to follow pilot
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(_currentPilotLocation!),
      );
    });
  }

  Future<bool> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }

    return permission != LocationPermission.deniedForever;
  }

  void _updateMarkers() {
    final markers = <Marker>{};

    // Pickup marker
    if (widget.pickupLocation != null) {
      markers.add(Marker(
        markerId: const MarkerId('pickup'),
        position: widget.pickupLocation!,
        icon: widget.pickupIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: 'Pickup Location'),
      ));
    }

    // Drop marker
    if (widget.dropLocation != null) {
      markers.add(Marker(
        markerId: const MarkerId('drop'),
        position: widget.dropLocation!,
        icon: widget.dropIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: 'Drop Location'),
      ));
    }

    // Pilot marker
    final pilotPos = _currentPilotLocation ?? widget.pilotLocation;
    if (pilotPos != null) {
      markers.add(Marker(
        markerId: const MarkerId('pilot'),
        position: pilotPos,
        icon: widget.pilotIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'Your Location'),
        anchor: const Offset(0.5, 0.5),
        flat: true,
      ));
    }

    setState(() {
      _markers = markers;
    });
  }

  void _updateRoute() {
    if (widget.pickupLocation == null || widget.dropLocation == null) {
      setState(() {
        _polylines = {};
      });
      return;
    }

    // Simple straight line route (in production, use Directions API for actual route)
    final polyline = Polyline(
      polylineId: const PolylineId('route'),
      points: [
        if (_currentPilotLocation != null) _currentPilotLocation!,
        widget.pickupLocation!,
        widget.dropLocation!,
      ],
      color: AppColors.primary,
      width: 4,
      patterns: [PatternItem.dash(20), PatternItem.gap(10)],
    );

    setState(() {
      _polylines = {polyline};
    });
  }

  void _fitBounds() {
    if (_mapController == null) return;

    final locations = <LatLng>[];
    if (widget.pickupLocation != null) locations.add(widget.pickupLocation!);
    if (widget.dropLocation != null) locations.add(widget.dropLocation!);
    if (_currentPilotLocation != null) locations.add(_currentPilotLocation!);

    if (locations.isEmpty) return;

    if (locations.length == 1) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(locations.first, 15),
      );
      return;
    }

    double minLat = locations.first.latitude;
    double maxLat = locations.first.latitude;
    double minLng = locations.first.longitude;
    double maxLng = locations.first.longitude;

    for (final loc in locations) {
      if (loc.latitude < minLat) minLat = loc.latitude;
      if (loc.latitude > maxLat) maxLat = loc.latitude;
      if (loc.longitude < minLng) minLng = loc.longitude;
      if (loc.longitude > maxLng) maxLng = loc.longitude;
    }

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        50, // padding
      ),
    );
  }

  LatLng _getInitialPosition() {
    if (_currentPilotLocation != null) return _currentPilotLocation!;
    if (widget.pilotLocation != null) return widget.pilotLocation!;
    if (widget.pickupLocation != null) return widget.pickupLocation!;
    if (widget.dropLocation != null) return widget.dropLocation!;
    // Default to Ahmedabad
    return const LatLng(23.0225, 72.5714);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _getInitialPosition(),
                zoom: 14,
              ),
              markers: _markers,
              polylines: _polylines,
              myLocationEnabled: widget.trackPilot,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: false,
              onMapCreated: (controller) {
                _mapController = controller;
                widget.onMapCreated?.call(controller);
                
                // Fit bounds after a short delay
                Future.delayed(const Duration(milliseconds: 500), () {
                  _fitBounds();
                });
              },
            ),
            
            // Zoom controls
            Positioned(
              right: 12,
              bottom: 12,
              child: Column(
                children: [
                  _buildMapButton(
                    icon: Icons.add,
                    onTap: () => _mapController?.animateCamera(CameraUpdate.zoomIn()),
                  ),
                  const SizedBox(height: 8),
                  _buildMapButton(
                    icon: Icons.remove,
                    onTap: () => _mapController?.animateCamera(CameraUpdate.zoomOut()),
                  ),
                  const SizedBox(height: 8),
                  _buildMapButton(
                    icon: Icons.my_location,
                    onTap: _fitBounds,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.grey.shade700, size: 20),
      ),
    );
  }
}

/// A simple map preview widget (non-interactive)
class MapPreview extends StatelessWidget {
  final LatLng location;
  final double height;
  final String? label;

  const MapPreview({
    super.key,
    required this.location,
    this.height = 150,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: location,
                zoom: 15,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('location'),
                  position: location,
                ),
              },
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              scrollGesturesEnabled: false,
              zoomGesturesEnabled: false,
              rotateGesturesEnabled: false,
              tiltGesturesEnabled: false,
            ),
            if (label != null)
              Positioned(
                left: 12,
                bottom: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Text(
                    label!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
