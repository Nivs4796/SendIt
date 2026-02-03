import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../controllers/registration_controller.dart';

class VerificationPendingView extends GetView<RegistrationController> {
  const VerificationPendingView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Success Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.hourglass_top_rounded,
                  size: 60,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 32),

              // Title
              Text(
                'Application Submitted!',
                style: AppTextStyles.h3.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Subtitle
              Text(
                'Your application is under review. We\'ll notify you once it\'s approved.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Timeline
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Column(
                  children: [
                    _buildTimelineItem(
                      context,
                      icon: Icons.check_circle,
                      title: 'Application Received',
                      subtitle: 'We\'ve received your application',
                      isCompleted: true,
                    ),
                    _buildTimelineConnector(context, isCompleted: true),
                    _buildTimelineItem(
                      context,
                      icon: Icons.search,
                      title: 'Under Review',
                      subtitle: 'Our team is verifying your documents',
                      isCompleted: false,
                      isActive: true,
                    ),
                    _buildTimelineConnector(context, isCompleted: false),
                    _buildTimelineItem(
                      context,
                      icon: Icons.verified,
                      title: 'Verification Complete',
                      subtitle: 'Usually takes 24-48 hours',
                      isCompleted: false,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Support Info
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.support_agent,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '24/7 Support Available',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Check Status Button
              Obx(() => AppButton(
                text: 'Check Status',
                onPressed: controller.checkVerificationStatus,
                isLoading: controller.isLoading.value,
                variant: AppButtonVariant.outline,
              )),

              const SizedBox(height: 12),

              // Contact Support
              TextButton(
                onPressed: () {
                  // TODO: Open support
                },
                child: Text(
                  'Contact Support',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isCompleted,
    bool isActive = false,
  }) {
    final theme = Theme.of(context);
    final color = isCompleted
        ? AppColors.primary
        : isActive
            ? AppColors.primary
            : theme.colorScheme.onSurface.withValues(alpha: 0.3);

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isCompleted || isActive
                ? AppColors.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: color,
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: color,
          ),
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
                  color: isCompleted || isActive
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineConnector(BuildContext context, {required bool isCompleted}) {
    return Container(
      margin: const EdgeInsets.only(left: 19),
      width: 2,
      height: 24,
      color: isCompleted
          ? AppColors.primary
          : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
    );
  }
}
