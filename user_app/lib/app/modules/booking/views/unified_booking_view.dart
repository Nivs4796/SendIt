import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/app_button.dart';
import '../controllers/booking_controller.dart';
import '../widgets/location_step_widget.dart';
import '../widgets/package_step_widget.dart';
import '../widgets/vehicle_step_widget.dart';

/// Unified booking view that combines all booking steps into a single screen.
/// Uses a stepper-style interface with collapsible sections for:
/// - Step 1: Pickup & Drop locations
/// - Step 2: Package details (type & description)
/// - Step 3: Vehicle selection & price breakdown
class UnifiedBookingView extends GetView<BookingController> {
  const UnifiedBookingView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('New Booking'),
        centerTitle: true,
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        surfaceTintColor: theme.appBarTheme.backgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            controller.resetBooking();
            Get.back();
          },
        ),
      ),
      body: Column(
        children: [
          // Scrollable step content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Obx(() => Column(
                    children: [
                      // Step 1: Locations
                      LocationStepWidget(
                        isExpanded: controller.expandedSteps[0],
                        isCompleted: controller.canProceedToStep1,
                        onTap: () => controller.goToStep(0),
                      ),

                      // Step 2: Package Details
                      PackageStepWidget(
                        isExpanded: controller.expandedSteps[1],
                        isCompleted: controller.currentStep.value >= 1,
                        isEnabled: controller.canProceedToStep1,
                        onTap: () => controller.goToStep(1),
                      ),

                      // Step 3: Vehicle & Price
                      VehicleStepWidget(
                        isExpanded: controller.expandedSteps[2],
                        isCompleted: controller.canCreateBooking,
                        isEnabled: controller.canProceedToStep2,
                        onTap: () => controller.goToStep(2),
                      ),

                      // Extra padding at bottom for scrolling
                      const SizedBox(height: 80),
                    ],
                  )),
            ),
          ),

          // Bottom action button
          _buildBottomButton(context),
        ],
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
          top: BorderSide(
            color: isDark
                ? theme.colorScheme.primary.withValues(alpha: 0.15)
                : theme.dividerColor,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Obx(() {
        final isLoading = controller.bookingState.value == BookingState.calculatingPrice;
        final buttonText = controller.getButtonText();
        final isEnabled = controller.isButtonEnabled;

        return AppButton.primary(
          text: buttonText,
          isLoading: isLoading,
          isDisabled: !isEnabled,
          onPressed: controller.onActionButtonPressed,
          suffixIcon: controller.currentStep.value < 2
              ? Icons.arrow_forward_rounded
              : Icons.check_rounded,
        );
      }),
    );
  }
}
