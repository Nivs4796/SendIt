import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../controllers/registration_controller.dart';
import '../widgets/personal_details_step.dart';
import '../widgets/vehicle_details_step.dart';
import '../widgets/documents_step.dart';
import '../widgets/bank_details_step.dart';

class RegistrationView extends GetView<RegistrationController> {
  const RegistrationView({super.key});

  static const List<_StepInfo> _steps = [
    _StepInfo(icon: Icons.person_rounded, label: 'Personal'),
    _StepInfo(icon: Icons.directions_bike_rounded, label: 'Vehicle'),
    _StepInfo(icon: Icons.description_rounded, label: 'Documents'),
    _StepInfo(icon: Icons.account_balance_rounded, label: 'Bank'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar with Progress
            _buildHeader(theme),

            // Step Content
            Expanded(
              child: Obx(() => AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.05, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: _buildCurrentStep(controller.currentStep.value),
              )),
            ),

            // Error Message
            _buildErrorMessage(theme),

            // Navigation Buttons
            _buildNavigationButtons(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 24, 0),
      child: Column(
        children: [
          // Top row with back and title
          Row(
            children: [
              IconButton(
                onPressed: () {
                  if (controller.currentStep.value > 0) {
                    controller.previousStep();
                  } else {
                    Get.back();
                  }
                },
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Obx(() => Text(
                'Step ${controller.currentStep.value + 1} of 4',
                style: AppTextStyles.bodySmall.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
              )),
            ],
          ),

          const SizedBox(height: 16),

          // Step Indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildStepIndicator(theme),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(ThemeData theme) {
    return Obx(() => Row(
      children: List.generate(_steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          // Connector line
          final stepIndex = index ~/ 2;
          final isCompleted = controller.currentStep.value > stepIndex;
          return Expanded(
            child: Container(
              height: 3,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppColors.primary
                    : theme.colorScheme.outline.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }

        // Step circle
        final stepIndex = index ~/ 2;
        final step = _steps[stepIndex];
        final isActive = controller.currentStep.value >= stepIndex;
        final isCurrent = controller.currentStep.value == stepIndex;
        final isCompleted = controller.currentStep.value > stepIndex;

        return GestureDetector(
          onTap: () => controller.goToStep(stepIndex),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            child: Column(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primary.withValues(alpha: isCurrent ? 1 : 0.15)
                        : theme.colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isActive
                          ? AppColors.primary
                          : theme.colorScheme.outline.withValues(alpha: 0.2),
                      width: isCurrent ? 2 : 1,
                    ),
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    isCompleted ? Icons.check_rounded : step.icon,
                    size: 20,
                    color: isCurrent
                        ? Colors.white
                        : isActive
                            ? AppColors.primary
                            : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  step.label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isActive
                        ? AppColors.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    ));
  }

  Widget _buildCurrentStep(int step) {
    switch (step) {
      case 0:
        return const PersonalDetailsStep(key: ValueKey(0));
      case 1:
        return const VehicleDetailsStep(key: ValueKey(1));
      case 2:
        return const DocumentsStep(key: ValueKey(2));
      case 3:
        return const BankDetailsStep(key: ValueKey(3));
      default:
        return const PersonalDetailsStep(key: ValueKey(0));
    }
  }

  Widget _buildErrorMessage(ThemeData theme) {
    return Obx(() {
      if (controller.errorMessage.value.isEmpty) {
        return const SizedBox.shrink();
      }
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.error.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: theme.colorScheme.error,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                controller.errorMessage.value,
                style: AppTextStyles.bodySmall.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => controller.errorMessage.value = '',
              child: Icon(
                Icons.close_rounded,
                color: theme.colorScheme.error,
                size: 18,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildNavigationButtons(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Obx(() {
        final isFirstStep = controller.currentStep.value == 0;
        final isLastStep = controller.currentStep.value == 3;

        return Row(
          children: [
            // Back Button
            if (!isFirstStep) ...[
              Expanded(
                child: AppButton(
                  text: 'Back',
                  onPressed: controller.previousStep,
                  variant: AppButtonVariant.outline,
                  icon: Icons.arrow_back_rounded,
                ),
              ),
              const SizedBox(width: 16),
            ],

            // Next/Submit Button
            Expanded(
              flex: isFirstStep ? 1 : 1,
              child: AppButton(
                text: isLastStep ? 'Submit Application' : 'Continue',
                onPressed: controller.nextStep,
                isLoading: controller.isLoading.value,
                icon: isLastStep ? Icons.check_circle_rounded : Icons.arrow_forward_rounded,
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _StepInfo {
  final IconData icon;
  final String label;

  const _StepInfo({required this.icon, required this.label});
}
