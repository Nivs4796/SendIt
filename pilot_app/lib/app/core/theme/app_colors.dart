import 'package:flutter/material.dart';

/// Theme-aware color scheme for dark and light modes
class AppColorScheme {
  // Backgrounds
  final Color background;
  final Color backgroundGradientEnd;
  final Color surface;
  final Color surfaceVariant;

  // Primary (Emerald)
  final Color primary;
  final Color primaryLight;
  final Color primaryDark;
  final Color primaryContainer;

  // Accent (Amber)
  final Color accent;
  final Color accentLight;
  final Color accentDark;

  // Text
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;
  final Color textDisabled;

  // Borders
  final Color border;
  final Color borderPrimary;

  // Semantic
  final Color success;
  final Color warning;
  final Color error;
  final Color info;

  const AppColorScheme({
    required this.background,
    required this.backgroundGradientEnd,
    required this.surface,
    required this.surfaceVariant,
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.primaryContainer,
    required this.accent,
    required this.accentLight,
    required this.accentDark,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.textDisabled,
    required this.border,
    required this.borderPrimary,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
  });

  /// Dark theme color scheme (default)
  static const dark = AppColorScheme(
    // Backgrounds
    background: Color(0xFF0F172A),
    backgroundGradientEnd: Color(0xFF1E293B),
    surface: Color(0xCC1E293B), // 0.8 opacity
    surfaceVariant: Color(0xFF334155),

    // Primary (Emerald - brighter for dark mode)
    primary: Color(0xFF34D399),
    primaryLight: Color(0xFF6EE7B7),
    primaryDark: Color(0xFF10B981),
    primaryContainer: Color(0xFF064E3B),

    // Accent (Amber - brighter for dark mode)
    accent: Color(0xFFFBBF24),
    accentLight: Color(0xFFFCD34D),
    accentDark: Color(0xFFF59E0B),

    // Text
    textPrimary: Color(0xFFF8FAFC),
    textSecondary: Color(0xFF94A3B8),
    textHint: Color(0xFF64748B),
    textDisabled: Color(0xFF475569),

    // Borders
    border: Color(0xFF334155),
    borderPrimary: Color(0x3334D399), // 0.2 opacity

    // Semantic
    success: Color(0xFF34D399),
    warning: Color(0xFFFBBF24),
    error: Color(0xFFF87171),
    info: Color(0xFF60A5FA),
  );

  /// Light theme color scheme
  static const light = AppColorScheme(
    // Backgrounds
    background: Color(0xFFECFDF5),
    backgroundGradientEnd: Color(0xFFF0FDF4),
    surface: Color(0xF2FFFFFF), // 0.95 opacity
    surfaceVariant: Color(0xFFF8FAFC),

    // Primary (Emerald - standard)
    primary: Color(0xFF10B981),
    primaryLight: Color(0xFF34D399),
    primaryDark: Color(0xFF059669),
    primaryContainer: Color(0xFFD1FAE5),

    // Accent (Amber)
    accent: Color(0xFFF59E0B),
    accentLight: Color(0xFFFBBF24),
    accentDark: Color(0xFFD97706),

    // Text
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF64748B),
    textHint: Color(0xFF94A3B8),
    textDisabled: Color(0xFFCBD5E1),

    // Borders
    border: Color(0xFFE2E8F0),
    borderPrimary: Color(0x6610B981), // 0.4 opacity

    // Semantic
    success: Color(0xFF10B981),
    warning: Color(0xFFF59E0B),
    error: Color(0xFFEF4444),
    info: Color(0xFF3B82F6),
  );

  /// Get color scheme based on brightness
  static AppColorScheme of(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? dark : light;
  }
}

/// SendIt User App Color Palette
/// Aligned with Admin Panel's Emerald + Amber theme
/// @deprecated Use AppColorScheme instead for theme-aware colors
class AppColors {
  AppColors._();

  // ============================================
  // PRIMARY COLORS (Emerald)
  // ============================================
  static const Color primary = Color(0xFF10B981);
  static const Color primaryLight = Color(0xFF34D399);
  static const Color primaryDark = Color(0xFF059669);
  static const Color primaryContainer = Color(0xFFD1FAE5);

  // ============================================
  // ACCENT COLORS (Amber)
  // ============================================
  static const Color accent = Color(0xFFF59E0B);
  static const Color accentLight = Color(0xFFFBBF24);
  static const Color accentDark = Color(0xFFD97706);
  static const Color accentContainer = Color(0xFFFEF3C7);

  // ============================================
  // SECONDARY COLORS (Slate)
  // ============================================
  static const Color secondary = Color(0xFFF1F5F9);
  static const Color secondaryLight = Color(0xFFF8FAFC);
  static const Color secondaryDark = Color(0xFF1E293B);

  // ============================================
  // NEUTRAL COLORS
  // ============================================
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // Slate Gray Scale
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

  // ============================================
  // SEMANTIC COLORS
  // ============================================
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

  // ============================================
  // BACKGROUND COLORS
  // ============================================
  static const Color background = Color(0xFFECFDF5); // Mint tint
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF8FAFC);
  static const Color scaffoldBackground = Color(0xFFFAFAFA);

  // ============================================
  // TEXT COLORS
  // ============================================
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textHint = Color(0xFF94A3B8);
  static const Color textDisabled = Color(0xFFCBD5E1);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnAccent = Color(0xFFFFFFFF);

  // ============================================
  // BORDER COLORS
  // ============================================
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);
  static const Color borderPrimary = Color(0xFF10B981);

  // ============================================
  // STATUS COLORS FOR ORDERS
  // ============================================
  static const Color statusPending = Color(0xFFF59E0B);    // Amber
  static const Color statusAccepted = Color(0xFF3B82F6);   // Blue
  static const Color statusPickedUp = Color(0xFF8B5CF6);   // Purple
  static const Color statusInTransit = Color(0xFF10B981);  // Emerald
  static const Color statusDelivered = Color(0xFF10B981);  // Emerald
  static const Color statusCancelled = Color(0xFFEF4444);  // Red

  // ============================================
  // VEHICLE TYPE COLORS
  // ============================================
  static const Color vehicleCycle = Color(0xFF10B981);   // Emerald
  static const Color vehicleBike = Color(0xFF3B82F6);    // Blue
  static const Color vehicleAuto = Color(0xFFF59E0B);    // Amber
  static const Color vehicleTruck = Color(0xFF8B5CF6);   // Purple

  // ============================================
  // GLASSMORPHISM COLORS
  // ============================================
  static Color get glassBackground => white.withValues(alpha: 0.95);
  static Color get glassBorder => primary.withValues(alpha: 0.2);
  static Color get glassInputBackground => white.withValues(alpha: 0.9);
  static Color get glassInputBorder => primary.withValues(alpha: 0.4);
}
