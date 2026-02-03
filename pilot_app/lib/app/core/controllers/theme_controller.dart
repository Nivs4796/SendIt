import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// Global theme controller for light/dark mode
class ThemeController extends GetxController {
  final _storage = GetStorage();
  static const _key = 'theme_mode';

  final Rx<ThemeMode> themeMode = ThemeMode.dark.obs;

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  void _loadTheme() {
    final savedMode = _storage.read<String>(_key);
    if (savedMode != null) {
      themeMode.value = ThemeMode.values.firstWhere(
        (e) => e.name == savedMode,
        orElse: () => ThemeMode.dark,
      );
    }
  }

  void toggleTheme() {
    themeMode.value = themeMode.value == ThemeMode.dark 
        ? ThemeMode.light 
        : ThemeMode.dark;
    _storage.write(_key, themeMode.value.name);
  }

  void setThemeMode(ThemeMode mode) {
    themeMode.value = mode;
    _storage.write(_key, mode.name);
  }
}
