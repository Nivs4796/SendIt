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
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.spacingLg,
        vertical: AppTheme.spacingSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text('Vehicle Details', style: AppTextStyles.h4),
          Text('Tell us about your ride', style: AppTextStyles.caption),

          SizedBox(height: AppTheme.spacingMd),

          // Vehicle Type
          Text('Vehicle Type', style: AppTextStyles.labelLarge),
          SizedBox(height: AppTheme.spacingSm),

          Obx(() => _buildVehicleTypeGrid(theme)),

          SizedBox(height: AppTheme.spacingMd),

          // Fuel Type
          Obx(() {
            if (controller.selectedVehicleType.value == null) {
              return const SizedBox.shrink();
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Fuel Type', style: AppTextStyles.labelLarge),
                SizedBox(height: AppTheme.spacingSm),
                Wrap(
                  spacing: AppTheme.spacingSm,
                  runSpacing: AppTheme.spacingSm,
                  children: controller.availableCategories.map((category) {
                    final isSelected = controller.selectedVehicleCategory.value == category;
                    return _buildFuelChip(theme, category, isSelected);
                  }).toList(),
                ),
                SizedBox(height: AppTheme.spacingMd),
              ],
            );
          }),

          // Vehicle Number
          AppTextField(
            controller: controller.vehicleNumberController,
            label: 'Vehicle Number',
            hint: 'e.g., GJ-01-AB-1234',
            prefixIcon: const Icon(Icons.confirmation_number_outlined),
            textCapitalization: TextCapitalization.characters,
          ),

          SizedBox(height: AppTheme.spacingSm),

          // Vehicle Model
          AppTextField(
            controller: controller.vehicleModelController,
            label: 'Vehicle Model (Optional)',
            hint: 'e.g., Honda Activa 6G',
            prefixIcon: const Icon(Icons.local_shipping_outlined),
          ),

          SizedBox(height: AppTheme.spacingMd),

          // Age Warning
          Obx(() {
            if (controller.requiresLicense && controller.isMinor) {
              return _buildWarningCard(theme);
            }
            return const SizedBox.shrink();
          }),

          // Info tip
          _buildInfoTip(theme),

          SizedBox(height: AppTheme.spacingMd),
        ],
      ),
    );
  }

  Widget _buildVehicleTypeGrid(ThemeData theme) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.15,
      ),
      itemCount: VehicleType.values.length,
      itemBuilder: (context, index) {
        final type = VehicleType.values[index];
        final isSelected = controller.selectedVehicleType.value == type;
        return _buildVehicleCard(theme, type, isSelected);
      },
    );
  }

  Widget _buildVehicleCard(ThemeData theme, VehicleType type, bool isSelected) {
    return GestureDetector(
      onTap: () {
        controller.selectedVehicleType.value = type;
        controller.selectedVehicleCategory.value = null;
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: isSelected ? AppColors.primary : theme.colorScheme.outline.withValues(alpha: 0.2),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getVehicleIcon(type),
              size: 22,
              color: isSelected ? AppColors.primary : theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            SizedBox(height: AppTheme.spacingXs),
            Text(
              type.displayText,
              style: AppTextStyles.labelSmall.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppColors.primary : theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFuelChip(ThemeData theme, VehicleCategory category, bool isSelected) {
    return GestureDetector(
      onTap: () => controller.selectedVehicleCategory.value = category,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMd,
          vertical: AppTheme.spacingSm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border: Border.all(
            color: isSelected ? AppColors.primary : theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getFuelIcon(category),
              size: 14,
              color: isSelected ? Colors.white : theme.colorScheme.onSurface,
            ),
            SizedBox(width: AppTheme.spacingXs),
            Text(
              category.displayText,
              style: AppTextStyles.labelSmall.copyWith(
                color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningCard(ThemeData theme) {
    return Container(
      margin: EdgeInsets.only(bottom: AppTheme.spacingMd),
      padding: EdgeInsets.all(AppTheme.spacingSm),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 18),
          SizedBox(width: AppTheme.spacingSm),
          Expanded(
            child: Text(
              'You must be 18+ for motorized vehicles.',
              style: AppTextStyles.bodySmall.copyWith(color: Colors.orange.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTip(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacingSm),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline, color: AppColors.primary, size: 16),
          SizedBox(width: AppTheme.spacingSm),
          Expanded(
            child: Text(
              'Choose your primary delivery vehicle',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getVehicleIcon(VehicleType type) {
    switch (type) {
      case VehicleType.cycle:
        return Icons.pedal_bike_rounded;
      case VehicleType.evCycle:
        return Icons.electric_bike_rounded;
      case VehicleType.twoWheeler:
        return Icons.two_wheeler_rounded;
      case VehicleType.threeWheeler:
        return Icons.electric_rickshaw_rounded;
      case VehicleType.truck:
        return Icons.local_shipping_rounded;
    }
  }

  IconData _getFuelIcon(VehicleCategory category) {
    switch (category) {
      case VehicleCategory.petrol:
        return Icons.local_gas_station_rounded;
      case VehicleCategory.diesel:
        return Icons.local_gas_station_rounded;
      case VehicleCategory.cng:
        return Icons.propane_tank_rounded;
      case VehicleCategory.ev:
        return Icons.electric_bolt_rounded;
      case VehicleCategory.manual:
        return Icons.directions_walk_rounded;
    }
  }
}
