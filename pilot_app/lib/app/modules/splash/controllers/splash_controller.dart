import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../data/models/pilot_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../routes/app_routes.dart';

class SplashController extends GetxController {
  late final AuthRepository _authRepository;

  @override
  void onInit() {
    super.onInit();
    _authRepository = AuthRepository();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    // Show splash for 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    try {
      // Debug: Check stored token
      debugPrint('🔍 Checking auth state...');
      debugPrint('🔍 Token exists: ${_authRepository.token != null}');
      debugPrint('🔍 isLoggedIn: ${_authRepository.isLoggedIn}');

      // Check if user is logged in
      if (_authRepository.isLoggedIn) {
        debugPrint('✅ User is logged in, checking profile...');
        
        // Try to get fresh profile from API
        final response = await _authRepository.getProfile();
        
        if (response['success'] == true && response['pilot'] != null) {
          final pilot = response['pilot'] as PilotModel;
          debugPrint('✅ Profile loaded: ${pilot.name}, status: ${pilot.verificationStatus}');
          
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
        } else if (response['unauthorized'] == true) {
          // Token expired, go to login
          debugPrint('⚠️ Token expired, going to login');
          Get.offAllNamed(Routes.login);
        } else {
          // Network error - try local pilot data
          final localPilot = _authRepository.currentPilot;
          if (localPilot != null) {
            debugPrint('✅ Using local pilot data');
            if (localPilot.verificationStatus == VerificationStatus.approved) {
              Get.offAllNamed(Routes.home);
            } else {
              Get.offAllNamed(Routes.verificationPending);
            }
          } else {
            debugPrint('⚠️ No local pilot data, going to login');
            Get.offAllNamed(Routes.login);
          }
        }
      } else {
        debugPrint('ℹ️ User not logged in, going to login');
        Get.offAllNamed(Routes.login);
      }
    } catch (e) {
      debugPrint('❌ Error in splash navigation: $e');
      // On any error, go to login
      Get.offAllNamed(Routes.login);
    }
  }
}
