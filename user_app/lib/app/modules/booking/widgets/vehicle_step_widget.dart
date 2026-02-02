import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/vehicle_type_model.dart';
import '../controllers/booking_controller.dart';

/// Step 3: Vehicle selection widget for the unified booking flow.
/// Allows user to select vehicle type and shows price breakdown.
class VehicleStepWidget extends GetView<BookingController> {
  final bool isExpanded;
  final bool isCompleted;
  final bool isEnabled;
  final VoidCallback onTap;

  const VehicleStepWidget({
    super.key,
    required this.isExpanded,
    required this.isCompleted,
    required this.isEnabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isEnabled ? theme.cardColor : theme.cardColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: isDark
            ? Border.all(
                color: isExpanded
                    ? theme.colorScheme.primary.withValues(alpha: 0.3)
                    : theme.colorScheme.primary.withValues(alpha: 0.15),
              )
            : Border.all(
                color: isExpanded
                    ? theme.colorScheme.primary.withValues(alpha: 0.5)
                    : theme.dividerColor,
              ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header (always visible)
          _buildHeader(context),

          // Expandable content
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildContent(context),
            crossFadeState:
                isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: isEnabled ? onTap : null,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Step indicator
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isCompleted || isExpanded
                    ? theme.colorScheme.primary
                    : isEnabled
                        ? theme.colorScheme.surfaceContainerHighest
                        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isCompleted && !isExpanded
                    ? Icon(
                        Icons.check_rounded,
                        color: theme.colorScheme.onPrimary,
                        size: 18,
                      )
                    : Text(
                        '3',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: isCompleted || isExpanded
                              ? theme.colorScheme.onPrimary
                              : isEnabled
                                  ? theme.colorScheme.onSurfaceVariant
                                  : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),

            // Title and summary
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vehicle & Price',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: isEnabled
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (!isExpanded && isCompleted)
                    Obx(() {
                      final vehicle = controller.selectedVehicle.value;
                      final price = controller.priceCalculation.value;
                      if (vehicle != null && price != null) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '${vehicle.name} • ${price.totalDisplay}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                  if (!isEnabled)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Complete previous steps first',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Expand/collapse icon
            if (isEnabled)
              Icon(
                isExpanded
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Route Summary
          _buildRouteSummary(context),
          const SizedBox(height: 16),

          // Vehicle List
          Obx(() => _buildVehicleList(context)),

          // Price Breakdown
          Obx(() {
            if (controller.priceCalculation.value != null) {
              return Column(
                children: [
                  const SizedBox(height: 16),
                  _buildPriceBreakdown(context),
                ],
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildRouteSummary(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      ),
      child: Row(
        children: [
          // Icons with connecting line
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.my_location_rounded,
                  color: theme.colorScheme.primary,
                  size: 14,
                ),
              ),
              Container(
                width: 2,
                height: 16,
                margin: const EdgeInsets.symmetric(vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.location_on_rounded,
                  color: theme.colorScheme.error,
                  size: 14,
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
                Obx(() => Text(
                      controller.pickupAddress.value.isNotEmpty
                          ? controller.pickupAddress.value
                          : 'Pickup location',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )),
                const SizedBox(height: 12),
                Obx(() => Text(
                      controller.dropAddress.value.isNotEmpty
                          ? controller.dropAddress.value
                          : 'Drop location',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleList(BuildContext context) {
    final theme = Theme.of(context);

    // Loading state
    if (controller.bookingState.value == BookingState.loadingVehicles) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Loading vehicles...',
                style: AppTextStyles.bodySmall.copyWith(
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
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(
                Icons.local_shipping_outlined,
                size: 48,
                color: theme.hintColor,
              ),
              const SizedBox(height: 12),
              Text(
                'No vehicles available',
                style: AppTextStyles.bodySmall.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: controller.refreshVehicleTypes,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Vehicle cards
    return Column(
      children: controller.vehicleTypes
          .map((vehicle) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildVehicleCard(context, vehicle),
              ))
          .toList(),
    );
  }

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
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
                : isDark
                    ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                    : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withValues(alpha: 0.2),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Vehicle Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary.withValues(alpha: 0.15)
                      : theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getVehicleIcon(vehicle.name),
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onPrimaryContainer,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),

              // Vehicle Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.name,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Up to ${vehicle.weightDisplay}',
                      style: AppTextStyles.caption.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // Price
              if (isCalculating)
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.primary,
                  ),
                )
              else
                Text(
                  vehicle.basePriceDisplay,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),

              const SizedBox(width: 8),

              // Selection indicator
              Container(
                width: 20,
                height: 20,
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
                        size: 14,
                      )
                    : null,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildPriceBreakdown(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final price = controller.priceCalculation.value!;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          // Distance & Duration
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.route_rounded,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      price.distanceDisplay,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 16,
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      price.durationDisplay,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Divider(color: theme.colorScheme.outline.withValues(alpha: 0.2), height: 1),
          const SizedBox(height: 12),

          // Price rows
          _buildPriceRow(context, 'Base Fare', price.baseFareDisplay),
          const SizedBox(height: 6),
          _buildPriceRow(context, 'Distance Fare', price.distanceFareDisplay),
          const SizedBox(height: 6),
          _buildPriceRow(context, 'Taxes & Fees', price.taxesDisplay),

          const SizedBox(height: 12),
          Divider(color: theme.colorScheme.outline.withValues(alpha: 0.2), height: 1),
          const SizedBox(height: 12),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: AppTextStyles.labelMedium.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                price.totalDisplay,
                style: AppTextStyles.labelLarge.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodySmall.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

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

    return Icons.local_shipping;
  }
}
