import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

/// Configurable button widget with multiple variants
/// Primary, Secondary, Outline, Text, and Icon button types
class AppButton extends StatelessWidget {
  final String? text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final bool isDisabled;
  final bool isFullWidth;
  final IconData? icon;
  final IconData? suffixIcon;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double? borderRadius;
  final EdgeInsets? padding;

  const AppButton({
    super.key,
    this.text,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.isFullWidth = true,
    this.icon,
    this.suffixIcon,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.borderRadius,
    this.padding,
  });

  // Named constructors for common variants
  const AppButton.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.isFullWidth = true,
    this.icon,
    this.suffixIcon,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.borderRadius,
    this.padding,
  }) : variant = AppButtonVariant.primary;

  const AppButton.secondary({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.isFullWidth = true,
    this.icon,
    this.suffixIcon,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.borderRadius,
    this.padding,
  }) : variant = AppButtonVariant.secondary;

  const AppButton.outline({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.isFullWidth = true,
    this.icon,
    this.suffixIcon,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.borderRadius,
    this.padding,
  }) : variant = AppButtonVariant.outline;

  const AppButton.text({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.isFullWidth = false,
    this.icon,
    this.suffixIcon,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.borderRadius,
    this.padding,
  }) : variant = AppButtonVariant.text;

  const AppButton.icon({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.borderRadius,
    this.padding,
  })  : variant = AppButtonVariant.icon,
        text = null,
        suffixIcon = null,
        isFullWidth = false;

  // Danger/destructive button
  const AppButton.danger({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.isFullWidth = true,
    this.icon,
    this.suffixIcon,
    this.borderColor,
    this.borderRadius,
    this.padding,
  })  : variant = AppButtonVariant.primary,
        backgroundColor = AppColors.error,
        textColor = AppColors.white;

  @override
  Widget build(BuildContext context) {
    final bool disabled = isDisabled || isLoading;

    switch (variant) {
      case AppButtonVariant.primary:
        return _buildElevatedButton(disabled);
      case AppButtonVariant.secondary:
        return _buildSecondaryButton(disabled);
      case AppButtonVariant.outline:
        return _buildOutlineButton(disabled);
      case AppButtonVariant.text:
        return _buildTextButton(disabled);
      case AppButtonVariant.icon:
        return _buildIconButton(disabled);
    }
  }

  Widget _buildElevatedButton(bool disabled) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: _getHeight(),
      child: ElevatedButton(
        onPressed: disabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          foregroundColor: textColor ?? AppColors.white,
          disabledBackgroundColor: AppColors.grey300,
          disabledForegroundColor: AppColors.grey500,
          elevation: 0,
          padding: padding ?? _getPadding(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? AppTheme.radiusMedium),
          ),
        ),
        child: _buildButtonContent(textColor ?? AppColors.white),
      ),
    );
  }

  Widget _buildSecondaryButton(bool disabled) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: _getHeight(),
      child: ElevatedButton(
        onPressed: disabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primaryContainer,
          foregroundColor: textColor ?? AppColors.primary,
          disabledBackgroundColor: AppColors.grey200,
          disabledForegroundColor: AppColors.grey500,
          elevation: 0,
          padding: padding ?? _getPadding(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? AppTheme.radiusMedium),
          ),
        ),
        child: _buildButtonContent(textColor ?? AppColors.primary),
      ),
    );
  }

  Widget _buildOutlineButton(bool disabled) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: _getHeight(),
      child: OutlinedButton(
        onPressed: disabled ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor ?? AppColors.primary,
          disabledForegroundColor: AppColors.grey500,
          side: BorderSide(
            color: disabled ? AppColors.grey300 : (borderColor ?? AppColors.primary),
            width: 1.5,
          ),
          padding: padding ?? _getPadding(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? AppTheme.radiusMedium),
          ),
        ),
        child: _buildButtonContent(textColor ?? AppColors.primary),
      ),
    );
  }

  Widget _buildTextButton(bool disabled) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: _getHeight(),
      child: TextButton(
        onPressed: disabled ? null : onPressed,
        style: TextButton.styleFrom(
          foregroundColor: textColor ?? AppColors.primary,
          disabledForegroundColor: AppColors.grey500,
          padding: padding ?? _getPadding(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? AppTheme.radiusMedium),
          ),
        ),
        child: _buildButtonContent(textColor ?? AppColors.primary),
      ),
    );
  }

  Widget _buildIconButton(bool disabled) {
    final double iconSize = _getIconSize();
    return Container(
      width: _getHeight(),
      height: _getHeight(),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(borderRadius ?? AppTheme.radiusMedium),
      ),
      child: IconButton(
        onPressed: disabled ? null : onPressed,
        icon: isLoading
            ? SizedBox(
                width: iconSize * 0.8,
                height: iconSize * 0.8,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: textColor ?? AppColors.primary,
                ),
              )
            : Icon(
                icon,
                size: iconSize,
                color: disabled ? AppColors.grey500 : (textColor ?? AppColors.primary),
              ),
      ),
    );
  }

  Widget _buildButtonContent(Color contentColor) {
    if (isLoading) {
      return SizedBox(
        height: _getIconSize(),
        width: _getIconSize(),
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: contentColor,
        ),
      );
    }

    final List<Widget> children = [];

    if (icon != null) {
      children.add(Icon(icon, size: _getIconSize()));
      if (text != null) children.add(const SizedBox(width: 8));
    }

    if (text != null) {
      children.add(
        Text(
          text!,
          style: _getTextStyle().copyWith(color: contentColor),
        ),
      );
    }

    if (suffixIcon != null) {
      if (text != null) children.add(const SizedBox(width: 8));
      children.add(Icon(suffixIcon, size: _getIconSize()));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  double _getHeight() {
    switch (size) {
      case AppButtonSize.small:
        return 40;
      case AppButtonSize.medium:
        return 52;
      case AppButtonSize.large:
        return 60;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case AppButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 14);
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 18);
    }
  }

  double _getIconSize() {
    switch (size) {
      case AppButtonSize.small:
        return 18;
      case AppButtonSize.medium:
        return 20;
      case AppButtonSize.large:
        return 24;
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case AppButtonSize.small:
        return AppTextStyles.buttonSmall;
      case AppButtonSize.medium:
        return AppTextStyles.button;
      case AppButtonSize.large:
        return AppTextStyles.button.copyWith(fontSize: 18);
    }
  }
}

enum AppButtonVariant {
  primary,
  secondary,
  outline,
  text,
  icon,
}

enum AppButtonSize {
  small,
  medium,
  large,
}
