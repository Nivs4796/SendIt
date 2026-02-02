import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';

/// Configurable text widget with predefined style variants
/// Uses AppTextStyles for consistent typography across the app
/// Theme-aware: adapts colors based on light/dark mode
class AppText extends StatelessWidget {
  final String text;
  final AppTextVariant variant;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;
  final double? letterSpacing;
  final FontWeight? fontWeight;
  final TextDecoration? decoration;
  final bool _isErrorText;
  final bool _isSecondaryText;

  const AppText(
    this.text, {
    super.key,
    this.variant = AppTextVariant.bodyMedium,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.letterSpacing,
    this.fontWeight,
    this.decoration,
  })  : _isErrorText = false,
        _isSecondaryText = false;

  // Named constructors for common variants
  const AppText.h1(this.text, {super.key, this.color, this.textAlign, this.maxLines, this.overflow, this.softWrap, this.letterSpacing, this.fontWeight, this.decoration})
      : variant = AppTextVariant.h1, _isErrorText = false, _isSecondaryText = false;

  const AppText.h2(this.text, {super.key, this.color, this.textAlign, this.maxLines, this.overflow, this.softWrap, this.letterSpacing, this.fontWeight, this.decoration})
      : variant = AppTextVariant.h2, _isErrorText = false, _isSecondaryText = false;

  const AppText.h3(this.text, {super.key, this.color, this.textAlign, this.maxLines, this.overflow, this.softWrap, this.letterSpacing, this.fontWeight, this.decoration})
      : variant = AppTextVariant.h3, _isErrorText = false, _isSecondaryText = false;

  const AppText.h4(this.text, {super.key, this.color, this.textAlign, this.maxLines, this.overflow, this.softWrap, this.letterSpacing, this.fontWeight, this.decoration})
      : variant = AppTextVariant.h4, _isErrorText = false, _isSecondaryText = false;

  const AppText.bodyLarge(this.text, {super.key, this.color, this.textAlign, this.maxLines, this.overflow, this.softWrap, this.letterSpacing, this.fontWeight, this.decoration})
      : variant = AppTextVariant.bodyLarge, _isErrorText = false, _isSecondaryText = false;

  const AppText.bodyMedium(this.text, {super.key, this.color, this.textAlign, this.maxLines, this.overflow, this.softWrap, this.letterSpacing, this.fontWeight, this.decoration})
      : variant = AppTextVariant.bodyMedium, _isErrorText = false, _isSecondaryText = false;

  const AppText.bodySmall(this.text, {super.key, this.color, this.textAlign, this.maxLines, this.overflow, this.softWrap, this.letterSpacing, this.fontWeight, this.decoration})
      : variant = AppTextVariant.bodySmall, _isErrorText = false, _isSecondaryText = false;

  const AppText.label(this.text, {super.key, this.color, this.textAlign, this.maxLines, this.overflow, this.softWrap, this.letterSpacing, this.fontWeight, this.decoration})
      : variant = AppTextVariant.labelMedium, _isErrorText = false, _isSecondaryText = false;

  const AppText.caption(this.text, {super.key, this.color, this.textAlign, this.maxLines, this.overflow, this.softWrap, this.letterSpacing, this.fontWeight, this.decoration})
      : variant = AppTextVariant.caption, _isErrorText = false, _isSecondaryText = false;

  const AppText.button(this.text, {super.key, this.color, this.textAlign, this.maxLines, this.overflow, this.softWrap, this.letterSpacing, this.fontWeight, this.decoration})
      : variant = AppTextVariant.button, _isErrorText = false, _isSecondaryText = false;

  const AppText.price(this.text, {super.key, this.color, this.textAlign, this.maxLines, this.overflow, this.softWrap, this.letterSpacing, this.fontWeight, this.decoration})
      : variant = AppTextVariant.price, _isErrorText = false, _isSecondaryText = false;

  // Error text helper - uses theme error color
  const AppText.error(this.text, {super.key, this.textAlign, this.maxLines, this.overflow, this.softWrap, this.letterSpacing, this.fontWeight, this.decoration})
      : variant = AppTextVariant.bodySmall,
        color = null,
        _isErrorText = true,
        _isSecondaryText = false;

  // Secondary text helper - uses theme secondary color
  const AppText.secondary(this.text, {super.key, this.textAlign, this.maxLines, this.overflow, this.softWrap, this.letterSpacing, this.fontWeight, this.decoration})
      : variant = AppTextVariant.bodyMedium,
        color = null,
        _isErrorText = false,
        _isSecondaryText = true;

  @override
  Widget build(BuildContext context) {
    TextStyle baseStyle = _getBaseStyle();

    // Determine the effective color
    Color? effectiveColor = color;
    if (_isErrorText) {
      effectiveColor = Theme.of(context).colorScheme.error;
    } else if (_isSecondaryText) {
      effectiveColor = Theme.of(context).colorScheme.onSurfaceVariant;
    }

    // Apply overrides
    if (effectiveColor != null || letterSpacing != null || fontWeight != null || decoration != null) {
      baseStyle = baseStyle.copyWith(
        color: effectiveColor,
        letterSpacing: letterSpacing,
        fontWeight: fontWeight,
        decoration: decoration,
      );
    }

    return Text(
      text,
      style: baseStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
    );
  }

  TextStyle _getBaseStyle() {
    switch (variant) {
      case AppTextVariant.h1:
        return AppTextStyles.h1;
      case AppTextVariant.h2:
        return AppTextStyles.h2;
      case AppTextVariant.h3:
        return AppTextStyles.h3;
      case AppTextVariant.h4:
        return AppTextStyles.h4;
      case AppTextVariant.bodyLarge:
        return AppTextStyles.bodyLarge;
      case AppTextVariant.bodyMedium:
        return AppTextStyles.bodyMedium;
      case AppTextVariant.bodySmall:
        return AppTextStyles.bodySmall;
      case AppTextVariant.labelLarge:
        return AppTextStyles.labelLarge;
      case AppTextVariant.labelMedium:
        return AppTextStyles.labelMedium;
      case AppTextVariant.labelSmall:
        return AppTextStyles.labelSmall;
      case AppTextVariant.button:
        return AppTextStyles.button;
      case AppTextVariant.caption:
        return AppTextStyles.caption;
      case AppTextVariant.price:
        return AppTextStyles.price;
      case AppTextVariant.priceSmall:
        return AppTextStyles.priceSmall;
    }
  }
}

enum AppTextVariant {
  h1,
  h2,
  h3,
  h4,
  bodyLarge,
  bodyMedium,
  bodySmall,
  labelLarge,
  labelMedium,
  labelSmall,
  button,
  caption,
  price,
  priceSmall,
}
