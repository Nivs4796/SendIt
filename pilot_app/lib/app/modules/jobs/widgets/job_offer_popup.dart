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
    return PopScope(
      canPop: false, // Prevent back button
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Timer Header
              _buildTimerHeader(),
              
              // Job Details
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Fare & Distance
                    _buildFareSection(),
                    
                    const SizedBox(height: 20),
                    
                    // Pickup & Drop
                    _buildAddressSection(),
                    
                    const SizedBox(height: 20),
                    
                    // Package Type
                    if (widget.offer.packageType != null)
                      _buildPackageInfo(),
                    
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

  Widget _buildTimerHeader() {
    final isUrgent = _remainingSeconds <= 10;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: isUrgent ? Colors.red.shade500 : AppColors.primary,
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
              color: Colors.white.withValues(alpha: 0.8),
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
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.timer,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_remainingSeconds}s',
                        style: AppTextStyles.h2.copyWith(
                          color: Colors.white,
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

  Widget _buildFareSection() {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            icon: Icons.currency_rupee,
            label: 'Fare',
            value: '₹${widget.offer.fare.toStringAsFixed(0)}',
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInfoCard(
            icon: Icons.route,
            label: 'Distance',
            value: '${widget.offer.distance.toStringAsFixed(1)} km',
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
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
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection() {
    return Column(
      children: [
        // Pickup
        _buildAddressRow(
          icon: Icons.radio_button_checked,
          color: Colors.green,
          address: widget.offer.pickupAddress.address,
          label: 'Pickup',
        ),
        
        // Dotted line connector
        Container(
          margin: const EdgeInsets.only(left: 11),
          height: 24,
          child: CustomPaint(
            painter: _DottedLinePainter(),
          ),
        ),
        
        // Drop
        _buildAddressRow(
          icon: Icons.location_on,
          color: Colors.red,
          address: widget.offer.dropAddress.address,
          label: 'Drop',
        ),
      ],
    );
  }

  Widget _buildAddressRow({
    required IconData icon,
    required Color color,
    required String address,
    required String label,
  }) {
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
                  color: Colors.grey.shade500,
                ),
              ),
              Text(
                address,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
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

  Widget _buildPackageInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.inventory_2_outlined, color: Colors.grey.shade600, size: 20),
          const SizedBox(width: 8),
          Text(
            widget.offer.packageType!,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.grey.shade700,
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
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade400
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
