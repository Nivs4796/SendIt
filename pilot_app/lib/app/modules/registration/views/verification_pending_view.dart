import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../controllers/registration_controller.dart';

class VerificationPendingView extends GetView<RegistrationController> {
  const VerificationPendingView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                SizedBox(height: size.height * 0.05),

                // Animated Success Illustration
                _buildSuccessAnimation(colors),

                const SizedBox(height: 40),

                // Title with gradient
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [colors.primary, colors.primary.withValues(alpha: 0.7)],
                  ).createShader(bounds),
                  child: Text(
                    'You\'re Almost There! 🎉',
                    style: AppTextStyles.h2.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'Your application has been submitted successfully.\nOur team is reviewing your documents.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // Progress Timeline
                _buildProgressTimeline(colors),

                const SizedBox(height: 32),

                // Estimated Time Card
                _buildEstimatedTimeCard(colors),

                const SizedBox(height: 24),

                // What's Next Section
                _buildWhatsNextSection(colors),

                const SizedBox(height: 32),

                // Action Buttons
                Obx(() => AppButton(
                  text: 'Check Application Status',
                  onPressed: controller.checkVerificationStatus,
                  isLoading: controller.isLoading.value,
                  icon: Icons.refresh_rounded,
                )),

                const SizedBox(height: 12),

                TextButton.icon(
                  onPressed: () {
                    // TODO: Open support chat
                  },
                  icon: Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 18,
                    color: colors.primary,
                  ),
                  label: Text(
                    'Need Help? Chat with Support',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessAnimation(AppColorScheme colors) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: Container(
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.primary.withValues(alpha: 0.15),
              colors.primary.withValues(alpha: 0.05),
            ],
          ),
          shape: BoxShape.circle,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer ring
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.primary.withValues(alpha: 0.3),
                  width: 3,
                ),
              ),
            ),
            // Inner circle with icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colors.primary,
                    colors.primary.withValues(alpha: 0.8),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.hourglass_top_rounded,
                size: 48,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressTimeline(AppColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.border.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          _buildTimelineStep(
            colors,
            icon: Icons.check_circle_rounded,
            title: 'Application Received',
            subtitle: 'Just now',
            status: TimelineStatus.completed,
            isFirst: true,
          ),
          _buildTimelineStep(
            colors,
            icon: Icons.document_scanner_rounded,
            title: 'Document Verification',
            subtitle: 'In progress...',
            status: TimelineStatus.inProgress,
          ),
          _buildTimelineStep(
            colors,
            icon: Icons.verified_user_rounded,
            title: 'Background Check',
            subtitle: 'Pending',
            status: TimelineStatus.pending,
          ),
          _buildTimelineStep(
            colors,
            icon: Icons.celebration_rounded,
            title: 'Account Activated',
            subtitle: 'Almost there!',
            status: TimelineStatus.pending,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(
    AppColorScheme colors, {
    required IconData icon,
    required String title,
    required String subtitle,
    required TimelineStatus status,
    bool isFirst = false,
    bool isLast = false,
  }) {
    final isCompleted = status == TimelineStatus.completed;
    final isInProgress = status == TimelineStatus.inProgress;

    Color getColor() {
      if (isCompleted) return colors.success;
      if (isInProgress) return colors.primary;
      return colors.textHint;
    }

    return IntrinsicHeight(
      child: Row(
        children: [
          // Timeline line and dot
          SizedBox(
            width: 40,
            child: Column(
              children: [
                // Top line
                if (!isFirst)
                  Container(
                    width: 2,
                    height: 12,
                    color: isCompleted || isInProgress
                        ? getColor()
                        : colors.border.withValues(alpha: 0.2),
                  ),
                // Dot
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isCompleted || isInProgress
                        ? getColor().withValues(alpha: 0.15)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: getColor(),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    isCompleted ? Icons.check_rounded : icon,
                    size: 16,
                    color: getColor(),
                  ),
                ),
                // Bottom line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isCompleted
                          ? colors.success
                          : colors.border.withValues(alpha: 0.2),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                top: isFirst ? 0 : 4,
                bottom: isLast ? 0 : 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isCompleted || isInProgress
                          ? colors.textPrimary
                          : colors.textHint,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (isInProgress) ...[
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(colors.primary),
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        subtitle,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isInProgress
                              ? colors.primary
                              : colors.textHint,
                          fontWeight: isInProgress ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstimatedTimeCard(AppColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primary.withValues(alpha: 0.1),
            colors.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.schedule_rounded,
              color: colors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estimated Wait Time',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '24-48 Hours',
                  style: AppTextStyles.h4.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhatsNextSection(AppColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What\'s Next?',
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildInfoTile(
          colors,
          icon: Icons.notifications_active_rounded,
          title: 'Stay Notified',
          subtitle: 'We\'ll send you updates via SMS & app notifications',
        ),
        const SizedBox(height: 12),
        _buildInfoTile(
          colors,
          icon: Icons.workspace_premium_rounded,
          title: 'Get Ready',
          subtitle: 'Once approved, you can start accepting deliveries',
        ),
      ],
    );
  }

  Widget _buildInfoTile(
    AppColorScheme colors, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: colors.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum TimelineStatus { completed, inProgress, pending }
