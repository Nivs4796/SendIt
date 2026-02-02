# Dark Theme Implementation Design

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Implement a dark theme (default) with light theme option, using subtle glassmorphism effects matching the admin portal aesthetic.

**Architecture:** Theme-aware color system with reusable BoxDecoration utilities and extensions. GetX-based theme controller with SharedPreferences persistence.

**Tech Stack:** Flutter, GetX, SharedPreferences

---

## Color System

### Dark Theme Colors (Default)

```dart
// Backgrounds
background:        Color(0xFF0F172A)  // Deep slate
backgroundGradientEnd: Color(0xFF1E293B)  // Lighter slate
surface:           Color(0xFF1E293B).withOpacity(0.8)  // Card backgrounds
surfaceVariant:    Color(0xFF334155)  // Elevated surfaces

// Primary (Emerald - brighter for dark mode)
primary:           Color(0xFF34D399)
primaryLight:      Color(0xFF6EE7B7)
primaryDark:       Color(0xFF10B981)
primaryContainer:  Color(0xFF064E3B)

// Accent (Amber - brighter for dark mode)
accent:            Color(0xFFFBBF24)
accentLight:       Color(0xFFFCD34D)
accentDark:        Color(0xFFF59E0B)

// Text
textPrimary:       Color(0xFFF8FAFC)
textSecondary:     Color(0xFF94A3B8)
textHint:          Color(0xFF64748B)
textDisabled:      Color(0xFF475569)

// Borders
border:            Color(0xFF334155)
borderPrimary:     Color(0xFF34D399).withOpacity(0.2)

// Semantic
success:           Color(0xFF34D399)
warning:           Color(0xFFFBBF24)
error:             Color(0xFFF87171)
info:              Color(0xFF60A5FA)
```

### Light Theme Colors

```dart
// Backgrounds
background:        Color(0xFFECFDF5)  // Mint tint
surface:           Color(0xFFFFFFFF).withOpacity(0.95)
surfaceVariant:    Color(0xFFF8FAFC)

// Primary (Emerald - standard)
primary:           Color(0xFF10B981)
primaryLight:      Color(0xFF34D399)
primaryDark:       Color(0xFF059669)
primaryContainer:  Color(0xFFD1FAE5)

// Accent (Amber)
accent:            Color(0xFFF59E0B)
accentLight:       Color(0xFFFBBF24)
accentDark:        Color(0xFFD97706)

// Text
textPrimary:       Color(0xFF0F172A)
textSecondary:     Color(0xFF64748B)
textHint:          Color(0xFF94A3B8)
textDisabled:      Color(0xFFCBD5E1)

// Borders
border:            Color(0xFFE2E8F0)
borderPrimary:     Color(0xFF10B981).withOpacity(0.4)

// Semantic
success:           Color(0xFF10B981)
warning:           Color(0xFFF59E0B)
error:             Color(0xFFEF4444)
info:              Color(0xFF3B82F6)
```

---

## File Structure

```
lib/app/core/
├── theme/
│   ├── app_colors.dart          # UPDATE: Add dark/light color getters
│   ├── app_theme.dart           # UPDATE: Dark & light ThemeData
│   ├── app_decorations.dart     # NEW: Common BoxDecoration presets
│   └── app_text_styles.dart     # UPDATE: Theme-aware text styles
├── extensions/
│   └── decoration_extensions.dart  # NEW: BoxDecoration extensions
└── controllers/
    └── theme_controller.dart    # NEW: Theme state management
```

---

## AppDecorations Class

```dart
class AppDecorations {
  AppDecorations._();

  // ============================================
  // CARD DECORATIONS
  // ============================================
  static BoxDecoration card(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark
        ? const Color(0xFF1E293B).withOpacity(0.8)
        : Colors.white.withOpacity(0.95),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isDark
          ? const Color(0xFF34D399).withOpacity(0.15)
          : const Color(0xFF10B981).withOpacity(0.3),
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

  static BoxDecoration cardElevated(BuildContext context) // Higher elevation
  static BoxDecoration cardFlat(BuildContext context)     // No shadow

  // ============================================
  // INPUT DECORATIONS
  // ============================================
  static BoxDecoration input(BuildContext context)
  static BoxDecoration inputFocused(BuildContext context)
  static BoxDecoration inputError(BuildContext context)

  // ============================================
  // BUTTON DECORATIONS
  // ============================================
  static BoxDecoration primaryButton(BuildContext context)
  static BoxDecoration secondaryButton(BuildContext context)
  static BoxDecoration outlineButton(BuildContext context)

  // ============================================
  // CONTAINER DECORATIONS
  // ============================================
  static BoxDecoration bottomSheet(BuildContext context)
  static BoxDecoration dialog(BuildContext context)
  static BoxDecoration appBar(BuildContext context)

  // ============================================
  // SPECIAL DECORATIONS
  // ============================================
  static BoxDecoration glass(BuildContext context)       // Subtle glass effect
  static BoxDecoration gradient(BuildContext context)    // Background gradient
  static BoxDecoration badge(BuildContext context, Color color)
}
```

---

## Decoration Extensions

```dart
extension BoxDecorationExtension on BoxDecoration {
  /// Copy with different border radius
  BoxDecoration withRadius(double radius) =>
    copyWith(borderRadius: BorderRadius.circular(radius));

  /// Copy with custom border
  BoxDecoration withBorder(Color color, {double width = 1}) =>
    copyWith(border: Border.all(color: color, width: width));

  /// Copy with shadow
  BoxDecoration withShadow({
    Color? color,
    double blur = 10,
    Offset offset = const Offset(0, 4),
  }) => copyWith(
    boxShadow: [
      BoxShadow(
        color: color ?? Colors.black.withOpacity(0.1),
        blurRadius: blur,
        offset: offset,
      ),
    ],
  );

  /// Copy with different color opacity
  BoxDecoration withColorOpacity(double opacity) {
    if (color == null) return this;
    return copyWith(color: color!.withOpacity(opacity));
  }

  /// Remove shadow
  BoxDecoration withoutShadow() => copyWith(boxShadow: []);

  /// Remove border
  BoxDecoration withoutBorder() => copyWith(border: null);
}

extension ColorExtension on Color {
  /// Get contrasting text color (black or white)
  Color get contrastText =>
    computeLuminance() > 0.5 ? Colors.black : Colors.white;

  /// Create subtle version for backgrounds
  Color subtle(bool isDark) =>
    withOpacity(isDark ? 0.15 : 0.1);
}
```

---

## Theme Controller

```dart
class ThemeController extends GetxController {
  static ThemeController get to => Get.find();

  final _storage = Get.find<StorageService>();

  // Observable theme mode
  final Rx<ThemeMode> themeMode = ThemeMode.dark.obs;

  bool get isDark => themeMode.value == ThemeMode.dark ||
    (themeMode.value == ThemeMode.system &&
     WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark);

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  void _loadTheme() {
    final savedTheme = _storage.themeMode;
    themeMode.value = ThemeMode.values.firstWhere(
      (e) => e.name == savedTheme,
      orElse: () => ThemeMode.dark,  // Default to dark
    );
  }

  void setThemeMode(ThemeMode mode) {
    themeMode.value = mode;
    _storage.themeMode = mode.name;
    Get.changeThemeMode(mode);
  }

  void toggleTheme() {
    setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
  }
}
```

---

## Views to Update

| View | Priority | Changes |
|------|----------|---------|
| `main.dart` | HIGH | Add ThemeController, set dark default |
| `app_theme.dart` | HIGH | Create dark/light ThemeData |
| `app_colors.dart` | HIGH | Add theme-aware color getters |
| `splash_view.dart` | HIGH | Theme-aware background |
| `login_view.dart` | HIGH | Dark inputs, buttons |
| `otp_view.dart` | HIGH | Dark inputs, buttons |
| `main_view.dart` | MEDIUM | Dark bottom nav |
| `home_view.dart` | MEDIUM | Dark cards, lists |
| `profile_view.dart` | MEDIUM | Add theme toggle, dark UI |
| `edit_profile_view.dart` | MEDIUM | Dark form |
| `addresses_view.dart` | MEDIUM | Dark cards, bottom sheet |
| `wallet_view.dart` | MEDIUM | Dark balance card, list |
| `onboarding_view.dart` | LOW | Dark pages |
| Core widgets | HIGH | Update AppButton, AppTextField, etc. |

---

## Theme Toggle UI (Profile Screen)

```dart
// Settings section in profile_view.dart
ListTile(
  leading: Icon(
    ThemeController.to.isDark
      ? Icons.dark_mode_rounded
      : Icons.light_mode_rounded,
  ),
  title: Text('Theme'),
  subtitle: Text(ThemeController.to.themeMode.value.name.capitalize),
  trailing: Icon(Icons.chevron_right_rounded),
  onTap: () => _showThemeSelector(),
)

void _showThemeSelector() {
  Get.bottomSheet(
    // Options: Dark, Light, System
  );
}
```

---

## Migration Checklist

- [ ] Create `app_decorations.dart` with all presets
- [ ] Create `decoration_extensions.dart` with extensions
- [ ] Create `theme_controller.dart` with GetX state
- [ ] Update `storage_service.dart` to persist theme
- [ ] Update `app_colors.dart` with dark/light variants
- [ ] Update `app_theme.dart` with both ThemeData
- [ ] Update `main.dart` to initialize theme controller
- [ ] Update all core widgets (AppButton, AppTextField, etc.)
- [ ] Update all views to use theme-aware decorations
- [ ] Add theme toggle to profile screen
- [ ] Test on both iOS and Android
- [ ] Test theme persistence across app restart

---

## Performance Notes

- **No blur effects** - Using simple opacity for glass effect
- **Minimal shadows** - Only essential elevation
- **Color caching** - Theme colors computed once per theme change
- **60fps target** - All animations use standard curves

