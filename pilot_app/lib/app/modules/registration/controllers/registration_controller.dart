import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/models/pilot_model.dart';
import '../../../data/models/vehicle_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../routes/app_routes.dart';
import '../../../services/storage_service.dart';

class RegistrationController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();
  final StorageService _storage = Get.find<StorageService>();
  final ImagePicker _imagePicker = ImagePicker();

  // Current step (0-3)
  final currentStep = 0.obs;

  // Loading state
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Step 1: Personal Details
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final pincodeController = TextEditingController();
  final Rx<DateTime?> dateOfBirth = Rx<DateTime?>(null);
  final Rx<File?> profilePhoto = Rx<File?>(null);

  // Step 2: Vehicle Details
  final selectedVehicleType = Rx<VehicleType?>(null);
  final selectedVehicleCategory = Rx<VehicleCategory?>(null);
  final vehicleNumberController = TextEditingController();
  final vehicleModelController = TextEditingController();

  // Step 3: Documents
  final Rx<File?> idProofFile = Rx<File?>(null);
  final Rx<File?> drivingLicenseFile = Rx<File?>(null);
  final Rx<File?> vehicleRcFile = Rx<File?>(null);
  final Rx<File?> insuranceFile = Rx<File?>(null);
  final Rx<File?> parentalConsentFile = Rx<File?>(null);

  // Step 4: Bank Details
  final accountHolderController = TextEditingController();
  final bankNameController = TextEditingController();
  final accountNumberController = TextEditingController();
  final confirmAccountNumberController = TextEditingController();
  final ifscController = TextEditingController();
  final Rx<File?> cancelledChequeFile = Rx<File?>(null);

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    addressController.dispose();
    cityController.dispose();
    stateController.dispose();
    pincodeController.dispose();
    vehicleNumberController.dispose();
    vehicleModelController.dispose();
    accountHolderController.dispose();
    bankNameController.dispose();
    accountNumberController.dispose();
    confirmAccountNumberController.dispose();
    ifscController.dispose();
    super.onClose();
  }

  /// Calculate age from date of birth
  int? get age {
    if (dateOfBirth.value == null) return null;
    final now = DateTime.now();
    int years = now.year - dateOfBirth.value!.year;
    if (now.month < dateOfBirth.value!.month ||
        (now.month == dateOfBirth.value!.month && now.day < dateOfBirth.value!.day)) {
      years--;
    }
    return years;
  }

  /// Check if pilot is minor (16-17)
  bool get isMinor => age != null && age! >= 16 && age! < 18;

  /// Check if motorized vehicle requires license
  bool get requiresLicense =>
      selectedVehicleType.value != null &&
      selectedVehicleType.value != VehicleType.cycle &&
      selectedVehicleType.value != VehicleType.evCycle;

  /// Get available vehicle categories for selected type
  List<VehicleCategory> get availableCategories {
    switch (selectedVehicleType.value) {
      case VehicleType.cycle:
        return [VehicleCategory.manual];
      case VehicleType.evCycle:
        return [VehicleCategory.ev];
      case VehicleType.twoWheeler:
        return [VehicleCategory.petrol, VehicleCategory.ev, VehicleCategory.cng];
      case VehicleType.threeWheeler:
        return [VehicleCategory.petrol, VehicleCategory.diesel, VehicleCategory.cng, VehicleCategory.ev];
      case VehicleType.truck:
        return [VehicleCategory.diesel, VehicleCategory.petrol, VehicleCategory.cng];
      default:
        return [];
    }
  }

  /// Go to next step
  void nextStep() {
    if (validateCurrentStep()) {
      if (currentStep.value < 3) {
        currentStep.value++;
      } else {
        submitRegistration();
      }
    }
  }

  /// Go to previous step
  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  /// Go to specific step
  void goToStep(int step) {
    if (step >= 0 && step <= 3 && step <= currentStep.value) {
      currentStep.value = step;
    }
  }

  /// Validate current step
  bool validateCurrentStep() {
    errorMessage.value = '';

    switch (currentStep.value) {
      case 0: // Personal Details
        if (nameController.text.trim().isEmpty) {
          errorMessage.value = 'Please enter your full name';
          return false;
        }
        if (emailController.text.trim().isEmpty || !GetUtils.isEmail(emailController.text.trim())) {
          errorMessage.value = 'Please enter a valid email address';
          return false;
        }
        if (dateOfBirth.value == null) {
          errorMessage.value = 'Please select your date of birth';
          return false;
        }
        if (age! < 16) {
          errorMessage.value = 'You must be at least 16 years old';
          return false;
        }
        if (addressController.text.trim().isEmpty) {
          errorMessage.value = 'Please enter your address';
          return false;
        }
        return true;

      case 1: // Vehicle Details
        if (selectedVehicleType.value == null) {
          errorMessage.value = 'Please select a vehicle type';
          return false;
        }
        if (selectedVehicleCategory.value == null) {
          errorMessage.value = 'Please select fuel type';
          return false;
        }
        if (vehicleNumberController.text.trim().isEmpty) {
          errorMessage.value = 'Please enter vehicle number';
          return false;
        }
        // Age restriction for motorized vehicles
        if (requiresLicense && age! < 18) {
          errorMessage.value = 'You must be 18+ for motorized vehicles';
          return false;
        }
        return true;

      case 2: // Documents
        if (idProofFile.value == null) {
          errorMessage.value = 'Please upload ID proof';
          return false;
        }
        if (requiresLicense && drivingLicenseFile.value == null) {
          errorMessage.value = 'Please upload driving license';
          return false;
        }
        if (requiresLicense && vehicleRcFile.value == null) {
          errorMessage.value = 'Please upload vehicle RC';
          return false;
        }
        if (isMinor && parentalConsentFile.value == null) {
          errorMessage.value = 'Please upload parental consent form';
          return false;
        }
        return true;

      case 3: // Bank Details
        if (accountHolderController.text.trim().isEmpty) {
          errorMessage.value = 'Please enter account holder name';
          return false;
        }
        if (accountNumberController.text.trim().isEmpty) {
          errorMessage.value = 'Please enter account number';
          return false;
        }
        if (accountNumberController.text != confirmAccountNumberController.text) {
          errorMessage.value = 'Account numbers do not match';
          return false;
        }
        if (ifscController.text.trim().isEmpty) {
          errorMessage.value = 'Please enter IFSC code';
          return false;
        }
        return true;

      default:
        return true;
    }
  }

  /// Pick image from gallery or camera
  Future<void> pickImage({
    required String type,
    ImageSource source = ImageSource.gallery,
  }) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        final file = File(image.path);
        switch (type) {
          case 'profile':
            profilePhoto.value = file;
            break;
          case 'id_proof':
            idProofFile.value = file;
            break;
          case 'driving_license':
            drivingLicenseFile.value = file;
            break;
          case 'vehicle_rc':
            vehicleRcFile.value = file;
            break;
          case 'insurance':
            insuranceFile.value = file;
            break;
          case 'parental_consent':
            parentalConsentFile.value = file;
            break;
          case 'cancelled_cheque':
            cancelledChequeFile.value = file;
            break;
        }
      }
    } catch (e) {
      errorMessage.value = 'Failed to pick image';
    }
  }

  /// Submit registration
  Future<void> submitRegistration() async {
    if (!validateCurrentStep()) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _authRepository.registerPilot(
        personalDetails: {
          'phone': _storage.phone,  // Include phone from storage
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'date_of_birth': dateOfBirth.value?.toIso8601String(),
          'age': age,
          'address': addressController.text.trim(),
          'city': cityController.text.trim(),
          'state': stateController.text.trim(),
          'pincode': pincodeController.text.trim(),
        },
        vehicleDetails: {
          'type': selectedVehicleType.value?.value,
          'category': selectedVehicleCategory.value?.value,
          'number': vehicleNumberController.text.trim(),
          'model': vehicleModelController.text.trim(),
        },
        documents: {
          // TODO: Upload files and get URLs
          'id_proof': idProofFile.value?.path,
          'driving_license': drivingLicenseFile.value?.path,
          'vehicle_rc': vehicleRcFile.value?.path,
          'insurance': insuranceFile.value?.path,
          'parental_consent': parentalConsentFile.value?.path,
        },
        bankDetails: {
          'account_holder': accountHolderController.text.trim(),
          'bank_name': bankNameController.text.trim(),
          'account_number': accountNumberController.text.trim(),
          'ifsc': ifscController.text.trim(),
        },
      );

      if (response['success'] == true) {
        Get.offAllNamed(Routes.verificationPending);
      } else {
        errorMessage.value = response['message'] ?? 'Registration failed';
      }
    } catch (e) {
      errorMessage.value = 'Registration failed. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Check verification status
  Future<void> checkVerificationStatus() async {
    try {
      isLoading.value = true;
      final response = await _authRepository.checkVerificationStatus();

      if (response['success'] == true) {
        final status = VerificationStatus.fromString(response['status'] as String);
        
        if (status == VerificationStatus.approved) {
          Get.offAllNamed(Routes.home);
        } else if (status == VerificationStatus.rejected) {
          errorMessage.value = 'Your application was rejected. Please contact support.';
        }
      }
    } catch (e) {
      // Silently fail, user can retry
    } finally {
      isLoading.value = false;
    }
  }
}
