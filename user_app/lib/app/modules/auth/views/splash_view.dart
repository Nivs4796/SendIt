import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_assets.dart';
import '../controllers/auth_controller.dart';

class SplashView extends GetView<AuthController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    // Trigger auth check when view is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.checkAuthState();
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // SendIt Logo
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Image.asset(
                AppAssets.logo,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 48),
            // Loading indicator
            SpinKitThreeBounce(
              color: AppColors.primary,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}
