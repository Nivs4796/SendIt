import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';

/// Multiline text area input for longer text content
/// Supports character count, min/max lines, and custom styling
class AppTextArea extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final int minLines;
  final int maxLines;
  final int? maxLength;
  final bool showCharacterCount;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final double? borderRadius;
  final EdgeInsets? contentPadding;

  const AppTextArea({
    super.key,
    this.label,
    this.hint = 'Enter text...',
    this.helperText,
    this.errorText,
    this.controller,
    this.focusNode,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.minLines = 3,
    this.maxLines = 6,
    this.maxLength,
    this.showCharacterCount = false,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.sentences,
    this.onChanged,
    this.onTap,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.borderRadius,
    this.contentPadding,
  });

  // Notes/Description variant
  const AppTextArea.notes({
    super.key,
    this.label = 'Notes',
    this.hint = 'Add notes or special instructions...',
    this.helperText,
    this.errorText,
    this.controller,
    this.focusNode,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLength = 500,
    this.textInputAction,
    this.onChanged,
    this.onTap,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.borderRadius,
    this.contentPadding,
  })  : minLines = 3,
        maxLines = 5,
        showCharacterCount = true,
        textCapitalization = TextCapitalization.sentences;

  // Address variant
  const AppTextArea.address({
    super.key,
    this.label = 'Address',
    this.hint = 'Enter full address...',
    this.helperText,
    this.errorText,
    this.controller,
    this.focusNode,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLength,
    this.textInputAction,
    this.onChanged,
    this.onTap,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.borderRadius,
    this.contentPadding,
  })  : minLines = 2,
        maxLines = 4,
        showCharacterCount = false,
        textCapitalization = TextCapitalization.words;

  @override
  State<AppTextArea> createState() => _AppTextAreaState();
}

class _AppTextAreaState extends State<AppTextArea> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  int _characterCount = 0;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
    if (widget.controller != null) {
      _characterCount = widget.controller!.text.length;
    }
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
    if (widget.showCharacterCount || widget.maxLength != null) {
      setState(() {
        _characterCount = value.length;
      });
    }
    widget.onChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final bool hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.label!,
                style: AppTextStyles.labelMedium.copyWith(
                  color: hasError ? AppColors.error : AppColors.textPrimary,
                ),
              ),
              if (widget.showCharacterCount && widget.maxLength != null)
                Text(
                  '$_characterCount/${widget.maxLength}',
                  style: AppTextStyles.caption.copyWith(
                    color: _characterCount > (widget.maxLength ?? 0)
                        ? AppColors.error
                        : AppColors.textSecondary,
                  ),
                ),
            ],
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
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                enabled: widget.enabled,
                readOnly: widget.readOnly,
                autofocus: widget.autofocus,
                minLines: widget.minLines,
                maxLines: widget.maxLines,
                maxLength: widget.maxLength,
                keyboardType: TextInputType.multiline,
                textInputAction: widget.textInputAction ?? TextInputAction.newline,
                textCapitalization: widget.textCapitalization,
                style: AppTextStyles.bodyLarge,
                onChanged: _onChanged,
                onTap: widget.onTap,
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: AppTextStyles.bodyLarge.copyWith(color: AppColors.textHint),
                  counterText: '',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: widget.contentPadding ?? const EdgeInsets.all(16),
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
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ],
    );
  }
}
