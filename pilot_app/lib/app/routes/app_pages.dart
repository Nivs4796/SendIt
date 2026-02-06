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
import '../modules/jobs/bindings/jobs_binding.dart';
import '../modules/jobs/views/active_job_view.dart';
import '../modules/earnings/bindings/earnings_binding.dart';
import '../modules/earnings/views/earnings_view.dart';
import '../modules/wallet/bindings/wallet_binding.dart';
import '../modules/wallet/views/wallet_view.dart';
import '../modules/wallet/views/withdraw_view.dart';
import '../modules/vehicles/bindings/vehicles_binding.dart';
import '../modules/vehicles/views/vehicles_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/edit_profile_view.dart';
import '../modules/notifications/bindings/notifications_binding.dart';
import '../modules/notifications/views/notifications_view.dart';
import '../modules/rewards/bindings/rewards_binding.dart';
import '../modules/rewards/views/rewards_view.dart';
import '../modules/documents/bindings/documents_binding.dart';
import '../modules/documents/views/documents_view.dart';
import '../modules/bank/bindings/bank_binding.dart';
import '../modules/bank/views/bank_details_view.dart';
import '../modules/history/bindings/history_binding.dart';
import '../modules/history/views/history_view.dart';
import '../modules/support/bindings/support_binding.dart';
import '../modules/support/views/help_view.dart';

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

    // Jobs
    GetPage(
      name: Routes.activeJob,
      page: () => const ActiveJobView(),
      binding: JobsBinding(),
    ),

    // Earnings
    GetPage(
      name: Routes.earnings,
      page: () => const EarningsView(),
      binding: EarningsBinding(),
    ),

    // Wallet
    GetPage(
      name: Routes.wallet,
      page: () => const WalletView(),
      binding: WalletBinding(),
    ),

    // Vehicles
    GetPage(
      name: Routes.vehicles,
      page: () => const VehiclesView(),
      binding: VehiclesBinding(),
    ),

    // Edit Profile
    GetPage(
      name: Routes.editProfile,
      page: () => const EditProfileView(),
      binding: ProfileBinding(),
    ),

    // Notifications
    GetPage(
      name: Routes.notifications,
      page: () => const NotificationsView(),
      binding: NotificationsBinding(),
    ),

    // Rewards
    GetPage(
      name: Routes.rewards,
      page: () => const RewardsView(),
      binding: RewardsBinding(),
    ),

    // Documents
    GetPage(
      name: Routes.documents,
      page: () => const DocumentsView(),
      binding: DocumentsBinding(),
    ),

    // Bank Accounts
    GetPage(
      name: Routes.bankDetails,
      page: () => const BankDetailsView(),
      binding: BankBinding(),
    ),

    // Job History
    GetPage(
      name: Routes.jobHistory,
      page: () => const HistoryView(),
      binding: HistoryBinding(),
    ),

    // Help & Support
    GetPage(
      name: Routes.help,
      page: () => const HelpView(),
      binding: SupportBinding(),
    ),

    // Withdraw
    GetPage(
      name: Routes.withdraw,
      page: () => const WithdrawView(),
      binding: WalletBinding(),
    ),
  ];
}
