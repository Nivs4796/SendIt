import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/vehicle_model.dart';
import '../controllers/vehicles_controller.dart';

class VehiclesView extends GetView<VehiclesController> {
  const VehiclesView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('My Vehicles'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () => _showAddVehicleSheet(context, colors),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.vehicles.isEmpty) {
          return _buildEmptyState(colors);
        }

        return RefreshIndicator(
          onRefresh: controller.refresh,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.vehicles.length,
            itemBuilder: (context, index) {
              return _buildVehicleCard(colors, controller.vehicles[index]);
            },
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState(AppColorScheme colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.two_wheeler_outlined,
              size: 80,
              color: colors.textHint,
            ),
            const SizedBox(height: 16),
            Text(
              'No Vehicles Yet',
              style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your vehicle to start accepting deliveries',
              style: AppTextStyles.bodyMedium.copyWith(
                color: colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddVehicleSheet(Get.context!, AppColorScheme.of(Get.context!)),
              icon: const Icon(Icons.add),
              label: const Text('Add Vehicle'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleCard(AppColorScheme colors, VehicleModel vehicle) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final insuranceExpiring = vehicle.insuranceExpiry != null &&
        vehicle.insuranceExpiry!.difference(DateTime.now()).inDays < 30;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: vehicle.isActive
            ? Border.all(color: colors.primary, width: 2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              // Vehicle icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getVehicleIcon(vehicle.vehicleType),
                  color: colors.primary,
                ),
              ),
              const SizedBox(width: 12),

              // Vehicle info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${vehicle.make} ${vehicle.model}',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (vehicle.isElectric) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: colors.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.bolt, size: 12, color: colors.success),
                                Text(
                                  'EV',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: colors.success,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      vehicle.registrationNumber,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Status badges
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (vehicle.isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: colors.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Active',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: vehicle.isVerified
                          ? colors.success.withValues(alpha: 0.1)
                          : colors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          vehicle.isVerified ? Icons.verified : Icons.pending,
                          size: 12,
                          color: vehicle.isVerified ? colors.success : colors.warning,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          vehicle.isVerified ? 'Verified' : 'Pending',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: vehicle.isVerified ? colors.success : colors.warning,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),
          Divider(color: colors.border),
          const SizedBox(height: 12),

          // Details
          Row(
            children: [
              _buildDetailItem(colors, 'Year', '${vehicle.year ?? '-'}'),
              _buildDetailItem(colors, 'Color', vehicle.color ?? '-'),
              _buildDetailItem(
                colors,
                'Type',
                vehicle.vehicleType == VehicleType.twoWheeler ? '2W' : '4W',
              ),
            ],
          ),

          // Insurance warning
          if (insuranceExpiring && vehicle.insuranceExpiry != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: colors.warning, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Insurance expires on ${dateFormat.format(vehicle.insuranceExpiry!)}',
                      style: AppTextStyles.labelSmall.copyWith(color: colors.warning),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Actions
          Row(
            children: [
              if (!vehicle.isActive)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => controller.setActiveVehicle(vehicle.id),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.primary,
                      side: BorderSide(color: colors.primary),
                    ),
                    child: const Text('Set as Active'),
                  ),
                ),
              if (!vehicle.isActive) const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showVehicleDetails(colors, vehicle),
                  child: const Text('View Details'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(AppColorScheme colors, String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  IconData _getVehicleIcon(VehicleType type) {
    switch (type) {
      case VehicleType.cycle:
        return Icons.pedal_bike;
      case VehicleType.evCycle:
        return Icons.electric_bike;
      case VehicleType.twoWheeler:
        return Icons.two_wheeler;
      case VehicleType.threeWheeler:
        return Icons.electric_rickshaw;
      case VehicleType.fourWheeler:
        return Icons.directions_car;
      case VehicleType.truck:
        return Icons.local_shipping;
    }
  }

  void _showVehicleDetails(AppColorScheme colors, VehicleModel vehicle) {
    final dateFormat = DateFormat('MMM d, yyyy');

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getVehicleIcon(vehicle.vehicleType),
                    color: colors.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${vehicle.make} ${vehicle.model}',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        vehicle.registrationNumber,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildDetailRow(colors, 'Vehicle Type', vehicle.vehicleType.displayName),
            _buildDetailRow(colors, 'Year', '${vehicle.year ?? '-'}'),
            _buildDetailRow(colors, 'Color', vehicle.color ?? '-'),
            if (vehicle.insuranceNumber != null)
              _buildDetailRow(colors, 'Insurance No.', vehicle.insuranceNumber!),
            if (vehicle.insuranceExpiry != null)
              _buildDetailRow(colors, 'Insurance Expiry', dateFormat.format(vehicle.insuranceExpiry!)),
            _buildDetailRow(colors, 'Added On', dateFormat.format(vehicle.createdAt)),

            const SizedBox(height: 24),

            if (!vehicle.isActive) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Get.back();
                        _confirmDeleteVehicle(colors, vehicle);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.error,
                        side: BorderSide(color: colors.error),
                      ),
                      child: const Text('Delete Vehicle'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        controller.setActiveVehicle(vehicle.id);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Set as Active'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildDetailRow(AppColorScheme colors, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: colors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteVehicle(AppColorScheme colors, VehicleModel vehicle) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Vehicle?'),
        content: Text(
          'Are you sure you want to remove ${vehicle.make} ${vehicle.model} (${vehicle.registrationNumber})?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteVehicle(vehicle.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: colors.error),
            child: Text('Delete', style: TextStyle(color: colors.textOnPrimary)),
          ),
        ],
      ),
    );
  }

  void _showAddVehicleSheet(BuildContext context, AppColorScheme colors) {
    final formKey = GlobalKey<FormState>();
    final registrationController = TextEditingController();
    final makeController = TextEditingController();
    final modelController = TextEditingController();
    final yearController = TextEditingController();
    final colorController = TextEditingController();
    final selectedType = VehicleType.twoWheeler.obs;

    Get.bottomSheet(
      SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add New Vehicle',
                  style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // Vehicle Type
                Text('Vehicle Type', style: AppTextStyles.labelMedium),
                const SizedBox(height: 8),
                Obx(() => Row(
                  children: VehicleType.values.map((type) {
                    final isSelected = selectedType.value == type;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => selectedType.value = type,
                        child: Container(
                          margin: EdgeInsets.only(
                            right: type != VehicleType.values.last ? 8 : 0,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colors.primary.withValues(alpha: 0.1)
                                : colors.surfaceVariant,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? colors.primary : Colors.transparent,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                _getVehicleIcon(type),
                                color: isSelected ? colors.primary : colors.textPrimary,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                type.displayName,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: isSelected ? colors.primary : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                )),
                const SizedBox(height: 16),

                // Registration Number
                TextFormField(
                  controller: registrationController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    labelText: 'Registration Number',
                    hintText: 'GJ-01-AB-1234',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) => v?.isEmpty == true ? 'Required' : null,
                ),
                const SizedBox(height: 12),

                // Make & Model
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: makeController,
                        decoration: InputDecoration(
                          labelText: 'Make',
                          hintText: 'Honda',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (v) => v?.isEmpty == true ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: modelController,
                        decoration: InputDecoration(
                          labelText: 'Model',
                          hintText: 'Activa',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (v) => v?.isEmpty == true ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Year & Color
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: yearController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Year',
                          hintText: '2022',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (v) => v?.isEmpty == true ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: colorController,
                        decoration: InputDecoration(
                          labelText: 'Color',
                          hintText: 'Black',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (v) => v?.isEmpty == true ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Add button
                Obx(() => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.isProcessing.value
                        ? null
                        : () async {
                            if (formKey.currentState?.validate() != true) return;
                            final success = await controller.addVehicle(
                              vehicleType: selectedType.value.name,
                              registrationNumber: registrationController.text.toUpperCase(),
                              make: makeController.text,
                              model: modelController.text,
                              year: int.tryParse(yearController.text) ?? DateTime.now().year,
                              color: colorController.text,
                            );
                            if (success) Get.back();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: controller.isProcessing.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Add Vehicle', style: TextStyle(color: Colors.white)),
                  ),
                )),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
