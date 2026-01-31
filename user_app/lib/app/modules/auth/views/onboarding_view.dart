import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_assets.dart';
import '../controllers/auth_controller.dart';

class OnboardingView extends GetView<AuthController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final pageController = PageController();
    final currentPage = 0.obs;

    final pages = [
      _OnboardingPage(
        imagePath: AppAssets.logo,
        title: 'Welcome to SendIt',
        description: 'Your trusted partner for fast, reliable package delivery across the city.',
        color: AppColors.primary,
      ),
      _OnboardingPage(
        icon: Icons.location_on_rounded,
        title: 'Real-Time Tracking',
        description: 'Track your delivery in real-time and know exactly when it will arrive.',
        color: AppColors.info,
      ),
      _OnboardingPage(
        icon: Icons.security_rounded,
        title: 'Safe & Secure',
        description: 'Your packages are handled with care and fully insured during transit.',
        color: AppColors.success,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: controller.completeOnboarding,
                child: Text(
                  'Skip',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            // Pages
            Expanded(
              child: PageView.builder(
                controller: pageController,
                itemCount: pages.length,
                onPageChanged: (index) => currentPage.value = index,
                itemBuilder: (context, index) => pages[index],
              ),
            ),
            // Indicators
            Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: currentPage.value == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: currentPage.value == index
                        ? AppColors.primary
                        : AppColors.grey300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            )),
            const SizedBox(height: 32),
            // Button
            Padding(
              padding: const EdgeInsets.all(24),
              child: Obx(() => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (currentPage.value < pages.length - 1) {
                      pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      controller.completeOnboarding();
                    }
                  },
                  child: Text(
                    currentPage.value < pages.length - 1
                        ? 'Next'
                        : 'Get Started',
                  ),
                ),
              )),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final IconData? icon;
  final String? imagePath;
  final String title;
  final String description;
  final Color color;

  const _OnboardingPage({
    this.icon,
    this.imagePath,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: imagePath != null
                ? Padding(
                    padding: const EdgeInsets.all(24),
                    child: Image.asset(
                      imagePath!,
                      fit: BoxFit.contain,
                    ),
                  )
                : Icon(
                    icon,
                    size: 80,
                    color: color,
                  ),
          ),
          const SizedBox(height: 48),
          Text(
            title,
            style: AppTextStyles.h2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
