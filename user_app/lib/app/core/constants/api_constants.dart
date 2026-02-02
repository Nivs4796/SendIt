class ApiConstants {
  ApiConstants._();

  // Base URLs
  // Use your computer's IP for physical device testing
  // For emulator use: 10.0.2.2 (Android) or localhost (iOS Simulator)
  static const String baseUrl = 'http://172.16.17.55:5000/api/v1';
  static const String socketUrl = 'http://172.16.17.55:5000';

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

  // Coupon Endpoints
  static const String validateCoupon = '/coupons/validate';
  static const String availableCoupons = '/coupons/available';

  // Review Endpoints
  static const String reviews = '/reviews';

  // Upload Endpoints
  static const String uploadAvatar = '/upload/user/avatar';

  // Timeouts
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
}
