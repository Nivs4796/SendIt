import 'package:get/get.dart';
import 'app_routes.dart';

// =============================================================================
// Auth Module Imports (uncomment when module is created)
// =============================================================================
// import '../modules/auth/bindings/auth_binding.dart';
// import '../modules/auth/views/splash_view.dart';
// import '../modules/auth/views/onboarding_view.dart';
// import '../modules/auth/views/login_view.dart';
// import '../modules/auth/views/otp_view.dart';
// import '../modules/auth/views/profile_setup_view.dart';

// =============================================================================
// Home Module Imports (uncomment when module is created)
// =============================================================================
// import '../modules/home/bindings/home_binding.dart';
// import '../modules/home/views/home_view.dart';
// import '../modules/home/views/main_view.dart';

// =============================================================================
// Booking Module Imports (uncomment when module is created)
// =============================================================================
// import '../modules/booking/bindings/booking_binding.dart';
// import '../modules/booking/views/pickup_location_view.dart';
// import '../modules/booking/views/drop_location_view.dart';
// import '../modules/booking/views/vehicle_selection_view.dart';
// import '../modules/booking/views/goods_type_view.dart';
// import '../modules/booking/views/review_booking_view.dart';
// import '../modules/booking/views/finding_driver_view.dart';
// import '../modules/booking/views/order_tracking_view.dart';
// import '../modules/booking/views/delivery_complete_view.dart';

// =============================================================================
// Orders Module Imports (uncomment when module is created)
// =============================================================================
// import '../modules/orders/bindings/orders_binding.dart';
// import '../modules/orders/views/orders_view.dart';
// import '../modules/orders/views/order_details_view.dart';

// =============================================================================
// Profile Module Imports (uncomment when module is created)
// =============================================================================
// import '../modules/profile/bindings/profile_binding.dart';
// import '../modules/profile/views/profile_view.dart';
// import '../modules/profile/views/personal_info_view.dart';
// import '../modules/profile/views/saved_addresses_view.dart';
// import '../modules/profile/views/wallet_view.dart';
// import '../modules/profile/views/notifications_view.dart';
// import '../modules/profile/views/help_support_view.dart';

/// Application page configuration for GetX routing
///
/// Each GetPage defines:
/// - name: Route path from Routes class
/// - page: Widget builder for the view
/// - binding: Dependency injection binding
/// - transition: Page transition animation
class AppPages {
  AppPages._();

  /// Initial route when app starts
  static const initial = Routes.splash;

  /// All application routes
  ///
  /// Routes are organized by module and will be uncommented
  /// as each module is implemented in subsequent tasks.
  static final routes = <GetPage>[
    // =========================================================================
    // Auth Routes
    // =========================================================================
    // GetPage(
    //   name: Routes.splash,
    //   page: () => const SplashView(),
    //   binding: AuthBinding(),
    // ),
    // GetPage(
    //   name: Routes.onboarding,
    //   page: () => const OnboardingView(),
    //   binding: AuthBinding(),
    //   transition: Transition.rightToLeft,
    // ),
    // GetPage(
    //   name: Routes.login,
    //   page: () => const LoginView(),
    //   binding: AuthBinding(),
    //   transition: Transition.rightToLeft,
    // ),
    // GetPage(
    //   name: Routes.otp,
    //   page: () => const OtpView(),
    //   binding: AuthBinding(),
    //   transition: Transition.rightToLeft,
    // ),
    // GetPage(
    //   name: Routes.profileSetup,
    //   page: () => const ProfileSetupView(),
    //   binding: AuthBinding(),
    //   transition: Transition.rightToLeft,
    // ),

    // =========================================================================
    // Main Routes
    // =========================================================================
    // GetPage(
    //   name: Routes.main,
    //   page: () => const MainView(),
    //   binding: HomeBinding(),
    //   transition: Transition.fadeIn,
    // ),
    // GetPage(
    //   name: Routes.home,
    //   page: () => const HomeView(),
    //   binding: HomeBinding(),
    // ),

    // =========================================================================
    // Booking Flow Routes
    // =========================================================================
    // GetPage(
    //   name: Routes.pickupLocation,
    //   page: () => const PickupLocationView(),
    //   binding: BookingBinding(),
    //   transition: Transition.rightToLeft,
    // ),
    // GetPage(
    //   name: Routes.dropLocation,
    //   page: () => const DropLocationView(),
    //   binding: BookingBinding(),
    //   transition: Transition.rightToLeft,
    // ),
    // GetPage(
    //   name: Routes.vehicleSelection,
    //   page: () => const VehicleSelectionView(),
    //   binding: BookingBinding(),
    //   transition: Transition.rightToLeft,
    // ),
    // GetPage(
    //   name: Routes.goodsType,
    //   page: () => const GoodsTypeView(),
    //   binding: BookingBinding(),
    //   transition: Transition.rightToLeft,
    // ),
    // GetPage(
    //   name: Routes.reviewBooking,
    //   page: () => const ReviewBookingView(),
    //   binding: BookingBinding(),
    //   transition: Transition.rightToLeft,
    // ),
    // GetPage(
    //   name: Routes.findingDriver,
    //   page: () => const FindingDriverView(),
    //   binding: BookingBinding(),
    //   transition: Transition.fadeIn,
    // ),
    // GetPage(
    //   name: Routes.orderTracking,
    //   page: () => const OrderTrackingView(),
    //   binding: BookingBinding(),
    //   transition: Transition.fadeIn,
    // ),
    // GetPage(
    //   name: Routes.deliveryComplete,
    //   page: () => const DeliveryCompleteView(),
    //   binding: BookingBinding(),
    //   transition: Transition.fadeIn,
    // ),

    // =========================================================================
    // Orders Routes
    // =========================================================================
    // GetPage(
    //   name: Routes.orders,
    //   page: () => const OrdersView(),
    //   binding: OrdersBinding(),
    //   transition: Transition.rightToLeft,
    // ),
    // GetPage(
    //   name: Routes.orderDetails,
    //   page: () => const OrderDetailsView(),
    //   binding: OrdersBinding(),
    //   transition: Transition.rightToLeft,
    // ),

    // =========================================================================
    // Profile Routes
    // =========================================================================
    // GetPage(
    //   name: Routes.profile,
    //   page: () => const ProfileView(),
    //   binding: ProfileBinding(),
    //   transition: Transition.rightToLeft,
    // ),
    // GetPage(
    //   name: Routes.personalInfo,
    //   page: () => const PersonalInfoView(),
    //   binding: ProfileBinding(),
    //   transition: Transition.rightToLeft,
    // ),
    // GetPage(
    //   name: Routes.savedAddresses,
    //   page: () => const SavedAddressesView(),
    //   binding: ProfileBinding(),
    //   transition: Transition.rightToLeft,
    // ),
    // GetPage(
    //   name: Routes.wallet,
    //   page: () => const WalletView(),
    //   binding: ProfileBinding(),
    //   transition: Transition.rightToLeft,
    // ),
    // GetPage(
    //   name: Routes.notifications,
    //   page: () => const NotificationsView(),
    //   binding: ProfileBinding(),
    //   transition: Transition.rightToLeft,
    // ),
    // GetPage(
    //   name: Routes.helpSupport,
    //   page: () => const HelpSupportView(),
    //   binding: ProfileBinding(),
    //   transition: Transition.rightToLeft,
    // ),
  ];
}
