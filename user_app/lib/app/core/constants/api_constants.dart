import '../config/app_config.dart';

class ApiConstants {
  ApiConstants._();

  // Base URLs - now using AppConfig for environment support
  // Override via: flutter run --dart-define=API_URL=https://your-api.com
  static String get baseUrl => AppConfig.apiUrl;
  static String get socketUrl => AppConfig.socketUrl;

  // Auth Endpoints
  static const String sendOtp = '/auth/user/send-otp';
  static const String verifyOtp = '/auth/user/verify-otp';
  static const String refreshToken = '/auth/refresh-token';

  // User Endpoints
  static const String userProfile = '/users/profile';
  static const String deleteAccount = '/users/account';

  // Address Endpoints
  static const String addresses = '/addresses';

  // Booking Endpoints
  static const String bookings = '/bookings';
  static const String calculatePrice = '/bookings/calculate-price';
  static const String myBookings = '/bookings/my-bookings';

  // Vehicle Endpoints
  static const String vehicleTypes = '/vehicles/types';

  // Wallet Endpoints
  static const String walletBalance = '/wallet/balance';
  static const String walletTransactions = '/wallet/transactions';
  static const String addMoney = '/wallet/add';
  static const String checkBalance = '/wallet/check';

  // Payment Endpoints (Razorpay)
  static const String createPaymentOrder = '/payments/create-order';
  static const String createWalletOrder = '/payments/wallet-order';
  static const String verifyPayment = '/payments/verify';
  static const String verifyWalletPayment = '/payments/wallet-verify';
  static const String paymentStatus = '/payments/status';

  // Coupon Endpoints
  static const String validateCoupon = '/coupons/validate';
  static const String availableCoupons = '/coupons/available';

  // Review Endpoints
  static const String reviews = '/reviews';

  // Upload Endpoints
  static const String uploadAvatar = '/upload/user/avatar';

  // FCM Push Notifications
  static const String fcmRegister = '/fcm/user/register';
  static const String fcmClearToken = '/fcm/user/token';

  // Timeouts
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
}
