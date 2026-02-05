import '../config/app_config.dart';

/// API Constants for Pilot App
class ApiConstants {
  ApiConstants._();

  // Base URLs - now using AppConfig for environment support
  // Override via: flutter run --dart-define=API_URL=https://your-api.com
  static String get baseUrl => AppConfig.apiUrl;
  static String get socketUrl => AppConfig.socketUrl;

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
  static const String pilotProfilePhoto = '/pilots/profile/photo';

  // ============================================
  // WALLET ENDPOINTS
  // ============================================
  static const String walletBalance = '/wallet/pilot/balance';
  static const String walletTransactions = '/wallet/pilot/transactions';
  static const String withdrawRequest = '/wallet/pilot/withdraw';

  // ============================================
  // DOCUMENTS ENDPOINTS
  // ============================================
  static const String pilotDocuments = '/pilots/documents';
  static String pilotDocument(String id) => '/pilots/documents/$id';

  // ============================================
  // BANK ACCOUNTS ENDPOINTS
  // ============================================
  static const String bankAccounts = '/pilots/bank-accounts';
  static String bankAccount(String id) => '/pilots/bank-accounts/$id';
  static String setBankPrimary(String id) => '/pilots/bank-accounts/$id/primary';
  static const String ifscLookup = '/utils/ifsc';

  // ============================================
  // NOTIFICATIONS ENDPOINTS
  // ============================================
  static const String notifications = '/pilots/notifications';
  static String notificationRead(String id) => '/pilots/notifications/$id/read';
  static const String notificationSettings = '/pilots/notification-settings';
  static const String markAllNotificationsRead = '/pilots/notifications/read-all';

  // ============================================
  // REWARDS & REFERRALS ENDPOINTS
  // ============================================
  static const String referral = '/pilots/referral';
  static const String rewards = '/pilots/rewards';
  static String claimReward(String id) => '/pilots/rewards/$id/claim';
  static const String achievements = '/pilots/achievements';

  // ============================================
  // SUPPORT ENDPOINTS
  // ============================================
  static const String faqs = '/support/faqs';
  static const String supportTickets = '/support/tickets';
  static const String supportContact = '/support/contact';

  // ============================================
  // JOB HISTORY ENDPOINTS
  // ============================================
  static const String jobHistory = '/pilots/bookings/history';
  static String jobDetails(String id) => '/bookings/$id';

  // ============================================
  // FCM PUSH NOTIFICATIONS
  // ============================================
  static const String fcmRegister = '/fcm/pilot/register';
  static const String fcmClearToken = '/fcm/pilot/token';

  // ============================================
  // TIMEOUTS
  // ============================================
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
}
