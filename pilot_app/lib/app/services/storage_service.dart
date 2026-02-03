import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// Storage keys
class StorageKeys {
  static const String token = 'auth_token';
  static const String refreshToken = 'refresh_token';
  static const String pilot = 'pilot_data';
  static const String phone = 'pilot_phone';
  static const String isLoggedIn = 'is_logged_in';
  static const String themeMode = 'theme_mode';
  static const String onboarding = 'onboarding_completed';
  static const String fcmToken = 'fcm_token';
}

/// Local storage service using GetStorage
class StorageService extends GetxService {
  late GetStorage _box;

  Future<StorageService> init() async {
    _box = GetStorage();
    return this;
  }

  // ============================================
  // TOKEN MANAGEMENT
  // ============================================
  String? get token => _box.read(StorageKeys.token);

  set token(String? value) {
    if (value != null) {
      _box.write(StorageKeys.token, value);
    } else {
      _box.remove(StorageKeys.token);
    }
  }

  String? get refreshToken => _box.read(StorageKeys.refreshToken);

  set refreshToken(String? value) {
    if (value != null) {
      _box.write(StorageKeys.refreshToken, value);
    } else {
      _box.remove(StorageKeys.refreshToken);
    }
  }

  bool get isLoggedIn => token != null && token!.isNotEmpty;

  // ============================================
  // PHONE (for registration)
  // ============================================
  String? get phone => _box.read(StorageKeys.phone);

  set phone(String? value) {
    if (value != null) {
      _box.write(StorageKeys.phone, value);
    } else {
      _box.remove(StorageKeys.phone);
    }
  }

  // ============================================
  // PILOT DATA
  // ============================================
  Map<String, dynamic>? get pilot {
    final data = _box.read(StorageKeys.pilot);
    if (data != null && data is String) {
      return json.decode(data);
    }
    return data;
  }

  set pilot(Map<String, dynamic>? value) {
    if (value != null) {
      _box.write(StorageKeys.pilot, json.encode(value));
    } else {
      _box.remove(StorageKeys.pilot);
    }
  }

  // ============================================
  // THEME
  // ============================================
  String get themeMode => _box.read(StorageKeys.themeMode) ?? 'dark';

  set themeMode(String value) {
    _box.write(StorageKeys.themeMode, value);
  }

  // ============================================
  // ONBOARDING
  // ============================================
  bool get hasCompletedOnboarding => _box.read(StorageKeys.onboarding) ?? false;

  set hasCompletedOnboarding(bool value) {
    _box.write(StorageKeys.onboarding, value);
  }

  // ============================================
  // FCM TOKEN
  // ============================================
  String? get fcmToken => _box.read(StorageKeys.fcmToken);

  set fcmToken(String? value) {
    if (value != null) {
      _box.write(StorageKeys.fcmToken, value);
    } else {
      _box.remove(StorageKeys.fcmToken);
    }
  }

  // ============================================
  // CLEAR METHODS
  // ============================================
  
  /// Clear all auth data (on logout)
  void clearAuth() {
    _box.remove(StorageKeys.token);
    _box.remove(StorageKeys.refreshToken);
    _box.remove(StorageKeys.pilot);
  }

  /// Clear all stored data
  Future<void> clearAll() async {
    await _box.erase();
  }

  // ============================================
  // GENERIC READ/WRITE
  // ============================================
  T? read<T>(String key) => _box.read<T>(key);

  Future<void> write(String key, dynamic value) async {
    await _box.write(key, value);
  }

  Future<void> remove(String key) async {
    await _box.remove(key);
  }
}
