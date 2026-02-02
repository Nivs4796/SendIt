import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Configurable text widget with predefined style variants
/// Uses AppTextStyles for consistent typography across the app
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
  });

  // Named constructors for common variants
  const AppText.h1(this.text, {super.key, this.color, this.textAlign, this.maxLines, this.overflow, this.softWrap, this.letterSpacing, this.fontWeight, this.decoration})
      : variant = AppTextVariant.h1;

  const AppText.h2(this.text, {super.key, this.color, this.textAlign, this.maxLines, this.overflow, this.softWrap, this.letterSpacing, this.fontWeight, this.decoration})
      : variant = AppTextVariant.h2;

  const AppText.h3(this.text, {super.key, this.color, this.textAlign, this.maxLines, this.overflow, this.softWrap, this.letterSpacing, this.fontWeight, this.decoration})
      : variant = AppTextVariant.h3;

  const AppText.h4(this.text, {super.key, this.color, this.textAlign, this.maxLines, this.overflow, this.softWrap, this.letterSpacing, this.fontWeight, this.decoration})
      : variant = AppTextVariant.h4;

  const AppText.bodyLarge(this.text, {super.key, this.color, this.textAlign, this.maxLines, this.overflow, this.softWrap, this.letterSpacing, this.fontWeight, this.decoration})
      : variant = AppTextVariant.bodyLarge;

  const AppText.bodyMedium(this.text, {super.key, this.color, this.textAlign, this.maxLines, this.overflow, this.softWrap, this.letterSpacing, this.fontWeight, this.decoration})
      : variant = AppTextVariant.bodyMedium;

  const AppText.bodySmall(this.text, {super.key, this.color, this.textAlign, this.maxLines, this.overflow, this.softWrap, this.letterSpacing, this.fontWeight, this.decoration})
      : variant = AppTextVariant.bodySmall;

  const AppText.label(this.text, {super.key, this.color, this.textAlign, this.maxLines, this.overflow, this.softWrap, this.letterSpacing, this.fontWeight, this.decoration})
      : variant = AppTextVariant.labelMedium;

  const AppText.caption(this.text, {super.key, this.color, this.textAlign, this.maxLines, this.overflow, this.softWrap, this.letterSpacing, this.fontWeight, this.decoration})
      : variant = AppTextVariant.caption;

  const AppText.button(this.text, {super.key, this.color, this.textAlign, this.maxLines, this.overflow, this.softWrap, this.letterSpacing, this.fontWeight, this.decoration})
      : variant = AppTextVariant.button;

  const AppText.price(this.text, {super.key, this.color, this.textAlign, this.maxLines, this.overflow, this.softWrap, this.letterSpacing, this.fontWeight, this.decoration})
      : variant = AppTextVariant.price;

  // Error text helper
  const AppText.error(this.text, {super.key, this.textAlign, this.maxLines, this.overflow, this.softWrap, this.letterSpacing, this.fontWeight, this.decoration})
      : variant = AppTextVariant.bodySmall,
        color = AppColors.error;

  // Secondary text helper
  const AppText.secondary(this.text, {super.key, this.textAlign, this.maxLines, this.overflow, this.softWrap, this.letterSpacing, this.fontWeight, this.decoration})
      : variant = AppTextVariant.bodyMedium,
        color = AppColors.textSecondary;

  @override
  Widget build(BuildContext context) {
    TextStyle baseStyle = _getBaseStyle();

    // Apply overrides
    if (color != null || letterSpacing != null || fontWeight != null || decoration != null) {
      baseStyle = baseStyle.copyWith(
        color: color,
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
