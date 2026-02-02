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
          color: color ?? Colors.black.withValues(alpha: 0.1),
          blurRadius: blur,
          offset: offset,
        ),
      ],
    );
  }

  /// Copy with different color opacity
  BoxDecoration withColorOpacity(double opacity) {
    if (color == null) return this;
    return copyWith(color: color!.withValues(alpha: opacity));
  }

  /// Remove shadow
  BoxDecoration withoutShadow() {
    return copyWith(boxShadow: []);
  }

  /// Remove border
  BoxDecoration withoutBorder() {
    return BoxDecoration(
      color: color,
      image: image,
      gradient: gradient,
      boxShadow: boxShadow,
      borderRadius: borderRadius,
      shape: shape,
      backgroundBlendMode: backgroundBlendMode,
    );
  }

  /// Add gradient
  BoxDecoration withGradient(List<Color> colors, {
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return copyWith(
      gradient: LinearGradient(
        colors: colors,
        begin: begin,
        end: end,
      ),
    );
  }
}

/// Extensions for Color to provide utility methods
extension ColorExtension on Color {
  /// Get contrasting text color (black or white)
  Color get contrastText {
    return computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }

  /// Create subtle version for backgrounds
  Color subtle(bool isDark) {
    return withValues(alpha: isDark ? 0.15 : 0.1);
  }

  /// Create a lighter version of the color
  Color lighter([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    return Color.lerp(this, Colors.white, amount)!;
  }

  /// Create a darker version of the color
  Color darker([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    return Color.lerp(this, Colors.black, amount)!;
  }

  /// Convert to MaterialColor
  MaterialColor toMaterialColor() {
    final strengths = <double>[.05, .1, .2, .3, .4, .5, .6, .7, .8, .9];
    final swatch = <int, Color>{};

    // Get RGB values as integers (0-255)
    final int red = (r * 255).round();
    final int green = (g * 255).round();
    final int blue = (b * 255).round();

    for (var strength in strengths) {
      final ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        red + ((ds < 0 ? red : (255 - red)) * ds).round(),
        green + ((ds < 0 ? green : (255 - green)) * ds).round(),
        blue + ((ds < 0 ? blue : (255 - blue)) * ds).round(),
        1,
      );
    }
    return MaterialColor(toARGB32(), swatch);
  }
}

/// Extensions for BuildContext to easily access theme properties
extension ThemeContextExtension on BuildContext {
  /// Check if current theme is dark
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Get current color scheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Get current text theme
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Get primary color based on current theme
  Color get primaryColor => Theme.of(this).colorScheme.primary;

  /// Get surface color based on current theme
  Color get surfaceColor => Theme.of(this).colorScheme.surface;

  /// Get background color based on current theme
  Color get backgroundColor => Theme.of(this).scaffoldBackgroundColor;
}
