import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';

/// Currency input field with symbol prefix and formatting
/// Supports different currencies and decimal precision
class AppCurrencyField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final String currencySymbol;
  final int decimalPlaces;
  final double? minValue;
  final double? maxValue;
  final TextInputAction? textInputAction;
  final ValueChanged<double?>? onChanged;
  final VoidCallback? onTap;
  final VoidCallback? onEditingComplete;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final double? borderRadius;

  const AppCurrencyField({
    super.key,
    this.label,
    this.hint = '0.00',
    this.helperText,
    this.errorText,
    this.controller,
    this.focusNode,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.currencySymbol = '₹',
    this.decimalPlaces = 2,
    this.minValue,
    this.maxValue,
    this.textInputAction,
    this.onChanged,
    this.onTap,
    this.onEditingComplete,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.borderRadius,
  });

  // Indian Rupee variant
  const AppCurrencyField.inr({
    super.key,
    this.label = 'Amount',
    this.hint = '0.00',
    this.helperText,
    this.errorText,
    this.controller,
    this.focusNode,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.minValue,
    this.maxValue,
    this.textInputAction,
    this.onChanged,
    this.onTap,
    this.onEditingComplete,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.borderRadius,
  })  : currencySymbol = '₹',
        decimalPlaces = 2;

  // US Dollar variant
  const AppCurrencyField.usd({
    super.key,
    this.label = 'Amount',
    this.hint = '0.00',
    this.helperText,
    this.errorText,
    this.controller,
    this.focusNode,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.minValue,
    this.maxValue,
    this.textInputAction,
    this.onChanged,
    this.onTap,
    this.onEditingComplete,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.borderRadius,
  })  : currencySymbol = '\$',
        decimalPlaces = 2;

  @override
  State<AppCurrencyField> createState() => _AppCurrencyFieldState();
}

class _AppCurrencyFieldState extends State<AppCurrencyField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _onChanged(String value) {
    if (value.isEmpty) {
      widget.onChanged?.call(null);
      return;
    }

    // Parse the value
    final double? parsed = double.tryParse(value.replaceAll(',', ''));
    widget.onChanged?.call(parsed);
  }

  @override
  Widget build(BuildContext context) {
    final bool hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTextStyles.labelMedium.copyWith(
              color: hasError ? AppColors.error : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius ?? AppTheme.radiusMedium),
            border: Border.all(
              color: hasError
                  ? AppColors.error
                  : _isFocused
                      ? (widget.focusedBorderColor ?? AppColors.primary)
                      : (widget.borderColor ?? AppColors.grey300),
              width: _isFocused || hasError ? 2.0 : 1.5,
            ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: (hasError ? AppColors.error : AppColors.primary).withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular((widget.borderRadius ?? AppTheme.radiusMedium) - 2),
            child: Container(
              color: widget.fillColor ?? AppColors.white,
              child: Row(
                children: [
                  // Currency Symbol
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    decoration: const BoxDecoration(
                      border: Border(
                        right: BorderSide(color: AppColors.grey300, width: 1),
                      ),
                    ),
                    child: Text(
                      widget.currencySymbol,
                      style: AppTextStyles.h4.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  // Amount Input
                  Expanded(
                    child: TextField(
                      controller: widget.controller,
                      focusNode: _focusNode,
                      enabled: widget.enabled,
                      readOnly: widget.readOnly,
                      autofocus: widget.autofocus,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: widget.decimalPlaces > 0,
                      ),
                      textInputAction: widget.textInputAction,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,' + widget.decimalPlaces.toString() + r'}'),
                        ),
                        _CurrencyInputFormatter(
                          minValue: widget.minValue,
                          maxValue: widget.maxValue,
                        ),
                      ],
                      style: AppTextStyles.h4.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.left,
                      onChanged: _onChanged,
                      onTap: widget.onTap,
                      onEditingComplete: widget.onEditingComplete,
                      decoration: InputDecoration(
                        hintText: widget.hint,
                        hintStyle: AppTextStyles.h4.copyWith(
                          color: AppColors.textHint,
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.error_outline_rounded, size: 14, color: AppColors.error),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  widget.errorText!,
                  style: AppTextStyles.caption.copyWith(color: AppColors.error),
                ),
              ),
            ],
          ),
        ] else if (widget.helperText != null) ...[
          const SizedBox(height: 6),
          Text(
            widget.helperText!,
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ],
    );
  }
}

/// Custom input formatter for currency values
class _CurrencyInputFormatter extends TextInputFormatter {
  final double? minValue;
  final double? maxValue;

  _CurrencyInputFormatter({this.minValue, this.maxValue});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final double? value = double.tryParse(newValue.text);
    if (value == null) {
      return oldValue;
    }

    // Check min/max constraints
    if (minValue != null && value < minValue!) {
      return oldValue;
    }
    if (maxValue != null && value > maxValue!) {
      return oldValue;
    }

    return newValue;
  }
}
