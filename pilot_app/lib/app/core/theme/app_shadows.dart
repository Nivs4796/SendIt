import 'package:flutter/material.dart';
import 'app_colors.dart';

/// SendIt User App Shadow Definitions
/// Emerald-tinted shadows for glassmorphism design
class AppShadows {
  AppShadows._();

  // ============================================
  // SMALL SHADOW
  // ============================================
  static BoxShadow get small => BoxShadow(
        color: AppColors.primary.withValues(alpha: 0.08),
        blurRadius: 8,
        offset: const Offset(0, 2),
      );

  // ============================================
  // MEDIUM SHADOW
  // ============================================
  static BoxShadow get medium => BoxShadow(
        color: AppColors.primary.withValues(alpha: 0.12),
        blurRadius: 16,
        offset: const Offset(0, 4),
      );

  // ============================================
  // LARGE SHADOW
  // ============================================
  static BoxShadow get large => BoxShadow(
        color: AppColors.primary.withValues(alpha: 0.15),
        blurRadius: 24,
        offset: const Offset(0, 8),
      );

  // ============================================
  // CARD SHADOW (Dual-layer)
  // ============================================
  static List<BoxShadow> get card => [
        BoxShadow(
          color: AppColors.black.withValues(alpha: 0.06),
          blurRadius: 24,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.10),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  // ============================================
  // BUTTON SHADOW
  // ============================================
  static List<BoxShadow> get button => [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.25),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  // ============================================
  // INPUT FOCUS SHADOW (Glow ring)
  // ============================================
  static List<BoxShadow> get inputFocus => [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.15),
          blurRadius: 8,
          spreadRadius: 2,
          offset: Offset.zero,
        ),
      ];

  // ============================================
  // BOTTOM NAV SHADOW
  // ============================================
  static List<BoxShadow> get bottomNav => [
        BoxShadow(
          color: AppColors.black.withValues(alpha: 0.08),
          blurRadius: 20,
          offset: const Offset(0, -4),
        ),
      ];

  // ============================================
  // MODAL/DIALOG SHADOW
  // ============================================
  static List<BoxShadow> get modal => [
        BoxShadow(
          color: AppColors.black.withValues(alpha: 0.12),
          blurRadius: 32,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.08),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];
}
