import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/models/address_model.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/models/price_calculation_model.dart';
import '../../../data/models/vehicle_type_model.dart';
import '../../../data/providers/api_exceptions.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../../services/location_service.dart';
import '../../../services/payment_service.dart';

/// Enum representing the various states of the booking flow.
enum BookingState {
  idle,
  loadingVehicles,
  calculatingPrice,
  creatingBooking,
  findingDriver,
}

/// Controller for managing the complete booking flow.
/// Handles location selection, vehicle selection, price calculation,
/// payment processing, and booking creation.
class BookingController extends GetxController {
  // Dependencies
  final BookingRepository _bookingRepository = BookingRepository();
  late final LocationService _locationService;
  late final PaymentService _paymentService;

  // Form Controllers
  late TextEditingController pickupController;
  late TextEditingController dropController;
  late TextEditingController packageDescriptionController;

  // ============================================
  // Observable State
  // ============================================

  /// Current state of the booking flow
  final Rx<BookingState> bookingState = BookingState.idle.obs;

  /// Error message to display to the user
  final RxString errorMessage = ''.obs;

  // Location State
  /// Pickup location coordinates
  final Rx<LatLng?> pickupLocation = Rx<LatLng?>(null);

  /// Drop location coordinates
  final Rx<LatLng?> dropLocation = Rx<LatLng?>(null);

  /// Pickup address string
  final RxString pickupAddress = ''.obs;

  /// Drop address string
  final RxString dropAddress = ''.obs;

  /// Pickup landmark for additional location context
  final RxString pickupLandmark = ''.obs;

  /// Drop landmark for additional location context
  final RxString dropLandmark = ''.obs;

  // Package State
  /// Selected package type (default: parcel)
  final Rx<PackageType> selectedPackageType = PackageType.parcel.obs;

  /// Package description entered by user
  final RxString packageDescription = ''.obs;

  // Vehicle State
  /// List of available vehicle types
  final RxList<VehicleTypeModel> vehicleTypes = <VehicleTypeModel>[].obs;

  /// Currently selected vehicle type
  final Rx<VehicleTypeModel?> selectedVehicle = Rx<VehicleTypeModel?>(null);

  // Price State
  /// Price calculation result from API
  final Rx<PriceCalculationModel?> priceCalculation =
      Rx<PriceCalculationModel?>(null);

  // Payment State
  /// Selected payment method (default: wallet)
  final Rx<PaymentMethod> selectedPaymentMethod = PaymentMethod.wallet.obs;

  /// Current wallet balance
  final RxDouble walletBalance = 0.0.obs;

  /// Whether user has sufficient balance for the booking
  final RxBool hasSufficientBalance = false.obs;

  /// Applied coupon code
  final RxString couponCode = ''.obs;

  /// Discount amount from coupon
  final RxDouble couponDiscount = 0.0.obs;

  // Booking State
  /// The current booking being created/tracked
  final Rx<BookingModel?> currentBooking = Rx<BookingModel?>(null);

  // ============================================
  // Getters
  // ============================================

  /// Returns true if any loading state is active
  bool get isLoading =>
      bookingState.value == BookingState.loadingVehicles ||
      bookingState.value == BookingState.calculatingPrice ||
      bookingState.value == BookingState.creatingBooking ||
      bookingState.value == BookingState.findingDriver;

  /// Returns true if user can proceed to vehicle selection
  /// Requires both pickup and drop locations to be set
  bool get canProceedToVehicle =>
      pickupLocation.value != null &&
      dropLocation.value != null &&
      pickupAddress.value.isNotEmpty &&
      dropAddress.value.isNotEmpty;

  /// Returns true if user can proceed to payment
  /// Requires vehicle to be selected and price to be calculated
  bool get canProceedToPayment =>
      canProceedToVehicle &&
      selectedVehicle.value != null &&
      priceCalculation.value != null;

  /// Calculates the final amount after applying coupon discount
  double get finalAmount {
    if (priceCalculation.value == null) return 0.0;
    final total = priceCalculation.value!.totalAmount;
    return (total - couponDiscount.value).clamp(0.0, double.infinity);
  }

  /// Formatted display string for final amount
  String get finalAmountDisplay =>
      '\u20B9${finalAmount.toStringAsFixed(2).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          )}';

  // ============================================
  // Lifecycle Methods
  // ============================================

  @override
  void onInit() {
    super.onInit();

    // Initialize form controllers
    pickupController = TextEditingController();
    dropController = TextEditingController();
    packageDescriptionController = TextEditingController();

    // Get service instances
    _locationService = Get.find<LocationService>();
    _paymentService = Get.find<PaymentService>();

    // Sync package description with observable
    packageDescriptionController.addListener(() {
      packageDescription.value = packageDescriptionController.text;
    });

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

  // ============================================
  // Private Methods
  // ============================================

  /// Loads available vehicle types from the API.
  Future<void> _loadVehicleTypes() async {
    try {
      bookingState.value = BookingState.loadingVehicles;
      errorMessage.value = '';

      final response = await _bookingRepository.getVehicleTypes();

      if (response.success && response.data != null) {
        vehicleTypes.value = response.data!;
      } else {
        _showError(response.message ?? 'Failed to load vehicle types');
      }
    } on ApiException catch (e) {
      _showError(e.message);
    } on NetworkException {
      _showError('No internet connection');
    } catch (e) {
      _showError('Something went wrong');
    } finally {
      bookingState.value = BookingState.idle;
    }
  }

  /// Checks the current wallet balance.
  Future<void> _checkWalletBalance() async {
    try {
      final balanceCheck = await _paymentService.checkWalletBalance(0);
      walletBalance.value = balanceCheck['currentBalance'] as double? ?? 0.0;

      // Update sufficient balance status if we have a price
      if (priceCalculation.value != null) {
        hasSufficientBalance.value = walletBalance.value >= finalAmount;
      }
    } catch (e) {
      // Silent fail - we'll check again when needed
      walletBalance.value = 0.0;
    }
  }

  // ============================================
  // Location Methods
  // ============================================

  /// Uses the current device location as the pickup location.
  Future<void> useCurrentLocationAsPickup() async {
    try {
      bookingState.value = BookingState.loadingVehicles;
      errorMessage.value = '';

      // Get current location
      final position = await _locationService.getCurrentLocation();

      if (position != null) {
        final latLng = LatLng(position.latitude, position.longitude);
        pickupLocation.value = latLng;

        // Get address from coordinates
        final address = await _locationService.getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (address != null) {
          pickupAddress.value = address;
          pickupController.text = address;
        }
      } else {
        _showError('Could not get current location');
      }
    } catch (e) {
      _showError('Failed to get current location');
    } finally {
      bookingState.value = BookingState.idle;
    }
  }

  /// Sets the pickup location with coordinates and address.
  void setPickupLocation({
    required LatLng location,
    required String address,
    String? landmark,
  }) {
    pickupLocation.value = location;
    pickupAddress.value = address;
    pickupController.text = address;
    if (landmark != null) {
      pickupLandmark.value = landmark;
    }

    // Reset price calculation when location changes
    _resetPriceCalculation();
  }

  /// Sets the drop location with coordinates and address.
  void setDropLocation({
    required LatLng location,
    required String address,
    String? landmark,
  }) {
    dropLocation.value = location;
    dropAddress.value = address;
    dropController.text = address;
    if (landmark != null) {
      dropLandmark.value = landmark;
    }

    // Reset price calculation when location changes
    _resetPriceCalculation();
  }

  /// Sets location from a saved address.
  void setFromSavedAddress({
    required AddressModel address,
    required bool isPickup,
  }) {
    final latLng = LatLng(address.lat, address.lng);

    if (isPickup) {
      setPickupLocation(
        location: latLng,
        address: address.fullAddress,
        landmark: address.landmark,
      );
    } else {
      setDropLocation(
        location: latLng,
        address: address.fullAddress,
        landmark: address.landmark,
      );
    }
  }

  // ============================================
  // Package & Vehicle Methods
  // ============================================

  /// Selects a package type.
  void selectPackageType(PackageType type) {
    selectedPackageType.value = type;
  }

  /// Selects a vehicle type and triggers price calculation.
  void selectVehicle(VehicleTypeModel vehicle) {
    selectedVehicle.value = vehicle;

    // Auto-calculate price when vehicle is selected
    if (canProceedToVehicle) {
      calculatePrice();
    }
  }

  /// Calculates the price for the current booking configuration.
  Future<void> calculatePrice() async {
    if (!canProceedToVehicle || selectedVehicle.value == null) {
      _showError('Please select pickup, drop locations and vehicle type');
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

        // Update balance check
        hasSufficientBalance.value = walletBalance.value >= finalAmount;
      } else {
        _showError(response.message ?? 'Failed to calculate price');
      }
    } on ApiException catch (e) {
      _showError(e.message);
    } on NetworkException {
      _showError('No internet connection');
    } catch (e) {
      _showError('Something went wrong');
    } finally {
      bookingState.value = BookingState.idle;
    }
  }

  // ============================================
  // Payment Methods
  // ============================================

  /// Selects a payment method.
  void selectPaymentMethod(PaymentMethod method) {
    selectedPaymentMethod.value = method;

    // Update balance check if wallet is selected
    if (method == PaymentMethod.wallet && priceCalculation.value != null) {
      hasSufficientBalance.value = walletBalance.value >= finalAmount;
    }
  }

  /// Applies a coupon code.
  /// Currently a placeholder - implement actual coupon validation API.
  Future<void> applyCoupon(String code) async {
    if (code.isEmpty) {
      couponCode.value = '';
      couponDiscount.value = 0.0;
      return;
    }

    try {
      // TODO: Implement actual coupon validation API
      // For now, we'll just store the code
      couponCode.value = code;

      // Placeholder discount logic - replace with API response
      // Example: 10% discount for 'FIRST10'
      if (code.toUpperCase() == 'FIRST10' && priceCalculation.value != null) {
        couponDiscount.value = priceCalculation.value!.totalAmount * 0.10;
        _showSuccess('Coupon applied successfully!');
      } else {
        couponDiscount.value = 0.0;
        _showError('Invalid coupon code');
      }

      // Update balance check after discount
      if (selectedPaymentMethod.value == PaymentMethod.wallet) {
        hasSufficientBalance.value = walletBalance.value >= finalAmount;
      }
    } catch (e) {
      couponCode.value = '';
      couponDiscount.value = 0.0;
      _showError('Failed to apply coupon');
    }
  }

  // ============================================
  // Booking Methods
  // ============================================

  /// Creates a new booking with the current configuration.
  Future<void> createBooking() async {
    if (!canProceedToPayment) {
      _showError('Please complete all booking details');
      return;
    }

    // Validate wallet balance if paying with wallet
    if (selectedPaymentMethod.value == PaymentMethod.wallet) {
      if (!hasSufficientBalance.value) {
        _showError(
          'Insufficient wallet balance. Please add funds or choose a different payment method.',
        );
        return;
      }
    }

    try {
      bookingState.value = BookingState.creatingBooking;
      errorMessage.value = '';

      // Create booking request
      final request = CreateBookingRequest(
        pickupLat: pickupLocation.value!.latitude,
        pickupLng: pickupLocation.value!.longitude,
        pickupAddress: pickupAddress.value,
        pickupLandmark:
            pickupLandmark.value.isNotEmpty ? pickupLandmark.value : null,
        dropLat: dropLocation.value!.latitude,
        dropLng: dropLocation.value!.longitude,
        dropAddress: dropAddress.value,
        dropLandmark: dropLandmark.value.isNotEmpty ? dropLandmark.value : null,
        vehicleTypeId: selectedVehicle.value!.id,
        packageType: _packageTypeToString(selectedPackageType.value),
        packageDescription: packageDescription.value.isNotEmpty
            ? packageDescription.value
            : null,
        paymentMethod: _paymentMethodToString(selectedPaymentMethod.value),
        couponCode: couponCode.value.isNotEmpty ? couponCode.value : null,
      );

      final response = await _bookingRepository.createBooking(request);

      if (response.success && response.data != null) {
        currentBooking.value = response.data!;
        bookingState.value = BookingState.findingDriver;
        _showSuccess('Booking created! Finding a driver...');
      } else {
        bookingState.value = BookingState.idle;
        _showError(response.message ?? 'Failed to create booking');
      }
    } on ApiException catch (e) {
      bookingState.value = BookingState.idle;
      _showError(e.message);
    } on NetworkException {
      bookingState.value = BookingState.idle;
      _showError('No internet connection');
    } catch (e) {
      bookingState.value = BookingState.idle;
      _showError('Something went wrong');
    }
  }

  /// Cancels the current booking.
  Future<void> cancelBooking({String? reason}) async {
    if (currentBooking.value == null) {
      _showError('No active booking to cancel');
      return;
    }

    try {
      bookingState.value = BookingState.creatingBooking;
      errorMessage.value = '';

      final response = await _bookingRepository.cancelBooking(
        currentBooking.value!.id,
        reason: reason,
      );

      if (response.success) {
        currentBooking.value = response.data;
        bookingState.value = BookingState.idle;
        _showSuccess('Booking cancelled successfully');
        resetBooking();
      } else {
        bookingState.value = BookingState.idle;
        _showError(response.message ?? 'Failed to cancel booking');
      }
    } on ApiException catch (e) {
      bookingState.value = BookingState.idle;
      _showError(e.message);
    } on NetworkException {
      bookingState.value = BookingState.idle;
      _showError('No internet connection');
    } catch (e) {
      bookingState.value = BookingState.idle;
      _showError('Something went wrong');
    }
  }

  /// Resets all booking state to initial values.
  void resetBooking() {
    // Reset location
    pickupLocation.value = null;
    dropLocation.value = null;
    pickupAddress.value = '';
    dropAddress.value = '';
    pickupLandmark.value = '';
    dropLandmark.value = '';
    pickupController.clear();
    dropController.clear();

    // Reset package
    selectedPackageType.value = PackageType.parcel;
    packageDescription.value = '';
    packageDescriptionController.clear();

    // Reset vehicle and price
    selectedVehicle.value = null;
    priceCalculation.value = null;

    // Reset payment
    selectedPaymentMethod.value = PaymentMethod.wallet;
    couponCode.value = '';
    couponDiscount.value = 0.0;

    // Reset booking
    currentBooking.value = null;
    bookingState.value = BookingState.idle;
    errorMessage.value = '';
  }

  // ============================================
  // Helper Methods
  // ============================================

  /// Resets the price calculation when locations change.
  void _resetPriceCalculation() {
    priceCalculation.value = null;
    couponDiscount.value = 0.0;
    hasSufficientBalance.value = false;
  }

  /// Shows an error message via snackbar.
  void _showError(String message) {
    errorMessage.value = message;
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  /// Shows a success message via snackbar.
  void _showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  /// Converts PackageType enum to API string.
  String _packageTypeToString(PackageType type) {
    switch (type) {
      case PackageType.document:
        return 'DOCUMENT';
      case PackageType.parcel:
        return 'PARCEL';
      case PackageType.food:
        return 'FOOD';
      case PackageType.grocery:
        return 'GROCERY';
      case PackageType.medicine:
        return 'MEDICINE';
      case PackageType.fragile:
        return 'FRAGILE';
      case PackageType.other:
        return 'OTHER';
    }
  }

  /// Converts PaymentMethod enum to API string.
  String _paymentMethodToString(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'CASH';
      case PaymentMethod.upi:
        return 'UPI';
      case PaymentMethod.card:
        return 'CARD';
      case PaymentMethod.wallet:
        return 'WALLET';
      case PaymentMethod.netbanking:
        return 'NETBANKING';
    }
  }

  /// Refreshes vehicle types list.
  Future<void> refreshVehicleTypes() async {
    await _loadVehicleTypes();
  }

  /// Refreshes wallet balance.
  Future<void> refreshWalletBalance() async {
    await _checkWalletBalance();
  }
}
