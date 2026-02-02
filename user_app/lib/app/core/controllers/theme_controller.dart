import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import '../../services/storage_service.dart';

/// Controller for managing app theme state
/// Uses GetX for reactive state management and SharedPreferences for persistence
class ThemeController extends GetxController {
  static ThemeController get to => Get.find();

  final StorageService _storage = Get.find<StorageService>();

  /// Observable theme mode - defaults to dark
  final Rx<ThemeMode> themeMode = ThemeMode.dark.obs;

  /// Check if current effective theme is dark
  bool get isDark {
    if (themeMode.value == ThemeMode.system) {
      return SchedulerBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;
    }
    return themeMode.value == ThemeMode.dark;
  }

  /// Check if using system theme
  bool get isSystem => themeMode.value == ThemeMode.system;

  /// Get display name for current theme mode
  String get themeModeName {
    switch (themeMode.value) {
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.system:
        return 'System';
    }
  }

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  /// Load saved theme preference from storage
  void _loadTheme() {
    final savedTheme = _storage.themeMode;
    if (savedTheme.isNotEmpty) {
      themeMode.value = ThemeMode.values.firstWhere(
        (e) => e.name == savedTheme,
        orElse: () => ThemeMode.dark, // Default to dark
      );
    } else {
      themeMode.value = ThemeMode.dark; // Default to dark
    }
  }

  /// Set theme mode and persist
  void setThemeMode(ThemeMode mode) {
    themeMode.value = mode;
    _storage.themeMode = mode.name;
    Get.changeThemeMode(mode);
  }

  /// Toggle between dark and light theme
  void toggleTheme() {
    if (isDark) {
      setThemeMode(ThemeMode.light);
    } else {
      setThemeMode(ThemeMode.dark);
    }
  }

  /// Set to dark theme
  void setDark() => setThemeMode(ThemeMode.dark);

  /// Set to light theme
  void setLight() => setThemeMode(ThemeMode.light);

  /// Set to system theme
  void setSystem() => setThemeMode(ThemeMode.system);

  /// Get icon for current theme mode
  IconData get themeIcon {
    switch (themeMode.value) {
      case ThemeMode.dark:
        return Icons.dark_mode_rounded;
      case ThemeMode.light:
        return Icons.light_mode_rounded;
      case ThemeMode.system:
        return Icons.brightness_auto_rounded;
    }
  }
}
