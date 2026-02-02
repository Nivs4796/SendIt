import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/address_model.dart';
import '../../../data/repositories/address_repository.dart';
import '../../../data/providers/api_exceptions.dart';

class AddressController extends GetxController {
  final AddressRepository _addressRepository = AddressRepository();

  // Observable state
  final addresses = <AddressModel>[].obs;
  final isLoading = false.obs;
  final isSaving = false.obs;
  final errorMessage = ''.obs;

  // Form controllers
  late TextEditingController labelController;
  late TextEditingController addressController;
  late TextEditingController landmarkController;
  late TextEditingController cityController;
  late TextEditingController stateController;
  late TextEditingController pincodeController;

  // Form state
  final isDefault = false.obs;
  final Rx<AddressModel?> editingAddress = Rx<AddressModel?>(null);

  // Location coordinates (default: Ahmedabad)
  final lat = 23.0225.obs;
  final lng = 72.5714.obs;

  // Getters
  bool get isEditMode => editingAddress.value != null;

  AddressModel? get defaultAddress {
    try {
      return addresses.firstWhere((addr) => addr.isDefault);
    } catch (e) {
      return null;
    }
  }

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
    fetchAddresses();
  }

  @override
  void onClose() {
    _disposeControllers();
    super.onClose();
  }

  void _initializeControllers() {
    labelController = TextEditingController();
    addressController = TextEditingController();
    landmarkController = TextEditingController();
    cityController = TextEditingController();
    stateController = TextEditingController();
    pincodeController = TextEditingController();
  }

  void _disposeControllers() {
    labelController.dispose();
    addressController.dispose();
    landmarkController.dispose();
    cityController.dispose();
    stateController.dispose();
    pincodeController.dispose();
  }

  /// Fetch all addresses from the API
  Future<void> fetchAddresses() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _addressRepository.getAddresses();

      if (response.success && response.data != null) {
        addresses.value = response.data!;
      } else {
        errorMessage.value = response.message ?? 'Failed to fetch addresses';
      }
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } on NetworkException {
      errorMessage.value = 'No internet connection';
    } catch (e) {
      errorMessage.value = 'Something went wrong';
    } finally {
      isLoading.value = false;
    }
  }

  /// Clear all form fields and reset editing state
  void clearForm() {
    labelController.clear();
    addressController.clear();
    landmarkController.clear();
    cityController.clear();
    stateController.clear();
    pincodeController.clear();
    isDefault.value = false;
    editingAddress.value = null;
    lat.value = 23.0225;
    lng.value = 72.5714;
    errorMessage.value = '';
  }

  /// Populate form fields with address data for editing
  void populateFormForEdit(AddressModel address) {
    editingAddress.value = address;
    labelController.text = address.label;
    addressController.text = address.address;
    landmarkController.text = address.landmark ?? '';
    cityController.text = address.city;
    stateController.text = address.state;
    pincodeController.text = address.pincode;
    isDefault.value = address.isDefault;
    lat.value = address.lat;
    lng.value = address.lng;
  }

  /// Validate form fields
  /// Returns null if valid, otherwise returns error message
  String? validateForm() {
    final label = labelController.text.trim();
    final address = addressController.text.trim();
    final city = cityController.text.trim();
    final state = stateController.text.trim();
    final pincode = pincodeController.text.trim();

    if (label.isEmpty) {
      return 'Please enter a label (e.g., Home, Office)';
    }

    if (address.length < 5) {
      return 'Address must be at least 5 characters';
    }

    if (city.length < 2) {
      return 'City must be at least 2 characters';
    }

    if (state.length < 2) {
      return 'State must be at least 2 characters';
    }

    // Validate pincode: exactly 6 digits
    final pincodeRegex = RegExp(r'^\d{6}$');
    if (!pincodeRegex.hasMatch(pincode)) {
      return 'Pincode must be exactly 6 digits';
    }

    return null;
  }

  /// Save address (create or update based on edit mode)
  Future<void> saveAddress() async {
    final validationError = validateForm();
    if (validationError != null) {
      errorMessage.value = validationError;
      return;
    }

    try {
      isSaving.value = true;
      errorMessage.value = '';

      final label = labelController.text.trim();
      final address = addressController.text.trim();
      final landmark = landmarkController.text.trim();
      final city = cityController.text.trim();
      final state = stateController.text.trim();
      final pincode = pincodeController.text.trim();

      if (isEditMode) {
        // Update existing address
        final response = await _addressRepository.updateAddress(
          id: editingAddress.value!.id,
          label: label,
          address: address,
          landmark: landmark.isNotEmpty ? landmark : null,
          city: city,
          state: state,
          pincode: pincode,
          lat: lat.value,
          lng: lng.value,
          isDefault: isDefault.value,
        );

        if (response.success) {
          Get.snackbar(
            'Success',
            'Address updated successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          clearForm();
          await fetchAddresses();
          Get.back();
        } else {
          errorMessage.value = response.message ?? 'Failed to update address';
        }
      } else {
        // Create new address
        final response = await _addressRepository.createAddress(
          label: label,
          address: address,
          landmark: landmark.isNotEmpty ? landmark : null,
          city: city,
          state: state,
          pincode: pincode,
          lat: lat.value,
          lng: lng.value,
          isDefault: isDefault.value,
        );

        if (response.success) {
          Get.snackbar(
            'Success',
            'Address saved successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          clearForm();
          await fetchAddresses();
          Get.back();
        } else {
          errorMessage.value = response.message ?? 'Failed to save address';
        }
      }
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } on NetworkException {
      errorMessage.value = 'No internet connection';
    } catch (e) {
      errorMessage.value = 'Something went wrong';
    } finally {
      isSaving.value = false;
    }
  }

  /// Delete an address with confirmation dialog
  Future<void> deleteAddress(AddressModel address) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Address'),
        content: Text(
          'Are you sure you want to delete "${address.label}"?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _addressRepository.deleteAddress(address.id);

      if (response.success) {
        addresses.removeWhere((addr) => addr.id == address.id);

        Get.snackbar(
          'Success',
          'Address deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        errorMessage.value = response.message ?? 'Failed to delete address';
      }
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } on NetworkException {
      errorMessage.value = 'No internet connection';
    } catch (e) {
      errorMessage.value = 'Something went wrong';
    } finally {
      isLoading.value = false;
    }
  }

  /// Set an address as the default
  Future<void> setAsDefault(AddressModel address) async {
    if (address.isDefault) return; // Already default

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _addressRepository.updateAddress(
        id: address.id,
        isDefault: true,
      );

      if (response.success) {
        await fetchAddresses();

        Get.snackbar(
          'Success',
          '"${address.label}" set as default address',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        errorMessage.value = response.message ?? 'Failed to set default address';
      }
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } on NetworkException {
      errorMessage.value = 'No internet connection';
    } catch (e) {
      errorMessage.value = 'Something went wrong';
    } finally {
      isLoading.value = false;
    }
  }

  /// Update location coordinates
  void updateLocation(double latitude, double longitude) {
    lat.value = latitude;
    lng.value = longitude;
  }

  /// Clear error message
  void clearError() {
    errorMessage.value = '';
  }
}
