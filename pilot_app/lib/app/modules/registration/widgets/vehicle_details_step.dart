import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import '../../../data/models/vehicle_model.dart';
import '../controllers/registration_controller.dart';

class VehicleDetailsStep extends GetView<RegistrationController> {
  const VehicleDetailsStep({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text('Vehicle Details', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          Text('Tell us about your ride', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),

          const SizedBox(height: 10),

          // Vehicle Type Selection
          Text('Vehicle Type', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          
          Obx(() => _buildVehicleTypeGrid(theme)),

          const SizedBox(height: 10),

          // Fuel Type (Category)
          Obx(() {
            if (controller.selectedVehicleType.value == null) {
              return const SizedBox.shrink();
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Fuel Type', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: controller.availableCategories.map((category) {
                    final isSelected = controller.selectedVehicleCategory.value == category;
                    return _buildFuelTypeChip(theme, category, isSelected);
                  }).toList(),
                ),
                const SizedBox(height: 10),
              ],
            );
          }),

          // Vehicle Info Card
          _buildFormCard(
            theme,
            children: [
              // Vehicle Number
              _buildCompactTextField(
                controller: controller.vehicleNumberController,
                label: 'Vehicle Number',
                hint: 'e.g., GJ-01-AB-1234',
                icon: Icons.confirmation_number_outlined,
              ),

              const SizedBox(height: 10),

              // Vehicle Model
              _buildCompactTextField(
                controller: controller.vehicleModelController,
                label: 'Vehicle Model (Optional)',
                hint: 'e.g., Honda Activa 6G',
                icon: Icons.local_shipping_outlined,
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Age Warning for motorized vehicles
          Obx(() {
            if (controller.requiresLicense && controller.isMinor) {
              return _buildWarningCard(theme);
            }
            return const SizedBox.shrink();
          }),

          // Info tip
          _buildInfoTip(theme),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildCompactTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Container(
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(fontSize: 13),
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.3)),
              prefixIcon: Icon(icon, size: 16, color: AppColors.primary),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard(ThemeData theme, {required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
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
        childAspectRatio: 1.1,
      ),
      itemCount: VehicleType.values.length,
      itemBuilder: (context, index) {
        final type = VehicleType.values[index];
        final isSelected = controller.selectedVehicleType.value == type;
        return _buildVehicleTypeCard(theme, type, isSelected);
      },
    );
  }

  Widget _buildVehicleTypeCard(ThemeData theme, VehicleType type, bool isSelected) {
    return GestureDetector(
      onTap: () {
        controller.selectedVehicleType.value = type;
        controller.selectedVehicleCategory.value = null;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : theme.colorScheme.outline.withValues(alpha: 0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getVehicleIcon(type),
              size: 24,
              color: isSelected
                  ? AppColors.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 4),
            Text(
              type.displayText,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? AppColors.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFuelTypeChip(ThemeData theme, VehicleCategory category, bool isSelected) {
    return GestureDetector(
      onTap: () {
        controller.selectedVehicleCategory.value = category;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : theme.colorScheme.outline.withValues(alpha: 0.2),
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
            const SizedBox(width: 4),
            Text(
              category.displayText,
              style: TextStyle(
                fontSize: 11,
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
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'You must be 18+ for motorized vehicles. Select Cycle or EV Cycle.',
              style: TextStyle(fontSize: 11, color: Colors.orange.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTip(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline_rounded, color: AppColors.primary, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Choose the vehicle you\'ll use most for deliveries',
              style: TextStyle(fontSize: 11, color: AppColors.primary),
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
