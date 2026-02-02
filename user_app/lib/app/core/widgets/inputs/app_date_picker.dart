import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';

/// Date picker field that opens a date picker dialog on tap
/// Supports date formatting and range constraints
class AppDatePicker extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final DateTime? value;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool enabled;
  final String dateFormat;
  final ValueChanged<DateTime>? onChanged;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final double? borderRadius;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const AppDatePicker({
    super.key,
    this.label,
    this.hint = 'Select date',
    this.helperText,
    this.errorText,
    this.value,
    this.firstDate,
    this.lastDate,
    this.enabled = true,
    this.dateFormat = 'dd MMM yyyy',
    this.onChanged,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.borderRadius,
    this.prefixIcon,
    this.suffixIcon,
  });

  // Birth date picker (only past dates)
  const AppDatePicker.birthDate({
    super.key,
    this.label = 'Date of Birth',
    this.hint = 'Select your birth date',
    this.helperText,
    this.errorText,
    this.value,
    this.enabled = true,
    this.onChanged,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.borderRadius,
    this.prefixIcon,
    this.suffixIcon,
  })  : firstDate = null,
        lastDate = null,
        dateFormat = 'dd MMM yyyy';

  // Future date picker (scheduling)
  const AppDatePicker.schedule({
    super.key,
    this.label = 'Schedule Date',
    this.hint = 'Select date',
    this.helperText,
    this.errorText,
    this.value,
    this.lastDate,
    this.enabled = true,
    this.onChanged,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.borderRadius,
    this.prefixIcon,
    this.suffixIcon,
  })  : firstDate = null,
        dateFormat = 'EEE, dd MMM yyyy';

  @override
  State<AppDatePicker> createState() => _AppDatePickerState();
}

class _AppDatePickerState extends State<AppDatePicker> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final String displayText = widget.value != null
        ? DateFormat(widget.dateFormat).format(widget.value!)
        : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTextStyles.labelMedium.copyWith(
              color: hasError ? AppColors.error : theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
        ],
        GestureDetector(
          onTap: widget.enabled ? _showDatePicker : null,
          onTapDown: (_) => setState(() => _isFocused = true),
          onTapUp: (_) => setState(() => _isFocused = false),
          onTapCancel: () => setState(() => _isFocused = false),
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: widget.enabled
                  ? (widget.fillColor ?? theme.cardColor)
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(widget.borderRadius ?? AppTheme.radiusMedium),
              border: Border.all(
                color: hasError
                    ? AppColors.error
                    : _isFocused
                        ? (widget.focusedBorderColor ?? theme.colorScheme.primary)
                        : (widget.borderColor ?? theme.dividerColor),
                width: _isFocused || hasError ? 2.0 : 1.5,
              ),
              boxShadow: _isFocused
                  ? [
                      BoxShadow(
                        color: (hasError ? AppColors.error : theme.colorScheme.primary).withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                if (widget.prefixIcon != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: widget.prefixIcon,
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Icon(
                      Icons.calendar_today_rounded,
                      color: widget.enabled ? theme.colorScheme.onSurfaceVariant : theme.colorScheme.outline,
                      size: 20,
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    displayText.isNotEmpty ? displayText : (widget.hint ?? ''),
                    style: displayText.isNotEmpty
                        ? AppTextStyles.bodyLarge.copyWith(color: theme.colorScheme.onSurface)
                        : AppTextStyles.bodyLarge.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
                if (widget.suffixIcon != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: widget.suffixIcon,
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Icon(
                      Icons.arrow_drop_down_rounded,
                      color: widget.enabled ? theme.colorScheme.onSurfaceVariant : theme.colorScheme.outline,
                      size: 24,
                    ),
                  ),
              ],
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
            style: AppTextStyles.caption.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ],
    );
  }

  Future<void> _showDatePicker() async {
    final theme = Theme.of(context);
    final DateTime now = DateTime.now();
    final DateTime firstDate = widget.firstDate ?? DateTime(1900);
    final DateTime lastDate = widget.lastDate ?? DateTime(2100);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.value ?? now,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: theme.colorScheme.primary,
              onPrimary: theme.colorScheme.onPrimary,
              surface: theme.colorScheme.surface,
              onSurface: theme.colorScheme.onSurface,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: theme.colorScheme.surface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      widget.onChanged?.call(picked);
    }
  }
}
