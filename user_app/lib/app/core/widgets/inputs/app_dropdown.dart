import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';

/// Dropdown selector with configurable items
/// Supports custom item builder and search functionality
class AppDropdown<T> extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final T? value;
  final List<AppDropdownItem<T>> items;
  final bool enabled;
  final bool searchable;
  final ValueChanged<T?>? onChanged;
  final String Function(T)? itemLabelBuilder;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final double? borderRadius;
  final Widget? prefixIcon;

  const AppDropdown({
    super.key,
    this.label,
    this.hint = 'Select an option',
    this.helperText,
    this.errorText,
    this.value,
    required this.items,
    this.enabled = true,
    this.searchable = false,
    this.onChanged,
    this.itemLabelBuilder,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.borderRadius,
    this.prefixIcon,
  });

  @override
  State<AppDropdown<T>> createState() => _AppDropdownState<T>();
}

class _AppDropdownState<T> extends State<AppDropdown<T>> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool hasError = widget.errorText != null && widget.errorText!.isNotEmpty;


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
          onTapDown: (_) => setState(() => _isFocused = true),
          onTapUp: (_) => setState(() => _isFocused = false),
          onTapCancel: () => setState(() => _isFocused = false),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius ?? AppTheme.radiusMedium),
              border: Border.all(
                color: hasError
                    ? AppColors.error
                    : _isFocused
                        ? (widget.focusedBorderColor ?? theme.colorScheme.primary)
                        : (widget.borderColor ?? theme.dividerColor),
                width: _isFocused || hasError ? 2.0 : 1.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular((widget.borderRadius ?? AppTheme.radiusMedium) - 2),
              child: Container(
                color: widget.enabled
                    ? (widget.fillColor ?? theme.cardColor)
                    : theme.colorScheme.surfaceContainerHighest,
                child: DropdownButtonHideUnderline(
              child: ButtonTheme(
                alignedDropdown: true,
                child: DropdownButton<T>(
                  value: widget.value,
                  hint: Text(
                    widget.hint ?? '',
                    style: AppTextStyles.bodyLarge.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  icon: Icon(
                    Icons.arrow_drop_down_rounded,
                    color: widget.enabled ? theme.colorScheme.onSurfaceVariant : theme.colorScheme.outline,
                    size: 24,
                  ),
                  isExpanded: true,
                  isDense: false,
                  style: AppTextStyles.bodyLarge.copyWith(color: theme.colorScheme.onSurface),
                  dropdownColor: theme.cardColor,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  padding: EdgeInsets.only(
                    left: widget.prefixIcon != null ? 8 : 20,
                    right: 12,
                  ),
                  onChanged: widget.enabled ? widget.onChanged : null,
                  items: widget.items.map((item) {
                    return DropdownMenuItem<T>(
                      value: item.value,
                      enabled: item.enabled,
                      child: Row(
                        children: [
                          if (item.icon != null) ...[
                            item.icon!,
                            const SizedBox(width: 12),
                          ],
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.itemLabelBuilder?.call(item.value) ?? item.label,
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    color: item.enabled ? theme.colorScheme.onSurface : theme.colorScheme.outline,
                                  ),
                                ),
                                if (item.subtitle != null)
                                  Text(
                                    item.subtitle!,
                                    style: AppTextStyles.caption.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  selectedItemBuilder: widget.prefixIcon != null
                      ? (context) {
                          return widget.items.map((item) {
                            return Row(
                              children: [
                                widget.prefixIcon!,
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    widget.itemLabelBuilder?.call(item.value) ?? item.label,
                                    style: AppTextStyles.bodyLarge.copyWith(color: theme.colorScheme.onSurface),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            );
                          }).toList();
                        }
                      : null,
                ),
              ),
            ),
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
            style: AppTextStyles.caption.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ],
    );
  }
}

/// Dropdown item model
class AppDropdownItem<T> {
  final T value;
  final String label;
  final String? subtitle;
  final Widget? icon;
  final bool enabled;

  const AppDropdownItem({
    required this.value,
    required this.label,
    this.subtitle,
    this.icon,
    this.enabled = true,
  });
}
