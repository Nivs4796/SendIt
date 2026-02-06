import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// SendIt Pilot App Theme Configuration - Compact Design
class AppTheme {
  AppTheme._();

  // ============================================
  // BORDER RADIUS TOKENS - Smaller for compact UI
  // ============================================
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 10.0;
  static const double radiusLarge = 12.0;
  static const double radiusXLarge = 16.0;
  static const double radiusFull = 9999.0;

  // ============================================
  // SPACING TOKENS - Compact
  // ============================================
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 12.0;
  static const double spacingLg = 16.0;
  static const double spacingXl = 20.0;

  // ============================================
  // INPUT FIELD SIZES - Compact
  // ============================================
  static const double inputHeight = 44.0;
  static const double inputPaddingH = 12.0;
  static const double inputPaddingV = 12.0;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.scaffoldBackground,
      fontFamily: AppTextStyles.fontFamily,

      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryContainer,
        secondary: AppColors.accent,
        secondaryContainer: AppColors.accentContainer,
        surface: AppColors.surface,
        surfaceContainerHighest: AppColors.surfaceVariant,
        error: AppColors.error,
        onPrimary: AppColors.textOnPrimary,
        onSecondary: AppColors.textOnAccent,
        onSurface: AppColors.textPrimary,
        onError: AppColors.white,
        outline: AppColors.border,
      ),

      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 20),
        titleTextStyle: AppTextStyles.h4,
        toolbarHeight: 48,
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.glassBackground,
        surfaceTintColor: Colors.transparent,
        margin: const EdgeInsets.all(spacingSm),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          side: BorderSide(color: AppColors.glassBorder),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 0,
          minimumSize: const Size(double.infinity, 44),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
          minimumSize: const Size(double.infinity, 44),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: AppTextStyles.button.copyWith(color: AppColors.primary),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: inputPaddingH, vertical: inputPaddingV),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: AppColors.glassInputBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: AppColors.glassInputBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
        labelStyle: AppTextStyles.labelMedium,
        errorStyle: AppTextStyles.caption.copyWith(color: AppColors.error),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.grey500,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(fontSize: 10),
        unselectedLabelStyle: TextStyle(fontSize: 10),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.grey100,
        selectedColor: AppColors.primaryContainer,
        labelStyle: AppTextStyles.labelSmall,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.grey800,
        contentTextStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.primaryContainer,
        circularTrackColor: AppColors.primaryContainer,
      ),

      listTileTheme: ListTileThemeData(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
      ),

      iconTheme: const IconThemeData(size: 20),
    );
  }

  static ThemeData get darkTheme {
    // Minimal Dark Design Palette
    const darkBackground = Color(0xFF0F172A); // Deep Slate
    const darkSurface = Color(0xFF1E293B); // Slate 800
    const darkSurfaceVariant = Color(0xFF334155); // Slate 700
    const darkPrimary = Color(0xFF10B981); // Emerald 500 - single accent
    const darkPrimaryContainer = Color(0xFF064E3B); // Emerald 900
    const darkAccent = Color(0xFFFBBF24); // Amber (warnings only)
    const darkAccentContainer = Color(0xFF78350F);
    const darkTextPrimary = Color(0xFFF8FAFC); // White
    const darkTextSecondary = Color(0xFF94A3B8); // Slate 400
    const darkTextHint = Color(0xFF64748B); // Slate 500
    const darkBorder = Color(0xFF334155); // Slate 700 - subtle borders
    const darkError = Color(0xFFF87171);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: darkPrimary,
      scaffoldBackgroundColor: darkBackground,
      fontFamily: AppTextStyles.fontFamily,

      colorScheme: const ColorScheme.dark(
        primary: darkPrimary,
        primaryContainer: darkPrimaryContainer,
        secondary: darkAccent,
        secondaryContainer: darkAccentContainer,
        surface: darkSurface,
        surfaceContainerHighest: darkSurfaceVariant,
        error: darkError,
        onPrimary: Color(0xFFFFFFFF), // White text on emerald
        onSecondary: Color(0xFF0F172A),
        onSurface: darkTextPrimary,
        onError: Color(0xFFFFFFFF),
        outline: darkBorder,
      ),

      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false, // Left-aligned title for minimal design
        backgroundColor: Colors.transparent,
        foregroundColor: darkTextPrimary,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: darkTextPrimary, size: 24),
        titleTextStyle: AppTextStyles.h3.copyWith(color: darkTextPrimary),
        toolbarHeight: 56,
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: darkSurface, // Solid color, no transparency
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXLarge), // 16px rounded
          side: const BorderSide(color: darkBorder, width: 1), // Subtle border
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimary,
          foregroundColor: const Color(0xFFFFFFFF), // White text
          elevation: 0,
          minimumSize: const Size(double.infinity, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLarge), // 12px
          ),
          textStyle: AppTextStyles.button,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkPrimary,
          backgroundColor: Colors.transparent,
          side: const BorderSide(color: darkPrimary, width: 1),
          minimumSize: const Size(double.infinity, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLarge),
          ),
          textStyle: AppTextStyles.button.copyWith(color: darkPrimary),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: darkPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: inputPaddingH, vertical: inputPaddingV),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: darkBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: darkBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: darkPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: darkError, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: darkError, width: 1.5),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: darkTextHint),
        labelStyle: AppTextStyles.labelMedium.copyWith(color: darkTextSecondary),
        errorStyle: AppTextStyles.caption.copyWith(color: darkError),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: darkPrimary,
        unselectedItemColor: darkTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: AppTextStyles.labelSmall.copyWith(
          color: darkPrimary,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTextStyles.labelSmall.copyWith(
          color: darkTextSecondary,
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: darkSurfaceVariant,
        selectedColor: darkPrimaryContainer,
        labelStyle: AppTextStyles.labelSmall.copyWith(color: darkTextPrimary),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: darkSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkSurfaceVariant,
        contentTextStyle: AppTextStyles.bodySmall.copyWith(color: darkTextPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: darkPrimary,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: darkBorder,
        thickness: 1,
        space: 1,
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: darkPrimary,
        linearTrackColor: darkPrimaryContainer,
        circularTrackColor: darkPrimaryContainer,
      ),

      listTileTheme: ListTileThemeData(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
        textColor: darkTextPrimary,
        iconColor: darkTextSecondary,
      ),

      iconTheme: const IconThemeData(color: darkTextSecondary, size: 20),

      textTheme: TextTheme(
        displayLarge: AppTextStyles.h1.copyWith(color: darkTextPrimary),
        displayMedium: AppTextStyles.h2.copyWith(color: darkTextPrimary),
        displaySmall: AppTextStyles.h3.copyWith(color: darkTextPrimary),
        headlineMedium: AppTextStyles.bodyLarge.copyWith(color: darkTextPrimary),
        headlineSmall: AppTextStyles.bodyLarge.copyWith(color: darkTextPrimary),
        titleLarge: AppTextStyles.bodyLarge.copyWith(color: darkTextPrimary, fontWeight: FontWeight.w600),
        titleMedium: AppTextStyles.bodyMedium.copyWith(color: darkTextPrimary, fontWeight: FontWeight.w600),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: darkTextPrimary),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: darkTextPrimary),
        bodySmall: AppTextStyles.bodySmall.copyWith(color: darkTextSecondary),
        labelLarge: AppTextStyles.labelLarge.copyWith(color: darkTextPrimary),
        labelMedium: AppTextStyles.labelMedium.copyWith(color: darkTextSecondary),
        labelSmall: AppTextStyles.labelSmall.copyWith(color: darkTextSecondary),
      ),
    );
  }
}
