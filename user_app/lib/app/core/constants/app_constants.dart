class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'SendIt';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  static const String onboardingKey = 'onboarding_complete';
  static const String themeKey = 'theme_mode';

  // Pagination
  static const int defaultPageSize = 20;

  // OTP
  static const int otpLength = 6;
  static const int otpResendSeconds = 60;

  // Location
  static const double defaultLat = 23.0225; // Ahmedabad
  static const double defaultLng = 72.5714;
  static const double defaultZoom = 15.0;

  // Booking
  static const int maxStops = 5;

  // Validation
  static const int minPhoneLength = 10;
  static const int maxPhoneLength = 10;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;

  // Animation Durations
  static const int shortAnimationDuration = 200;
  static const int mediumAnimationDuration = 400;
  static const int longAnimationDuration = 600;
}

// Enums
enum BookingStatus {
  pending,
  accepted,
  arrivedPickup,
  pickedUp,
  inTransit,
  arrivedDrop,
  delivered,
  cancelled,
}

enum PaymentMethod {
  cash,
  upi,
  card,
  wallet,
  netbanking,
}

enum PaymentStatus {
  pending,
  completed,
  failed,
  refunded,
}

enum PackageType {
  document,
  parcel,
  food,
  grocery,
  medicine,
  fragile,
  other,
}
