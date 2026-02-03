import 'package:get/get.dart';

import '../../../routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    // Show splash for 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    // TODO: Check auth state and navigate accordingly
    // For now, go to login
    // Get.offAllNamed(Routes.login);
    
    // Temporary: Stay on splash until auth is implemented
    // Will navigate to login once auth module is ready
  }

  void navigateToLogin() {
    Get.offAllNamed(Routes.login);
  }

  void navigateToHome() {
    Get.offAllNamed(Routes.home);
  }
}
