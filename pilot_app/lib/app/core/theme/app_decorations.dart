import 'package:flutter/material.dart';

/// Common BoxDecoration presets for consistent UI styling across the app.
/// All decorations are theme-aware and adapt to dark/light mode.
class AppDecorations {
  AppDecorations._();

  // ============================================
  // CARD DECORATIONS
  // ============================================

  /// Standard card decoration with subtle border and shadow
  static BoxDecoration card(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark
          ? const Color(0xFF1E293B).withOpacity(0.8)
          : Colors.white.withOpacity(0.95),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isDark
            ? const Color(0xFF34D399).withOpacity(0.15)
            : const Color(0xFF10B981).withOpacity(0.3),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
          blurRadius: isDark ? 16 : 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Elevated card with stronger shadow
  static BoxDecoration cardElevated(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark
          ? const Color(0xFF334155).withOpacity(0.9)
          : Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isDark
            ? const Color(0xFF34D399).withOpacity(0.2)
            : const Color(0xFF10B981).withOpacity(0.4),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(isDark ? 0.4 : 0.12),
          blurRadius: isDark ? 24 : 16,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  /// Flat card without shadow
  static BoxDecoration cardFlat(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark
          ? const Color(0xFF1E293B).withOpacity(0.6)
          : Colors.white.withOpacity(0.9),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isDark
            ? const Color(0xFF334155)
            : const Color(0xFFE2E8F0),
      ),
    );
  }

  // ============================================
  // INPUT DECORATIONS
  // ============================================

  /// Standard input field decoration
  static BoxDecoration input(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark
          ? const Color(0xFF1E293B).withOpacity(0.6)
          : const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: isDark
            ? const Color(0xFF334155)
            : const Color(0xFFE2E8F0),
      ),
    );
  }

  /// Focused input field decoration
  static BoxDecoration inputFocused(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark
          ? const Color(0xFF1E293B).withOpacity(0.8)
          : Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: isDark
            ? const Color(0xFF34D399)
            : const Color(0xFF10B981),
        width: 2,
      ),
      boxShadow: [
        BoxShadow(
          color: (isDark ? const Color(0xFF34D399) : const Color(0xFF10B981))
              .withOpacity(0.2),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  /// Error state input decoration
  static BoxDecoration inputError(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark
          ? const Color(0xFF1E293B).withOpacity(0.6)
          : const Color(0xFFFEF2F2),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: isDark
            ? const Color(0xFFF87171)
            : const Color(0xFFEF4444),
        width: 1.5,
      ),
    );
  }

  // ============================================
  // BUTTON DECORATIONS
  // ============================================

  /// Primary button decoration
  static BoxDecoration primaryButton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      gradient: LinearGradient(
        colors: isDark
            ? [const Color(0xFF34D399), const Color(0xFF10B981)]
            : [const Color(0xFF10B981), const Color(0xFF059669)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: (isDark ? const Color(0xFF34D399) : const Color(0xFF10B981))
              .withOpacity(0.3),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Secondary button decoration
  static BoxDecoration secondaryButton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark
          ? const Color(0xFF334155)
          : const Color(0xFFF1F5F9),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: isDark
            ? const Color(0xFF475569)
            : const Color(0xFFE2E8F0),
      ),
    );
  }

  /// Outline button decoration
  static BoxDecoration outlineButton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: isDark
            ? const Color(0xFF34D399)
            : const Color(0xFF10B981),
        width: 1.5,
      ),
    );
  }

  // ============================================
  // CONTAINER DECORATIONS
  // ============================================

  /// Bottom sheet decoration
  static BoxDecoration bottomSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark
          ? const Color(0xFF1E293B)
          : Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      border: Border(
        top: BorderSide(
          color: isDark
              ? const Color(0xFF34D399).withOpacity(0.2)
              : const Color(0xFF10B981).withOpacity(0.3),
        ),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(isDark ? 0.4 : 0.15),
          blurRadius: 20,
          offset: const Offset(0, -4),
        ),
      ],
    );
  }

  /// Dialog decoration
  static BoxDecoration dialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark
          ? const Color(0xFF1E293B)
          : Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: isDark
            ? const Color(0xFF34D399).withOpacity(0.15)
            : const Color(0xFF10B981).withOpacity(0.2),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(isDark ? 0.5 : 0.2),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  /// App bar decoration
  static BoxDecoration appBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark
          ? const Color(0xFF0F172A).withOpacity(0.95)
          : Colors.white.withOpacity(0.95),
      border: Border(
        bottom: BorderSide(
          color: isDark
              ? const Color(0xFF334155)
              : const Color(0xFFE2E8F0),
        ),
      ),
    );
  }

  // ============================================
  // SPECIAL DECORATIONS
  // ============================================

  /// Subtle glass effect (no heavy blur for performance)
  static BoxDecoration glass(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark
          ? const Color(0xFF1E293B).withOpacity(0.7)
          : Colors.white.withOpacity(0.8),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isDark
            ? Colors.white.withOpacity(0.1)
            : Colors.white.withOpacity(0.5),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Background gradient decoration
  static BoxDecoration gradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      gradient: LinearGradient(
        colors: isDark
            ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
            : [const Color(0xFFECFDF5), const Color(0xFFF0FDF4)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    );
  }

  /// Badge decoration with custom color
  static BoxDecoration badge(BuildContext context, Color color) {
    return BoxDecoration(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: color.withOpacity(0.3),
      ),
    );
  }

  /// Status badge (success, warning, error, info)
  static BoxDecoration statusBadge(BuildContext context, String status) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color color;
    switch (status.toLowerCase()) {
      case 'success':
        color = isDark ? const Color(0xFF34D399) : const Color(0xFF10B981);
        break;
      case 'warning':
        color = isDark ? const Color(0xFFFBBF24) : const Color(0xFFF59E0B);
        break;
      case 'error':
        color = isDark ? const Color(0xFFF87171) : const Color(0xFFEF4444);
        break;
      case 'info':
      default:
        color = isDark ? const Color(0xFF60A5FA) : const Color(0xFF3B82F6);
    }
    return badge(context, color);
  }
}
