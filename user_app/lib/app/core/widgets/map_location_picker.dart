import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// Result returned when a location is selected
class LocationPickerResult {
  final double lat;
  final double lng;
  final String address;
  final String? city;
  final String? state;
  final String? pincode;
  final String? landmark;

  LocationPickerResult({
    required this.lat,
    required this.lng,
    required this.address,
    this.city,
    this.state,
    this.pincode,
    this.landmark,
  });

  Map<String, dynamic> toJson() => {
        'lat': lat,
        'lng': lng,
        'address': address,
        'city': city,
        'state': state,
        'pincode': pincode,
        'landmark': landmark,
      };
}

/// Full screen map location picker with:
/// - Google Maps with draggable center pin
/// - Search bar with place autocomplete
/// - Current location button
/// - Bottom sheet showing selected address
/// - Editable address form before saving
class MapLocationPicker extends StatefulWidget {
  final String title;
  final LatLng? initialLocation;
  final bool showSearch;

  const MapLocationPicker({
    super.key,
    this.title = 'Select Location',
    this.initialLocation,
    this.showSearch = true,
  });

  /// Show the picker and return selected location
  static Future<LocationPickerResult?> show({
    String title = 'Select Location',
    LatLng? initialLocation,
    bool showSearch = true,
  }) async {
    return await Get.to<LocationPickerResult>(
      () => MapLocationPicker(
        title: title,
        initialLocation: initialLocation,
        showSearch: showSearch,
      ),
      fullscreenDialog: true,
      transition: Transition.downToUp,
    );
  }

  @override
  State<MapLocationPicker> createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends State<MapLocationPicker> {
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // State
  LatLng? _currentPosition;
  String _selectedAddress = 'Move the map to select location';
  String? _city;
  String? _state;
  String? _pincode;
  bool _isLoading = false;
  bool _isSearching = false;
  List<_PlaceSuggestion> _suggestions = [];
  Timer? _debounceTimer;

  // Default to Ahmedabad, India
  static const LatLng _defaultLocation = LatLng(23.0225, 72.5714);

  @override
  void initState() {
    super.initState();
    _currentPosition = widget.initialLocation ?? _defaultLocation;
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    if (widget.initialLocation != null) {
      _getAddressFromLatLng(_currentPosition!);
      return;
    }

    try {
      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _getAddressFromLatLng(_currentPosition!);
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLng(_currentPosition!),
      );

      _getAddressFromLatLng(_currentPosition!);
    } catch (e) {
      debugPrint('Error getting location: $e');
      _getAddressFromLatLng(_currentPosition!);
    }
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    setState(() => _isLoading = true);

    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        // Build address string
        final parts = <String>[];
        if (place.street?.isNotEmpty == true) parts.add(place.street!);
        if (place.subLocality?.isNotEmpty == true) parts.add(place.subLocality!);
        if (place.locality?.isNotEmpty == true) parts.add(place.locality!);

        setState(() {
          _selectedAddress = parts.isNotEmpty ? parts.join(', ') : 'Unknown location';
          _city = place.locality;
          _state = place.administrativeArea;
          _pincode = place.postalCode;
        });
      }
    } catch (e) {
      debugPrint('Error getting address: $e');
      setState(() {
        _selectedAddress = 'Unable to get address';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onCameraMove(CameraPosition position) {
    _currentPosition = position.target;
  }

  void _onCameraIdle() {
    if (_currentPosition != null) {
      _getAddressFromLatLng(_currentPosition!);
    }
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();

    if (query.length < 3) {
      setState(() {
        _suggestions = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _searchPlaces(query);
    });
  }

  Future<void> _searchPlaces(String query) async {
    try {
      // Add India context to improve results
      final searchQuery = '$query, India';
      final locations = await locationFromAddress(searchQuery);

      if (locations.isNotEmpty) {
        final suggestions = <_PlaceSuggestion>[];

        for (final location in locations.take(5)) {
          try {
            final placemarks = await placemarkFromCoordinates(
              location.latitude,
              location.longitude,
            );

            if (placemarks.isNotEmpty) {
              final place = placemarks.first;
              final title = place.street ?? place.subLocality ?? place.name ?? query;
              suggestions.add(_PlaceSuggestion(
                title: title,
                subtitle: [place.locality, place.administrativeArea]
                    .where((e) => e?.isNotEmpty == true)
                    .join(', '),
                latLng: LatLng(location.latitude, location.longitude),
              ));
            }
          } catch (_) {}
        }

        if (mounted) {
          setState(() {
            _suggestions = suggestions;
            _isSearching = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _suggestions = [];
            _isSearching = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Search error: $e');
      if (mounted) {
        setState(() {
          _suggestions = [];
          _isSearching = false;
        });
      }
    }
  }

  void _selectSuggestion(_PlaceSuggestion suggestion) {
    _searchController.clear();
    _searchFocusNode.unfocus();

    setState(() {
      _currentPosition = suggestion.latLng;
      _suggestions = [];
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(suggestion.latLng, 17),
    );

    _getAddressFromLatLng(suggestion.latLng);
  }

  void _confirmLocation() {
    if (_currentPosition == null || _isLoading) return;

    // Show address form bottom sheet
    _showAddressFormSheet();
  }

  void _showAddressFormSheet() {
    final theme = Theme.of(context);
    
    // Controllers for form fields
    final addressController = TextEditingController(text: _selectedAddress);
    final landmarkController = TextEditingController();
    final cityController = TextEditingController(text: _city ?? '');
    final stateController = TextEditingController(text: _state ?? '');
    final pincodeController = TextEditingController(text: _pincode ?? '');

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                'Confirm Address Details',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please verify and edit if needed',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor,
                ),
              ),
              const SizedBox(height: 20),

              // Address field
              _buildFormField(
                controller: addressController,
                label: 'Address',
                hint: 'Street address, building name',
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Landmark field
              _buildFormField(
                controller: landmarkController,
                label: 'Landmark (Optional)',
                hint: 'Near landmark',
              ),
              const SizedBox(height: 16),

              // City and Pincode row
              Row(
                children: [
                  Expanded(
                    child: _buildFormField(
                      controller: cityController,
                      label: 'City',
                      hint: 'City',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildFormField(
                      controller: pincodeController,
                      label: 'Pincode',
                      hint: 'Pincode',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // State field
              _buildFormField(
                controller: stateController,
                label: 'State',
                hint: 'State',
              ),
              const SizedBox(height: 24),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Create result
                    final result = LocationPickerResult(
                      lat: _currentPosition!.latitude,
                      lng: _currentPosition!.longitude,
                      address: addressController.text.trim(),
                      landmark: landmarkController.text.trim().isNotEmpty
                          ? landmarkController.text.trim()
                          : null,
                      city: cityController.text.trim().isNotEmpty
                          ? cityController.text.trim()
                          : null,
                      state: stateController.text.trim().isNotEmpty
                          ? stateController.text.trim()
                          : null,
                      pincode: pincodeController.text.trim().isNotEmpty
                          ? pincodeController.text.trim()
                          : null,
                    );

                    // Close bottom sheet
                    Get.back();
                    // Return result
                    Get.back(result: result);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Save Location',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      isDismissible: true,
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  void _goToCurrentLocation() async {
    try {
      setState(() => _isLoading = true);
      
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final latLng = LatLng(position.latitude, position.longitude);
      
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(latLng, 17),
      );
      
      setState(() {
        _currentPosition = latLng;
      });
      
      _getAddressFromLatLng(latLng);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Unable to get current location',
        snackPosition: SnackPosition.BOTTOM,
      );
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition ?? _defaultLocation,
              zoom: 15,
            ),
            onMapCreated: (controller) => _mapController = controller,
            onCameraMove: _onCameraMove,
            onCameraIdle: _onCameraIdle,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),

          // Center Pin
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 36),
              child: Icon(
                Icons.location_pin,
                size: 48,
                color: theme.colorScheme.primary,
              ),
            ),
          ),

          // Pin shadow
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 32),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          // Top bar with back and search
          SafeArea(
            child: Column(
              children: [
                // App bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      // Back button
                      Material(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        elevation: 2,
                        child: InkWell(
                          onTap: () => Get.back(),
                          borderRadius: BorderRadius.circular(12),
                          child: const Padding(
                            padding: EdgeInsets.all(12),
                            child: Icon(Icons.arrow_back_rounded),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Search bar
                      if (widget.showSearch)
                        Expanded(
                          child: Material(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(12),
                            elevation: 2,
                            child: TextField(
                              controller: _searchController,
                              focusNode: _searchFocusNode,
                              onChanged: _onSearchChanged,
                              decoration: InputDecoration(
                                hintText: 'Search location...',
                                prefixIcon: _isSearching
                                    ? const Padding(
                                        padding: EdgeInsets.all(12),
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        ),
                                      )
                                    : const Icon(Icons.search_rounded),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear_rounded),
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() => _suggestions = []);
                                        },
                                      )
                                    : null,
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Search suggestions
                if (_suggestions.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    constraints: const BoxConstraints(maxHeight: 250),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: _suggestions.length,
                      itemBuilder: (context, index) {
                        final suggestion = _suggestions[index];
                        return ListTile(
                          leading: const Icon(Icons.location_on_outlined),
                          title: Text(
                            suggestion.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: suggestion.subtitle.isNotEmpty
                              ? Text(
                                  suggestion.subtitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )
                              : null,
                          onTap: () => _selectSuggestion(suggestion),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // Current location FAB
          Positioned(
            right: 16,
            bottom: 200,
            child: FloatingActionButton.small(
              heroTag: 'location',
              onPressed: _goToCurrentLocation,
              backgroundColor: theme.cardColor,
              child: Icon(
                Icons.my_location_rounded,
                color: theme.colorScheme.primary,
              ),
            ),
          ),

          // Bottom sheet with address
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: theme.dividerColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Title
                      Text(
                        widget.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Address
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.location_on_rounded,
                              color: theme.colorScheme.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _isLoading
                                ? Row(
                                    children: [
                                      SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text('Getting address...'),
                                    ],
                                  )
                                : Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _selectedAddress,
                                        style: theme.textTheme.bodyLarge,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (_city != null || _pincode != null)
                                        Text(
                                          [_city, _state, _pincode]
                                              .where((e) => e?.isNotEmpty == true)
                                              .join(', '),
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: theme.hintColor,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                    ],
                                  ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Confirm button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _confirmLocation,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Confirm Location',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Place suggestion model
class _PlaceSuggestion {
  final String title;
  final String subtitle;
  final LatLng latLng;

  _PlaceSuggestion({
    required this.title,
    required this.subtitle,
    required this.latLng,
  });
}
