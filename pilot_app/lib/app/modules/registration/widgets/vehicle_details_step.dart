import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import '../../../data/models/vehicle_model.dart';
import '../controllers/registration_controller.dart';

class VehicleDetailsStep extends GetView<RegistrationController> {
  const VehicleDetailsStep({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vehicle Details',
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your vehicle information',
            style: AppTextStyles.bodyMedium.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),

          // Vehicle Type
          Text(
            'Vehicle Type',
            style: AppTextStyles.labelLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Obx(() => Wrap(
            spacing: 12,
            runSpacing: 12,
            children: VehicleType.values.map((type) {
              final isSelected = controller.selectedVehicleType.value == type;
              return _buildTypeChip(
                context,
                type: type,
                isSelected: isSelected,
                onTap: () {
                  controller.selectedVehicleType.value = type;
                  controller.selectedVehicleCategory.value = null;
                },
              );
            }).toList(),
          )),

          const SizedBox(height: 24),

          // Fuel Type (Category)
          Obx(() {
            if (controller.selectedVehicleType.value == null) {
              return const SizedBox.shrink();
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fuel Type',
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: controller.availableCategories.map((category) {
                    final isSelected = controller.selectedVehicleCategory.value == category;
                    return _buildCategoryChip(
                      context,
                      category: category,
                      isSelected: isSelected,
                      onTap: () {
                        controller.selectedVehicleCategory.value = category;
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
              ],
            );
          }),

          // Vehicle Number
          AppTextField(
            controller: controller.vehicleNumberController,
            label: 'Vehicle Number',
            hint: 'e.g., GJ-01-AB-1234',
            prefixIcon: Icon(Icons.pin_outlined),
            textCapitalization: TextCapitalization.characters,
          ),

          const SizedBox(height: 16),

          // Vehicle Model
          AppTextField(
            controller: controller.vehicleModelController,
            label: 'Vehicle Model (Optional)',
            hint: 'e.g., Honda Activa 6G',
            prefixIcon: Icon(Icons.directions_bike_outlined),
          ),

          const SizedBox(height: 24),

          // Age Warning for motorized vehicles
          Obx(() {
            if (controller.requiresLicense && controller.isMinor) {
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You must be 18+ to use motorized vehicles. Please select Cycle or EV Cycle.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildTypeChip(
    BuildContext context, {
    required VehicleType type,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : theme.colorScheme.outline.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getVehicleIcon(type),
              size: 20,
              color: isSelected ? AppColors.primary : theme.colorScheme.onSurface,
            ),
            const SizedBox(width: 8),
            Text(
              type.displayText,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isSelected ? AppColors.primary : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(
    BuildContext context, {
    required VehicleCategory category,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : theme.colorScheme.outline.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          category.displayText,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isSelected ? AppColors.primary : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  IconData _getVehicleIcon(VehicleType type) {
    switch (type) {
      case VehicleType.cycle:
        return Icons.pedal_bike_outlined;
      case VehicleType.evCycle:
        return Icons.electric_bike_outlined;
      case VehicleType.twoWheeler:
        return Icons.two_wheeler_outlined;
      case VehicleType.threeWheeler:
        return Icons.electric_rickshaw_outlined;
      case VehicleType.truck:
        return Icons.local_shipping_outlined;
    }
  }
}
