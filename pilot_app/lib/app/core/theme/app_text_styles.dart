import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static String? get fontFamily => GoogleFonts.poppins().fontFamily;

  /// Get theme-aware text color for primary text
  static Color textColor(BuildContext context) =>
      AppColorScheme.of(context).textPrimary;

  /// Get theme-aware text color for secondary text
  static Color textSecondaryColor(BuildContext context) =>
      AppColorScheme.of(context).textSecondary;

  // Headings - Compact sizes (use with .copyWith(color:) for theme awareness)
  static TextStyle get h1 => GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  static TextStyle get h2 => GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    height: 1.3,
  );

  static TextStyle get h3 => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static TextStyle get h4 => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  // Body Text - Compact sizes
  static TextStyle get bodyLarge => GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.normal,
    height: 1.4,
  );

  static TextStyle get bodyMedium => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.4,
  );

  static TextStyle get bodySmall => GoogleFonts.poppins(
    fontSize: 11,
    fontWeight: FontWeight.normal,
    height: 1.4,
  );

  // Labels - Compact sizes
  static TextStyle get labelLarge => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  static TextStyle get labelMedium => GoogleFonts.poppins(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  static TextStyle get labelSmall => GoogleFonts.poppins(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  // Button Text - Compact (white color for buttons on colored backgrounds)
  static TextStyle get button => GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    height: 1.2,
  );

  static TextStyle get buttonSmall => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    height: 1.2,
  );

  // Caption
  static TextStyle get caption => GoogleFonts.poppins(
    fontSize: 10,
    fontWeight: FontWeight.normal,
    height: 1.3,
  );

  // Display Styles (for large hero text)
  static TextStyle get displayLarge => GoogleFonts.poppins(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  static TextStyle get displayMedium => GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  static TextStyle get displaySmall => GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  // Title Styles (for section headers)
  static TextStyle get titleLarge => GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static TextStyle get titleMedium => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static TextStyle get titleSmall => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  // Price
  static TextStyle get price => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  static TextStyle get priceSmall => GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  // ============================================
  // THEME-AWARE STYLES (use these for proper theming)
  // ============================================

  /// Get body text style with theme-aware color
  static TextStyle bodyText(BuildContext context, {bool secondary = false}) {
    final colorScheme = AppColorScheme.of(context);
    return bodyMedium.copyWith(
      color: secondary ? colorScheme.textSecondary : colorScheme.textPrimary,
    );
  }

  /// Get title style with theme-aware color
  static TextStyle titleText(BuildContext context) {
    return titleMedium.copyWith(
      color: AppColorScheme.of(context).textPrimary,
    );
  }

  /// Get label style with theme-aware color
  static TextStyle labelText(BuildContext context, {bool secondary = false}) {
    final colorScheme = AppColorScheme.of(context);
    return labelMedium.copyWith(
      color: secondary ? colorScheme.textSecondary : colorScheme.textPrimary,
    );
  }
}
