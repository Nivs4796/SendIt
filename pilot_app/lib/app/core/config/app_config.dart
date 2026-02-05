/// App configuration with environment support
///
/// Usage:
/// 1. For development: Use default values (current IP)
/// 2. For staging: Set via --dart-define or flutter_dotenv
/// 3. For production: Set via --dart-define at build time
///
/// Build commands:
/// - Dev: flutter run
/// - Staging: flutter run --dart-define=ENV=staging --dart-define=API_URL=https://staging-api.sendit.com
/// - Prod: flutter build --dart-define=ENV=production --dart-define=API_URL=https://api.sendit.com
class AppConfig {
  AppConfig._();

  /// Current environment
  static const String environment = String.fromEnvironment(
    'ENV',
    defaultValue: 'development',
  );

  /// API Base URL - override via --dart-define=API_URL=https://your-api.com
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://172.16.17.55:5000/api/v1', // Development default
  );

  /// Socket URL - override via --dart-define=SOCKET_URL=https://your-socket.com
  static const String socketUrl = String.fromEnvironment(
    'SOCKET_URL',
    defaultValue: 'http://172.16.17.55:5000', // Development default
  );

  /// Google Maps API Key - already configured
  static const String googleMapsKey = String.fromEnvironment(
    'GOOGLE_MAPS_KEY',
    defaultValue: '', // Set in AndroidManifest.xml / Info.plist
  );

  /// Razorpay Key (static placeholder - replace at build time)
  static const String razorpayKey = String.fromEnvironment(
    'RAZORPAY_KEY',
    defaultValue: 'rzp_test_PLACEHOLDER', // Placeholder for testing
  );

  /// Check if running in development
  static bool get isDevelopment => environment == 'development';

  /// Check if running in staging
  static bool get isStaging => environment == 'staging';

  /// Check if running in production
  static bool get isProduction => environment == 'production';

  /// Enable debug features
  static bool get enableDebugFeatures => !isProduction;

  /// Enable mock data fallback (development only)
  static bool get enableMockData => isDevelopment;
}
