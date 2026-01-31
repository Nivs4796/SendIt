import 'package:flutter/material.dart';

/// SendIt User App Color Palette
/// Aligned with Admin Panel's Emerald + Amber theme
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
