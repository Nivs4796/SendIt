import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/pilot_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../core/constants/app_constants.dart';
import '../../../routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  // Observable state
  final isLoading = false.obs;
  final countryCode = '+91'.obs;
  final phone = ''.obs;
  final otp = ''.obs;
  final errorMessage = ''.obs;

  // OTP Timer
  final canResendOtp = false.obs;
  final resendSeconds = 30.obs;
  Timer? _resendTimer;

  // Current pilot
  final Rx<PilotModel?> currentPilot = Rx<PilotModel?>(null);

  // Text controllers
  late TextEditingController phoneController;

  @override
  void onInit() {
    super.onInit();
    phoneController = TextEditingController();
    phoneController.addListener(() {
      phone.value = phoneController.text;
    });
  }

  @override
  void onClose() {
    _resendTimer?.cancel();
    phoneController.dispose();
    super.onClose();
  }

  /// Check auth state and navigate accordingly
  Future<void> checkAuthState() async {
    await Future.delayed(const Duration(milliseconds: 1500));

    final isLoggedIn = await _authRepository.isLoggedIn();
    
    if (isLoggedIn) {
      final pilot = await _authRepository.getCurrentPilot();
      if (pilot != null) {
        currentPilot.value = pilot;
        
        // Check verification status
        if (pilot.verificationStatus == VerificationStatus.approved) {
          Get.offAllNamed(Routes.home);
        } else if (pilot.verificationStatus == VerificationStatus.pending ||
                   pilot.verificationStatus == VerificationStatus.inReview) {
          Get.offAllNamed(Routes.verificationPending);
        } else {
          // Rejected or needs re-registration
          Get.offAllNamed(Routes.registration);
        }
      } else {
        Get.offAllNamed(Routes.login);
      }
    } else {
      Get.offAllNamed(Routes.login);
    }
  }

  /// Send OTP to phone number
  Future<void> sendOtp() async {
    if (phone.value.length < 10) {
      errorMessage.value = 'Please enter a valid 10-digit phone number';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _authRepository.sendOtp(
        phone: phone.value,
        countryCode: countryCode.value,
        userType: 'pilot',
      );

      if (response['success'] == true) {
        Get.toNamed(Routes.otp);
        _startResendTimer();
      } else {
        errorMessage.value = response['message'] ?? 'Failed to send OTP';
      }
    } catch (e) {
      errorMessage.value = 'Network error. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Verify OTP
  Future<void> verifyOtp() async {
    if (otp.value.length != 6) {
      errorMessage.value = 'Please enter a valid 6-digit OTP';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _authRepository.verifyOtp(
        phone: phone.value,
        countryCode: countryCode.value,
        otp: otp.value,
        userType: 'pilot',
      );

      if (response['success'] == true) {
        final isNewUser = response['is_new_user'] ?? true;
        final pilot = response['pilot'] != null 
            ? PilotModel.fromJson(response['pilot']) 
            : null;

        if (isNewUser || pilot == null) {
          // New pilot - go to registration
          Get.offAllNamed(Routes.registration);
        } else {
          currentPilot.value = pilot;
          
          // Existing pilot - check verification status
          if (pilot.verificationStatus == VerificationStatus.approved) {
            Get.offAllNamed(Routes.home);
          } else {
            Get.offAllNamed(Routes.verificationPending);
          }
        }
      } else {
        errorMessage.value = response['message'] ?? 'Invalid OTP';
      }
    } catch (e) {
      errorMessage.value = 'Verification failed. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Resend OTP
  Future<void> resendOtp() async {
    if (!canResendOtp.value) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _authRepository.sendOtp(
        phone: phone.value,
        countryCode: countryCode.value,
        userType: 'pilot',
      );

      if (response['success'] == true) {
        Get.snackbar(
          'OTP Sent',
          'A new OTP has been sent to your phone',
          snackPosition: SnackPosition.BOTTOM,
        );
        _startResendTimer();
      } else {
        errorMessage.value = response['message'] ?? 'Failed to resend OTP';
      }
    } catch (e) {
      errorMessage.value = 'Failed to resend OTP';
    } finally {
      isLoading.value = false;
    }
  }

  /// Start resend timer
  void _startResendTimer() {
    canResendOtp.value = false;
    resendSeconds.value = 30;

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

  /// Logout
  Future<void> logout() async {
    await _authRepository.logout();
    currentPilot.value = null;
    phone.value = '';
    otp.value = '';
    Get.offAllNamed(Routes.login);
  }

  /// Clear error
  void clearError() {
    errorMessage.value = '';
  }

  /// Update OTP value
  void updateOtp(String value) {
    otp.value = value;
    if (value.length == 6) {
      verifyOtp();
    }
  }
}
