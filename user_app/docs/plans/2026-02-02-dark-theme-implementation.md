# Dark Theme Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Implement dark theme (default) with light theme option, using subtle glassmorphism effects and reusable decoration utilities.

**Architecture:** Theme-aware color system with GetX ThemeController, reusable AppDecorations class, and BoxDecoration extensions. Dark theme as default with persistence via GetStorage.

**Tech Stack:** Flutter, GetX, GetStorage

---

## Task 1: Create AppDecorations Class

**Files:**
- Create: `lib/app/core/theme/app_decorations.dart`

**Step 1: Create the decorations utility file**

```dart
import 'package:flutter/material.dart';

/// Reusable BoxDecoration presets for consistent UI styling
/// Supports both light and dark themes with subtle glass effects
class AppDecorations {
  AppDecorations._();

  // ============================================
  // CARD DECORATIONS
  // ============================================

  /// Standard card decoration with subtle shadow
  static BoxDecoration card(bool isDark) {
    return BoxDecoration(
      color: isDark
          ? const Color(0xFF1E293B).withOpacity(0.8)
          : Colors.white.withOpacity(0.95),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isDark
            ? const Color(0xFF34D399).withOpacity(0.15)
            : const Color(0xFF10B981).withOpacity(0.25),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
          blurRadius: isDark ? 16 : 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Elevated card with stronger shadow
  static BoxDecoration cardElevated(bool isDark) {
    return BoxDecoration(
      color: isDark
          ? const Color(0xFF1E293B).withOpacity(0.9)
          : Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: isDark
            ? const Color(0xFF34D399).withOpacity(0.2)
            : const Color(0xFF10B981).withOpacity(0.3),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(isDark ? 0.4 : 0.12),
          blurRadius: isDark ? 24 : 16,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  /// Flat card without shadow
  static BoxDecoration cardFlat(bool isDark) {
    return BoxDecoration(
      color: isDark
          ? const Color(0xFF1E293B).withOpacity(0.6)
          : Colors.white.withOpacity(0.9),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isDark
            ? const Color(0xFF334155)
            : const Color(0xFFE2E8F0),
      ),
    );
  }

  // ============================================
  // INPUT DECORATIONS
  // ============================================

  /// Standard input field decoration
  static BoxDecoration input(bool isDark) {
    return BoxDecoration(
      color: isDark
          ? const Color(0xFF334155).withOpacity(0.6)
          : Colors.white.withOpacity(0.9),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: isDark
            ? const Color(0xFF475569)
            : const Color(0xFF10B981).withOpacity(0.4),
      ),
    );
  }

  /// Focused input field decoration
  static BoxDecoration inputFocused(bool isDark) {
    return BoxDecoration(
      color: isDark
          ? const Color(0xFF334155).withOpacity(0.8)
          : Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: isDark
            ? const Color(0xFF34D399)
            : const Color(0xFF10B981),
        width: 2,
      ),
      boxShadow: [
        BoxShadow(
          color: (isDark ? const Color(0xFF34D399) : const Color(0xFF10B981))
              .withOpacity(0.15),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  /// Error state input decoration
  static BoxDecoration inputError(bool isDark) {
    return BoxDecoration(
      color: isDark
          ? const Color(0xFF334155).withOpacity(0.6)
          : Colors.white.withOpacity(0.9),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: isDark
            ? const Color(0xFFF87171)
            : const Color(0xFFEF4444),
      ),
    );
  }

  // ============================================
  // BUTTON DECORATIONS
  // ============================================

  /// Primary button decoration
  static BoxDecoration primaryButton(bool isDark) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: isDark
            ? [const Color(0xFF34D399), const Color(0xFF10B981)]
            : [const Color(0xFF10B981), const Color(0xFF059669)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: (isDark ? const Color(0xFF34D399) : const Color(0xFF10B981))
              .withOpacity(0.3),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Secondary/outline button decoration
  static BoxDecoration outlineButton(bool isDark) {
    return BoxDecoration(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: isDark
            ? const Color(0xFF34D399).withOpacity(0.5)
            : const Color(0xFF10B981).withOpacity(0.5),
        width: 1.5,
      ),
    );
  }

  /// Secondary filled button decoration
  static BoxDecoration secondaryButton(bool isDark) {
    return BoxDecoration(
      color: isDark
          ? const Color(0xFF334155)
          : const Color(0xFFF1F5F9),
      borderRadius: BorderRadius.circular(12),
    );
  }

  // ============================================
  // CONTAINER DECORATIONS
  // ============================================

  /// Bottom sheet decoration
  static BoxDecoration bottomSheet(bool isDark) {
    return BoxDecoration(
      color: isDark
          ? const Color(0xFF1E293B)
          : Colors.white,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(24),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(isDark ? 0.4 : 0.15),
          blurRadius: 20,
          offset: const Offset(0, -4),
        ),
      ],
    );
  }

  /// Dialog decoration
  static BoxDecoration dialog(bool isDark) {
    return BoxDecoration(
      color: isDark
          ? const Color(0xFF1E293B)
          : Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(isDark ? 0.5 : 0.2),
          blurRadius: 32,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  /// AppBar decoration (for custom app bars)
  static BoxDecoration appBar(bool isDark) {
    return BoxDecoration(
      color: isDark
          ? const Color(0xFF0F172A)
          : Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  // ============================================
  // SPECIAL DECORATIONS
  // ============================================

  /// Subtle glass effect decoration
  static BoxDecoration glass(bool isDark) {
    return BoxDecoration(
      color: isDark
          ? const Color(0xFF1E293B).withOpacity(0.7)
          : Colors.white.withOpacity(0.85),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isDark
            ? Colors.white.withOpacity(0.1)
            : Colors.white.withOpacity(0.5),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(isDark ? 0.25 : 0.08),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Background gradient decoration
  static BoxDecoration gradient(bool isDark) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: isDark
            ? [const Color(0xFF0F172A), const Color(0xFF1E293B), const Color(0xFF0F172A)]
            : [const Color(0xFFFFFFFF), const Color(0xFFECFDF5), const Color(0xFFD1FAE5)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }

  /// Badge decoration with custom color
  static BoxDecoration badge(Color color, bool isDark) {
    return BoxDecoration(
      color: color.withOpacity(isDark ? 0.2 : 0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: color.withOpacity(isDark ? 0.4 : 0.3),
      ),
    );
  }

  /// Navigation bar decoration
  static BoxDecoration navigationBar(bool isDark) {
    return BoxDecoration(
      color: isDark
          ? const Color(0xFF0F172A)
          : Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
          blurRadius: 16,
          offset: const Offset(0, -4),
        ),
      ],
    );
  }

  /// Avatar/profile image decoration
  static BoxDecoration avatar(bool isDark, {bool hasBorder = true}) {
    return BoxDecoration(
      color: isDark
          ? const Color(0xFF064E3B)
          : const Color(0xFFD1FAE5),
      shape: BoxShape.circle,
      border: hasBorder
          ? Border.all(
              color: isDark
                  ? const Color(0xFF34D399).withOpacity(0.3)
                  : const Color(0xFF10B981).withOpacity(0.3),
              width: 2,
            )
          : null,
    );
  }
}
```

**Step 2: Verify file compiles**

Run: `flutter analyze lib/app/core/theme/app_decorations.dart`
Expected: No errors

**Step 3: Commit**

```bash
git add lib/app/core/theme/app_decorations.dart
git commit -m "feat: Add AppDecorations utility class for theme-aware decorations"
```

---

## Task 2: Create Decoration Extensions

**Files:**
- Create: `lib/app/core/extensions/decoration_extensions.dart`

**Step 1: Create the extensions file**

```dart
import 'package:flutter/material.dart';

/// Extensions for BoxDecoration to enable fluent modification
extension BoxDecorationExtension on BoxDecoration {
  /// Copy with different border radius
  BoxDecoration withRadius(double radius) {
    return copyWith(borderRadius: BorderRadius.circular(radius));
  }

  /// Copy with custom border
  BoxDecoration withBorder(Color color, {double width = 1}) {
    return copyWith(border: Border.all(color: color, width: width));
  }

  /// Copy with shadow
  BoxDecoration withShadow({
    Color? color,
    double blur = 10,
    Offset offset = const Offset(0, 4),
  }) {
    return copyWith(
      boxShadow: [
        BoxShadow(
          color: color ?? Colors.black.withOpacity(0.1),
          blurRadius: blur,
          offset: offset,
        ),
      ],
    );
  }

  /// Copy with additional shadow (keeps existing shadows)
  BoxDecoration addShadow({
    Color? color,
    double blur = 10,
    Offset offset = const Offset(0, 4),
  }) {
    final existingShadows = boxShadow ?? [];
    return copyWith(
      boxShadow: [
        ...existingShadows,
        BoxShadow(
          color: color ?? Colors.black.withOpacity(0.1),
          blurRadius: blur,
          offset: offset,
        ),
      ],
    );
  }

  /// Copy with different color opacity
  BoxDecoration withColorOpacity(double opacity) {
    if (color == null) return this;
    return copyWith(color: color!.withOpacity(opacity));
  }

  /// Remove shadow
  BoxDecoration withoutShadow() {
    return copyWith(boxShadow: []);
  }

  /// Remove border
  BoxDecoration withoutBorder() {
    return copyWith(border: null);
  }

  /// Copy with gradient
  BoxDecoration withGradient(Gradient gradient) {
    return copyWith(gradient: gradient, color: null);
  }

  /// Copy with solid color (removes gradient)
  BoxDecoration withColor(Color color) {
    return copyWith(color: color, gradient: null);
  }
}

/// Extensions for Color utilities
extension ColorExtension on Color {
  /// Get contrasting text color (black or white)
  Color get contrastText {
    return computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }

  /// Create subtle version for backgrounds
  Color subtle(bool isDark) {
    return withOpacity(isDark ? 0.15 : 0.1);
  }

  /// Create muted version
  Color muted(bool isDark) {
    return withOpacity(isDark ? 0.6 : 0.7);
  }

  /// Darken color by percentage (0.0 - 1.0)
  Color darken([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final darkened = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return darkened.toColor();
  }

  /// Lighten color by percentage (0.0 - 1.0)
  Color lighten([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final lightened = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return lightened.toColor();
  }
}

/// Extensions for BuildContext to easily access theme info
extension ThemeContextExtension on BuildContext {
  /// Check if current theme is dark
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  /// Get current color scheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Get current text theme
  TextTheme get textTheme => Theme.of(this).textTheme;
}
```

**Step 2: Verify file compiles**

Run: `flutter analyze lib/app/core/extensions/decoration_extensions.dart`
Expected: No errors

**Step 3: Commit**

```bash
git add lib/app/core/extensions/decoration_extensions.dart
git commit -m "feat: Add BoxDecoration and Color extensions for fluent API"
```

---

## Task 3: Update AppColors with Dark Theme Support

**Files:**
- Modify: `lib/app/core/theme/app_colors.dart`

**Step 1: Update app_colors.dart with theme-aware colors**

```dart
import 'package:flutter/material.dart';

/// SendIt User App Color Palette
/// Supports both light and dark themes with emerald + amber palette
class AppColors {
  AppColors._();

  // ============================================
  // THEME-AWARE COLOR GETTERS
  // ============================================

  /// Get colors based on brightness
  static AppColorScheme of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? dark : light;
  }

  /// Check if dark mode
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  // ============================================
  // LIGHT THEME COLORS
  // ============================================
  static const AppColorScheme light = AppColorScheme(
    // Backgrounds
    background: Color(0xFFECFDF5),
    backgroundGradientEnd: Color(0xFFD1FAE5),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFF8FAFC),
    scaffoldBackground: Color(0xFFFAFAFA),

    // Primary (Emerald)
    primary: Color(0xFF10B981),
    primaryLight: Color(0xFF34D399),
    primaryDark: Color(0xFF059669),
    primaryContainer: Color(0xFFD1FAE5),

    // Accent (Amber)
    accent: Color(0xFFF59E0B),
    accentLight: Color(0xFFFBBF24),
    accentDark: Color(0xFFD97706),
    accentContainer: Color(0xFFFEF3C7),

    // Text
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF64748B),
    textHint: Color(0xFF94A3B8),
    textDisabled: Color(0xFFCBD5E1),
    textOnPrimary: Color(0xFFFFFFFF),

    // Borders
    border: Color(0xFFE2E8F0),
    borderLight: Color(0xFFF1F5F9),
    borderPrimary: Color(0xFF10B981),

    // Semantic
    success: Color(0xFF10B981),
    successLight: Color(0xFFD1FAE5),
    warning: Color(0xFFF59E0B),
    warningLight: Color(0xFFFEF3C7),
    error: Color(0xFFEF4444),
    errorLight: Color(0xFFFEE2E2),
    info: Color(0xFF3B82F6),
    infoLight: Color(0xFFDBEAFE),

    // Greys
    grey50: Color(0xFFF8FAFC),
    grey100: Color(0xFFF1F5F9),
    grey200: Color(0xFFE2E8F0),
    grey300: Color(0xFFCBD5E1),
    grey400: Color(0xFF94A3B8),
    grey500: Color(0xFF64748B),
    grey600: Color(0xFF475569),
    grey700: Color(0xFF334155),
    grey800: Color(0xFF1E293B),
    grey900: Color(0xFF0F172A),
  );

  // ============================================
  // DARK THEME COLORS
  // ============================================
  static const AppColorScheme dark = AppColorScheme(
    // Backgrounds
    background: Color(0xFF0F172A),
    backgroundGradientEnd: Color(0xFF1E293B),
    surface: Color(0xFF1E293B),
    surfaceVariant: Color(0xFF334155),
    scaffoldBackground: Color(0xFF0F172A),

    // Primary (Brighter Emerald for dark mode)
    primary: Color(0xFF34D399),
    primaryLight: Color(0xFF6EE7B7),
    primaryDark: Color(0xFF10B981),
    primaryContainer: Color(0xFF064E3B),

    // Accent (Brighter Amber for dark mode)
    accent: Color(0xFFFBBF24),
    accentLight: Color(0xFFFCD34D),
    accentDark: Color(0xFFF59E0B),
    accentContainer: Color(0xFF78350F),

    // Text
    textPrimary: Color(0xFFF8FAFC),
    textSecondary: Color(0xFF94A3B8),
    textHint: Color(0xFF64748B),
    textDisabled: Color(0xFF475569),
    textOnPrimary: Color(0xFF0F172A),

    // Borders
    border: Color(0xFF334155),
    borderLight: Color(0xFF475569),
    borderPrimary: Color(0xFF34D399),

    // Semantic
    success: Color(0xFF34D399),
    successLight: Color(0xFF064E3B),
    warning: Color(0xFFFBBF24),
    warningLight: Color(0xFF78350F),
    error: Color(0xFFF87171),
    errorLight: Color(0xFF7F1D1D),
    info: Color(0xFF60A5FA),
    infoLight: Color(0xFF1E3A5F),

    // Greys (inverted for dark mode)
    grey50: Color(0xFF0F172A),
    grey100: Color(0xFF1E293B),
    grey200: Color(0xFF334155),
    grey300: Color(0xFF475569),
    grey400: Color(0xFF64748B),
    grey500: Color(0xFF94A3B8),
    grey600: Color(0xFFCBD5E1),
    grey700: Color(0xFFE2E8F0),
    grey800: Color(0xFFF1F5F9),
    grey900: Color(0xFFF8FAFC),
  );

  // ============================================
  // LEGACY STATIC COLORS (for backward compatibility)
  // ============================================
  static const Color primary = Color(0xFF10B981);
  static const Color primaryLight = Color(0xFF34D399);
  static const Color primaryDark = Color(0xFF059669);
  static const Color primaryContainer = Color(0xFFD1FAE5);

  static const Color accent = Color(0xFFF59E0B);
  static const Color accentLight = Color(0xFFFBBF24);
  static const Color accentDark = Color(0xFFD97706);
  static const Color accentContainer = Color(0xFFFEF3C7);

  static const Color secondary = Color(0xFFF1F5F9);
  static const Color secondaryLight = Color(0xFFF8FAFC);
  static const Color secondaryDark = Color(0xFF1E293B);

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  static const Color grey50 = Color(0xFFF8FAFC);
  static const Color grey100 = Color(0xFFF1F5F9);
  static const Color grey200 = Color(0xFFE2E8F0);
  static const Color grey300 = Color(0xFFCBD5E1);
  static const Color grey400 = Color(0xFF94A3B8);
  static const Color grey500 = Color(0xFF64748B);
  static const Color grey600 = Color(0xFF475569);
  static const Color grey700 = Color(0xFF334155);
  static const Color grey800 = Color(0xFF1E293B);
  static const Color grey900 = Color(0xFF0F172A);

  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color successDark = Color(0xFF059669);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color warningDark = Color(0xFFD97706);

  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color errorDark = Color(0xFFDC2626);

  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);
  static const Color infoDark = Color(0xFF2563EB);

  static const Color background = Color(0xFFECFDF5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF8FAFC);
  static const Color scaffoldBackground = Color(0xFFFAFAFA);

  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textHint = Color(0xFF94A3B8);
  static const Color textDisabled = Color(0xFFCBD5E1);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnAccent = Color(0xFFFFFFFF);

  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);
  static const Color borderPrimary = Color(0xFF10B981);

  static const Color statusPending = Color(0xFFF59E0B);
  static const Color statusAccepted = Color(0xFF3B82F6);
  static const Color statusPickedUp = Color(0xFF8B5CF6);
  static const Color statusInTransit = Color(0xFF10B981);
  static const Color statusDelivered = Color(0xFF10B981);
  static const Color statusCancelled = Color(0xFFEF4444);

  static const Color vehicleCycle = Color(0xFF10B981);
  static const Color vehicleBike = Color(0xFF3B82F6);
  static const Color vehicleAuto = Color(0xFFF59E0B);
  static const Color vehicleTruck = Color(0xFF8B5CF6);

  static Color get glassBackground => white.withOpacity(0.95);
  static Color get glassBorder => primary.withOpacity(0.2);
  static Color get glassInputBackground => white.withOpacity(0.9);
  static Color get glassInputBorder => primary.withOpacity(0.4);
}

/// Color scheme class for type-safe color access
class AppColorScheme {
  final Color background;
  final Color backgroundGradientEnd;
  final Color surface;
  final Color surfaceVariant;
  final Color scaffoldBackground;

  final Color primary;
  final Color primaryLight;
  final Color primaryDark;
  final Color primaryContainer;

  final Color accent;
  final Color accentLight;
  final Color accentDark;
  final Color accentContainer;

  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;
  final Color textDisabled;
  final Color textOnPrimary;

  final Color border;
  final Color borderLight;
  final Color borderPrimary;

  final Color success;
  final Color successLight;
  final Color warning;
  final Color warningLight;
  final Color error;
  final Color errorLight;
  final Color info;
  final Color infoLight;

  final Color grey50;
  final Color grey100;
  final Color grey200;
  final Color grey300;
  final Color grey400;
  final Color grey500;
  final Color grey600;
  final Color grey700;
  final Color grey800;
  final Color grey900;

  const AppColorScheme({
    required this.background,
    required this.backgroundGradientEnd,
    required this.surface,
    required this.surfaceVariant,
    required this.scaffoldBackground,
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.primaryContainer,
    required this.accent,
    required this.accentLight,
    required this.accentDark,
    required this.accentContainer,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.textDisabled,
    required this.textOnPrimary,
    required this.border,
    required this.borderLight,
    required this.borderPrimary,
    required this.success,
    required this.successLight,
    required this.warning,
    required this.warningLight,
    required this.error,
    required this.errorLight,
    required this.info,
    required this.infoLight,
    required this.grey50,
    required this.grey100,
    required this.grey200,
    required this.grey300,
    required this.grey400,
    required this.grey500,
    required this.grey600,
    required this.grey700,
    required this.grey800,
    required this.grey900,
  });
}
```

**Step 2: Verify file compiles**

Run: `flutter analyze lib/app/core/theme/app_colors.dart`
Expected: No errors

**Step 3: Commit**

```bash
git add lib/app/core/theme/app_colors.dart
git commit -m "feat: Add dark theme color scheme and AppColorScheme class"
```

---

## Task 4: Create ThemeController

**Files:**
- Create: `lib/app/core/controllers/theme_controller.dart`

**Step 1: Create the theme controller**

```dart
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import '../../services/storage_service.dart';

/// Controller for managing app theme state
/// Supports dark (default), light, and system theme modes
class ThemeController extends GetxController {
  static ThemeController get to => Get.find();

  final StorageService _storage = Get.find<StorageService>();

  /// Current theme mode
  final Rx<ThemeMode> themeMode = ThemeMode.dark.obs;

  /// Check if current effective theme is dark
  bool get isDark {
    if (themeMode.value == ThemeMode.system) {
      return SchedulerBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;
    }
    return themeMode.value == ThemeMode.dark;
  }

  /// Check if current effective theme is light
  bool get isLight => !isDark;

  /// Get theme mode display name
  String get themeModeDisplayName {
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

  /// Load saved theme preference
  void _loadTheme() {
    final savedTheme = _storage.themeMode;
    themeMode.value = ThemeMode.values.firstWhere(
      (e) => e.name == savedTheme,
      orElse: () => ThemeMode.dark, // Default to dark
    );
  }

  /// Set theme mode and persist
  void setThemeMode(ThemeMode mode) {
    themeMode.value = mode;
    _storage.themeMode = mode.name;
    Get.changeThemeMode(mode);
  }

  /// Set to dark mode
  void setDarkMode() => setThemeMode(ThemeMode.dark);

  /// Set to light mode
  void setLightMode() => setThemeMode(ThemeMode.light);

  /// Set to system mode
  void setSystemMode() => setThemeMode(ThemeMode.system);

  /// Toggle between dark and light
  void toggleTheme() {
    if (isDark) {
      setLightMode();
    } else {
      setDarkMode();
    }
  }

  /// Get icon for current theme
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
```

**Step 2: Verify file compiles**

Run: `flutter analyze lib/app/core/controllers/theme_controller.dart`
Expected: No errors

**Step 3: Commit**

```bash
git add lib/app/core/controllers/theme_controller.dart
git commit -m "feat: Add ThemeController for theme state management"
```

---

## Task 5: Update AppTheme with Dark Theme

**Files:**
- Modify: `lib/app/core/theme/app_theme.dart`

**Step 1: Update app_theme.dart with complete dark theme**

Replace the entire file content with the dark theme implementation. The file is large, so key changes:

1. Update `darkTheme` getter to return a fully configured dark ThemeData
2. Use dark color values from AppColors.dark
3. Ensure all component themes (AppBar, Card, Input, etc.) have dark variants

```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// SendIt User App Theme Configuration
/// Emerald + Amber Glassmorphism Design with Dark/Light support
class AppTheme {
  AppTheme._();

  // ============================================
  // BORDER RADIUS TOKENS
  // ============================================
  static const double radiusSmall = 12.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 20.0;
  static const double radiusXLarge = 24.0;
  static const double radiusFull = 9999.0;

  // ============================================
  // LIGHT THEME
  // ============================================
  static ThemeData get lightTheme {
    const colors = AppColors.light;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: colors.primary,
      scaffoldBackgroundColor: colors.scaffoldBackground,
      fontFamily: AppTextStyles.fontFamily,

      // Color Scheme
      colorScheme: ColorScheme.light(
        primary: colors.primary,
        primaryContainer: colors.primaryContainer,
        secondary: colors.accent,
        secondaryContainer: colors.accentContainer,
        surface: colors.surface,
        surfaceContainerHighest: colors.surfaceVariant,
        error: colors.error,
        onPrimary: colors.textOnPrimary,
        onSecondary: colors.textOnPrimary,
        onSurface: colors.textPrimary,
        onError: AppColors.white,
        outline: colors.border,
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: colors.surface,
        foregroundColor: colors.textPrimary,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: colors.textPrimary),
        titleTextStyle: AppTextStyles.h4.copyWith(color: colors.textPrimary),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 0,
        color: colors.surface.withOpacity(0.95),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXLarge),
          side: BorderSide(color: colors.primary.withOpacity(0.2)),
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.textOnPrimary,
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.primary,
          side: BorderSide(color: colors.primary.withOpacity(0.5)),
          minimumSize: const Size(double.infinity, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.primary,
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface.withOpacity(0.9),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: colors.primary.withOpacity(0.4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: colors.primary.withOpacity(0.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: colors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: colors.error, width: 2),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: colors.textHint),
        labelStyle: AppTextStyles.labelMedium.copyWith(color: colors.textSecondary),
        errorStyle: AppTextStyles.caption.copyWith(color: colors.error),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.surface,
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.grey500,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // Navigation Bar Theme
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.surface,
        indicatorColor: colors.primaryContainer,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.labelSmall.copyWith(color: colors.primary);
          }
          return AppTextStyles.labelSmall.copyWith(color: colors.grey500);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colors.primary, size: 24);
          }
          return IconThemeData(color: colors.grey500, size: 24);
        }),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: colors.grey100,
        selectedColor: colors.primaryContainer,
        labelStyle: AppTextStyles.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXLarge),
        ),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.grey800,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // FAB Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.primary,
        foregroundColor: colors.textOnPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: colors.border,
        thickness: 1,
        space: 1,
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.primary,
        linearTrackColor: colors.primaryContainer,
        circularTrackColor: colors.primaryContainer,
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.primary;
          }
          return colors.grey400;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.primaryContainer;
          }
          return colors.grey200;
        }),
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(colors.textOnPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      // Radio Theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.primary;
          }
          return colors.grey400;
        }),
      ),

      // Tab Bar Theme
      tabBarTheme: TabBarThemeData(
        labelColor: colors.primary,
        unselectedLabelColor: colors.grey500,
        indicatorColor: colors.primary,
      ),

      // List Tile Theme
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
      ),

      // Icon Theme
      iconTheme: IconThemeData(
        color: colors.textPrimary,
        size: 24,
      ),
    );
  }

  // ============================================
  // DARK THEME
  // ============================================
  static ThemeData get darkTheme {
    const colors = AppColors.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: colors.primary,
      scaffoldBackgroundColor: colors.scaffoldBackground,
      fontFamily: AppTextStyles.fontFamily,

      // Color Scheme
      colorScheme: ColorScheme.dark(
        primary: colors.primary,
        primaryContainer: colors.primaryContainer,
        secondary: colors.accent,
        secondaryContainer: colors.accentContainer,
        surface: colors.surface,
        surfaceContainerHighest: colors.surfaceVariant,
        error: colors.error,
        onPrimary: colors.textOnPrimary,
        onSecondary: colors.textOnPrimary,
        onSurface: colors.textPrimary,
        onError: AppColors.black,
        outline: colors.border,
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: colors.background,
        foregroundColor: colors.textPrimary,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: colors.textPrimary),
        titleTextStyle: AppTextStyles.h4.copyWith(color: colors.textPrimary),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 0,
        color: colors.surface.withOpacity(0.8),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXLarge),
          side: BorderSide(color: colors.primary.withOpacity(0.15)),
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.textOnPrimary,
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.primary,
          side: BorderSide(color: colors.primary.withOpacity(0.5)),
          minimumSize: const Size(double.infinity, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.primary,
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceVariant.withOpacity(0.6),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: colors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: colors.error, width: 2),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: colors.textHint),
        labelStyle: AppTextStyles.labelMedium.copyWith(color: colors.textSecondary),
        errorStyle: AppTextStyles.caption.copyWith(color: colors.error),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.background,
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.grey400,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // Navigation Bar Theme
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.background,
        indicatorColor: colors.primaryContainer,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.labelSmall.copyWith(color: colors.primary);
          }
          return AppTextStyles.labelSmall.copyWith(color: colors.grey400);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colors.primary, size: 24);
          }
          return IconThemeData(color: colors.grey400, size: 24);
        }),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: colors.surfaceVariant,
        selectedColor: colors.primaryContainer,
        labelStyle: AppTextStyles.labelMedium.copyWith(color: colors.textPrimary),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXLarge),
        ),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.surfaceVariant,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: colors.textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // FAB Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.primary,
        foregroundColor: colors.textOnPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: colors.border,
        thickness: 1,
        space: 1,
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.primary,
        linearTrackColor: colors.primaryContainer,
        circularTrackColor: colors.primaryContainer,
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.primary;
          }
          return colors.grey400;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.primaryContainer;
          }
          return colors.surfaceVariant;
        }),
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(colors.textOnPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        side: BorderSide(color: colors.border),
      ),

      // Radio Theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.primary;
          }
          return colors.grey400;
        }),
      ),

      // Tab Bar Theme
      tabBarTheme: TabBarThemeData(
        labelColor: colors.primary,
        unselectedLabelColor: colors.grey400,
        indicatorColor: colors.primary,
      ),

      // List Tile Theme
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
        textColor: colors.textPrimary,
        iconColor: colors.textPrimary,
      ),

      // Icon Theme
      iconTheme: IconThemeData(
        color: colors.textPrimary,
        size: 24,
      ),
    );
  }
}
```

**Step 2: Verify file compiles**

Run: `flutter analyze lib/app/core/theme/app_theme.dart`
Expected: No errors

**Step 3: Commit**

```bash
git add lib/app/core/theme/app_theme.dart
git commit -m "feat: Add complete dark theme to AppTheme"
```

---

## Task 6: Update main.dart with Theme Controller

**Files:**
- Modify: `lib/main.dart`

**Step 1: Update main.dart to initialize and use ThemeController**

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app/core/controllers/theme_controller.dart';
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

  // Initialize services
  await initServices();

  runApp(const SendItApp());
}

Future<void> initServices() async {
  // Initialize storage service
  await Get.putAsync(() => StorageService().init());

  // Initialize theme controller
  Get.put(ThemeController());
}

class SendItApp extends StatelessWidget {
  const SendItApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(() {
      // Update system UI based on theme
      final isDark = themeController.isDark;
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
          systemNavigationBarColor: isDark
              ? const Color(0xFF0F172A)
              : Colors.white,
          systemNavigationBarIconBrightness:
              isDark ? Brightness.light : Brightness.dark,
        ),
      );

      return GetMaterialApp(
        title: 'SendIt',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeController.themeMode.value,
        initialRoute: AppPages.initial,
        getPages: AppPages.routes,
        defaultTransition: Transition.cupertino,
      );
    });
  }
}
```

**Step 2: Verify file compiles**

Run: `flutter analyze lib/main.dart`
Expected: No errors

**Step 3: Commit**

```bash
git add lib/main.dart
git commit -m "feat: Integrate ThemeController in main.dart with dark default"
```

---

## Task 7: Add Theme Toggle to Profile View

**Files:**
- Modify: `lib/app/modules/profile/views/profile_view.dart`

**Step 1: Add theme settings section to profile view**

Add a new section in the profile view between "Account" and "Support" sections:

```dart
// Add import at top
import '../../../core/controllers/theme_controller.dart';

// Add this section after the Account section (around line 60):
const SizedBox(height: 16),

// Settings Section
_buildMenuSection(
  title: 'Settings',
  items: [
    _MenuItem(
      icon: ThemeController.to.themeIcon,
      title: 'Theme',
      subtitle: ThemeController.to.themeModeDisplayName,
      onTap: () => _showThemeSelector(),
    ),
  ],
),
```

Also add the `_showThemeSelector` method and update `_MenuItem` class to support subtitle:

```dart
void _showThemeSelector() {
  final themeController = ThemeController.to;

  Get.bottomSheet(
    Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose Theme',
            style: AppTextStyles.h4,
          ),
          const SizedBox(height: 24),
          Obx(() => _buildThemeOption(
                icon: Icons.dark_mode_rounded,
                title: 'Dark',
                isSelected: themeController.themeMode.value == ThemeMode.dark,
                onTap: () {
                  themeController.setDarkMode();
                  Get.back();
                },
              )),
          const SizedBox(height: 12),
          Obx(() => _buildThemeOption(
                icon: Icons.light_mode_rounded,
                title: 'Light',
                isSelected: themeController.themeMode.value == ThemeMode.light,
                onTap: () {
                  themeController.setLightMode();
                  Get.back();
                },
              )),
          const SizedBox(height: 12),
          Obx(() => _buildThemeOption(
                icon: Icons.brightness_auto_rounded,
                title: 'System',
                isSelected: themeController.themeMode.value == ThemeMode.system,
                onTap: () {
                  themeController.setSystemMode();
                  Get.back();
                },
              )),
          const SizedBox(height: 16),
        ],
      ),
    ),
  );
}

Widget _buildThemeOption({
  required IconData icon,
  required String title,
  required bool isSelected,
  required VoidCallback onTap,
}) {
  final colors = AppColors.of(Get.context!);

  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected
            ? colors.primary.withOpacity(0.1)
            : colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? colors.primary
              : colors.border,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isSelected ? colors.primary : colors.textSecondary,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isSelected ? colors.primary : colors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          if (isSelected)
            Icon(
              Icons.check_circle_rounded,
              color: colors.primary,
            ),
        ],
      ),
    ),
  );
}
```

**Step 2: Update `_MenuItem` class to support subtitle**

```dart
class _MenuItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? titleColor;
  final bool showDivider;

  const _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.iconColor,
    this.titleColor,
    this.showDivider = true,
  });
}
```

**Step 3: Update `_buildMenuItem` to show subtitle**

```dart
Widget _buildMenuItem(_MenuItem item) {
  return Column(
    children: [
      ListTile(
        leading: Icon(
          item.icon,
          color: item.iconColor ?? AppColors.textPrimary,
          size: 24,
        ),
        title: Text(
          item.title,
          style: AppTextStyles.bodyMedium.copyWith(
            color: item.titleColor ?? AppColors.textPrimary,
          ),
        ),
        subtitle: item.subtitle != null
            ? Text(
                item.subtitle!,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              )
            : null,
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: item.iconColor ?? AppColors.textSecondary,
          size: 24,
        ),
        onTap: item.onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      ),
      if (item.showDivider)
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Divider(
            height: 1,
            color: AppColors.border,
          ),
        ),
    ],
  );
}
```

**Step 4: Verify file compiles**

Run: `flutter analyze lib/app/modules/profile/views/profile_view.dart`
Expected: No errors

**Step 5: Commit**

```bash
git add lib/app/modules/profile/views/profile_view.dart
git commit -m "feat: Add theme toggle to profile settings"
```

---

## Task 8: Update Core Widgets for Theme Support

**Files:**
- Modify: `lib/app/core/widgets/app_button.dart`

**Step 1: Update AppButton to be theme-aware**

The button should automatically adapt to the current theme. Update color references to use theme colors.

**Step 2: Verify and commit**

```bash
flutter analyze lib/app/core/widgets/app_button.dart
git add lib/app/core/widgets/app_button.dart
git commit -m "feat: Update AppButton for theme support"
```

---

## Task 9: Update Views for Theme Support

Update remaining views to use theme-aware colors. Priority order:

1. `splash_view.dart` - First impression
2. `login_view.dart` - Critical flow
3. `otp_view.dart` - Critical flow
4. `main_view.dart` - Shell view
5. `home_view.dart` - Main content
6. `edit_profile_view.dart`
7. `addresses_view.dart`
8. `wallet_view.dart`
9. `onboarding_view.dart`

For each view:
1. Replace hardcoded `AppColors.white` with theme surface color
2. Replace hardcoded `AppColors.background` with theme background
3. Use `AppDecorations` for cards and containers
4. Test in both dark and light modes

**Commit after each view:**

```bash
git add <view_file>
git commit -m "feat: Update <ViewName> for theme support"
```

---

## Task 10: Final Integration Test

**Step 1: Run full analysis**

```bash
flutter analyze
```

Expected: No errors (warnings/info acceptable)

**Step 2: Test app**

```bash
flutter run
```

Test checklist:
- [ ] App starts in dark theme by default
- [ ] Profile > Settings > Theme toggle works
- [ ] Switching to light theme updates all screens
- [ ] Switching to system follows device setting
- [ ] Theme persists after app restart
- [ ] All screens readable in both themes
- [ ] No hardcoded white/black colors visible

**Step 3: Final commit**

```bash
git add .
git commit -m "feat: Complete dark theme implementation with toggle"
```

---

## Summary

| Task | Description | Files |
|------|-------------|-------|
| 1 | AppDecorations class | `app_decorations.dart` |
| 2 | Decoration extensions | `decoration_extensions.dart` |
| 3 | Update AppColors | `app_colors.dart` |
| 4 | ThemeController | `theme_controller.dart` |
| 5 | Update AppTheme | `app_theme.dart` |
| 6 | Update main.dart | `main.dart` |
| 7 | Theme toggle in Profile | `profile_view.dart` |
| 8 | Update core widgets | `app_button.dart`, etc. |
| 9 | Update views | All view files |
| 10 | Integration test | Full app test |

Total estimated tasks: 10 major tasks with ~15+ commits
