# Profile & Wallet Feature Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Implement complete Profile management (view/edit profile, saved addresses CRUD, settings, logout, delete account) and Wallet features (balance, add money, transaction history) for the SendIt user app.

**Architecture:** GetX-based module structure with separate controllers for Profile, Address, and Wallet. Repositories handle API communication. Views follow existing design system with AppColors, AppTextStyles, and common widgets.

**Tech Stack:** Flutter 3.x, GetX (state management + routing), Dio (HTTP client), existing common widgets library

---

## Pre-Implementation Checklist

- [x] Backend APIs verified and ready
- [x] AddressModel exists at `lib/app/data/models/address_model.dart`
- [x] WalletTransactionModel exists at `lib/app/data/models/wallet_model.dart`
- [x] API constants defined at `lib/app/core/constants/api_constants.dart`
- [x] Routes defined at `lib/app/routes/app_routes.dart`

---

## Task 1: Create Address Repository

**Files:**
- Create: `lib/app/data/repositories/address_repository.dart`

**Step 1: Create the repository file**

```dart
import 'package:get/get.dart';
import '../models/address_model.dart';
import '../models/api_response.dart';
import '../providers/api_client.dart';
import '../../core/constants/api_constants.dart';

class AddressRepository {
  final ApiClient _apiClient = ApiClient();

  /// Get all saved addresses for current user
  Future<ApiResponse<List<AddressModel>>> getAddresses() async {
    try {
      final response = await _apiClient.get(ApiConstants.addresses);
      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        final addressesJson = apiResponse.data!['addresses'] as List? ?? [];
        final addresses = addressesJson
            .map((json) => AddressModel.fromJson(json))
            .toList();
        return ApiResponse(
          success: true,
          message: apiResponse.message,
          data: addresses,
        );
      }

      return ApiResponse(
        success: false,
        message: apiResponse.message ?? 'Failed to get addresses',
        data: [],
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: e.toString(),
        data: [],
      );
    }
  }

  /// Get single address by ID
  Future<ApiResponse<AddressModel?>> getAddress(String id) async {
    try {
      final response = await _apiClient.get('${ApiConstants.addresses}/$id');
      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        final addressData = apiResponse.data!['address'];
        return ApiResponse(
          success: true,
          message: apiResponse.message,
          data: AddressModel.fromJson(addressData),
        );
      }

      return ApiResponse(
        success: false,
        message: apiResponse.message ?? 'Address not found',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: e.toString(),
      );
    }
  }

  /// Create new address
  Future<ApiResponse<AddressModel?>> createAddress({
    required String label,
    required String address,
    String? landmark,
    required String city,
    required String state,
    required String pincode,
    required double lat,
    required double lng,
    bool isDefault = false,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.addresses,
        data: {
          'label': label,
          'address': address,
          'landmark': landmark,
          'city': city,
          'state': state,
          'pincode': pincode,
          'lat': lat,
          'lng': lng,
          'isDefault': isDefault,
        },
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        final addressData = apiResponse.data!['address'];
        return ApiResponse(
          success: true,
          message: apiResponse.message,
          data: AddressModel.fromJson(addressData),
        );
      }

      return ApiResponse(
        success: false,
        message: apiResponse.message ?? 'Failed to create address',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: e.toString(),
      );
    }
  }

  /// Update existing address
  Future<ApiResponse<AddressModel?>> updateAddress({
    required String id,
    String? label,
    String? address,
    String? landmark,
    String? city,
    String? state,
    String? pincode,
    double? lat,
    double? lng,
    bool? isDefault,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (label != null) data['label'] = label;
      if (address != null) data['address'] = address;
      if (landmark != null) data['landmark'] = landmark;
      if (city != null) data['city'] = city;
      if (state != null) data['state'] = state;
      if (pincode != null) data['pincode'] = pincode;
      if (lat != null) data['lat'] = lat;
      if (lng != null) data['lng'] = lng;
      if (isDefault != null) data['isDefault'] = isDefault;

      final response = await _apiClient.patch(
        '${ApiConstants.addresses}/$id',
        data: data,
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        final addressData = apiResponse.data!['address'];
        return ApiResponse(
          success: true,
          message: apiResponse.message,
          data: AddressModel.fromJson(addressData),
        );
      }

      return ApiResponse(
        success: false,
        message: apiResponse.message ?? 'Failed to update address',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: e.toString(),
      );
    }
  }

  /// Delete address
  Future<ApiResponse> deleteAddress(String id) async {
    try {
      final response = await _apiClient.delete('${ApiConstants.addresses}/$id');
      return ApiResponse.fromJson(response.data, null);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: e.toString(),
      );
    }
  }
}
```

**Step 2: Verify file created correctly**

Run: `cat lib/app/data/repositories/address_repository.dart | head -20`

**Step 3: Commit**

```bash
git add lib/app/data/repositories/address_repository.dart
git commit -m "feat(profile): add AddressRepository for saved addresses CRUD"
```

---

## Task 2: Create Wallet Repository

**Files:**
- Create: `lib/app/data/repositories/wallet_repository.dart`

**Step 1: Create the repository file**

```dart
import '../models/wallet_model.dart';
import '../models/api_response.dart';
import '../providers/api_client.dart';
import '../../core/constants/api_constants.dart';

class WalletRepository {
  final ApiClient _apiClient = ApiClient();

  /// Get current wallet balance
  Future<ApiResponse<double>> getBalance() async {
    try {
      final response = await _apiClient.get(ApiConstants.walletBalance);
      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        final balance = (apiResponse.data!['balance'] ?? 0).toDouble();
        return ApiResponse(
          success: true,
          message: apiResponse.message,
          data: balance,
        );
      }

      return ApiResponse(
        success: false,
        message: apiResponse.message ?? 'Failed to get balance',
        data: 0.0,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: e.toString(),
        data: 0.0,
      );
    }
  }

  /// Add money to wallet
  Future<ApiResponse<Map<String, dynamic>>> addMoney(double amount) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.addMoney,
        data: {'amount': amount},
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        return ApiResponse(
          success: true,
          message: apiResponse.message,
          data: {
            'balance': (apiResponse.data!['balance'] ?? 0).toDouble(),
            'transaction': apiResponse.data!['transaction'],
          },
        );
      }

      return ApiResponse(
        success: false,
        message: apiResponse.message ?? 'Failed to add money',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: e.toString(),
      );
    }
  }

  /// Check if wallet has sufficient balance
  Future<ApiResponse<Map<String, dynamic>>> checkBalance(double amount) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.walletBalance}/check',
        data: {'amount': amount},
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        return ApiResponse(
          success: true,
          message: apiResponse.message,
          data: {
            'hasSufficientBalance': apiResponse.data!['hasSufficientBalance'] ?? false,
            'currentBalance': (apiResponse.data!['currentBalance'] ?? 0).toDouble(),
            'requiredAmount': (apiResponse.data!['requiredAmount'] ?? 0).toDouble(),
            'shortfall': (apiResponse.data!['shortfall'] ?? 0).toDouble(),
          },
        );
      }

      return ApiResponse(
        success: false,
        message: apiResponse.message ?? 'Failed to check balance',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: e.toString(),
      );
    }
  }

  /// Get transaction history with pagination
  Future<ApiResponse<Map<String, dynamic>>> getTransactions({
    int page = 1,
    int limit = 10,
    String? type, // 'CREDIT' | 'DEBIT' | null for all
  }) async {
    try {
      String url = '${ApiConstants.walletTransactions}?page=$page&limit=$limit';
      if (type != null) {
        url += '&type=$type';
      }

      final response = await _apiClient.get(url);
      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        final transactionsJson = apiResponse.data!['transactions'] as List? ?? [];
        final transactions = transactionsJson
            .map((json) => WalletTransactionModel.fromJson(json))
            .toList();

        return ApiResponse(
          success: true,
          message: apiResponse.message,
          data: {
            'transactions': transactions,
            'summary': apiResponse.data!['summary'],
          },
          meta: apiResponse.meta,
        );
      }

      return ApiResponse(
        success: false,
        message: apiResponse.message ?? 'Failed to get transactions',
        data: {'transactions': <WalletTransactionModel>[], 'summary': null},
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: e.toString(),
        data: {'transactions': <WalletTransactionModel>[], 'summary': null},
      );
    }
  }
}
```

**Step 2: Commit**

```bash
git add lib/app/data/repositories/wallet_repository.dart
git commit -m "feat(wallet): add WalletRepository for balance and transactions"
```

---

## Task 3: Create Profile Controller

**Files:**
- Create: `lib/app/modules/profile/controllers/profile_controller.dart`

**Step 1: Create the controller file**

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/upload_repository.dart';
import '../../../routes/app_routes.dart';
import '../../../services/storage_service.dart';

class ProfileController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();
  final UploadRepository _uploadRepository = UploadRepository();
  final StorageService _storage = Get.find<StorageService>();
  final ImagePicker _picker = ImagePicker();

  // State
  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final isLoading = false.obs;
  final isUpdating = false.obs;
  final errorMessage = ''.obs;

  // Edit profile form
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final Rx<File?> selectedAvatarFile = Rx<File?>(null);

  @override
  void onInit() {
    super.onInit();
    loadUserFromStorage();
    fetchProfile();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    super.onClose();
  }

  void loadUserFromStorage() {
    final userData = _storage.user;
    if (userData != null) {
      user.value = UserModel.fromJson(userData);
      _populateFormFields();
    }
  }

  void _populateFormFields() {
    if (user.value != null) {
      nameController.text = user.value!.name ?? '';
      emailController.text = user.value!.email ?? '';
    }
  }

  Future<void> fetchProfile() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _authRepository.getProfile();
      if (response.success && response.data != null) {
        user.value = response.data;
        _storage.user = response.data!.toJson();
        _populateFormFields();
      } else {
        errorMessage.value = response.message ?? 'Failed to load profile';
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickAvatar() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (image != null) {
        selectedAvatarFile.value = File(image.path);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e');
    }
  }

  Future<void> takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (image != null) {
        selectedAvatarFile.value = File(image.path);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to take photo: $e');
    }
  }

  void showAvatarPicker() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Change Profile Photo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Get.back();
                takePhoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Get.back();
                pickAvatar();
              },
            ),
            if (user.value?.avatar != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Get.back();
                  selectedAvatarFile.value = null;
                  // TODO: API to remove avatar
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> updateProfile() async {
    if (nameController.text.trim().length < 2) {
      Get.snackbar('Error', 'Name must be at least 2 characters');
      return;
    }

    isUpdating.value = true;
    errorMessage.value = '';

    try {
      String? avatarUrl;

      // Upload new avatar if selected
      if (selectedAvatarFile.value != null) {
        final uploadResponse = await _uploadRepository.uploadAvatar(selectedAvatarFile.value!);
        if (uploadResponse.success && uploadResponse.data != null) {
          avatarUrl = uploadResponse.data;
        } else {
          Get.snackbar('Error', uploadResponse.message ?? 'Failed to upload avatar');
          isUpdating.value = false;
          return;
        }
      }

      // Update profile
      final response = await _authRepository.updateProfile(
        name: nameController.text.trim(),
        email: emailController.text.trim().isNotEmpty ? emailController.text.trim() : null,
        avatar: avatarUrl,
      );

      if (response.success && response.data != null) {
        user.value = response.data;
        _storage.user = response.data!.toJson();
        selectedAvatarFile.value = null;
        Get.snackbar('Success', 'Profile updated successfully');
        Get.back();
      } else {
        errorMessage.value = response.message ?? 'Failed to update profile';
        Get.snackbar('Error', errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> deleteAccount() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
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

    isLoading.value = true;
    try {
      final response = await _authRepository.deleteAccount();
      if (response.success) {
        _storage.clearAuth();
        Get.offAllNamed(Routes.login);
        Get.snackbar('Account Deleted', 'Your account has been deleted');
      } else {
        Get.snackbar('Error', response.message ?? 'Failed to delete account');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void logout() {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _storage.clearAuth();
              Get.offAllNamed(Routes.login);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  // Helper getters
  String get userName => user.value?.name ?? 'User';
  String get userPhone => user.value?.phone ?? '';
  String get userEmail => user.value?.email ?? '';
  String? get userAvatar => user.value?.avatar;
}
```

**Step 2: Add deleteAccount method to AuthRepository**

Modify: `lib/app/data/repositories/auth_repository.dart` - Add at the end before closing brace:

```dart
  Future<ApiResponse> deleteAccount() async {
    try {
      final response = await _apiClient.delete(ApiConstants.deleteAccount);
      return ApiResponse.fromJson(response.data, null);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }
```

**Step 3: Commit**

```bash
git add lib/app/modules/profile/controllers/profile_controller.dart
git add lib/app/data/repositories/auth_repository.dart
git commit -m "feat(profile): add ProfileController with edit, logout, delete account"
```

---

## Task 4: Create Address Controller

**Files:**
- Create: `lib/app/modules/profile/controllers/address_controller.dart`

**Step 1: Create the controller file**

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/address_model.dart';
import '../../../data/repositories/address_repository.dart';

class AddressController extends GetxController {
  final AddressRepository _addressRepository = AddressRepository();

  // State
  final addresses = <AddressModel>[].obs;
  final isLoading = false.obs;
  final isSaving = false.obs;
  final errorMessage = ''.obs;

  // Form controllers
  final labelController = TextEditingController();
  final addressController = TextEditingController();
  final landmarkController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final pincodeController = TextEditingController();
  final isDefault = false.obs;

  // Edit mode
  final Rx<AddressModel?> editingAddress = Rx<AddressModel?>(null);
  bool get isEditMode => editingAddress.value != null;

  // Location (for map picker - default to Ahmedabad)
  final lat = 23.0225.obs;
  final lng = 72.5714.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAddresses();
  }

  @override
  void onClose() {
    labelController.dispose();
    addressController.dispose();
    landmarkController.dispose();
    cityController.dispose();
    stateController.dispose();
    pincodeController.dispose();
    super.onClose();
  }

  Future<void> fetchAddresses() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _addressRepository.getAddresses();
      if (response.success && response.data != null) {
        addresses.value = response.data!;
      } else {
        errorMessage.value = response.message ?? 'Failed to load addresses';
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void clearForm() {
    labelController.clear();
    addressController.clear();
    landmarkController.clear();
    cityController.clear();
    stateController.clear();
    pincodeController.clear();
    isDefault.value = false;
    lat.value = 23.0225;
    lng.value = 72.5714;
    editingAddress.value = null;
  }

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

  bool validateForm() {
    if (labelController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter a label (e.g., Home, Office)');
      return false;
    }
    if (addressController.text.trim().length < 5) {
      Get.snackbar('Error', 'Please enter a valid address');
      return false;
    }
    if (cityController.text.trim().length < 2) {
      Get.snackbar('Error', 'Please enter city name');
      return false;
    }
    if (stateController.text.trim().length < 2) {
      Get.snackbar('Error', 'Please enter state name');
      return false;
    }
    if (!RegExp(r'^\d{6}$').hasMatch(pincodeController.text.trim())) {
      Get.snackbar('Error', 'Please enter valid 6-digit pincode');
      return false;
    }
    return true;
  }

  Future<void> saveAddress() async {
    if (!validateForm()) return;

    isSaving.value = true;
    errorMessage.value = '';

    try {
      if (isEditMode) {
        // Update existing address
        final response = await _addressRepository.updateAddress(
          id: editingAddress.value!.id,
          label: labelController.text.trim(),
          address: addressController.text.trim(),
          landmark: landmarkController.text.trim().isNotEmpty
              ? landmarkController.text.trim()
              : null,
          city: cityController.text.trim(),
          state: stateController.text.trim(),
          pincode: pincodeController.text.trim(),
          lat: lat.value,
          lng: lng.value,
          isDefault: isDefault.value,
        );

        if (response.success && response.data != null) {
          // Update in list
          final index = addresses.indexWhere((a) => a.id == editingAddress.value!.id);
          if (index != -1) {
            addresses[index] = response.data!;
            // If set as default, unset others
            if (response.data!.isDefault) {
              for (var i = 0; i < addresses.length; i++) {
                if (i != index && addresses[i].isDefault) {
                  addresses[i] = AddressModel(
                    id: addresses[i].id,
                    userId: addresses[i].userId,
                    label: addresses[i].label,
                    address: addresses[i].address,
                    landmark: addresses[i].landmark,
                    city: addresses[i].city,
                    state: addresses[i].state,
                    pincode: addresses[i].pincode,
                    lat: addresses[i].lat,
                    lng: addresses[i].lng,
                    isDefault: false,
                    createdAt: addresses[i].createdAt,
                    updatedAt: addresses[i].updatedAt,
                  );
                }
              }
            }
          }
          Get.snackbar('Success', 'Address updated');
          Get.back();
          clearForm();
        } else {
          Get.snackbar('Error', response.message ?? 'Failed to update address');
        }
      } else {
        // Create new address
        final response = await _addressRepository.createAddress(
          label: labelController.text.trim(),
          address: addressController.text.trim(),
          landmark: landmarkController.text.trim().isNotEmpty
              ? landmarkController.text.trim()
              : null,
          city: cityController.text.trim(),
          state: stateController.text.trim(),
          pincode: pincodeController.text.trim(),
          lat: lat.value,
          lng: lng.value,
          isDefault: isDefault.value,
        );

        if (response.success && response.data != null) {
          // If new address is default, unset others
          if (response.data!.isDefault) {
            for (var i = 0; i < addresses.length; i++) {
              if (addresses[i].isDefault) {
                addresses[i] = AddressModel(
                  id: addresses[i].id,
                  userId: addresses[i].userId,
                  label: addresses[i].label,
                  address: addresses[i].address,
                  landmark: addresses[i].landmark,
                  city: addresses[i].city,
                  state: addresses[i].state,
                  pincode: addresses[i].pincode,
                  lat: addresses[i].lat,
                  lng: addresses[i].lng,
                  isDefault: false,
                  createdAt: addresses[i].createdAt,
                  updatedAt: addresses[i].updatedAt,
                );
              }
            }
          }
          addresses.insert(0, response.data!);
          Get.snackbar('Success', 'Address saved');
          Get.back();
          clearForm();
        } else {
          Get.snackbar('Error', response.message ?? 'Failed to save address');
        }
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteAddress(AddressModel address) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Address'),
        content: Text('Delete "${address.label}"?'),
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
      final response = await _addressRepository.deleteAddress(address.id);
      if (response.success) {
        addresses.removeWhere((a) => a.id == address.id);
        Get.snackbar('Success', 'Address deleted');
      } else {
        Get.snackbar('Error', response.message ?? 'Failed to delete address');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> setAsDefault(AddressModel address) async {
    if (address.isDefault) return;

    try {
      final response = await _addressRepository.updateAddress(
        id: address.id,
        isDefault: true,
      );

      if (response.success) {
        await fetchAddresses(); // Refresh to get updated default states
        Get.snackbar('Success', '${address.label} set as default');
      } else {
        Get.snackbar('Error', response.message ?? 'Failed to set default');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  // Helper getters
  AddressModel? get defaultAddress {
    try {
      return addresses.firstWhere((a) => a.isDefault);
    } catch (_) {
      return addresses.isNotEmpty ? addresses.first : null;
    }
  }
}
```

**Step 2: Commit**

```bash
git add lib/app/modules/profile/controllers/address_controller.dart
git commit -m "feat(profile): add AddressController for saved addresses management"
```

---

## Task 5: Create Wallet Controller

**Files:**
- Create: `lib/app/modules/wallet/controllers/wallet_controller.dart`

**Step 1: Create the controller file**

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/wallet_model.dart';
import '../../../data/repositories/wallet_repository.dart';

class WalletController extends GetxController {
  final WalletRepository _walletRepository = WalletRepository();

  // State
  final balance = 0.0.obs;
  final transactions = <WalletTransactionModel>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final isAddingMoney = false.obs;
  final errorMessage = ''.obs;

  // Pagination
  final currentPage = 1.obs;
  final hasMorePages = true.obs;
  final totalCredits = 0.0.obs;
  final totalDebits = 0.0.obs;

  // Filter
  final selectedFilter = Rx<String?>(null); // null = all, 'CREDIT', 'DEBIT'

  // Add money form
  final amountController = TextEditingController();
  final predefinedAmounts = [100, 200, 500, 1000, 2000, 5000];

  @override
  void onInit() {
    super.onInit();
    fetchBalance();
    fetchTransactions();
  }

  @override
  void onClose() {
    amountController.dispose();
    super.onClose();
  }

  Future<void> fetchBalance() async {
    try {
      final response = await _walletRepository.getBalance();
      if (response.success && response.data != null) {
        balance.value = response.data!;
      }
    } catch (e) {
      // Silent fail for balance - will show 0
    }
  }

  Future<void> fetchTransactions({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      hasMorePages.value = true;
      transactions.clear();
    }

    if (!hasMorePages.value && !refresh) return;

    isLoading.value = transactions.isEmpty;
    isLoadingMore.value = transactions.isNotEmpty;
    errorMessage.value = '';

    try {
      final response = await _walletRepository.getTransactions(
        page: currentPage.value,
        limit: 10,
        type: selectedFilter.value,
      );

      if (response.success && response.data != null) {
        final newTransactions = response.data!['transactions'] as List<WalletTransactionModel>;
        final summary = response.data!['summary'] as Map<String, dynamic>?;

        if (refresh || currentPage.value == 1) {
          transactions.value = newTransactions;
        } else {
          transactions.addAll(newTransactions);
        }

        if (summary != null) {
          totalCredits.value = (summary['totalCredits'] ?? 0).toDouble();
          totalDebits.value = (summary['totalDebits'] ?? 0).toDouble();
        }

        // Check pagination
        if (response.meta != null) {
          hasMorePages.value = currentPage.value < (response.meta!['totalPages'] ?? 1);
        } else {
          hasMorePages.value = newTransactions.length >= 10;
        }

        currentPage.value++;
      } else {
        errorMessage.value = response.message ?? 'Failed to load transactions';
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  void setFilter(String? filter) {
    if (selectedFilter.value != filter) {
      selectedFilter.value = filter;
      fetchTransactions(refresh: true);
    }
  }

  void selectPredefinedAmount(int amount) {
    amountController.text = amount.toString();
  }

  Future<void> addMoney() async {
    final amountText = amountController.text.trim();
    if (amountText.isEmpty) {
      Get.snackbar('Error', 'Please enter amount');
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount < 1) {
      Get.snackbar('Error', 'Please enter valid amount (minimum ₹1)');
      return;
    }
    if (amount > 100000) {
      Get.snackbar('Error', 'Maximum amount is ₹1,00,000');
      return;
    }

    isAddingMoney.value = true;

    try {
      final response = await _walletRepository.addMoney(amount);

      if (response.success && response.data != null) {
        balance.value = response.data!['balance'] as double;
        amountController.clear();
        Get.back(); // Close add money sheet
        Get.snackbar('Success', '₹${amount.toStringAsFixed(0)} added to wallet');
        fetchTransactions(refresh: true);
      } else {
        Get.snackbar('Error', response.message ?? 'Failed to add money');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isAddingMoney.value = false;
    }
  }

  Future<void> refreshAll() async {
    await Future.wait([
      fetchBalance(),
      fetchTransactions(refresh: true),
    ]);
  }

  // Helper getters
  String get balanceDisplay => '₹${balance.value.toStringAsFixed(2)}';
  String get totalCreditsDisplay => '₹${totalCredits.value.toStringAsFixed(2)}';
  String get totalDebitsDisplay => '₹${totalDebits.value.toStringAsFixed(2)}';
}
```

**Step 2: Commit**

```bash
git add lib/app/modules/wallet/controllers/wallet_controller.dart
git commit -m "feat(wallet): add WalletController for balance and transactions"
```

---

## Task 6: Create Profile Binding

**Files:**
- Create: `lib/app/modules/profile/bindings/profile_binding.dart`

**Step 1: Create the binding file**

```dart
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../controllers/address_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(() => ProfileController());
    Get.lazyPut<AddressController>(() => AddressController());
  }
}
```

**Step 2: Commit**

```bash
git add lib/app/modules/profile/bindings/profile_binding.dart
git commit -m "feat(profile): add ProfileBinding for dependency injection"
```

---

## Task 7: Create Wallet Binding

**Files:**
- Create: `lib/app/modules/wallet/bindings/wallet_binding.dart`

**Step 1: Create the binding file**

```dart
import 'package:get/get.dart';
import '../controllers/wallet_controller.dart';

class WalletBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WalletController>(() => WalletController());
  }
}
```

**Step 2: Commit**

```bash
git add lib/app/modules/wallet/bindings/wallet_binding.dart
git commit -m "feat(wallet): add WalletBinding for dependency injection"
```

---

## Task 8: Create Profile View (Main Hub)

**Files:**
- Create: `lib/app/modules/profile/views/profile_view.dart`

**Step 1: Create the profile view**

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/api_constants.dart';
import '../../../routes/app_routes.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.user.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.fetchProfile,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // Profile Header
                _buildProfileHeader(),
                const SizedBox(height: 16),

                // Menu Sections
                _buildMenuSection(
                  'Account',
                  [
                    _MenuItem(
                      icon: Icons.person_outline,
                      title: 'Personal Information',
                      onTap: () => Get.toNamed(Routes.personalInfo),
                    ),
                    _MenuItem(
                      icon: Icons.location_on_outlined,
                      title: 'Saved Addresses',
                      onTap: () => Get.toNamed(Routes.savedAddresses),
                    ),
                    _MenuItem(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'Wallet',
                      onTap: () => Get.toNamed(Routes.wallet),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _buildMenuSection(
                  'Support',
                  [
                    _MenuItem(
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      onTap: () {
                        // TODO: Navigate to help
                        Get.snackbar('Coming Soon', 'Help & Support');
                      },
                    ),
                    _MenuItem(
                      icon: Icons.description_outlined,
                      title: 'Terms & Conditions',
                      onTap: () {
                        // TODO: Navigate to terms
                        Get.snackbar('Coming Soon', 'Terms & Conditions');
                      },
                    ),
                    _MenuItem(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      onTap: () {
                        // TODO: Navigate to privacy
                        Get.snackbar('Coming Soon', 'Privacy Policy');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _buildMenuSection(
                  'Actions',
                  [
                    _MenuItem(
                      icon: Icons.logout,
                      title: 'Logout',
                      iconColor: AppColors.warning,
                      onTap: controller.logout,
                    ),
                    _MenuItem(
                      icon: Icons.delete_forever_outlined,
                      title: 'Delete Account',
                      iconColor: AppColors.error,
                      textColor: AppColors.error,
                      onTap: controller.deleteAccount,
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // App Version
                Text(
                  'Version 1.0.0',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      color: AppColors.white,
      child: Row(
        children: [
          // Avatar
          Obx(() {
            final avatar = controller.userAvatar;
            return GestureDetector(
              onTap: () => Get.toNamed(Routes.personalInfo),
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryContainer,
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 2,
                  ),
                  image: avatar != null
                      ? DecorationImage(
                          image: NetworkImage(
                            avatar.startsWith('http')
                                ? avatar
                                : '${ApiConstants.baseUrl.replaceAll('/api/v1', '')}$avatar',
                          ),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: avatar == null
                    ? const Icon(
                        Icons.person,
                        size: 36,
                        color: AppColors.primary,
                      )
                    : null,
              ),
            );
          }),
          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => Text(
                      controller.userName,
                      style: AppTextStyles.h4,
                    )),
                const SizedBox(height: 4),
                Obx(() => Text(
                      controller.userPhone,
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    )),
                if (controller.userEmail.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Obx(() => Text(
                        controller.userEmail,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      )),
                ],
              ],
            ),
          ),

          // Edit button
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            color: AppColors.primary,
            onPressed: () => Get.toNamed(Routes.personalInfo),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(String title, List<_MenuItem> items) {
    return Container(
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ...items.map((item) => _buildMenuItem(item)),
        ],
      ),
    );
  }

  Widget _buildMenuItem(_MenuItem item) {
    return ListTile(
      leading: Icon(
        item.icon,
        color: item.iconColor ?? AppColors.textSecondary,
      ),
      title: Text(
        item.title,
        style: AppTextStyles.body1.copyWith(
          color: item.textColor ?? AppColors.textPrimary,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: item.iconColor ?? AppColors.textTertiary,
      ),
      onTap: item.onTap,
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
    this.textColor,
  });
}
```

**Step 2: Commit**

```bash
git add lib/app/modules/profile/views/profile_view.dart
git commit -m "feat(profile): add ProfileView main hub with menu items"
```

---

## Task 9: Create Edit Profile View

**Files:**
- Create: `lib/app/modules/profile/views/edit_profile_view.dart`

**Step 1: Create the edit profile view**

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/widgets/widgets.dart';
import '../controllers/profile_controller.dart';

class EditProfileView extends GetView<ProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Personal Information'),
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar
            Center(
              child: GestureDetector(
                onTap: controller.showAvatarPicker,
                child: Obx(() {
                  final selectedFile = controller.selectedAvatarFile.value;
                  final existingAvatar = controller.userAvatar;

                  return Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryContainer,
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                            width: 3,
                          ),
                          image: selectedFile != null
                              ? DecorationImage(
                                  image: FileImage(selectedFile),
                                  fit: BoxFit.cover,
                                )
                              : existingAvatar != null
                                  ? DecorationImage(
                                      image: NetworkImage(
                                        existingAvatar.startsWith('http')
                                            ? existingAvatar
                                            : '${ApiConstants.baseUrl.replaceAll('/api/v1', '')}$existingAvatar',
                                      ),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                        ),
                        child: selectedFile == null && existingAvatar == null
                            ? const Icon(
                                Icons.person,
                                size: 50,
                                color: AppColors.primary,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.white,
                              width: 3,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 18,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap to change photo',
              style: TextStyle(
                color: AppColors.textTertiary,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 32),

            // Phone (read-only)
            Obx(() => AppTextField(
                  label: 'Phone Number',
                  initialValue: controller.userPhone,
                  enabled: false,
                  prefixIcon: const Icon(Icons.phone_outlined),
                )),

            const SizedBox(height: 16),

            // Name
            AppTextField.name(
              controller: controller.nameController,
              label: 'Full Name',
              hint: 'Enter your name',
              prefixIcon: const Icon(Icons.person_outline),
            ),

            const SizedBox(height: 16),

            // Email
            AppTextField.email(
              controller: controller.emailController,
              label: 'Email (Optional)',
              hint: 'Enter your email',
              prefixIcon: const Icon(Icons.email_outlined),
            ),

            const SizedBox(height: 40),

            // Save Button
            Obx(() => AppButton.primary(
                  text: 'Save Changes',
                  isLoading: controller.isUpdating.value,
                  onPressed: controller.updateProfile,
                )),
          ],
        ),
      ),
    );
  }
}
```

**Step 2: Commit**

```bash
git add lib/app/modules/profile/views/edit_profile_view.dart
git commit -m "feat(profile): add EditProfileView for personal information"
```

---

## Task 10: Create Addresses List View

**Files:**
- Create: `lib/app/modules/profile/views/addresses_view.dart`

**Step 1: Create the addresses view**

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/address_model.dart';
import '../controllers/address_controller.dart';

class AddressesView extends GetView<AddressController> {
  const AddressesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Saved Addresses'),
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          controller.clearForm();
          _showAddressForm(context);
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: AppColors.white),
        label: const Text('Add Address', style: TextStyle(color: AppColors.white)),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.addresses.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.addresses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_off_outlined,
                  size: 80,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(height: 16),
                Text(
                  'No saved addresses',
                  style: AppTextStyles.h4.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add addresses for quick booking',
                  style: AppTextStyles.body2.copyWith(color: AppColors.textTertiary),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchAddresses,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.addresses.length,
            itemBuilder: (context, index) {
              final address = controller.addresses[index];
              return _AddressCard(
                address: address,
                onEdit: () {
                  controller.populateFormForEdit(address);
                  _showAddressForm(context);
                },
                onDelete: () => controller.deleteAddress(address),
                onSetDefault: () => controller.setAsDefault(address),
              );
            },
          ),
        );
      }),
    );
  }

  void _showAddressForm(BuildContext context) {
    Get.bottomSheet(
      _AddressFormSheet(controller: controller),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

class _AddressCard extends StatelessWidget {
  final AddressModel address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;

  const _AddressCard({
    required this.address,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: address.isDefault
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getLabelIcon(address.label),
                color: AppColors.primary,
              ),
            ),
            title: Row(
              children: [
                Text(
                  address.label,
                  style: AppTextStyles.subtitle1,
                ),
                if (address.isDefault) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Default',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                address.fullAddress,
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    onEdit();
                    break;
                  case 'delete':
                    onDelete();
                    break;
                  case 'default':
                    onSetDefault();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 20),
                      SizedBox(width: 12),
                      Text('Edit'),
                    ],
                  ),
                ),
                if (!address.isDefault)
                  const PopupMenuItem(
                    value: 'default',
                    child: Row(
                      children: [
                        Icon(Icons.star_outline, size: 20),
                        SizedBox(width: 12),
                        Text('Set as Default'),
                      ],
                    ),
                  ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                      SizedBox(width: 12),
                      Text('Delete', style: TextStyle(color: AppColors.error)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  IconData _getLabelIcon(String label) {
    switch (label.toLowerCase()) {
      case 'home':
        return Icons.home_outlined;
      case 'office':
      case 'work':
        return Icons.business_outlined;
      default:
        return Icons.location_on_outlined;
    }
  }
}

class _AddressFormSheet extends StatelessWidget {
  final AddressController controller;

  const _AddressFormSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() => Text(
                      controller.isEditMode ? 'Edit Address' : 'Add New Address',
                      style: AppTextStyles.h4,
                    )),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Label
                  AppTextField(
                    controller: controller.labelController,
                    label: 'Label',
                    hint: 'e.g., Home, Office, etc.',
                    prefixIcon: const Icon(Icons.label_outline),
                  ),
                  const SizedBox(height: 16),

                  // Address
                  AppTextArea(
                    controller: controller.addressController,
                    label: 'Address',
                    hint: 'Enter full address',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  // Landmark
                  AppTextField(
                    controller: controller.landmarkController,
                    label: 'Landmark (Optional)',
                    hint: 'Near landmark',
                    prefixIcon: const Icon(Icons.place_outlined),
                  ),
                  const SizedBox(height: 16),

                  // City & State Row
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: controller.cityController,
                          label: 'City',
                          hint: 'City',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AppTextField(
                          controller: controller.stateController,
                          label: 'State',
                          hint: 'State',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Pincode
                  AppTextField(
                    controller: controller.pincodeController,
                    label: 'Pincode',
                    hint: '6-digit pincode',
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    prefixIcon: const Icon(Icons.pin_drop_outlined),
                  ),
                  const SizedBox(height: 16),

                  // Set as Default
                  Obx(() => SwitchListTile(
                        title: const Text('Set as default address'),
                        subtitle: const Text('Use this address by default'),
                        value: controller.isDefault.value,
                        onChanged: (value) => controller.isDefault.value = value,
                        activeColor: AppColors.primary,
                        contentPadding: EdgeInsets.zero,
                      )),
                  const SizedBox(height: 24),

                  // Save Button
                  Obx(() => AppButton.primary(
                        text: controller.isEditMode ? 'Update Address' : 'Save Address',
                        isLoading: controller.isSaving.value,
                        onPressed: controller.saveAddress,
                      )),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

**Step 2: Commit**

```bash
git add lib/app/modules/profile/views/addresses_view.dart
git commit -m "feat(profile): add AddressesView with CRUD operations"
```

---

## Task 11: Create Wallet View

**Files:**
- Create: `lib/app/modules/wallet/views/wallet_view.dart`

**Step 1: Create the wallet view**

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/wallet_model.dart';
import '../controllers/wallet_controller.dart';

class WalletView extends GetView<WalletController> {
  const WalletView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Wallet'),
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshAll,
        child: CustomScrollView(
          slivers: [
            // Balance Card
            SliverToBoxAdapter(
              child: _buildBalanceCard(),
            ),

            // Filter Chips
            SliverToBoxAdapter(
              child: _buildFilterChips(),
            ),

            // Transactions Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  'Transaction History',
                  style: AppTextStyles.subtitle1,
                ),
              ),
            ),

            // Transactions List
            Obx(() {
              if (controller.isLoading.value && controller.transactions.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (controller.transactions.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 80,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No transactions yet',
                          style: AppTextStyles.h4.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == controller.transactions.length) {
                      // Load more indicator
                      if (controller.hasMorePages.value) {
                        controller.fetchTransactions();
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }

                    final transaction = controller.transactions[index];
                    return _TransactionTile(transaction: transaction);
                  },
                  childCount: controller.transactions.length +
                      (controller.hasMorePages.value ? 1 : 0),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Wallet Balance',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.account_balance_wallet, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'SendIt Wallet',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() => Text(
                controller.balanceDisplay,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              )),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _showAddMoneySheet,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Add Money',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(() => Row(
            children: [
              _FilterChip(
                label: 'All',
                isSelected: controller.selectedFilter.value == null,
                onTap: () => controller.setFilter(null),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Credit',
                isSelected: controller.selectedFilter.value == 'CREDIT',
                onTap: () => controller.setFilter('CREDIT'),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Debit',
                isSelected: controller.selectedFilter.value == 'DEBIT',
                onTap: () => controller.setFilter('DEBIT'),
              ),
            ],
          )),
    );
  }

  void _showAddMoneySheet() {
    Get.bottomSheet(
      _AddMoneySheet(controller: controller),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final WalletTransactionModel transaction;

  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.isCredit;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isCredit
                ? AppColors.success.withOpacity(0.1)
                : AppColors.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isCredit ? Icons.arrow_downward : Icons.arrow_upward,
            color: isCredit ? AppColors.success : AppColors.error,
          ),
        ),
        title: Text(
          transaction.description ?? _getDefaultDescription(transaction),
          style: AppTextStyles.subtitle2,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          _formatDate(transaction.createdAt),
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              transaction.amountDisplay,
              style: AppTextStyles.subtitle1.copyWith(
                color: isCredit ? AppColors.success : AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            _StatusBadge(status: transaction.status),
          ],
        ),
      ),
    );
  }

  String _getDefaultDescription(WalletTransactionModel txn) {
    switch (txn.referenceType) {
      case 'TOPUP':
        return 'Wallet Top-up';
      case 'BOOKING':
        return 'Booking Payment';
      case 'REFUND':
        return 'Refund';
      case 'BONUS':
        return 'Bonus Credit';
      default:
        return txn.isCredit ? 'Credit' : 'Debit';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today, ${_formatTime(date)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday, ${_formatTime(date)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final amPm = date.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} $amPm';
  }
}

class _StatusBadge extends StatelessWidget {
  final WalletTxnStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;

    switch (status) {
      case WalletTxnStatus.completed:
        color = AppColors.success;
        text = 'Completed';
        break;
      case WalletTxnStatus.pending:
        color = AppColors.warning;
        text = 'Pending';
        break;
      case WalletTxnStatus.failed:
        color = AppColors.error;
        text = 'Failed';
        break;
      case WalletTxnStatus.reversed:
        color = AppColors.textTertiary;
        text = 'Reversed';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _AddMoneySheet extends StatelessWidget {
  final WalletController controller;

  const _AddMoneySheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Text('Add Money to Wallet', style: AppTextStyles.h4),
          const SizedBox(height: 8),
          Text(
            'Enter amount or select a quick option',
            style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),

          // Amount Input
          AppTextField(
            controller: controller.amountController,
            label: 'Amount',
            hint: 'Enter amount',
            keyboardType: TextInputType.number,
            prefixIcon: const Padding(
              padding: EdgeInsets.only(left: 16, right: 8),
              child: Text('₹', style: TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(height: 16),

          // Quick Amount Options
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.predefinedAmounts.map((amount) {
              return GestureDetector(
                onTap: () => controller.selectPredefinedAmount(amount),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: Text(
                    '₹$amount',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Info Text
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.info, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'This is a simulated payment. In production, this will connect to a payment gateway.',
                    style: AppTextStyles.caption.copyWith(color: AppColors.info),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Add Button
          Obx(() => AppButton.primary(
                text: 'Add Money',
                isLoading: controller.isAddingMoney.value,
                onPressed: controller.addMoney,
              )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
```

**Step 2: Commit**

```bash
git add lib/app/modules/wallet/views/wallet_view.dart
git commit -m "feat(wallet): add WalletView with balance, add money, transactions"
```

---

## Task 12: Register Routes in app_pages.dart

**Files:**
- Modify: `lib/app/routes/app_pages.dart`

**Step 1: Update app_pages.dart to include all new routes**

Add imports at top and new GetPage entries after existing routes:

```dart
import 'package:get/get.dart';
import 'app_routes.dart';

// Auth Module Imports
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/splash_view.dart';
import '../modules/auth/views/onboarding_view.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/otp_view.dart';
import '../modules/auth/views/profile_setup_view.dart';

// Home Module Imports
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/main_view.dart';

// Profile Module Imports
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/profile/views/edit_profile_view.dart';
import '../modules/profile/views/addresses_view.dart';

// Wallet Module Imports
import '../modules/wallet/bindings/wallet_binding.dart';
import '../modules/wallet/views/wallet_view.dart';

/// Application page configuration for GetX routing
class AppPages {
  AppPages._();

  /// Initial route when app starts
  static const initial = Routes.splash;

  /// All application routes
  static final routes = <GetPage>[
    // Auth Routes
    GetPage(
      name: Routes.splash,
      page: () => const SplashView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.onboarding,
      page: () => const OnboardingView(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.otp,
      page: () => const OtpView(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.profileSetup,
      page: () => const ProfileSetupView(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
    ),

    // Main Routes
    GetPage(
      name: Routes.main,
      page: () => const MainView(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
    ),

    // Profile Routes
    GetPage(
      name: Routes.profile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.personalInfo,
      page: () => const EditProfileView(),
      binding: ProfileBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.savedAddresses,
      page: () => const AddressesView(),
      binding: ProfileBinding(),
      transition: Transition.rightToLeft,
    ),

    // Wallet Routes
    GetPage(
      name: Routes.wallet,
      page: () => const WalletView(),
      binding: WalletBinding(),
      transition: Transition.rightToLeft,
    ),
  ];
}
```

**Step 2: Commit**

```bash
git add lib/app/routes/app_pages.dart
git commit -m "feat(routes): register Profile and Wallet routes"
```

---

## Task 13: Update MainView with Profile Navigation

**Files:**
- Modify: `lib/app/modules/home/views/main_view.dart`

**Step 1: Update MainView to include a profile button and navigation**

Replace the current placeholder MainView with proper navigation to profile:

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../routes/app_routes.dart';
import '../controllers/home_controller.dart';

class MainView extends GetView<HomeController> {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('SendIt'),
        backgroundColor: AppColors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navigate to notifications
              Get.snackbar('Coming Soon', 'Notifications');
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Get.toNamed(Routes.profile),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, Color(0xFF059669)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome to SendIt!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your reliable delivery partner',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Quick Actions
              Text('Quick Actions', style: AppTextStyles.h4),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.local_shipping_outlined,
                      title: 'Book Now',
                      subtitle: 'Send a package',
                      onTap: () {
                        // TODO: Navigate to booking
                        Get.snackbar('Coming Soon', 'Booking flow in Sprint 1');
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.history,
                      title: 'My Orders',
                      subtitle: 'View history',
                      onTap: () {
                        // TODO: Navigate to orders
                        Get.snackbar('Coming Soon', 'Orders in Sprint 2');
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'Wallet',
                      subtitle: 'Add money',
                      onTap: () => Get.toNamed(Routes.wallet),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.location_on_outlined,
                      title: 'Addresses',
                      subtitle: 'Saved places',
                      onTap: () => Get.toNamed(Routes.savedAddresses),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Development Status
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.info.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: AppColors.info),
                        const SizedBox(width: 8),
                        Text(
                          'Development Status',
                          style: AppTextStyles.subtitle1.copyWith(
                            color: AppColors.info,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _StatusItem(title: 'Auth Flow', status: 'Complete', isComplete: true),
                    _StatusItem(title: 'Profile & Wallet', status: 'Complete', isComplete: true),
                    _StatusItem(title: 'Booking Flow', status: 'Sprint 1', isComplete: false),
                    _StatusItem(title: 'Orders & Tracking', status: 'Sprint 2', isComplete: false),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(height: 12),
            Text(title, style: AppTextStyles.subtitle1),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusItem extends StatelessWidget {
  final String title;
  final String status;
  final bool isComplete;

  const _StatusItem({
    required this.title,
    required this.status,
    required this.isComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            isComplete ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 18,
            color: isComplete ? AppColors.success : AppColors.textTertiary,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(title, style: AppTextStyles.body2)),
          Text(
            status,
            style: AppTextStyles.caption.copyWith(
              color: isComplete ? AppColors.success : AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
```

**Step 2: Commit**

```bash
git add lib/app/modules/home/views/main_view.dart
git commit -m "feat(home): update MainView with profile navigation and quick actions"
```

---

## Task 14: Final Integration Test

**Step 1: Verify all files exist**

```bash
ls -la lib/app/data/repositories/
ls -la lib/app/modules/profile/
ls -la lib/app/modules/wallet/
```

**Step 2: Run Flutter analyze**

```bash
cd user_app && flutter analyze
```

Expected: No errors (warnings acceptable)

**Step 3: Run the app**

```bash
flutter run
```

Expected: App launches, can navigate to Profile and Wallet screens

**Step 4: Final commit with all changes**

```bash
git add .
git commit -m "feat: complete Profile & Wallet feature implementation

- Add AddressRepository for saved addresses CRUD
- Add WalletRepository for balance and transactions
- Add ProfileController with edit, logout, delete account
- Add AddressController for address management
- Add WalletController for wallet operations
- Add ProfileView, EditProfileView, AddressesView
- Add WalletView with balance card and transaction history
- Register all routes in app_pages.dart
- Update MainView with quick actions navigation"
```

---

## Summary

**Total Tasks:** 14

**Files Created:**
- `lib/app/data/repositories/address_repository.dart`
- `lib/app/data/repositories/wallet_repository.dart`
- `lib/app/modules/profile/controllers/profile_controller.dart`
- `lib/app/modules/profile/controllers/address_controller.dart`
- `lib/app/modules/profile/bindings/profile_binding.dart`
- `lib/app/modules/profile/views/profile_view.dart`
- `lib/app/modules/profile/views/edit_profile_view.dart`
- `lib/app/modules/profile/views/addresses_view.dart`
- `lib/app/modules/wallet/controllers/wallet_controller.dart`
- `lib/app/modules/wallet/bindings/wallet_binding.dart`
- `lib/app/modules/wallet/views/wallet_view.dart`

**Files Modified:**
- `lib/app/data/repositories/auth_repository.dart` (add deleteAccount)
- `lib/app/routes/app_pages.dart` (register routes)
- `lib/app/modules/home/views/main_view.dart` (add navigation)

**Features Delivered:**
1. Profile hub with menu navigation
2. Edit personal information (name, email, avatar)
3. Saved addresses CRUD (create, read, update, delete, set default)
4. Wallet balance display
5. Add money to wallet (simulated)
6. Transaction history with filters
7. Logout functionality
8. Delete account functionality
