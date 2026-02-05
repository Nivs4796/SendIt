import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../controllers/jobs_controller.dart';

/// Popup dialog for incoming job offers with countdown timer
class JobOfferPopup extends StatefulWidget {
  final JobOffer offer;

  const JobOfferPopup({
    super.key,
    required this.offer,
  });

  @override
  State<JobOfferPopup> createState() => _JobOfferPopupState();
}

class _JobOfferPopupState extends State<JobOfferPopup>
    with SingleTickerProviderStateMixin {
  late final JobsController _controller;
  late int _remainingSeconds;
  Timer? _timer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<JobsController>();
    _remainingSeconds = widget.offer.remainingSeconds;
    
    // Start countdown
    _startTimer();
    
    // Pulse animation for timer
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      setState(() {
        _remainingSeconds = widget.offer.remainingSeconds;
      });
      
      // Auto-decline when expired
      if (_remainingSeconds <= 0) {
        timer.cancel();
        _controller.declineOffer(reason: 'timeout');
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopScope(
      canPop: false, // Prevent back button
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: theme.brightness == Brightness.dark ? 0.4 : 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Timer Header
              _buildTimerHeader(context),

              // Job Details
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Fare & Distance
                    _buildFareSection(context),

                    const SizedBox(height: 20),

                    // Pickup & Drop
                    _buildAddressSection(context),

                    const SizedBox(height: 20),

                    // Package Type
                    if (widget.offer.packageType != null)
                      _buildPackageInfo(context),

                    const SizedBox(height: 24),

                    // Action Buttons
                    _buildActionButtons(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimerHeader(BuildContext context) {
    final theme = Theme.of(context);
    final isUrgent = _remainingSeconds <= 10;
    final errorColor = theme.brightness == Brightness.dark
        ? const Color(0xFFF87171)
        : Colors.red.shade500;
    final headerColor = isUrgent ? errorColor : theme.colorScheme.primary;
    final onHeaderColor = theme.colorScheme.onPrimary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: headerColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Text(
            'NEW JOB REQUEST',
            style: AppTextStyles.labelMedium.copyWith(
              color: onHeaderColor.withValues(alpha: 0.8),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: isUrgent ? _pulseAnimation.value : 1.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    color: onHeaderColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer,
                        color: onHeaderColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_remainingSeconds}s',
                        style: AppTextStyles.h2.copyWith(
                          color: onHeaderColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFareSection(BuildContext context) {
    final theme = Theme.of(context);
    final infoColor = theme.brightness == Brightness.dark
        ? const Color(0xFF60A5FA)
        : Colors.blue;

    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            context,
            icon: Icons.currency_rupee,
            label: 'Fare',
            value: '₹${widget.offer.fare.toStringAsFixed(0)}',
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInfoCard(
            context,
            icon: Icons.route,
            label: 'Distance',
            value: '${widget.offer.distance.toStringAsFixed(1)} km',
            color: infoColor,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.h3.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection(BuildContext context) {
    final theme = Theme.of(context);
    final successColor = theme.brightness == Brightness.dark
        ? const Color(0xFF34D399)
        : Colors.green;
    final errorColor = theme.brightness == Brightness.dark
        ? const Color(0xFFF87171)
        : Colors.red;

    return Column(
      children: [
        // Pickup
        _buildAddressRow(
          context,
          icon: Icons.radio_button_checked,
          color: successColor,
          address: widget.offer.pickupAddress.address,
          label: 'Pickup',
        ),

        // Dotted line connector
        Container(
          margin: const EdgeInsets.only(left: 11),
          height: 24,
          child: CustomPaint(
            painter: _DottedLinePainter(color: theme.dividerColor),
          ),
        ),

        // Drop
        _buildAddressRow(
          context,
          icon: Icons.location_on,
          color: errorColor,
          address: widget.offer.dropAddress.address,
          label: 'Drop',
        ),
      ],
    );
  }

  Widget _buildAddressRow(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String address,
    required String label,
  }) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                address,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPackageInfo(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.inventory_2_outlined, color: theme.colorScheme.onSurfaceVariant, size: 20),
          const SizedBox(width: 8),
          Text(
            widget.offer.packageType!,
            style: AppTextStyles.bodyMedium.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Obx(() => Row(
      children: [
        // Decline Button
        Expanded(
          child: AppButton(
            text: 'Decline',
            onPressed: _controller.isDeclining.value 
                ? null 
                : () => _controller.declineOffer(),
            isLoading: _controller.isDeclining.value,
            variant: AppButtonVariant.outline,
            size: AppButtonSize.large,
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Accept Button
        Expanded(
          flex: 2,
          child: AppButton(
            text: 'Accept Job',
            onPressed: _controller.isAccepting.value 
                ? null 
                : () => _controller.acceptOffer(),
            isLoading: _controller.isAccepting.value,
            variant: AppButtonVariant.primary,
            size: AppButtonSize.large,
          ),
        ),
      ],
    ));
  }
}

/// Painter for dotted line between pickup and drop
class _DottedLinePainter extends CustomPainter {
  final Color color;

  _DottedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    const dashHeight = 4.0;
    const dashSpace = 4.0;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(0, startY),
        Offset(0, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
