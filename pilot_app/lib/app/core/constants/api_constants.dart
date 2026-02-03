/// API Constants for Pilot App
class ApiConstants {
  ApiConstants._();

  // Base URLs
  // Use your computer's IP for physical device testing
  // For emulator use: 10.0.2.2 (Android) or localhost (iOS Simulator)
  static const String baseUrl = 'http://172.16.17.55:5000/api/v1';
  static const String socketUrl = 'http://172.16.17.55:5000';

  // ============================================
  // AUTH ENDPOINTS
  // ============================================
  static const String sendOtp = '/auth/pilot/send-otp';
  static const String verifyOtp = '/auth/pilot/verify-otp';
  static const String refreshToken = '/auth/refresh-token';

  // ============================================
  // PILOT ENDPOINTS
  // ============================================
  static const String pilotRegister = '/pilots/register';
  static const String pilotProfile = '/pilots/profile';
  static const String pilotLocation = '/pilots/location';
  static const String pilotStatus = '/pilots/status';
  static const String pilotEarnings = '/pilots/earnings';
  static const String pilotBookings = '/pilots/bookings';

  // ============================================
  // VEHICLE ENDPOINTS
  // ============================================
  static const String vehicles = '/vehicles';
  static const String vehicleTypes = '/vehicles/types';

  // ============================================
  // BOOKING ENDPOINTS
  // ============================================
  static const String bookings = '/bookings';
  static String acceptBooking(String id) => '/bookings/$id/accept';
  static String bookingStatus(String id) => '/bookings/$id/status';
  static String bookingDetails(String id) => '/bookings/$id';

  // ============================================
  // UPLOAD ENDPOINTS
  // ============================================
  static const String uploadImage = '/upload/image';
  static const String uploadDocument = '/upload/document';
  static const String uploadPilotDocuments = '/upload/pilot/documents';
  static const String uploadAvatar = '/upload/pilot/avatar';

  // ============================================
  // WALLET ENDPOINTS
  // ============================================
  static const String walletBalance = '/wallet/pilot/balance';
  static const String walletTransactions = '/wallet/pilot/transactions';
  static const String withdrawRequest = '/wallet/pilot/withdraw';

  // ============================================
  // TIMEOUTS
  // ============================================
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
}
