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

// Profile Module Imports
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/profile/views/edit_profile_view.dart';
import '../modules/profile/views/addresses_view.dart';

// Wallet Module Imports
import '../modules/wallet/bindings/wallet_binding.dart';
import '../modules/wallet/views/wallet_view.dart';

// Booking Module Imports
import '../modules/booking/bindings/booking_binding.dart';
import '../modules/booking/views/create_booking_view.dart';
import '../modules/booking/views/vehicle_selection_view.dart';
import '../modules/booking/views/payment_view.dart';
import '../modules/booking/views/finding_driver_view.dart';

// Orders Module Imports
import '../modules/orders/bindings/orders_binding.dart';
import '../modules/orders/views/orders_view.dart';
import '../modules/orders/views/order_details_view.dart';

// Tracking Module Imports
import '../modules/tracking/bindings/tracking_binding.dart';
import '../modules/tracking/views/tracking_view.dart';

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

    // Profile Routes
    GetPage(
      name: Routes.profile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.personalInfo,
      page: () => const EditProfileView(),
      binding: ProfileBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.savedAddresses,
      page: () => const AddressesView(),
      binding: ProfileBinding(),
      transition: Transition.rightToLeft,
    ),

    // Wallet Routes
    GetPage(
      name: Routes.wallet,
      page: () => const WalletView(),
      binding: WalletBinding(),
      transition: Transition.rightToLeft,
    ),

    // Booking Routes
    GetPage(
      name: Routes.createBooking,
      page: () => const CreateBookingView(),
      binding: BookingBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.vehicleSelection,
      page: () => const VehicleSelectionView(),
      binding: BookingBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.payment,
      page: () => const PaymentView(),
      binding: BookingBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.findingDriver,
      page: () => const FindingDriverView(),
      binding: BookingBinding(),
      transition: Transition.fadeIn,
    ),

    // Orders Routes
    GetPage(
      name: Routes.orders,
      page: () => const OrdersView(),
      binding: OrdersBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.orderDetails,
      page: () => const OrderDetailsView(),
      binding: OrdersBinding(),
      transition: Transition.rightToLeft,
    ),

    // Tracking Route
    GetPage(
      name: Routes.tracking,
      page: () => const TrackingView(),
      binding: TrackingBinding(),
      transition: Transition.rightToLeft,
    ),
  ];
}
