import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/upload_repository.dart';
import '../../../data/providers/api_exceptions.dart';
import '../../../routes/app_routes.dart';
import '../../../services/storage_service.dart';

class ProfileController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();
  final UploadRepository _uploadRepository = UploadRepository();
  final StorageService _storage = Get.find<StorageService>();
  final ImagePicker _imagePicker = ImagePicker();

  // Observable state
  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final isLoading = false.obs;
  final isUpdating = false.obs;
  final errorMessage = ''.obs;
  final Rx<File?> selectedAvatarFile = Rx<File?>(null);

  // Text controllers for profile editing
  late TextEditingController nameController;
  late TextEditingController emailController;

  // Getters for user data
  String get userName => user.value?.name ?? '';
  String get userPhone => user.value?.phone ?? '';
  String get userEmail => user.value?.email ?? '';
  String? get userAvatar => user.value?.avatar;

  @override
  void onInit() {
    super.onInit();
    nameController = TextEditingController();
    emailController = TextEditingController();
    loadUserFromStorage();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    super.onClose();
  }

  /// Load user data from local storage
  void loadUserFromStorage() {
    final userData = _storage.user;
    if (userData != null) {
      user.value = UserModel.fromJson(userData);
      _populateTextControllers();
    }
  }

  /// Populate text controllers with current user data
  void _populateTextControllers() {
    nameController.text = userName;
    emailController.text = userEmail;
  }

  /// Fetch latest profile from API
  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _authRepository.getProfile();

      if (response.success && response.data != null) {
        user.value = response.data;
        _storage.user = response.data!.toJson();
        _populateTextControllers();
      } else {
        final message = response.message ?? 'Failed to fetch profile';
        errorMessage.value = message;
        Get.snackbar(
          'Error',
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      Get.snackbar(
        'Error',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } on NetworkException {
      errorMessage.value = 'No internet connection';
      Get.snackbar(
        'Error',
        'No internet connection',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      errorMessage.value = 'Something went wrong';
      Get.snackbar(
        'Error',
        'Something went wrong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Pick avatar from gallery
  Future<void> pickAvatar() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        selectedAvatarFile.value = File(image.path);
      }
    } catch (e) {
      errorMessage.value = 'Failed to pick image';
    }
  }

  /// Take photo from camera
  Future<void> takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        selectedAvatarFile.value = File(image.path);
      }
    } catch (e) {
      errorMessage.value = 'Failed to take photo';
    }
  }

  /// Show bottom sheet to choose avatar source
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
              'Choose Photo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAvatarOption(
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  onTap: () {
                    Get.back();
                    takePhoto();
                  },
                ),
                _buildAvatarOption(
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  onTap: () {
                    Get.back();
                    pickAvatar();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 28, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  /// Update user profile
  Future<void> updateProfile() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();

    if (name.length < 2) {
      errorMessage.value = 'Name must be at least 2 characters';
      return;
    }

    try {
      isUpdating.value = true;
      errorMessage.value = '';

      String? avatarUrl;

      // Upload avatar first if selected
      if (selectedAvatarFile.value != null) {
        final uploadResponse = await _uploadRepository.uploadAvatar(
          selectedAvatarFile.value!,
        );

        if (uploadResponse.success && uploadResponse.data != null) {
          avatarUrl = uploadResponse.data;
        } else {
          errorMessage.value = uploadResponse.message ?? 'Failed to upload avatar';
          isUpdating.value = false;
          return;
        }
      }

      // Update profile
      final response = await _authRepository.updateProfile(
        name: name,
        email: email.isNotEmpty ? email : null,
        avatar: avatarUrl,
      );

      if (response.success && response.data != null) {
        user.value = response.data;
        selectedAvatarFile.value = null;
        _storage.user = response.data!.toJson();

        Get.back();
        Get.snackbar(
          'Success',
          'Profile updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        final message = response.message ?? 'Failed to update profile';
        errorMessage.value = message;
        Get.snackbar(
          'Error',
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      Get.snackbar(
        'Error',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } on NetworkException {
      errorMessage.value = 'No internet connection';
      Get.snackbar(
        'Error',
        'No internet connection',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      errorMessage.value = 'Something went wrong';
      Get.snackbar(
        'Error',
        'Something went wrong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isUpdating.value = false;
    }
  }

  /// Delete user account with confirmation
  Future<void> deleteAccount() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently removed.',
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

      final response = await _authRepository.deleteAccount();

      if (response.success) {
        _storage.clearAuth();
        user.value = null;

        Get.snackbar(
          'Account Deleted',
          'Your account has been successfully deleted',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        Get.offAllNamed(Routes.login);
      } else {
        final message = response.message ?? 'Failed to delete account';
        errorMessage.value = message;
        Get.snackbar(
          'Error',
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      Get.snackbar(
        'Error',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } on NetworkException {
      errorMessage.value = 'No internet connection';
      Get.snackbar(
        'Error',
        'No internet connection',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      errorMessage.value = 'Something went wrong';
      Get.snackbar(
        'Error',
        'Something went wrong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Logout with confirmation
  Future<void> logout() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    _storage.clearAuth();
    user.value = null;

    Get.offAllNamed(Routes.login);
  }

  /// Clear error message
  void clearError() {
    errorMessage.value = '';
  }

  /// Reset selected avatar
  void clearSelectedAvatar() {
    selectedAvatarFile.value = null;
  }
}
