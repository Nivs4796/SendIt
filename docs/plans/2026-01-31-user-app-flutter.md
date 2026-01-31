# SendIt User App (Flutter) Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a Flutter mobile app for users to book and track deliveries using the SendIt backend API.

**Architecture:** GetX modular architecture with feature-based modules (auth, home, booking, orders, profile). Dio + Retrofit for type-safe API calls. Socket.io for real-time tracking. Google Maps for location selection and driver tracking.

**Tech Stack:** Flutter 3.16+, Dart, GetX (state/navigation/DI), Dio, Retrofit, Google Maps Flutter, Socket.io Client, GetStorage, Hive

---

## Phase 1: Project Setup & Core Infrastructure

### Task 1: Create Flutter Project

**Files:**
- Create: `user_app/` (Flutter project root)
- Create: `user_app/pubspec.yaml`
- Create: `user_app/lib/main.dart`

**Step 1: Create Flutter project**

Run:
```bash
cd /Users/sotsys386/Nirav/claude_projects/SendIt
flutter create user_app --org com.sendit --project-name sendit_user
cd user_app
```

Expected: Flutter project created with default structure

**Step 2: Verify project runs**

Run:
```bash
cd /Users/sotsys386/Nirav/claude_projects/SendIt/user_app
flutter pub get
flutter analyze
```

Expected: No analysis issues

**Step 3: Commit**

```bash
git add user_app/
git commit -m "feat(user-app): initialize Flutter project"
```

---

### Task 2: Configure Dependencies

**Files:**
- Modify: `user_app/pubspec.yaml`

**Step 1: Update pubspec.yaml with all dependencies**

```yaml
name: sendit_user
description: SendIt User App - Book and track deliveries
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.2.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # State Management & Navigation
  get: ^4.6.6

  # Networking
  dio: ^5.4.0
  retrofit: ^4.1.0
  json_annotation: ^4.8.1

  # Local Storage
  get_storage: ^2.1.1
  hive: ^2.2.3
  hive_flutter: ^1.1.0

  # Maps & Location
  google_maps_flutter: ^2.5.3
  geolocator: ^11.0.0
  geocoding: ^3.0.0

  # Real-time
  socket_io_client: ^2.0.3+1

  # UI Components
  flutter_svg: ^2.0.9
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0
  pinput: ^3.0.1
  flutter_spinkit: ^5.2.0

  # Utils
  intl: ^0.19.0
  url_launcher: ^6.2.4
  share_plus: ^7.2.2
  permission_handler: ^11.3.0
  connectivity_plus: ^5.0.2

  # Icons
  cupertino_icons: ^1.0.6
  flutter_iconly: ^1.0.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  retrofit_generator: ^8.1.0
  build_runner: ^2.4.8
  json_serializable: ^6.7.1
  hive_generator: ^2.0.1

flutter:
  uses-material-design: true

  assets:
    - assets/images/
    - assets/icons/
    - assets/animations/

  fonts:
    - family: Poppins
      fonts:
        - asset: assets/fonts/Poppins-Regular.ttf
        - asset: assets/fonts/Poppins-Medium.ttf
          weight: 500
        - asset: assets/fonts/Poppins-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Poppins-Bold.ttf
          weight: 700
```

**Step 2: Create asset directories**

Run:
```bash
cd /Users/sotsys386/Nirav/claude_projects/SendIt/user_app
mkdir -p assets/images assets/icons assets/animations assets/fonts
touch assets/images/.gitkeep assets/icons/.gitkeep assets/animations/.gitkeep assets/fonts/.gitkeep
```

**Step 3: Install dependencies**

Run:
```bash
flutter pub get
```

Expected: All packages resolved successfully

**Step 4: Commit**

```bash
git add user_app/pubspec.yaml user_app/assets/
git commit -m "feat(user-app): add project dependencies and assets structure"
```

---

### Task 3: Create Project Structure

**Files:**
- Create: `user_app/lib/app/` directory structure
- Create: Multiple directories and placeholder files

**Step 1: Create GetX modular folder structure**

Run:
```bash
cd /Users/sotsys386/Nirav/claude_projects/SendIt/user_app/lib

# Remove default files
rm -f main.dart

# Create app structure
mkdir -p app/core/theme
mkdir -p app/core/constants
mkdir -p app/core/utils
mkdir -p app/core/widgets
mkdir -p app/data/models
mkdir -p app/data/providers
mkdir -p app/data/repositories
mkdir -p app/modules/auth/bindings
mkdir -p app/modules/auth/controllers
mkdir -p app/modules/auth/views
mkdir -p app/modules/home/bindings
mkdir -p app/modules/home/controllers
mkdir -p app/modules/home/views
mkdir -p app/modules/booking/bindings
mkdir -p app/modules/booking/controllers
mkdir -p app/modules/booking/views
mkdir -p app/modules/orders/bindings
mkdir -p app/modules/orders/controllers
mkdir -p app/modules/orders/views
mkdir -p app/modules/profile/bindings
mkdir -p app/modules/profile/controllers
mkdir -p app/modules/profile/views
mkdir -p app/routes
mkdir -p app/services
```

**Step 2: Create main.dart**

Create: `user_app/lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app/core/theme/app_theme.dart';
import 'app/routes/app_pages.dart';
import 'app/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize GetStorage
  await GetStorage.init();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize services
  await initServices();

  runApp(const SendItApp());
}

Future<void> initServices() async {
  // Initialize storage service
  await Get.putAsync(() => StorageService().init());
}

class SendItApp extends StatelessWidget {
  const SendItApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SendIt',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      defaultTransition: Transition.cupertino,
    );
  }
}
```

**Step 3: Commit**

```bash
git add user_app/lib/
git commit -m "feat(user-app): create GetX modular project structure"
```

---

### Task 4: Create Theme & Constants

**Files:**
- Create: `user_app/lib/app/core/theme/app_theme.dart`
- Create: `user_app/lib/app/core/theme/app_colors.dart`
- Create: `user_app/lib/app/core/theme/app_text_styles.dart`
- Create: `user_app/lib/app/core/constants/api_constants.dart`
- Create: `user_app/lib/app/core/constants/app_constants.dart`

**Step 1: Create app_colors.dart**

Create: `user_app/lib/app/core/theme/app_colors.dart`

```dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF9D97FF);
  static const Color primaryDark = Color(0xFF4A42DB);

  // Secondary Colors
  static const Color secondary = Color(0xFFFF6B6B);
  static const Color secondaryLight = Color(0xFFFF9B9B);
  static const Color secondaryDark = Color(0xFFCC5555);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFFFC107);
  static const Color warningLight = Color(0xFFFFF8E1);
  static const Color error = Color(0xFFF44336);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFFE3F2FD);

  // Background Colors
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textDisabled = Color(0xFFE0E0E0);

  // Border Colors
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderLight = Color(0xFFF5F5F5);

  // Status Colors for Orders
  static const Color statusPending = Color(0xFFFFA726);
  static const Color statusAccepted = Color(0xFF42A5F5);
  static const Color statusPickedUp = Color(0xFF7E57C2);
  static const Color statusInTransit = Color(0xFF26A69A);
  static const Color statusDelivered = Color(0xFF66BB6A);
  static const Color statusCancelled = Color(0xFFEF5350);

  // Vehicle Type Colors
  static const Color vehicleCycle = Color(0xFF4CAF50);
  static const Color vehicleBike = Color(0xFF2196F3);
  static const Color vehicleAuto = Color(0xFFFF9800);
  static const Color vehicleTruck = Color(0xFF9C27B0);
}
```

**Step 2: Create app_text_styles.dart**

Create: `user_app/lib/app/core/theme/app_text_styles.dart`

```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const String fontFamily = 'Poppins';

  // Headings
  static const TextStyle h1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle h4 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  // Body Text
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  // Labels
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // Button Text
  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    height: 1.2,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    height: 1.2,
  );

  // Caption
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // Price
  static const TextStyle price = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle priceSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.2,
  );
}
```

**Step 3: Create app_theme.dart**

Create: `user_app/lib/app/core/theme/app_theme.dart`

```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: AppTextStyles.fontFamily,

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryLight,
        secondary: AppColors.secondary,
        secondaryContainer: AppColors.secondaryLight,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.textPrimary,
        onError: AppColors.white,
      ),

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: AppTextStyles.h4,
      ),

      // Card Theme
      cardTheme: CardTheme(
        elevation: 2,
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTextStyles.button.copyWith(color: AppColors.primary),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.labelLarge,
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.grey100,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
        labelStyle: AppTextStyles.labelMedium,
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.grey500,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static ThemeData get darkTheme {
    // For now, return light theme. Dark theme can be implemented later.
    return lightTheme;
  }
}
```

**Step 4: Create api_constants.dart**

Create: `user_app/lib/app/core/constants/api_constants.dart`

```dart
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
```

**Step 5: Create app_constants.dart**

Create: `user_app/lib/app/core/constants/app_constants.dart`

```dart
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
```

**Step 6: Commit**

```bash
git add user_app/lib/app/core/
git commit -m "feat(user-app): add theme, colors, text styles, and constants"
```

---

### Task 5: Create Storage Service

**Files:**
- Create: `user_app/lib/app/services/storage_service.dart`

**Step 1: Create storage_service.dart**

Create: `user_app/lib/app/services/storage_service.dart`

```dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../core/constants/app_constants.dart';

class StorageService extends GetxService {
  late GetStorage _box;

  Future<StorageService> init() async {
    _box = GetStorage();
    return this;
  }

  // Token Management
  String? get token => _box.read(AppConstants.tokenKey);

  set token(String? value) {
    if (value != null) {
      _box.write(AppConstants.tokenKey, value);
    } else {
      _box.remove(AppConstants.tokenKey);
    }
  }

  String? get refreshToken => _box.read(AppConstants.refreshTokenKey);

  set refreshToken(String? value) {
    if (value != null) {
      _box.write(AppConstants.refreshTokenKey, value);
    } else {
      _box.remove(AppConstants.refreshTokenKey);
    }
  }

  bool get isLoggedIn => token != null;

  // User Data
  Map<String, dynamic>? get user {
    final data = _box.read(AppConstants.userKey);
    if (data != null) {
      return json.decode(data);
    }
    return null;
  }

  set user(Map<String, dynamic>? value) {
    if (value != null) {
      _box.write(AppConstants.userKey, json.encode(value));
    } else {
      _box.remove(AppConstants.userKey);
    }
  }

  // Onboarding
  bool get hasCompletedOnboarding => _box.read(AppConstants.onboardingKey) ?? false;

  set hasCompletedOnboarding(bool value) {
    _box.write(AppConstants.onboardingKey, value);
  }

  // Theme
  String get themeMode => _box.read(AppConstants.themeKey) ?? 'light';

  set themeMode(String value) {
    _box.write(AppConstants.themeKey, value);
  }

  // Clear All Data (Logout)
  Future<void> clearAll() async {
    await _box.erase();
  }

  // Clear Auth Data Only
  void clearAuth() {
    _box.remove(AppConstants.tokenKey);
    _box.remove(AppConstants.refreshTokenKey);
    _box.remove(AppConstants.userKey);
  }

  // Generic Read/Write
  T? read<T>(String key) => _box.read<T>(key);

  Future<void> write(String key, dynamic value) async {
    await _box.write(key, value);
  }

  Future<void> remove(String key) async {
    await _box.remove(key);
  }
}
```

**Step 2: Commit**

```bash
git add user_app/lib/app/services/storage_service.dart
git commit -m "feat(user-app): add storage service for local data persistence"
```

---

### Task 6: Create API Client with Dio

**Files:**
- Create: `user_app/lib/app/data/providers/api_client.dart`
- Create: `user_app/lib/app/data/providers/api_exceptions.dart`

**Step 1: Create api_exceptions.dart**

Create: `user_app/lib/app/data/providers/api_exceptions.dart`

```dart
class ApiException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;
  final dynamic data;

  ApiException({
    required this.message,
    this.code,
    this.statusCode,
    this.data,
  });

  @override
  String toString() => 'ApiException: $message (code: $code, status: $statusCode)';

  factory ApiException.fromResponse(Map<String, dynamic> response, int? statusCode) {
    return ApiException(
      message: response['message'] ?? 'An error occurred',
      code: response['code'],
      statusCode: statusCode,
      data: response['errors'],
    );
  }
}

class NetworkException implements Exception {
  final String message;

  NetworkException([this.message = 'No internet connection']);

  @override
  String toString() => 'NetworkException: $message';
}

class TimeoutException implements Exception {
  final String message;

  TimeoutException([this.message = 'Request timed out']);

  @override
  String toString() => 'TimeoutException: $message';
}

class UnauthorizedException implements Exception {
  final String message;

  UnauthorizedException([this.message = 'Unauthorized access']);

  @override
  String toString() => 'UnauthorizedException: $message';
}
```

**Step 2: Create api_client.dart**

Create: `user_app/lib/app/data/providers/api_client.dart`

```dart
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import '../../core/constants/api_constants.dart';
import '../../services/storage_service.dart';
import 'api_exceptions.dart';

class ApiClient {
  late Dio _dio;
  final StorageService _storage = Get.find<StorageService>();

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeout),
      receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Add auth token if available
        final token = _storage.token;
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (error, handler) async {
        // Handle 401 Unauthorized - Token expired
        if (error.response?.statusCode == 401) {
          // Try to refresh token
          final refreshed = await _refreshToken();
          if (refreshed) {
            // Retry the request
            final retryResponse = await _retry(error.requestOptions);
            return handler.resolve(retryResponse);
          } else {
            // Logout user
            _storage.clearAuth();
            return handler.reject(error);
          }
        }
        return handler.next(error);
      },
    ));

    // Add logging interceptor in debug mode
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = _storage.refreshToken;
      if (refreshToken == null) return false;

      final response = await Dio().post(
        '${ApiConstants.baseUrl}${ApiConstants.refreshToken}',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        _storage.token = response.data['data']['token'];
        _storage.refreshToken = response.data['data']['refreshToken'];
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<Response> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        'Authorization': 'Bearer ${_storage.token}',
      },
    );
    return _dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  // GET Request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST Request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT Request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PATCH Request
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE Request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Multipart Request (for file uploads)
  Future<Response> uploadFile(
    String path, {
    required FormData formData,
    void Function(int, int)? onSendProgress,
  }) async {
    try {
      return await _dio.post(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Error Handler
  Exception _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException();
      case DioExceptionType.connectionError:
        return NetworkException();
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;

        if (statusCode == 401) {
          return UnauthorizedException();
        }

        if (data is Map<String, dynamic>) {
          return ApiException.fromResponse(data, statusCode);
        }

        return ApiException(
          message: 'Server error occurred',
          statusCode: statusCode,
        );
      case DioExceptionType.cancel:
        return ApiException(message: 'Request cancelled');
      default:
        return ApiException(message: error.message ?? 'An error occurred');
    }
  }
}
```

**Step 3: Commit**

```bash
git add user_app/lib/app/data/providers/
git commit -m "feat(user-app): add Dio API client with interceptors and error handling"
```

---

### Task 7: Create Data Models

**Files:**
- Create: `user_app/lib/app/data/models/user_model.dart`
- Create: `user_app/lib/app/data/models/address_model.dart`
- Create: `user_app/lib/app/data/models/booking_model.dart`
- Create: `user_app/lib/app/data/models/vehicle_type_model.dart`
- Create: `user_app/lib/app/data/models/wallet_model.dart`
- Create: `user_app/lib/app/data/models/api_response.dart`

**Step 1: Create api_response.dart**

Create: `user_app/lib/app/data/models/api_response.dart`

```dart
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final String? code;
  final PaginationMeta? meta;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.code,
    this.meta,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'],
      code: json['code'],
      meta: json['meta'] != null
          ? PaginationMeta.fromJson(json['meta'])
          : null,
    );
  }
}

class PaginationMeta {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  PaginationMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      total: json['total'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
    );
  }
}
```

**Step 2: Create user_model.dart**

Create: `user_app/lib/app/data/models/user_model.dart`

```dart
class UserModel {
  final String id;
  final String phone;
  final String? email;
  final String? name;
  final String? avatar;
  final double walletBalance;
  final bool isVerified;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.phone,
    this.email,
    this.name,
    this.avatar,
    this.walletBalance = 0,
    this.isVerified = false,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      phone: json['phone'],
      email: json['email'],
      name: json['name'],
      avatar: json['avatar'],
      walletBalance: (json['walletBalance'] ?? 0).toDouble(),
      isVerified: json['isVerified'] ?? false,
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'email': email,
      'name': name,
      'avatar': avatar,
      'walletBalance': walletBalance,
      'isVerified': isVerified,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? phone,
    String? email,
    String? name,
    String? avatar,
    double? walletBalance,
    bool? isVerified,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      walletBalance: walletBalance ?? this.walletBalance,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
```

**Step 3: Create address_model.dart**

Create: `user_app/lib/app/data/models/address_model.dart`

```dart
class AddressModel {
  final String id;
  final String userId;
  final String label;
  final String address;
  final String? landmark;
  final String city;
  final String state;
  final String pincode;
  final double lat;
  final double lng;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  AddressModel({
    required this.id,
    required this.userId,
    required this.label,
    required this.address,
    this.landmark,
    required this.city,
    required this.state,
    required this.pincode,
    required this.lat,
    required this.lng,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'],
      userId: json['userId'],
      label: json['label'],
      address: json['address'],
      landmark: json['landmark'],
      city: json['city'],
      state: json['state'],
      pincode: json['pincode'],
      lat: (json['lat'] ?? 0).toDouble(),
      lng: (json['lng'] ?? 0).toDouble(),
      isDefault: json['isDefault'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'label': label,
      'address': address,
      'landmark': landmark,
      'city': city,
      'state': state,
      'pincode': pincode,
      'lat': lat,
      'lng': lng,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // For creating new address (without id and timestamps)
  Map<String, dynamic> toCreateJson() {
    return {
      'label': label,
      'address': address,
      'landmark': landmark,
      'city': city,
      'state': state,
      'pincode': pincode,
      'lat': lat,
      'lng': lng,
      'isDefault': isDefault,
    };
  }

  String get shortAddress {
    if (address.length > 40) {
      return '${address.substring(0, 40)}...';
    }
    return address;
  }

  String get fullAddress {
    final parts = [address, landmark, city, state, pincode]
        .where((p) => p != null && p.isNotEmpty)
        .toList();
    return parts.join(', ');
  }
}
```

**Step 4: Create vehicle_type_model.dart**

Create: `user_app/lib/app/data/models/vehicle_type_model.dart`

```dart
class VehicleTypeModel {
  final String id;
  final String name;
  final String? description;
  final String? icon;
  final double maxWeight;
  final double basePrice;
  final double pricePerKm;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  VehicleTypeModel({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    required this.maxWeight,
    required this.basePrice,
    required this.pricePerKm,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VehicleTypeModel.fromJson(Map<String, dynamic> json) {
    return VehicleTypeModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
      maxWeight: (json['maxWeight'] ?? 0).toDouble(),
      basePrice: (json['basePrice'] ?? 0).toDouble(),
      pricePerKm: (json['pricePerKm'] ?? 0).toDouble(),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'maxWeight': maxWeight,
      'basePrice': basePrice,
      'pricePerKm': pricePerKm,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get weightDisplay => '${maxWeight.toStringAsFixed(0)} kg';
  String get basePriceDisplay => '₹${basePrice.toStringAsFixed(0)}';
}
```

**Step 5: Create booking_model.dart**

Create: `user_app/lib/app/data/models/booking_model.dart`

```dart
import 'address_model.dart';
import 'vehicle_type_model.dart';
import '../../core/constants/app_constants.dart';

class BookingModel {
  final String id;
  final String bookingNumber;
  final String userId;
  final String? pilotId;
  final String? vehicleId;
  final String vehicleTypeId;
  final String pickupAddressId;
  final String dropAddressId;
  final PackageType packageType;
  final double? packageWeight;
  final String? packageDescription;
  final double distance;
  final double baseFare;
  final double distanceFare;
  final double taxes;
  final double discount;
  final double totalAmount;
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final BookingStatus status;
  final DateTime? scheduledAt;
  final DateTime? acceptedAt;
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;
  final String? cancelReason;
  final String? pickupOtp;
  final String? deliveryOtp;
  final double? currentLat;
  final double? currentLng;
  final String? deliveryPhoto;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relations
  final AddressModel? pickupAddress;
  final AddressModel? dropAddress;
  final VehicleTypeModel? vehicleType;
  final PilotInfo? pilot;

  BookingModel({
    required this.id,
    required this.bookingNumber,
    required this.userId,
    this.pilotId,
    this.vehicleId,
    required this.vehicleTypeId,
    required this.pickupAddressId,
    required this.dropAddressId,
    this.packageType = PackageType.parcel,
    this.packageWeight,
    this.packageDescription,
    required this.distance,
    required this.baseFare,
    required this.distanceFare,
    this.taxes = 0,
    this.discount = 0,
    required this.totalAmount,
    this.paymentMethod = PaymentMethod.cash,
    this.paymentStatus = PaymentStatus.pending,
    this.status = BookingStatus.pending,
    this.scheduledAt,
    this.acceptedAt,
    this.pickedUpAt,
    this.deliveredAt,
    this.cancelledAt,
    this.cancelReason,
    this.pickupOtp,
    this.deliveryOtp,
    this.currentLat,
    this.currentLng,
    this.deliveryPhoto,
    required this.createdAt,
    required this.updatedAt,
    this.pickupAddress,
    this.dropAddress,
    this.vehicleType,
    this.pilot,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'],
      bookingNumber: json['bookingNumber'],
      userId: json['userId'],
      pilotId: json['pilotId'],
      vehicleId: json['vehicleId'],
      vehicleTypeId: json['vehicleTypeId'],
      pickupAddressId: json['pickupAddressId'],
      dropAddressId: json['dropAddressId'],
      packageType: _parsePackageType(json['packageType']),
      packageWeight: json['packageWeight']?.toDouble(),
      packageDescription: json['packageDescription'],
      distance: (json['distance'] ?? 0).toDouble(),
      baseFare: (json['baseFare'] ?? 0).toDouble(),
      distanceFare: (json['distanceFare'] ?? 0).toDouble(),
      taxes: (json['taxes'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      paymentMethod: _parsePaymentMethod(json['paymentMethod']),
      paymentStatus: _parsePaymentStatus(json['paymentStatus']),
      status: _parseBookingStatus(json['status']),
      scheduledAt: json['scheduledAt'] != null ? DateTime.parse(json['scheduledAt']) : null,
      acceptedAt: json['acceptedAt'] != null ? DateTime.parse(json['acceptedAt']) : null,
      pickedUpAt: json['pickedUpAt'] != null ? DateTime.parse(json['pickedUpAt']) : null,
      deliveredAt: json['deliveredAt'] != null ? DateTime.parse(json['deliveredAt']) : null,
      cancelledAt: json['cancelledAt'] != null ? DateTime.parse(json['cancelledAt']) : null,
      cancelReason: json['cancelReason'],
      pickupOtp: json['pickupOtp'],
      deliveryOtp: json['deliveryOtp'],
      currentLat: json['currentLat']?.toDouble(),
      currentLng: json['currentLng']?.toDouble(),
      deliveryPhoto: json['deliveryPhoto'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      pickupAddress: json['pickupAddress'] != null
          ? AddressModel.fromJson(json['pickupAddress'])
          : null,
      dropAddress: json['dropAddress'] != null
          ? AddressModel.fromJson(json['dropAddress'])
          : null,
      vehicleType: json['vehicleType'] != null
          ? VehicleTypeModel.fromJson(json['vehicleType'])
          : null,
      pilot: json['pilot'] != null
          ? PilotInfo.fromJson(json['pilot'])
          : null,
    );
  }

  static PackageType _parsePackageType(String? value) {
    switch (value?.toUpperCase()) {
      case 'DOCUMENT': return PackageType.document;
      case 'FOOD': return PackageType.food;
      case 'GROCERY': return PackageType.grocery;
      case 'MEDICINE': return PackageType.medicine;
      case 'FRAGILE': return PackageType.fragile;
      case 'OTHER': return PackageType.other;
      default: return PackageType.parcel;
    }
  }

  static PaymentMethod _parsePaymentMethod(String? value) {
    switch (value?.toUpperCase()) {
      case 'UPI': return PaymentMethod.upi;
      case 'CARD': return PaymentMethod.card;
      case 'WALLET': return PaymentMethod.wallet;
      case 'NETBANKING': return PaymentMethod.netbanking;
      default: return PaymentMethod.cash;
    }
  }

  static PaymentStatus _parsePaymentStatus(String? value) {
    switch (value?.toUpperCase()) {
      case 'COMPLETED': return PaymentStatus.completed;
      case 'FAILED': return PaymentStatus.failed;
      case 'REFUNDED': return PaymentStatus.refunded;
      default: return PaymentStatus.pending;
    }
  }

  static BookingStatus _parseBookingStatus(String? value) {
    switch (value?.toUpperCase()) {
      case 'ACCEPTED': return BookingStatus.accepted;
      case 'ARRIVED_PICKUP': return BookingStatus.arrivedPickup;
      case 'PICKED_UP': return BookingStatus.pickedUp;
      case 'IN_TRANSIT': return BookingStatus.inTransit;
      case 'ARRIVED_DROP': return BookingStatus.arrivedDrop;
      case 'DELIVERED': return BookingStatus.delivered;
      case 'CANCELLED': return BookingStatus.cancelled;
      default: return BookingStatus.pending;
    }
  }

  bool get isActive => status != BookingStatus.delivered && status != BookingStatus.cancelled;
  bool get isCompleted => status == BookingStatus.delivered;
  bool get isCancelled => status == BookingStatus.cancelled;

  String get statusDisplay {
    switch (status) {
      case BookingStatus.pending: return 'Pending';
      case BookingStatus.accepted: return 'Accepted';
      case BookingStatus.arrivedPickup: return 'Driver Arrived';
      case BookingStatus.pickedUp: return 'Picked Up';
      case BookingStatus.inTransit: return 'In Transit';
      case BookingStatus.arrivedDrop: return 'Near Destination';
      case BookingStatus.delivered: return 'Delivered';
      case BookingStatus.cancelled: return 'Cancelled';
    }
  }

  String get amountDisplay => '₹${totalAmount.toStringAsFixed(2)}';
}

class PilotInfo {
  final String id;
  final String name;
  final String phone;
  final String? avatar;
  final double rating;
  final String? vehicleNumber;
  final String? vehicleModel;

  PilotInfo({
    required this.id,
    required this.name,
    required this.phone,
    this.avatar,
    this.rating = 0,
    this.vehicleNumber,
    this.vehicleModel,
  });

  factory PilotInfo.fromJson(Map<String, dynamic> json) {
    return PilotInfo(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      avatar: json['avatar'],
      rating: (json['rating'] ?? 0).toDouble(),
      vehicleNumber: json['vehicle']?['registrationNo'],
      vehicleModel: json['vehicle']?['model'],
    );
  }
}
```

**Step 6: Create wallet_model.dart**

Create: `user_app/lib/app/data/models/wallet_model.dart`

```dart
class WalletTransactionModel {
  final String id;
  final String userId;
  final WalletTxnType type;
  final double amount;
  final double balanceBefore;
  final double balanceAfter;
  final String? description;
  final String? referenceId;
  final String? referenceType;
  final WalletTxnStatus status;
  final DateTime createdAt;

  WalletTransactionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.balanceBefore,
    required this.balanceAfter,
    this.description,
    this.referenceId,
    this.referenceType,
    this.status = WalletTxnStatus.completed,
    required this.createdAt,
  });

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    return WalletTransactionModel(
      id: json['id'],
      userId: json['userId'],
      type: json['type'] == 'CREDIT' ? WalletTxnType.credit : WalletTxnType.debit,
      amount: (json['amount'] ?? 0).toDouble(),
      balanceBefore: (json['balanceBefore'] ?? 0).toDouble(),
      balanceAfter: (json['balanceAfter'] ?? 0).toDouble(),
      description: json['description'],
      referenceId: json['referenceId'],
      referenceType: json['referenceType'],
      status: _parseStatus(json['status']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  static WalletTxnStatus _parseStatus(String? value) {
    switch (value?.toUpperCase()) {
      case 'PENDING': return WalletTxnStatus.pending;
      case 'FAILED': return WalletTxnStatus.failed;
      case 'REVERSED': return WalletTxnStatus.reversed;
      default: return WalletTxnStatus.completed;
    }
  }

  bool get isCredit => type == WalletTxnType.credit;
  String get amountDisplay => '${isCredit ? '+' : '-'}₹${amount.toStringAsFixed(2)}';
}

enum WalletTxnType { credit, debit }
enum WalletTxnStatus { pending, completed, failed, reversed }
```

**Step 7: Commit**

```bash
git add user_app/lib/app/data/models/
git commit -m "feat(user-app): add data models for User, Address, Booking, VehicleType, Wallet"
```

---

### Task 8: Create Routes Configuration

**Files:**
- Create: `user_app/lib/app/routes/app_routes.dart`
- Create: `user_app/lib/app/routes/app_pages.dart`

**Step 1: Create app_routes.dart**

Create: `user_app/lib/app/routes/app_routes.dart`

```dart
abstract class Routes {
  Routes._();

  // Auth
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const otp = '/otp';
  static const profileSetup = '/profile-setup';

  // Main
  static const home = '/home';
  static const main = '/main';

  // Booking
  static const pickupLocation = '/booking/pickup';
  static const dropLocation = '/booking/drop';
  static const vehicleSelection = '/booking/vehicle';
  static const goodsType = '/booking/goods-type';
  static const reviewBooking = '/booking/review';
  static const findingDriver = '/booking/finding-driver';
  static const orderTracking = '/booking/tracking';
  static const deliveryComplete = '/booking/complete';

  // Orders
  static const orders = '/orders';
  static const orderDetails = '/orders/details';

  // Profile
  static const profile = '/profile';
  static const personalInfo = '/profile/personal-info';
  static const savedAddresses = '/profile/addresses';
  static const wallet = '/wallet';
  static const notifications = '/notifications';
  static const helpSupport = '/help';
}
```

**Step 2: Create app_pages.dart**

Create: `user_app/lib/app/routes/app_pages.dart`

```dart
import 'package:get/get.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/splash_view.dart';
import '../modules/auth/views/onboarding_view.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/otp_view.dart';
import '../modules/auth/views/profile_setup_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/home/views/main_view.dart';
import '../modules/booking/bindings/booking_binding.dart';
import '../modules/booking/views/pickup_location_view.dart';
import '../modules/booking/views/drop_location_view.dart';
import '../modules/booking/views/vehicle_selection_view.dart';
import '../modules/booking/views/goods_type_view.dart';
import '../modules/booking/views/review_booking_view.dart';
import '../modules/booking/views/finding_driver_view.dart';
import '../modules/booking/views/order_tracking_view.dart';
import '../modules/booking/views/delivery_complete_view.dart';
import '../modules/orders/bindings/orders_binding.dart';
import '../modules/orders/views/orders_view.dart';
import '../modules/orders/views/order_details_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/profile/views/personal_info_view.dart';
import '../modules/profile/views/saved_addresses_view.dart';
import '../modules/profile/views/wallet_view.dart';
import '../modules/profile/views/notifications_view.dart';
import '../modules/profile/views/help_support_view.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.splash;

  static final routes = [
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
    ),
    GetPage(
      name: Routes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.otp,
      page: () => const OtpView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.profileSetup,
      page: () => const ProfileSetupView(),
      binding: AuthBinding(),
    ),

    // Main Routes
    GetPage(
      name: Routes.main,
      page: () => const MainView(),
      bindings: [
        HomeBinding(),
        OrdersBinding(),
        ProfileBinding(),
      ],
    ),
    GetPage(
      name: Routes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),

    // Booking Routes
    GetPage(
      name: Routes.pickupLocation,
      page: () => const PickupLocationView(),
      binding: BookingBinding(),
    ),
    GetPage(
      name: Routes.dropLocation,
      page: () => const DropLocationView(),
      binding: BookingBinding(),
    ),
    GetPage(
      name: Routes.vehicleSelection,
      page: () => const VehicleSelectionView(),
      binding: BookingBinding(),
    ),
    GetPage(
      name: Routes.goodsType,
      page: () => const GoodsTypeView(),
      binding: BookingBinding(),
    ),
    GetPage(
      name: Routes.reviewBooking,
      page: () => const ReviewBookingView(),
      binding: BookingBinding(),
    ),
    GetPage(
      name: Routes.findingDriver,
      page: () => const FindingDriverView(),
      binding: BookingBinding(),
    ),
    GetPage(
      name: Routes.orderTracking,
      page: () => const OrderTrackingView(),
      binding: BookingBinding(),
    ),
    GetPage(
      name: Routes.deliveryComplete,
      page: () => const DeliveryCompleteView(),
      binding: BookingBinding(),
    ),

    // Orders Routes
    GetPage(
      name: Routes.orders,
      page: () => const OrdersView(),
      binding: OrdersBinding(),
    ),
    GetPage(
      name: Routes.orderDetails,
      page: () => const OrderDetailsView(),
      binding: OrdersBinding(),
    ),

    // Profile Routes
    GetPage(
      name: Routes.profile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: Routes.personalInfo,
      page: () => const PersonalInfoView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: Routes.savedAddresses,
      page: () => const SavedAddressesView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: Routes.wallet,
      page: () => const WalletView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: Routes.notifications,
      page: () => const NotificationsView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: Routes.helpSupport,
      page: () => const HelpSupportView(),
      binding: ProfileBinding(),
    ),
  ];
}
```

**Step 3: Commit**

```bash
git add user_app/lib/app/routes/
git commit -m "feat(user-app): add GetX routing configuration with all app routes"
```

---

## Phase 2: Authentication Module

### Task 9: Create Auth Repository & Controller

**Files:**
- Create: `user_app/lib/app/data/repositories/auth_repository.dart`
- Create: `user_app/lib/app/modules/auth/controllers/auth_controller.dart`
- Create: `user_app/lib/app/modules/auth/bindings/auth_binding.dart`

**Step 1: Create auth_repository.dart**

Create: `user_app/lib/app/data/repositories/auth_repository.dart`

```dart
import 'package:get/get.dart';
import '../models/user_model.dart';
import '../models/api_response.dart';
import '../providers/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../../services/storage_service.dart';

class AuthRepository {
  final ApiClient _apiClient = ApiClient();
  final StorageService _storage = Get.find<StorageService>();

  Future<ApiResponse> sendOtp(String phone) async {
    final response = await _apiClient.post(
      ApiConstants.sendOtp,
      data: {'phone': phone},
    );
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse<UserModel>> verifyOtp(String phone, String otp) async {
    final response = await _apiClient.post(
      ApiConstants.verifyOtp,
      data: {'phone': phone, 'otp': otp},
    );

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (data) => data as Map<String, dynamic>,
    );

    if (apiResponse.success && apiResponse.data != null) {
      // Store tokens
      _storage.token = apiResponse.data!['token'];
      _storage.refreshToken = apiResponse.data!['refreshToken'];

      // Parse and store user
      final user = UserModel.fromJson(apiResponse.data!['user']);
      _storage.user = user.toJson();

      return ApiResponse(
        success: true,
        message: apiResponse.message,
        data: user,
      );
    }

    return ApiResponse(
      success: false,
      message: apiResponse.message ?? 'Verification failed',
      code: apiResponse.code,
    );
  }

  Future<ApiResponse<UserModel>> getProfile() async {
    final response = await _apiClient.get(ApiConstants.userProfile);
    return ApiResponse<UserModel>.fromJson(
      response.data,
      (data) => UserModel.fromJson(data),
    );
  }

  Future<ApiResponse<UserModel>> updateProfile({
    String? name,
    String? email,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;

    final response = await _apiClient.patch(
      ApiConstants.userProfile,
      data: data,
    );

    final apiResponse = ApiResponse<UserModel>.fromJson(
      response.data,
      (data) => UserModel.fromJson(data),
    );

    if (apiResponse.success && apiResponse.data != null) {
      _storage.user = apiResponse.data!.toJson();
    }

    return apiResponse;
  }

  void logout() {
    _storage.clearAuth();
  }

  bool get isLoggedIn => _storage.isLoggedIn;

  UserModel? get currentUser {
    final userData = _storage.user;
    if (userData != null) {
      return UserModel.fromJson(userData);
    }
    return null;
  }
}
```

**Step 2: Create auth_controller.dart**

Create: `user_app/lib/app/modules/auth/controllers/auth_controller.dart`

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/providers/api_exceptions.dart';
import '../../../core/constants/app_constants.dart';
import '../../../routes/app_routes.dart';
import '../../../services/storage_service.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();
  final StorageService _storage = Get.find<StorageService>();

  // Observable state
  final isLoading = false.obs;
  final phone = ''.obs;
  final otp = ''.obs;
  final name = ''.obs;
  final email = ''.obs;
  final errorMessage = ''.obs;

  // OTP Timer
  final canResendOtp = false.obs;
  final resendSeconds = AppConstants.otpResendSeconds.obs;
  Timer? _resendTimer;

  // Current user
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  @override
  void onInit() {
    super.onInit();
    _loadCurrentUser();
  }

  @override
  void onClose() {
    _resendTimer?.cancel();
    super.onClose();
  }

  void _loadCurrentUser() {
    currentUser.value = _authRepository.currentUser;
  }

  // Check auth state and navigate accordingly
  Future<void> checkAuthState() async {
    await Future.delayed(const Duration(seconds: 2)); // Splash delay

    if (!_storage.hasCompletedOnboarding) {
      Get.offAllNamed(Routes.onboarding);
    } else if (_authRepository.isLoggedIn) {
      _loadCurrentUser();
      Get.offAllNamed(Routes.main);
    } else {
      Get.offAllNamed(Routes.login);
    }
  }

  // Complete onboarding
  void completeOnboarding() {
    _storage.hasCompletedOnboarding = true;
    Get.offAllNamed(Routes.login);
  }

  // Send OTP
  Future<void> sendOtp() async {
    if (phone.value.length != AppConstants.minPhoneLength) {
      errorMessage.value = 'Please enter a valid 10-digit phone number';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _authRepository.sendOtp(phone.value);

      if (response.success) {
        Get.toNamed(Routes.otp);
        _startResendTimer();
      } else {
        errorMessage.value = response.message ?? 'Failed to send OTP';
      }
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } on NetworkException {
      errorMessage.value = 'No internet connection';
    } catch (e) {
      errorMessage.value = 'Something went wrong';
    } finally {
      isLoading.value = false;
    }
  }

  // Verify OTP
  Future<void> verifyOtp() async {
    if (otp.value.length != AppConstants.otpLength) {
      errorMessage.value = 'Please enter the complete OTP';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _authRepository.verifyOtp(phone.value, otp.value);

      if (response.success && response.data != null) {
        currentUser.value = response.data;

        // Check if profile is complete
        if (response.data!.name == null || response.data!.name!.isEmpty) {
          Get.offAllNamed(Routes.profileSetup);
        } else {
          Get.offAllNamed(Routes.main);
        }
      } else {
        errorMessage.value = response.message ?? 'Invalid OTP';
      }
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } on NetworkException {
      errorMessage.value = 'No internet connection';
    } catch (e) {
      errorMessage.value = 'Something went wrong';
    } finally {
      isLoading.value = false;
    }
  }

  // Resend OTP
  Future<void> resendOtp() async {
    if (!canResendOtp.value) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _authRepository.sendOtp(phone.value);

      if (response.success) {
        _startResendTimer();
        Get.snackbar(
          'OTP Sent',
          'A new OTP has been sent to your phone',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        errorMessage.value = response.message ?? 'Failed to resend OTP';
      }
    } catch (e) {
      errorMessage.value = 'Something went wrong';
    } finally {
      isLoading.value = false;
    }
  }

  void _startResendTimer() {
    canResendOtp.value = false;
    resendSeconds.value = AppConstants.otpResendSeconds;

    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendSeconds.value > 0) {
        resendSeconds.value--;
      } else {
        canResendOtp.value = true;
        timer.cancel();
      }
    });
  }

  // Update Profile
  Future<void> updateProfile() async {
    if (name.value.length < AppConstants.minNameLength) {
      errorMessage.value = 'Name must be at least ${AppConstants.minNameLength} characters';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _authRepository.updateProfile(
        name: name.value,
        email: email.value.isNotEmpty ? email.value : null,
      );

      if (response.success && response.data != null) {
        currentUser.value = response.data;
        Get.offAllNamed(Routes.main);
      } else {
        errorMessage.value = response.message ?? 'Failed to update profile';
      }
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'Something went wrong';
    } finally {
      isLoading.value = false;
    }
  }

  // Logout
  void logout() {
    _authRepository.logout();
    currentUser.value = null;
    phone.value = '';
    otp.value = '';
    name.value = '';
    email.value = '';
    Get.offAllNamed(Routes.login);
  }

  // Clear error
  void clearError() {
    errorMessage.value = '';
  }
}
```

**Step 3: Create auth_binding.dart**

Create: `user_app/lib/app/modules/auth/bindings/auth_binding.dart`

```dart
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
  }
}
```

**Step 4: Commit**

```bash
git add user_app/lib/app/data/repositories/auth_repository.dart
git add user_app/lib/app/modules/auth/
git commit -m "feat(user-app): add auth repository, controller, and binding"
```

---

### Task 10: Create Auth Views (Splash, Onboarding, Login, OTP, Profile Setup)

**Files:**
- Create: `user_app/lib/app/modules/auth/views/splash_view.dart`
- Create: `user_app/lib/app/modules/auth/views/onboarding_view.dart`
- Create: `user_app/lib/app/modules/auth/views/login_view.dart`
- Create: `user_app/lib/app/modules/auth/views/otp_view.dart`
- Create: `user_app/lib/app/modules/auth/views/profile_setup_view.dart`

**Step 1: Create splash_view.dart**

Create: `user_app/lib/app/modules/auth/views/splash_view.dart`

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../controllers/auth_controller.dart';

class SplashView extends GetView<AuthController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    // Trigger auth check when view is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.checkAuthState();
    });

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.local_shipping_rounded,
                size: 60,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            // App Name
            Text(
              'SendIt',
              style: AppTextStyles.h1.copyWith(
                color: AppColors.white,
                fontSize: 36,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Deliver with Ease',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 48),
            // Loading indicator
            const SpinKitThreeBounce(
              color: AppColors.white,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
```

**Step 2: Create onboarding_view.dart**

Create: `user_app/lib/app/modules/auth/views/onboarding_view.dart`

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../controllers/auth_controller.dart';

class OnboardingView extends GetView<AuthController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final pageController = PageController();
    final currentPage = 0.obs;

    final pages = [
      _OnboardingPage(
        icon: Icons.local_shipping_rounded,
        title: 'Fast Delivery',
        description: 'Get your packages delivered quickly and safely with our reliable delivery network.',
        color: AppColors.primary,
      ),
      _OnboardingPage(
        icon: Icons.location_on_rounded,
        title: 'Real-Time Tracking',
        description: 'Track your delivery in real-time and know exactly when it will arrive.',
        color: AppColors.secondary,
      ),
      _OnboardingPage(
        icon: Icons.security_rounded,
        title: 'Safe & Secure',
        description: 'Your packages are handled with care and fully insured during transit.',
        color: AppColors.success,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: controller.completeOnboarding,
                child: Text(
                  'Skip',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            // Pages
            Expanded(
              child: PageView.builder(
                controller: pageController,
                itemCount: pages.length,
                onPageChanged: (index) => currentPage.value = index,
                itemBuilder: (context, index) => pages[index],
              ),
            ),
            // Indicators
            Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: currentPage.value == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: currentPage.value == index
                        ? AppColors.primary
                        : AppColors.grey300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            )),
            const SizedBox(height: 32),
            // Button
            Padding(
              padding: const EdgeInsets.all(24),
              child: Obx(() => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (currentPage.value < pages.length - 1) {
                      pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      controller.completeOnboarding();
                    }
                  },
                  child: Text(
                    currentPage.value < pages.length - 1
                        ? 'Next'
                        : 'Get Started',
                  ),
                ),
              )),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 80,
              color: color,
            ),
          ),
          const SizedBox(height: 48),
          Text(
            title,
            style: AppTextStyles.h2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
```

**Step 3: Create login_view.dart**

Create: `user_app/lib/app/modules/auth/views/login_view.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../controllers/auth_controller.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final phoneController = TextEditingController();

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              // Logo
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.local_shipping_rounded,
                  size: 32,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 32),
              // Title
              Text(
                'Welcome to SendIt',
                style: AppTextStyles.h2,
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your phone number to continue',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 40),
              // Phone Input
              Container(
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    // Country Code
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: const BoxDecoration(
                        border: Border(
                          right: BorderSide(color: AppColors.grey300),
                        ),
                      ),
                      child: Text(
                        '+91',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    // Phone Number
                    Expanded(
                      child: TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        maxLength: AppConstants.maxPhoneLength,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: AppTextStyles.bodyLarge,
                        decoration: const InputDecoration(
                          hintText: 'Phone Number',
                          counterText: '',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        onChanged: (value) => controller.phone.value = value,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Error Message
              Obx(() => controller.errorMessage.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        controller.errorMessage.value,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    )
                  : const SizedBox.shrink()),
              const Spacer(),
              // Terms
              Text(
                'By continuing, you agree to our Terms of Service and Privacy Policy',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Submit Button
              Obx(() => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.sendOtp,
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : const Text('Send OTP'),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
```

**Step 4: Create otp_view.dart**

Create: `user_app/lib/app/modules/auth/views/otp_view.dart`

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../controllers/auth_controller.dart';

class OtpView extends GetView<AuthController> {
  const OtpView({super.key});

  @override
  Widget build(BuildContext context) {
    final pinController = TextEditingController();

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: AppTextStyles.h3,
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(12),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary, width: 2),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Verification Code',
                style: AppTextStyles.h2,
              ),
              const SizedBox(height: 8),
              Obx(() => Text(
                'We have sent the code to +91 ${controller.phone.value}',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              )),
              const SizedBox(height: 40),
              // OTP Input
              Center(
                child: Pinput(
                  controller: pinController,
                  length: AppConstants.otpLength,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: focusedPinTheme,
                  onCompleted: (pin) {
                    controller.otp.value = pin;
                    controller.verifyOtp();
                  },
                  onChanged: (value) => controller.otp.value = value,
                ),
              ),
              const SizedBox(height: 24),
              // Error Message
              Obx(() => controller.errorMessage.isNotEmpty
                  ? Center(
                      child: Text(
                        controller.errorMessage.value,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    )
                  : const SizedBox.shrink()),
              const SizedBox(height: 24),
              // Resend OTP
              Center(
                child: Obx(() => controller.canResendOtp.value
                    ? TextButton(
                        onPressed: controller.resendOtp,
                        child: Text(
                          'Resend OTP',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    : Text(
                        'Resend OTP in ${controller.resendSeconds.value}s',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      )),
              ),
              const Spacer(),
              // Verify Button
              Obx(() => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.verifyOtp,
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : const Text('Verify'),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
```

**Step 5: Create profile_setup_view.dart**

Create: `user_app/lib/app/modules/auth/views/profile_setup_view.dart`

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../controllers/auth_controller.dart';

class ProfileSetupView extends GetView<AuthController> {
  const ProfileSetupView({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text('Complete Profile'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tell us about yourself',
                style: AppTextStyles.h3,
              ),
              const SizedBox(height: 8),
              Text(
                'This helps us personalize your experience',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              // Profile Picture
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.grey200,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 50,
                        color: AppColors.grey500,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Name Input
              TextField(
                controller: nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'Enter your name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                onChanged: (value) => controller.name.value = value,
              ),
              const SizedBox(height: 16),
              // Email Input
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email (Optional)',
                  hintText: 'Enter your email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                onChanged: (value) => controller.email.value = value,
              ),
              const SizedBox(height: 16),
              // Error Message
              Obx(() => controller.errorMessage.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        controller.errorMessage.value,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    )
                  : const SizedBox.shrink()),
              const Spacer(),
              // Submit Button
              Obx(() => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.updateProfile,
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : const Text('Continue'),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
```

**Step 6: Commit**

```bash
git add user_app/lib/app/modules/auth/views/
git commit -m "feat(user-app): add auth views - splash, onboarding, login, OTP, profile setup"
```

---

## Summary - Phase 1 & 2 Complete

This plan covers the foundation and authentication module. The remaining phases would include:

**Phase 3: Home Module** (Tasks 11-13)
- Home controller, repository, views
- Main navigation with bottom tabs

**Phase 4: Booking Module** (Tasks 14-22)
- Location selection with Google Maps
- Vehicle selection
- Goods type selection
- Review booking with pricing
- Finding driver with Socket.io
- Order tracking with real-time updates
- Delivery complete with rating

**Phase 5: Orders Module** (Tasks 23-25)
- Orders list with filtering
- Order details view

**Phase 6: Profile Module** (Tasks 26-30)
- Profile view with settings
- Personal info editing
- Saved addresses management
- Wallet view with transactions
- Notifications & Help screens

**Phase 7: Common Widgets & Services** (Tasks 31-35)
- Reusable widgets (buttons, cards, inputs)
- Location service
- Socket service
- Error handling utilities

---

**Total Estimated Tasks:** 35 tasks across 7 phases

Continue to Phase 3?
