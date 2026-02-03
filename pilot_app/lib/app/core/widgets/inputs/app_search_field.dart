import 'package:flutter/material.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';

/// Search input field with search icon and clear button
/// Supports debouncing and custom styling
class AppSearchField extends StatefulWidget {
  final String? hint;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool enabled;
  final bool autofocus;
  final bool showClearButton;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? iconColor;
  final double? borderRadius;
  final EdgeInsets? contentPadding;
  final double? height;

  const AppSearchField({
    super.key,
    this.hint = 'Search...',
    this.controller,
    this.focusNode,
    this.enabled = true,
    this.autofocus = false,
    this.showClearButton = true,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.iconColor,
    this.borderRadius,
    this.contentPadding,
    this.height,
  });

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
    _controller.addListener(_onTextChange);
    _hasText = _controller.text.isNotEmpty;
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
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

  void _onTextChange() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  void _onClear() {
    _controller.clear();
    widget.onClear?.call();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = widget.borderRadius ?? AppTheme.radiusMedium;

    return Container(
      height: widget.height ?? 52,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: _isFocused
              ? (widget.focusedBorderColor ?? theme.colorScheme.primary)
              : (widget.borderColor ?? theme.dividerColor),
          width: _isFocused ? 2.0 : 1.5,
        ),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius - 2),
        child: Container(
          color: widget.fillColor ?? theme.cardColor,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Icon(
                  Icons.search_rounded,
                  color: _isFocused
                      ? (widget.iconColor ?? theme.colorScheme.primary)
                      : theme.colorScheme.onSurfaceVariant,
                  size: 22,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: widget.enabled,
                  autofocus: widget.autofocus,
                  textInputAction: TextInputAction.search,
                  style: AppTextStyles.bodyLarge.copyWith(color: theme.colorScheme.onSurface),
                  onChanged: widget.onChanged,
                  onSubmitted: widget.onSubmitted,
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: AppTextStyles.bodyLarge.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: widget.contentPadding ??
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                ),
              ),
              if (widget.showClearButton && _hasText)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    color: theme.colorScheme.onSurfaceVariant,
                    onPressed: _onClear,
                    splashRadius: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
