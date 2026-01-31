class ApiConstants {
  ApiConstants._();

  // Base URLs
  static const String baseUrl = 'http://localhost:5000/api/v1';
  static const String socketUrl = 'http://localhost:5000';

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
