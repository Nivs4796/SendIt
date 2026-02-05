import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/models/pilot_model.dart';
import '../../../data/repositories/pilot_repository.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../services/storage_service.dart';
import '../../../routes/app_routes.dart';

class ProfileController extends GetxController {
  final PilotRepository _pilotRepository = PilotRepository();
  final AuthRepository _authRepository = AuthRepository();
  late final StorageService _storage;
  final ImagePicker _picker = ImagePicker();

  // State
  final isLoading = true.obs;
  final pilot = Rxn<PilotModel>();
  final isProcessing = false.obs;

  @override
  void onInit() {
    super.onInit();
    _storage = Get.find<StorageService>();
    loadProfile();
  }

  /// Load pilot profile
  Future<void> loadProfile() async {
    try {
      isLoading.value = true;
      
      // Try local first
      final localPilot = _authRepository.currentPilot;
      if (localPilot != null) {
        pilot.value = localPilot;
      }

      // Then refresh from API
      final response = await _pilotRepository.getProfile();
      if (response['success'] == true) {
        pilot.value = response['pilot'] as PilotModel;
      }
    } catch (e) {
      // Use local data
    } finally {
      isLoading.value = false;
    }
  }

  /// Update profile
  Future<bool> updateProfile({
    String? name,
    String? email,
    String? emergencyContact,
  }) async {
    try {
      isProcessing.value = true;
      
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (email != null) updates['email'] = email;
      if (emergencyContact != null) updates['emergencyContact'] = emergencyContact;

      final response = await _pilotRepository.updateProfile(updates);
      if (response['success'] == true) {
        pilot.value = response['pilot'] as PilotModel;
        Get.snackbar(
          'Profile Updated',
          'Your profile has been updated successfully',
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
        );
        return true;
      }
      throw Exception(response['message'] ?? 'Update failed');
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return false;
    } finally {
      isProcessing.value = false;
    }
  }

  /// Upload profile photo
  Future<bool> uploadProfilePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 80,
      );

      if (image == null) return false;

      isProcessing.value = true;

      final response = await _pilotRepository.uploadProfilePhoto(File(image.path));
      if (response['success'] == true) {
        // Refresh profile
        await loadProfile();
        Get.snackbar(
          'Photo Updated',
          'Your profile photo has been updated',
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
        );
        return true;
      }
      throw Exception(response['message'] ?? 'Upload failed');
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return false;
    } finally {
      isProcessing.value = false;
    }
  }

  /// Logout
  Future<void> logout() async {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await _performLogout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _performLogout() async {
    try {
      isProcessing.value = true;
      
      // Clear auth data
      await _authRepository.logout();
      _storage.clearAuth();
      
      // Navigate to login
      Get.offAllNamed(Routes.login);
    } catch (e) {
      Get.snackbar('Error', 'Failed to logout');
    } finally {
      isProcessing.value = false;
    }
  }

  /// Delete account
  Future<void> deleteAccount() async {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await _performDeleteAccount();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _performDeleteAccount() async {
    try {
      isProcessing.value = true;
      
      final response = await _pilotRepository.deleteAccount();
      if (response['success'] == true) {
        await _authRepository.logout();
        _storage.clearAuth();
        Get.offAllNamed(Routes.login);
        Get.snackbar('Account Deleted', 'Your account has been deleted');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete account');
    } finally {
      isProcessing.value = false;
    }
  }

  /// Refresh profile
  Future<void> refresh() => loadProfile();
}
