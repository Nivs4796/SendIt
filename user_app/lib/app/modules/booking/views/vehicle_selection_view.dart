import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../data/models/vehicle_type_model.dart';
import '../controllers/booking_controller.dart';

/// View for selecting vehicle type and viewing price calculation.
/// Displays route summary, available vehicles, and price breakdown.
class VehicleSelectionView extends GetView<BookingController> {
  const VehicleSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Select Vehicle'),
        centerTitle: true,
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        surfaceTintColor: theme.appBarTheme.backgroundColor,
      ),
      body: Column(
        children: [
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Route Summary Card
                  _buildRouteSummary(context),
                  const SizedBox(height: 24),

                  // Choose Vehicle Type Title
                  Text(
                    'Choose Vehicle Type',
                    style: AppTextStyles.h4.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Vehicle Cards List
                  Obx(() => _buildVehicleList(context)),
                  const SizedBox(height: 24),

                  // Price Breakdown Card
                  Obx(() {
                    if (controller.priceCalculation.value != null) {
                      return _buildPriceBreakdown(context);
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
            ),
          ),

          // Bottom Fixed Button
          _buildBottomButton(context),
        ],
      ),
    );
  }

  /// Builds the route summary card showing pickup and drop addresses.
  Widget _buildRouteSummary(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: isDark
            ? Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icons with connecting line
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.my_location_rounded,
                  color: theme.colorScheme.primary,
                  size: 18,
                ),
              ),
              Container(
                width: 2,
                height: 24,
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.location_on_rounded,
                  color: theme.colorScheme.error,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),

          // Addresses
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pickup Address
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pickup',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Obx(() => Text(
                          controller.pickupAddress.value.isNotEmpty
                              ? controller.pickupAddress.value
                              : 'Select pickup location',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        )),
                  ],
                ),
                const SizedBox(height: 16),

                // Drop Address
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Drop',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Obx(() => Text(
                          controller.dropAddress.value.isNotEmpty
                              ? controller.dropAddress.value
                              : 'Select drop location',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        )),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the vehicle list with loading and empty states.
  Widget _buildVehicleList(BuildContext context) {
    final theme = Theme.of(context);

    // Loading state
    if (controller.bookingState.value == BookingState.loadingVehicles) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Loading vehicles...',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Empty state
    if (controller.vehicleTypes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.local_shipping_outlined,
                size: 64,
                color: theme.hintColor,
              ),
              const SizedBox(height: 16),
              Text(
                'No vehicles available',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please try again later',
                style: AppTextStyles.bodySmall.copyWith(
                  color: theme.hintColor,
                ),
              ),
              const SizedBox(height: 16),
              AppButton.secondary(
                text: 'Retry',
                isFullWidth: false,
                onPressed: controller.refreshVehicleTypes,
                icon: Icons.refresh_rounded,
              ),
            ],
          ),
        ),
      );
    }

    // Vehicle cards
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.vehicleTypes.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final vehicle = controller.vehicleTypes[index];
        return _buildVehicleCard(context, vehicle);
      },
    );
  }

  /// Builds an individual vehicle card.
  Widget _buildVehicleCard(BuildContext context, VehicleTypeModel vehicle) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      final isSelected = controller.selectedVehicle.value?.id == vehicle.id;
      final isCalculating =
          controller.bookingState.value == BookingState.calculatingPrice &&
              isSelected;

      return GestureDetector(
        onTap: () => controller.selectVehicle(vehicle),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
                : theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : isDark
                      ? theme.colorScheme.primary.withValues(alpha: 0.15)
                      : theme.dividerColor,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
          child: Row(
            children: [
              // Vehicle Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary.withValues(alpha: 0.15)
                      : theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getVehicleIcon(vehicle.name),
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onPrimaryContainer,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),

              // Vehicle Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.name,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.fitness_center_rounded,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Up to ${vehicle.weightDisplay}',
                          style: AppTextStyles.caption.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Price and Selection
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (isCalculating)
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.primary,
                      ),
                    )
                  else
                    Text(
                      vehicle.basePriceDisplay,
                      style: AppTextStyles.priceSmall.copyWith(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    'Base fare',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),

              // Selection Checkmark
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Icon(
                        Icons.check_rounded,
                        color: theme.colorScheme.onPrimary,
                        size: 16,
                      )
                    : null,
              ),
            ],
          ),
        ),
      );
    });
  }

  /// Builds the price breakdown card.
  Widget _buildPriceBreakdown(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final price = controller.priceCalculation.value!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: isDark
            ? Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.receipt_long_rounded,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Price Breakdown',
                style: AppTextStyles.labelLarge.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Distance & Duration
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.route_rounded,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        price.distanceDisplay,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 20,
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        price.durationDisplay,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Price Rows
          _buildPriceRow(
            context,
            'Base Fare',
            price.baseFareDisplay,
            isBold: false,
          ),
          const SizedBox(height: 8),
          _buildPriceRow(
            context,
            'Distance Fare',
            price.distanceFareDisplay,
            isBold: false,
          ),
          const SizedBox(height: 8),
          _buildPriceRow(
            context,
            'Taxes & Fees',
            price.taxesDisplay,
            isBold: false,
          ),

          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(
              color: theme.dividerColor,
              height: 1,
            ),
          ),

          // Total
          _buildPriceRow(
            context,
            'Total',
            price.totalDisplay,
            isBold: true,
          ),
        ],
      ),
    );
  }

  /// Builds a single price row with label and value.
  Widget _buildPriceRow(
    BuildContext context,
    String label,
    String value, {
    required bool isBold,
  }) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isBold
              ? AppTextStyles.labelLarge.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                )
              : AppTextStyles.bodyMedium.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
        ),
        Text(
          value,
          style: isBold
              ? AppTextStyles.price.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                )
              : AppTextStyles.bodyMedium.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
        ),
      ],
    );
  }

  /// Builds the bottom fixed button.
  Widget _buildBottomButton(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        16 + MediaQuery.of(context).padding.bottom,
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
        final canProceed = controller.canProceedToPayment;
        final price = controller.priceCalculation.value;
        final isCalculating =
            controller.bookingState.value == BookingState.calculatingPrice;

        String buttonText = 'Continue';
        if (price != null) {
          buttonText = 'Continue \u2022 ${price.totalDisplay}';
        }

        return AppButton.primary(
          text: buttonText,
          isLoading: isCalculating,
          isDisabled: !canProceed,
          onPressed: () {
            // Navigate to payment view
            Get.toNamed('/payment');
          },
          suffixIcon: Icons.arrow_forward_rounded,
        );
      }),
    );
  }

  /// Returns the appropriate icon for a vehicle type based on its name.
  IconData _getVehicleIcon(String name) {
    final lowerName = name.toLowerCase();

    if (lowerName.contains('bike') ||
        lowerName.contains('cycle') ||
        lowerName.contains('two wheeler') ||
        lowerName.contains('2 wheeler')) {
      return Icons.two_wheeler;
    }

    if (lowerName.contains('car') ||
        lowerName.contains('sedan') ||
        lowerName.contains('hatchback')) {
      return Icons.directions_car;
    }

    if (lowerName.contains('auto') ||
        lowerName.contains('van') ||
        lowerName.contains('mini')) {
      return Icons.airport_shuttle;
    }

    if (lowerName.contains('truck') ||
        lowerName.contains('lorry') ||
        lowerName.contains('tempo') ||
        lowerName.contains('pickup')) {
      return Icons.local_shipping;
    }

    // Default icon for unknown vehicle types
    return Icons.local_shipping;
  }
}
