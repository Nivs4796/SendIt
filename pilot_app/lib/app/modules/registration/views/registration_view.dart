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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Pilot Registration',
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Step Indicator
          _buildStepIndicator(theme),

          // Step Content
          Expanded(
            child: Obx(() => IndexedStack(
              index: controller.currentStep.value,
              children: const [
                PersonalDetailsStep(),
                VehicleDetailsStep(),
                DocumentsStep(),
                BankDetailsStep(),
              ],
            )),
          ),

          // Error Message
          Obx(() {
            if (controller.errorMessage.value.isEmpty) {
              return const SizedBox.shrink();
            }
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: theme.colorScheme.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      controller.errorMessage.value,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          // Navigation Buttons
          _buildNavigationButtons(theme),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(ThemeData theme) {
    final steps = ['Personal', 'Vehicle', 'Documents', 'Bank'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: List.generate(steps.length, (index) {
          return Expanded(
            child: Obx(() {
              final isActive = controller.currentStep.value >= index;
              final isCurrent = controller.currentStep.value == index;

              return GestureDetector(
                onTap: () => controller.goToStep(index),
                child: Column(
                  children: [
                    Row(
                      children: [
                        if (index > 0)
                          Expanded(
                            child: Container(
                              height: 2,
                              color: isActive
                                  ? AppColors.primary
                                  : theme.colorScheme.outline.withValues(alpha: 0.2),
                            ),
                          ),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: isActive ? AppColors.primary : Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isActive
                                  ? AppColors.primary
                                  : theme.colorScheme.outline.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: isActive && !isCurrent
                                ? const Icon(
                                    Icons.check,
                                    size: 16,
                                    color: Colors.white,
                                  )
                                : Text(
                                    '${index + 1}',
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: isActive ? Colors.white : theme.colorScheme.onSurface,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        if (index < steps.length - 1)
                          Expanded(
                            child: Container(
                              height: 2,
                              color: controller.currentStep.value > index
                                  ? AppColors.primary
                                  : theme.colorScheme.outline.withValues(alpha: 0.2),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      steps[index],
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isCurrent
                            ? AppColors.primary
                            : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            }),
          );
        }),
      ),
    );
  }

  Widget _buildNavigationButtons(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          // Back Button
          Obx(() {
            if (controller.currentStep.value == 0) {
              return const SizedBox.shrink();
            }
            return Expanded(
              child: AppButton(
                text: 'Back',
                onPressed: controller.previousStep,
                variant: AppButtonVariant.outline,
              ),
            );
          }),

          Obx(() => controller.currentStep.value > 0
              ? const SizedBox(width: 16)
              : const SizedBox.shrink()),

          // Next/Submit Button
          Expanded(
            child: Obx(() => AppButton(
              text: controller.currentStep.value == 3 ? 'Submit' : 'Next',
              onPressed: controller.nextStep,
              isLoading: controller.isLoading.value,
            )),
          ),
        ],
      ),
    );
  }
}
