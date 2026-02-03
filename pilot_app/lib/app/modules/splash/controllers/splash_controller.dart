import 'package:get/get.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../data/models/pilot_model.dart';
import '../../../routes/app_routes.dart';

class SplashController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  @override
  void onInit() {
    super.onInit();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    // Show splash for 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    // Check auth state and navigate accordingly
    final isLoggedIn = await _authRepository.isLoggedIn();
    
    if (isLoggedIn) {
      final pilot = await _authRepository.getCurrentPilot();
      if (pilot != null) {
        // Check verification status
        if (pilot.verificationStatus == VerificationStatus.approved) {
          Get.offAllNamed(Routes.home);
        } else {
          Get.offAllNamed(Routes.verificationPending);
        }
      } else {
        Get.offAllNamed(Routes.login);
      }
    } else {
      Get.offAllNamed(Routes.login);
    }
  }
}
