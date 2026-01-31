/// Route path constants for the SendIt User App
///
/// Usage: Get.toNamed(Routes.login)
abstract class Routes {
  Routes._();

  // ==================== Auth Routes ====================

  /// Splash screen - initial route
  static const splash = '/splash';

  /// Onboarding screens for first-time users
  static const onboarding = '/onboarding';

  /// Phone number login screen
  static const login = '/login';

  /// OTP verification screen
  static const otp = '/otp';

  /// Profile setup for new users
  static const profileSetup = '/profile-setup';

  // ==================== Main Routes ====================

  /// Home screen with map and quick booking
  static const home = '/home';

  /// Main navigation container (bottom nav)
  static const main = '/main';

  // ==================== Booking Flow Routes ====================

  /// Select pickup location
  static const pickupLocation = '/booking/pickup';

  /// Select drop/delivery location
  static const dropLocation = '/booking/drop';

  /// Select vehicle type
  static const vehicleSelection = '/booking/vehicle';

  /// Select type of goods being delivered
  static const goodsType = '/booking/goods-type';

  /// Review booking details before confirmation
  static const reviewBooking = '/booking/review';

  /// Finding driver screen with animation
  static const findingDriver = '/booking/finding-driver';

  /// Live order tracking with map
  static const orderTracking = '/booking/tracking';

  /// Delivery completion and rating screen
  static const deliveryComplete = '/booking/complete';

  // ==================== Orders Routes ====================

  /// Order history list
  static const orders = '/orders';

  /// Order details view
  static const orderDetails = '/orders/details';

  // ==================== Profile Routes ====================

  /// User profile screen
  static const profile = '/profile';

  /// Edit personal information
  static const personalInfo = '/profile/personal-info';

  /// Saved addresses management
  static const savedAddresses = '/profile/addresses';

  /// Wallet and payment methods
  static const wallet = '/wallet';

  /// Notifications list
  static const notifications = '/notifications';

  /// Help and support
  static const helpSupport = '/help';
}
