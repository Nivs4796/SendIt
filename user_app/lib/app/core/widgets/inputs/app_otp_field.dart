import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';

/// OTP/PIN input field with configurable length and styling
/// Uses Pinput package for smooth OTP input experience
class AppOtpField extends StatelessWidget {
  final int length;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool enabled;
  final bool autofocus;
  final bool obscureText;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;
  final bool showCursor;
  final double? pinWidth;
  final double? pinHeight;
  final double? spacing;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;
  final double? borderRadius;

  const AppOtpField({
    super.key,
    this.length = 6,
    this.controller,
    this.focusNode,
    this.enabled = true,
    this.autofocus = true,
    this.obscureText = false,
    this.errorText,
    this.onChanged,
    this.onCompleted,
    this.showCursor = true,
    this.pinWidth,
    this.pinHeight,
    this.spacing,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.borderRadius,
  });

  // 4-digit OTP variant
  const AppOtpField.fourDigit({
    super.key,
    this.controller,
    this.focusNode,
    this.enabled = true,
    this.autofocus = true,
    this.obscureText = false,
    this.errorText,
    this.onChanged,
    this.onCompleted,
    this.showCursor = true,
    this.pinWidth,
    this.pinHeight,
    this.spacing,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.borderRadius,
  }) : length = 4;

  // 6-digit OTP variant (default)
  const AppOtpField.sixDigit({
    super.key,
    this.controller,
    this.focusNode,
    this.enabled = true,
    this.autofocus = true,
    this.obscureText = false,
    this.errorText,
    this.onChanged,
    this.onCompleted,
    this.showCursor = true,
    this.pinWidth,
    this.pinHeight,
    this.spacing,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.borderRadius,
  }) : length = 6;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool hasError = errorText != null && errorText!.isNotEmpty;
    final double width = pinWidth ?? 56;
    final double height = pinHeight ?? 60;
    final double radius = borderRadius ?? AppTheme.radiusMedium;

    // Default pin theme
    final defaultPinTheme = PinTheme(
      width: width,
      height: height,
      textStyle: AppTextStyles.h3.copyWith(color: theme.colorScheme.onSurface),
      decoration: BoxDecoration(
        color: fillColor ?? theme.cardColor,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: borderColor ?? theme.dividerColor,
          width: 1.5,
        ),
      ),
    );

    // Focused pin theme
    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: fillColor ?? theme.cardColor,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: focusedBorderColor ?? theme.colorScheme.primary,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.15),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
    );

    // Submitted pin theme
    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: theme.colorScheme.primary,
          width: 1.5,
        ),
      ),
    );

    // Error pin theme
    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: errorBorderColor ?? AppColors.error,
          width: 1.5,
        ),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Pinput(
          length: length,
          controller: controller,
          focusNode: focusNode,
          enabled: enabled,
          autofocus: autofocus,
          obscureText: obscureText,
          showCursor: showCursor,
          defaultPinTheme: defaultPinTheme,
          focusedPinTheme: focusedPinTheme,
          submittedPinTheme: submittedPinTheme,
          errorPinTheme: errorPinTheme,
          forceErrorState: hasError,
          separatorBuilder: (index) => SizedBox(width: spacing ?? 12),
          hapticFeedbackType: HapticFeedbackType.lightImpact,
          closeKeyboardWhenCompleted: true,
          animationCurve: Curves.easeInOut,
          animationDuration: const Duration(milliseconds: 200),
          onChanged: onChanged,
          onCompleted: onCompleted,
        ),
        if (hasError) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.errorLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, size: 16, color: AppColors.error),
                const SizedBox(width: 6),
                Text(
                  errorText!,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
