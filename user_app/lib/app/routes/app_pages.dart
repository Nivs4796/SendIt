import 'package:get/get.dart';
import 'app_routes.dart';

// Auth Module Imports
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/splash_view.dart';
import '../modules/auth/views/onboarding_view.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/otp_view.dart';
import '../modules/auth/views/profile_setup_view.dart';

// Home Module Imports
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/main_view.dart';

/// Application page configuration for GetX routing
class AppPages {
  AppPages._();

  /// Initial route when app starts
  static const initial = Routes.splash;

  /// All application routes
  static final routes = <GetPage>[
    // Auth Routes
    GetPage(
      name: Routes.splash,
      page: () => const SplashView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.onboarding,
      page: () => const OnboardingView(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.otp,
      page: () => const OtpView(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.profileSetup,
      page: () => const ProfileSetupView(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
    ),

    // Main Routes
    GetPage(
      name: Routes.main,
      page: () => const MainView(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
    ),
  ];
}
