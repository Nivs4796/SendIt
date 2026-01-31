import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/providers/api_exceptions.dart';
import '../../../core/constants/app_constants.dart';
import '../../../routes/app_routes.dart';
import '../../../services/storage_service.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();
  final StorageService _storage = Get.find<StorageService>();

  // Observable state
  final isLoading = false.obs;
  final phone = ''.obs;
  final otp = ''.obs;
  final name = ''.obs;
  final email = ''.obs;
  final errorMessage = ''.obs;

  // OTP Timer
  final canResendOtp = false.obs;
  final resendSeconds = AppConstants.otpResendSeconds.obs;
  Timer? _resendTimer;

  // Current user
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  @override
  void onInit() {
    super.onInit();
    _loadCurrentUser();
  }

  @override
  void onClose() {
    _resendTimer?.cancel();
    super.onClose();
  }

  void _loadCurrentUser() {
    currentUser.value = _authRepository.currentUser;
  }

  // Check auth state and navigate accordingly
  Future<void> checkAuthState() async {
    await Future.delayed(const Duration(seconds: 2)); // Splash delay

    if (!_storage.hasCompletedOnboarding) {
      Get.offAllNamed(Routes.onboarding);
    } else if (_authRepository.isLoggedIn) {
      _loadCurrentUser();
      Get.offAllNamed(Routes.main);
    } else {
      Get.offAllNamed(Routes.login);
    }
  }

  // Complete onboarding
  void completeOnboarding() {
    _storage.hasCompletedOnboarding = true;
    Get.offAllNamed(Routes.login);
  }

  // Send OTP
  Future<void> sendOtp() async {
    if (phone.value.length != AppConstants.minPhoneLength) {
      errorMessage.value = 'Please enter a valid 10-digit phone number';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _authRepository.sendOtp(phone.value);

      if (response.success) {
        Get.toNamed(Routes.otp);
        _startResendTimer();
      } else {
        errorMessage.value = response.message ?? 'Failed to send OTP';
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

  // Verify OTP
  Future<void> verifyOtp() async {
    if (otp.value.length != AppConstants.otpLength) {
      errorMessage.value = 'Please enter the complete OTP';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _authRepository.verifyOtp(phone.value, otp.value);

      if (response.success && response.data != null) {
        currentUser.value = response.data;

        // Check if profile is complete
        if (response.data!.name == null || response.data!.name!.isEmpty) {
          Get.offAllNamed(Routes.profileSetup);
        } else {
          Get.offAllNamed(Routes.main);
        }
      } else {
        errorMessage.value = response.message ?? 'Invalid OTP';
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

  // Resend OTP
  Future<void> resendOtp() async {
    if (!canResendOtp.value) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _authRepository.sendOtp(phone.value);

      if (response.success) {
        _startResendTimer();
        Get.snackbar(
          'OTP Sent',
          'A new OTP has been sent to your phone',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        errorMessage.value = response.message ?? 'Failed to resend OTP';
      }
    } catch (e) {
      errorMessage.value = 'Something went wrong';
    } finally {
      isLoading.value = false;
    }
  }

  void _startResendTimer() {
    canResendOtp.value = false;
    resendSeconds.value = AppConstants.otpResendSeconds;

    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendSeconds.value > 0) {
        resendSeconds.value--;
      } else {
        canResendOtp.value = true;
        timer.cancel();
      }
    });
  }

  // Update Profile
  Future<void> updateProfile() async {
    if (name.value.length < AppConstants.minNameLength) {
      errorMessage.value = 'Name must be at least ${AppConstants.minNameLength} characters';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _authRepository.updateProfile(
        name: name.value,
        email: email.value.isNotEmpty ? email.value : null,
      );

      if (response.success && response.data != null) {
        currentUser.value = response.data;
        Get.offAllNamed(Routes.main);
      } else {
        errorMessage.value = response.message ?? 'Failed to update profile';
      }
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'Something went wrong';
    } finally {
      isLoading.value = false;
    }
  }

  // Logout
  void logout() {
    _authRepository.logout();
    currentUser.value = null;
    phone.value = '';
    otp.value = '';
    name.value = '';
    email.value = '';
    Get.offAllNamed(Routes.login);
  }

  // Clear error
  void clearError() {
    errorMessage.value = '';
  }
}
