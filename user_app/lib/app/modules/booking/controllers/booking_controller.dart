import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/map_location_picker.dart';
import '../../../data/models/address_model.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/models/coupon_model.dart';
import '../../../data/models/price_calculation_model.dart';
import '../../../data/models/vehicle_type_model.dart';
import '../../../data/providers/api_exceptions.dart';
import '../../../data/repositories/address_repository.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../../data/repositories/coupon_repository.dart';
import '../../../routes/app_routes.dart';
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
  final CouponRepository _couponRepository = CouponRepository();
  final AddressRepository _addressRepository = AddressRepository();
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

  /// Applied coupon model (for displaying coupon details)
  final Rx<CouponModel?> appliedCoupon = Rx<CouponModel?>(null);

  /// Discount amount from coupon
  final RxDouble couponDiscount = 0.0.obs;

  /// Whether coupon validation is in progress
  final RxBool isValidatingCoupon = false.obs;

  // Booking State
  /// The current booking being created/tracked
  final Rx<BookingModel?> currentBooking = Rx<BookingModel?>(null);

  // Step Tracking State (for unified booking flow)
  /// Current step in the booking flow (0: Locations, 1: Package, 2: Vehicle)
  final RxInt currentStep = 0.obs;

  /// Whether each step is expanded in the UI
  final RxList<bool> expandedSteps = <bool>[true, false, false].obs;

  // Saved Address State (for API calls with address IDs)
  /// Selected pickup address (saved address with ID for API)
  final Rx<AddressModel?> selectedPickupAddress = Rx<AddressModel?>(null);

  /// Selected drop address (saved address with ID for API)
  final Rx<AddressModel?> selectedDropAddress = Rx<AddressModel?>(null);

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
  /// Requires both pickup and drop saved addresses to be selected
  bool get canProceedToVehicle =>
      selectedPickupAddress.value != null &&
      selectedDropAddress.value != null;

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
      // Use getWalletBalance() to avoid the API validation error
      // that requires a positive amount
      walletBalance.value = await _paymentService.getWalletBalance();

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
  /// Note: This clears the saved address - you must use setFromSavedAddress()
  /// for the booking API to work properly.
  void setPickupLocation({
    required LatLng location,
    required String address,
    String? landmark,
  }) {
    // Clear saved address since raw coordinates don't have IDs
    selectedPickupAddress.value = null;

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
  /// Note: This clears the saved address - you must use setFromSavedAddress()
  /// for the booking API to work properly.
  void setDropLocation({
    required LatLng location,
    required String address,
    String? landmark,
  }) {
    // Clear saved address since raw coordinates don't have IDs
    selectedDropAddress.value = null;

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
  /// This stores the full AddressModel (with ID) for API calls.
  void setFromSavedAddress({
    required AddressModel address,
    required bool isPickup,
  }) {
    final latLng = LatLng(address.lat, address.lng);

    if (isPickup) {
      // Store the full address model for API calls
      selectedPickupAddress.value = address;
      // Also update display fields for UI
      pickupLocation.value = latLng;
      pickupAddress.value = address.fullAddress;
      pickupController.text = address.fullAddress;
      pickupLandmark.value = address.landmark ?? '';
    } else {
      // Store the full address model for API calls
      selectedDropAddress.value = address;
      // Also update display fields for UI
      dropLocation.value = latLng;
      dropAddress.value = address.fullAddress;
      dropController.text = address.fullAddress;
      dropLandmark.value = address.landmark ?? '';
    }

    // Reset price calculation when address changes
    _resetPriceCalculation();
  }

  /// Opens the map location picker and saves the selected location as an address.
  /// The saved address is then set as pickup or drop location.
  Future<void> openMapPicker({required bool isPickup}) async {
    final title = isPickup ? 'Select Pickup Location' : 'Select Drop Location';
    
    // Get initial location (current location or existing selection)
    LatLng? initialLocation;
    if (isPickup && pickupLocation.value != null) {
      initialLocation = pickupLocation.value;
    } else if (!isPickup && dropLocation.value != null) {
      initialLocation = dropLocation.value;
    }

    // Show the map picker
    final result = await MapLocationPicker.show(
      title: title,
      initialLocation: initialLocation,
    );

    if (result == null) return; // User cancelled

    // Show loading
    bookingState.value = BookingState.loadingVehicles;
    errorMessage.value = '';

    try {
      // Create a temporary address label
      final label = isPickup ? 'Pickup Location' : 'Drop Location';

      // Save the address via API
      final response = await _addressRepository.createAddress(
        label: label,
        address: result.address,
        landmark: result.landmark,
        city: result.city ?? '',
        state: result.state ?? '',
        pincode: result.pincode ?? '',
        lat: result.lat,
        lng: result.lng,
        isDefault: false,
      );

      if (response.success && response.data != null) {
        // Use the saved address for booking
        setFromSavedAddress(
          address: response.data!,
          isPickup: isPickup,
        );
      } else {
        _showError(response.message ?? 'Failed to save location');
      }
    } catch (e) {
      _showError('Failed to save location');
    } finally {
      bookingState.value = BookingState.idle;
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
  /// Uses saved address IDs for the API call.
  Future<void> calculatePrice() async {
    if (!canProceedToVehicle || selectedVehicle.value == null) {
      _showError('Please select pickup, drop addresses and vehicle type');
      return;
    }

    try {
      bookingState.value = BookingState.calculatingPrice;
      errorMessage.value = '';

      final response = await _bookingRepository.calculatePrice(
        vehicleTypeId: selectedVehicle.value!.id,
        pickupAddressId: selectedPickupAddress.value!.id,
        dropAddressId: selectedDropAddress.value!.id,
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

  /// Applies a coupon code by validating it with the backend API.
  /// Validates the coupon against order amount and vehicle type.
  Future<void> applyCoupon(String code) async {
    // Handle empty code - clear coupon
    if (code.isEmpty) {
      _clearCoupon();
      return;
    }

    // Validate prerequisites
    if (priceCalculation.value == null) {
      _showError('Please select a vehicle first to apply coupon');
      return;
    }

    if (selectedVehicle.value == null) {
      _showError('Please select a vehicle type');
      return;
    }

    try {
      isValidatingCoupon.value = true;
      errorMessage.value = '';

      final response = await _couponRepository.validateCoupon(
        code: code.trim().toUpperCase(),
        orderAmount: priceCalculation.value!.totalAmount,
        vehicleTypeId: selectedVehicle.value!.id,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        final coupon = data['coupon'] as CouponModel?;
        final discount = data['discount'] as double;

        if (coupon != null && discount > 0) {
          // Apply coupon successfully
          couponCode.value = code.trim().toUpperCase();
          appliedCoupon.value = coupon;
          couponDiscount.value = discount;

          _showSuccess(
            'Coupon applied! You save ₹${discount.toStringAsFixed(2)}',
          );

          // Update balance check after discount
          if (selectedPaymentMethod.value == PaymentMethod.wallet) {
            hasSufficientBalance.value = walletBalance.value >= finalAmount;
          }
        } else {
          _clearCoupon();
          _showError('Coupon is not applicable for this order');
        }
      } else {
        _clearCoupon();
        _showError(response.message ?? 'Invalid coupon code');
      }
    } on ApiException catch (e) {
      _clearCoupon();
      _showError(e.message);
    } on NetworkException {
      _clearCoupon();
      _showError('No internet connection');
    } catch (e) {
      _clearCoupon();
      _showError('Failed to validate coupon');
    } finally {
      isValidatingCoupon.value = false;
    }
  }

  /// Removes the currently applied coupon.
  void removeCoupon() {
    _clearCoupon();
    _showSuccess('Coupon removed');
  }

  /// Clears coupon state without showing any message.
  void _clearCoupon() {
    couponCode.value = '';
    appliedCoupon.value = null;
    couponDiscount.value = 0.0;

    // Update balance check after removing discount
    if (selectedPaymentMethod.value == PaymentMethod.wallet &&
        priceCalculation.value != null) {
      hasSufficientBalance.value = walletBalance.value >= finalAmount;
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

      // Create booking request using saved address IDs
      final request = CreateBookingRequest(
        vehicleTypeId: selectedVehicle.value!.id,
        pickupAddressId: selectedPickupAddress.value!.id,
        dropAddressId: selectedDropAddress.value!.id,
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
        // Navigate to finding driver screen
        Get.offNamed(Routes.findingDriver);
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
  /// Reason is required by the API.
  Future<void> cancelBooking({required String reason}) async {
    if (currentBooking.value == null) {
      _showError('No active booking to cancel');
      return;
    }

    if (reason.isEmpty) {
      _showError('Please provide a reason for cancellation');
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

  /// Retries the driver search for the current booking.
  /// Called when no drivers were found and user wants to try again.
  Future<void> retryDriverSearch() async {
    if (currentBooking.value == null) {
      _showError('No active booking to retry');
      return;
    }

    try {
      bookingState.value = BookingState.findingDriver;
      errorMessage.value = '';

      final response = await _bookingRepository.retryAssignment(
        currentBooking.value!.id,
      );

      if (response.success) {
        _showSuccess('Searching for drivers again...');
      } else {
        _showError(response.message ?? 'Failed to retry search');
      }
    } on ApiException catch (e) {
      _showError(e.message);
    } on NetworkException {
      _showError('No internet connection');
    } catch (e) {
      _showError('Something went wrong');
    }
  }

  /// Resets all booking state to initial values.
  void resetBooking() {
    // Reset saved addresses
    selectedPickupAddress.value = null;
    selectedDropAddress.value = null;

    // Reset location display fields
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
    appliedCoupon.value = null;
    couponDiscount.value = 0.0;
    isValidatingCoupon.value = false;

    // Reset booking
    currentBooking.value = null;
    bookingState.value = BookingState.idle;
    errorMessage.value = '';

    // Reset step tracking
    resetSteps();
  }

  // ============================================
  // Helper Methods
  // ============================================

  /// Resets the price calculation when locations change.
  /// Also clears any applied coupon since it may not be valid for new price.
  void _resetPriceCalculation() {
    priceCalculation.value = null;
    _clearCoupon();
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

  // ============================================
  // Step Navigation Methods (Unified Booking Flow)
  // ============================================

  /// Moves to a specific step if allowed.
  void goToStep(int step) {
    if (step < 0 || step > 2) return;

    // Can always go back to previous steps
    if (step < currentStep.value) {
      _collapseAllExcept(step);
      currentStep.value = step;
      return;
    }

    // Validate before moving forward
    if (step == 1 && !canProceedToStep1) return;
    if (step == 2 && !canProceedToStep2) return;

    _collapseAllExcept(step);
    currentStep.value = step;
  }

  /// Advances to the next step if validation passes.
  void nextStep() {
    if (currentStep.value == 0 && canProceedToStep1) {
      goToStep(1);
    } else if (currentStep.value == 1) {
      // Package step is optional, always allow proceeding
      goToStep(2);
      // Auto-select first vehicle if none selected and trigger price calculation
      if (selectedVehicle.value == null && vehicleTypes.isNotEmpty) {
        selectVehicle(vehicleTypes.first);
      }
    }
  }

  /// Goes back to the previous step.
  void previousStep() {
    if (currentStep.value > 0) {
      goToStep(currentStep.value - 1);
    }
  }

  /// Toggles expansion of a step.
  void toggleStepExpansion(int step) {
    // Only allow toggling completed or current steps
    if (step <= currentStep.value) {
      expandedSteps[step] = !expandedSteps[step];
    }
  }

  /// Collapses all steps except the specified one.
  void _collapseAllExcept(int step) {
    for (int i = 0; i < expandedSteps.length; i++) {
      expandedSteps[i] = (i == step);
    }
  }

  /// Returns true if user can proceed to step 1 (Package Details).
  bool get canProceedToStep1 =>
      selectedPickupAddress.value != null &&
      selectedDropAddress.value != null;

  /// Returns true if user can proceed to step 2 (Vehicle Selection).
  bool get canProceedToStep2 => canProceedToStep1;

  /// Returns true if booking can be created.
  bool get canCreateBooking => canProceedToPayment;

  /// Gets the appropriate button text based on current step.
  String getButtonText() {
    switch (currentStep.value) {
      case 0:
        return 'Continue';
      case 1:
        return 'Select Vehicle';
      case 2:
        if (priceCalculation.value != null) {
          return 'Book Now • ${priceCalculation.value!.totalDisplay}';
        }
        return 'Select a Vehicle';
      default:
        return 'Continue';
    }
  }

  /// Returns true if the bottom button should be enabled.
  bool get isButtonEnabled {
    switch (currentStep.value) {
      case 0:
        return canProceedToStep1;
      case 1:
        return true; // Package details are optional
      case 2:
        return canCreateBooking;
      default:
        return false;
    }
  }

  /// Handles the main action button press.
  void onActionButtonPressed() {
    if (currentStep.value < 2) {
      nextStep();
    } else if (canCreateBooking) {
      // Navigate to payment screen
      Get.toNamed(Routes.payment);
    }
  }

  /// Resets the step tracking state.
  void resetSteps() {
    currentStep.value = 0;
    expandedSteps.value = [true, false, false];
  }
}
