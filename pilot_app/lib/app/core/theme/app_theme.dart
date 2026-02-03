import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// SendIt User App Theme Configuration
/// Emerald + Amber Glassmorphism Design
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

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.scaffoldBackground,
      fontFamily: AppTextStyles.fontFamily,

      // Color Scheme
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

      // AppBar Theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: AppTextStyles.bodyLarge,
      ),

      // Card Theme - Glassmorphism style
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.glassBackground,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXLarge),
          side: BorderSide(color: AppColors.glassBorder),
        ),
      ),

      // Elevated Button Theme - Primary emerald
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),

      // Outlined Button Theme - Emerald border
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
          minimumSize: const Size(double.infinity, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: AppTextStyles.button.copyWith(color: AppColors.primary),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.labelLarge,
        ),
      ),

      // Input Decoration Theme - Glassmorphism style
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.glassInputBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: AppColors.glassInputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: AppColors.glassInputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
        labelStyle: AppTextStyles.labelMedium,
        errorStyle: AppTextStyles.caption.copyWith(color: AppColors.error),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.grey500,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // Navigation Bar Theme (Material 3)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.white,
        indicatorColor: AppColors.primaryContainer,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.labelSmall.copyWith(color: AppColors.primary);
          }
          return AppTextStyles.labelSmall.copyWith(color: AppColors.grey500);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary, size: 24);
          }
          return const IconThemeData(color: AppColors.grey500, size: 24);
        }),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.grey100,
        selectedColor: AppColors.primaryContainer,
        labelStyle: AppTextStyles.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXLarge),
        ),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.grey800,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.primaryContainer,
        circularTrackColor: AppColors.primaryContainer,
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.grey400;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryContainer;
          }
          return AppColors.grey200;
        }),
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      // Radio Theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.grey400;
        }),
      ),

      // Tab Bar Theme
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.grey500,
        indicatorColor: AppColors.primary,
        labelStyle: AppTextStyles.labelLarge,
        unselectedLabelStyle: AppTextStyles.labelLarge,
      ),

      // List Tile Theme
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    // Dark theme colors
    const darkBackground = Color(0xFF0F172A);
    const darkSurface = Color(0xFF1E293B);
    const darkSurfaceVariant = Color(0xFF334155);
    const darkPrimary = Color(0xFF34D399);
    const darkPrimaryContainer = Color(0xFF064E3B);
    const darkAccent = Color(0xFFFBBF24);
    const darkAccentContainer = Color(0xFF78350F);
    const darkTextPrimary = Color(0xFFF8FAFC);
    const darkTextSecondary = Color(0xFF94A3B8);
    const darkTextHint = Color(0xFF64748B);
    const darkBorder = Color(0xFF334155);
    const darkError = Color(0xFFF87171);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: darkPrimary,
      scaffoldBackgroundColor: darkBackground,
      fontFamily: AppTextStyles.fontFamily,

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: darkPrimary,
        primaryContainer: darkPrimaryContainer,
        secondary: darkAccent,
        secondaryContainer: darkAccentContainer,
        surface: darkSurface,
        surfaceContainerHighest: darkSurfaceVariant,
        error: darkError,
        onPrimary: Color(0xFF0F172A),
        onSecondary: Color(0xFF0F172A),
        onSurface: darkTextPrimary,
        onError: Color(0xFF0F172A),
        outline: darkBorder,
      ),

      // AppBar Theme - Dark with transparent background
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: darkTextPrimary,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: darkTextPrimary),
        titleTextStyle: AppTextStyles.bodyLarge.copyWith(color: darkTextPrimary),
      ),

      // Card Theme - Dark glassmorphism style
      cardTheme: CardThemeData(
        elevation: 0,
        color: darkSurface.withValues(alpha: 0.8),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXLarge),
          side: BorderSide(color: darkPrimary.withValues(alpha: 0.2)),
        ),
      ),

      // Elevated Button Theme - Primary emerald
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimary,
          foregroundColor: const Color(0xFF0F172A),
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),

      // Outlined Button Theme - Emerald border
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkPrimary,
          side: BorderSide(color: darkPrimary.withValues(alpha: 0.3)),
          minimumSize: const Size(double.infinity, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: AppTextStyles.button.copyWith(color: darkPrimary),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: darkPrimary,
          textStyle: AppTextStyles.labelLarge,
        ),
      ),

      // Input Decoration Theme - Dark glassmorphism style
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface.withValues(alpha: 0.5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: darkPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: darkError),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: darkError, width: 2),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: darkTextHint),
        labelStyle: AppTextStyles.labelMedium.copyWith(color: darkTextSecondary),
        errorStyle: AppTextStyles.caption.copyWith(color: darkError),
      ),

      // Bottom Navigation Bar Theme - Dark
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: darkPrimary,
        unselectedItemColor: darkTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // Navigation Bar Theme (Material 3) - Dark
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkSurface,
        indicatorColor: darkPrimaryContainer,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.labelSmall.copyWith(color: darkPrimary);
          }
          return AppTextStyles.labelSmall.copyWith(color: darkTextSecondary);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: darkPrimary, size: 24);
          }
          return const IconThemeData(color: darkTextSecondary, size: 24);
        }),
      ),

      // Chip Theme - Dark
      chipTheme: ChipThemeData(
        backgroundColor: darkSurfaceVariant,
        selectedColor: darkPrimaryContainer,
        labelStyle: AppTextStyles.labelMedium.copyWith(color: darkTextPrimary),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
      ),

      // Dialog Theme - Dark
      dialogTheme: DialogThemeData(
        backgroundColor: darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXLarge),
        ),
      ),

      // Bottom Sheet Theme - Dark
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: darkSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
      ),

      // Snackbar Theme - Dark
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkSurfaceVariant,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: darkTextPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Floating Action Button Theme - Dark
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: darkPrimary,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
      ),

      // Divider Theme - Dark
      dividerTheme: const DividerThemeData(
        color: darkBorder,
        thickness: 1,
        space: 1,
      ),

      // Progress Indicator Theme - Dark
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: darkPrimary,
        linearTrackColor: darkPrimaryContainer,
        circularTrackColor: darkPrimaryContainer,
      ),

      // Switch Theme - Dark
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return darkPrimary;
          }
          return darkTextSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return darkPrimaryContainer;
          }
          return darkSurfaceVariant;
        }),
      ),

      // Checkbox Theme - Dark
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return darkPrimary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(const Color(0xFF0F172A)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        side: const BorderSide(color: darkBorder),
      ),

      // Radio Theme - Dark
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return darkPrimary;
          }
          return darkTextSecondary;
        }),
      ),

      // Tab Bar Theme - Dark
      tabBarTheme: TabBarThemeData(
        labelColor: darkPrimary,
        unselectedLabelColor: darkTextSecondary,
        indicatorColor: darkPrimary,
        labelStyle: AppTextStyles.labelLarge,
        unselectedLabelStyle: AppTextStyles.labelLarge,
      ),

      // List Tile Theme - Dark
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
        textColor: darkTextPrimary,
        iconColor: darkTextSecondary,
      ),

      // Icon Theme - Dark
      iconTheme: const IconThemeData(
        color: darkTextSecondary,
      ),

      // Text Theme - Dark
      textTheme: TextTheme(
        displayLarge: AppTextStyles.h1.copyWith(color: darkTextPrimary),
        displayMedium: AppTextStyles.h2.copyWith(color: darkTextPrimary),
        displaySmall: AppTextStyles.h3.copyWith(color: darkTextPrimary),
        headlineMedium: AppTextStyles.bodyLarge.copyWith(color: darkTextPrimary),
        headlineSmall: AppTextStyles.bodyLarge.copyWith(color: darkTextPrimary, fontSize: 16),
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
