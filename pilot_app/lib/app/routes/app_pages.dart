import 'package:get/get.dart';

import 'app_routes.dart';

// Module imports
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/otp_view.dart';
import '../modules/registration/bindings/registration_binding.dart';
import '../modules/registration/views/registration_view.dart';
import '../modules/registration/views/verification_pending_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';

/// App route pages configuration
class AppPages {
  AppPages._();

  static final routes = <GetPage>[
    // Splash
    GetPage(
      name: Routes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),

    // Auth
    GetPage(
      name: Routes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.otp,
      page: () => const OtpView(),
      binding: AuthBinding(),
    ),

    // Registration
    GetPage(
      name: Routes.registration,
      page: () => const RegistrationView(),
      binding: RegistrationBinding(),
    ),
    GetPage(
      name: Routes.verificationPending,
      page: () => const VerificationPendingView(),
      binding: RegistrationBinding(),
    ),

    // Home/Dashboard
    GetPage(
      name: Routes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),

    // Jobs (to be implemented)
    // GetPage(
    //   name: Routes.activeJob,
    //   page: () => const ActiveJobView(),
    //   binding: JobBinding(),
    // ),

    // Earnings (to be implemented)
    // GetPage(
    //   name: Routes.earnings,
    //   page: () => const EarningsView(),
    //   binding: EarningsBinding(),
    // ),

    // Wallet (to be implemented)
    // GetPage(
    //   name: Routes.wallet,
    //   page: () => const WalletView(),
    //   binding: WalletBinding(),
    // ),

    // Vehicles (to be implemented)
    // GetPage(
    //   name: Routes.vehicles,
    //   page: () => const VehiclesView(),
    //   binding: VehicleBinding(),
    // ),

    // Profile (to be implemented)
    // GetPage(
    //   name: Routes.profile,
    //   page: () => const ProfileView(),
    //   binding: ProfileBinding(),
    // ),
  ];
}
