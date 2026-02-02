import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/widgets/widgets.dart';
import '../controllers/auth_controller.dart';

class OnboardingView extends GetView<AuthController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const _OnboardingContent();
  }
}

class _OnboardingContent extends StatefulWidget {
  const _OnboardingContent();

  @override
  State<_OnboardingContent> createState() => _OnboardingContentState();
}

class _OnboardingContentState extends State<_OnboardingContent>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final _currentPage = 0.obs;

  final List<_OnboardingPageData> _pages = [
    _OnboardingPageData(
      imagePath: AppAssets.logo,
      title: 'Welcome to SendIt',
      description: 'Your trusted partner for fast, reliable package delivery across the city.',
      color: AppColors.primary,
    ),
    _OnboardingPageData(
      icon: Icons.location_on_rounded,
      title: 'Real-Time Tracking',
      description: 'Track your delivery in real-time and know exactly when it will arrive.',
      color: AppColors.info,
    ),
    _OnboardingPageData(
      icon: Icons.security_rounded,
      title: 'Safe & Secure',
      description: 'Your packages are handled with care and fully insured during transit.',
      color: AppColors.success,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onNextPressed() {
    if (_currentPage.value < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      Get.find<AuthController>().completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Skip button - Using AppButton.text
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AppButton.text(
                    text: 'Skip',
                    textColor: AppColors.textSecondary,
                    onPressed: () => Get.find<AuthController>().completeOnboarding(),
                  ),
                ),
              ),

              // Pages
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) => _currentPage.value = index,
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return _OnboardingPage(
                      icon: page.icon,
                      imagePath: page.imagePath,
                      title: page.title,
                      description: page.description,
                      color: page.color,
                    );
                  },
                ),
              ),

              // Indicators with animation
              Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage.value == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage.value == index
                          ? AppColors.primary
                          : AppColors.grey300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              )),

              const SizedBox(height: 32),

              // Button - Using AppButton with animated text
              Padding(
                padding: const EdgeInsets.all(24),
                child: Obx(() => AppButton.primary(
                  text: _currentPage.value < _pages.length - 1
                      ? 'Next'
                      : 'Get Started',
                  onPressed: _onNextPressed,
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  final IconData? icon;
  final String? imagePath;
  final String title;
  final String description;
  final Color color;

  const _OnboardingPageData({
    this.icon,
    this.imagePath,
    required this.title,
    required this.description,
    required this.color,
  });
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
          // Animated icon/image container
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.8, end: 1.0),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: child,
              );
            },
            child: Container(
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
          ),

          const SizedBox(height: 48),

          // Title - Using AppText
          AppText.h2(
            title,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Description - Using AppText
          AppText.secondary(
            description,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
