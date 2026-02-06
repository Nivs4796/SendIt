import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Hero toggle button for going online/offline
/// Takes up majority of screen when no active job
class OnlineToggleButton extends StatelessWidget {
  final bool isOnline;
  final bool isLoading;
  final VoidCallback onToggle;

  const OnlineToggleButton({
    super.key,
    required this.isOnline,
    required this.isLoading,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);

    return GestureDetector(
      onTap: isLoading ? null : onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: isOnline ? colors.primary : colors.surface,
          borderRadius: BorderRadius.circular(24),
          border: isOnline
              ? null
              : Border.all(color: colors.border, width: 1),
          boxShadow: isOnline
              ? [
                  BoxShadow(
                    color: colors.primaryGlow,
                    blurRadius: 40,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Pulse animation when online
            if (isOnline && !isLoading)
              _PulseAnimation(color: colors.textOnPrimary),

            // Content
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon or loading indicator
                if (isLoading)
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: isOnline ? colors.textOnPrimary : colors.primary,
                    ),
                  )
                else
                  Icon(
                    isOnline ? Icons.wifi_tethering : Icons.power_settings_new,
                    size: 32,
                    color: isOnline ? colors.textOnPrimary : colors.textPrimary,
                  ),

                const SizedBox(height: 16),

                // Main text
                Text(
                  isOnline ? 'ONLINE' : 'GO ONLINE',
                  style: AppTextStyles.h1.copyWith(
                    color: isOnline ? colors.textOnPrimary : colors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 8),

                // Subtext
                Text(
                  isOnline ? 'Accepting deliveries' : 'Tap to start earning',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isOnline
                        ? colors.textOnPrimary.withValues(alpha: 0.8)
                        : colors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Pulse animation widget for online state
class _PulseAnimation extends StatefulWidget {
  final Color color;

  const _PulseAnimation({required this.color});

  @override
  State<_PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<_PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 80 + (_animation.value * 40),
          height: 80 + (_animation.value * 40),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.color.withValues(alpha: 1.0 - _animation.value),
              width: 2,
            ),
          ),
        );
      },
    );
  }
}
