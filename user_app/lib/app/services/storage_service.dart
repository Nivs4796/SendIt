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
