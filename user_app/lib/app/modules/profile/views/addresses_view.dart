import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import '../../../core/widgets/inputs/app_text_area.dart';
import '../../../data/models/address_model.dart';
import '../controllers/address_controller.dart';

class AddressesView extends GetView<AddressController> {
  const AddressesView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Saved Addresses'),
        centerTitle: true,
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddressFormSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Address'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: Obx(() {
        // Loading state
        if (controller.isLoading.value && controller.addresses.isEmpty) {
          return Center(
            child: CircularProgressIndicator(
              color: theme.colorScheme.primary,
            ),
          );
        }

        // Empty state
        if (controller.addresses.isEmpty) {
          return _buildEmptyState(context);
        }

        // Address list
        return RefreshIndicator(
          onRefresh: controller.fetchAddresses,
          color: theme.colorScheme.primary,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.addresses.length,
            itemBuilder: (context, index) {
              final address = controller.addresses[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _AddressCard(
                  address: address,
                  onEdit: () => _showAddressFormSheet(context, address: address),
                  onSetDefault: () => controller.setAsDefault(address),
                  onDelete: () => controller.deleteAddress(address),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark
                    ? theme.colorScheme.surfaceContainerHighest
                    : theme.colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_off_outlined,
                size: 64,
                color: theme.hintColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No saved addresses',
              style: AppTextStyles.h4.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add addresses for quick booking',
              style: AppTextStyles.bodyMedium.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddressFormSheet(BuildContext context, {AddressModel? address}) {
    if (address != null) {
      controller.populateFormForEdit(address);
    } else {
      controller.clearForm();
    }

    Get.bottomSheet(
      _AddressFormSheet(controller: controller),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

class _AddressCard extends StatelessWidget {
  final AddressModel address;
  final VoidCallback onEdit;
  final VoidCallback onSetDefault;
  final VoidCallback onDelete;

  const _AddressCard({
    required this.address,
    required this.onEdit,
    required this.onSetDefault,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: address.isDefault
            ? Border.all(color: theme.colorScheme.primary, width: 2)
            : isDark
                ? Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                  )
                : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: isDark ? 8 : 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: address.isDefault
                ? theme.colorScheme.primaryContainer
                : isDark
                    ? theme.colorScheme.surfaceContainerHighest
                    : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getIconForLabel(address.label),
            color: address.isDefault
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
            size: 24,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                address.label,
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (address.isDefault)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Default',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            address.fullAddress,
            style: AppTextStyles.bodySmall.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert_rounded,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onSelected: (value) {
            switch (value) {
              case 'edit':
                onEdit();
                break;
              case 'default':
                onSetDefault();
                break;
              case 'delete':
                onDelete();
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(
                    Icons.edit_outlined,
                    size: 20,
                    color: theme.colorScheme.onSurface,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Edit',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            if (!address.isDefault)
              PopupMenuItem(
                value: 'default',
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      size: 20,
                      color: theme.colorScheme.onSurface,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Set as Default',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  const Icon(
                    Icons.delete_outline_rounded,
                    size: 20,
                    color: AppColors.error,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Delete',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForLabel(String label) {
    final lowerLabel = label.toLowerCase();
    if (lowerLabel.contains('home')) {
      return Icons.home_outlined;
    } else if (lowerLabel.contains('office') || lowerLabel.contains('work')) {
      return Icons.business_outlined;
    }
    return Icons.location_on_outlined;
  }
}

class _AddressFormSheet extends StatelessWidget {
  final AddressController controller;

  const _AddressFormSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.85,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() => Text(
                      controller.isEditMode ? 'Edit Address' : 'Add New Address',
                      style: AppTextStyles.h4.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    )),
                IconButton(
                  onPressed: () {
                    controller.clearForm();
                    Get.back();
                  },
                  icon: Icon(
                    Icons.close_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          Divider(color: theme.dividerColor),

          // Form content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Error message
                  Obx(() {
                    if (controller.errorMessage.value.isNotEmpty) {
                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.errorLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: AppColors.error,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                controller.errorMessage.value,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),

                  // Label field
                  AppTextField(
                    label: 'Label',
                    hint: 'e.g., Home, Office, Gym',
                    controller: controller.labelController,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                  ),

                  const SizedBox(height: 16),

                  // Address field
                  AppTextArea(
                    label: 'Address',
                    hint: 'Enter your full address',
                    controller: controller.addressController,
                    minLines: 2,
                    maxLines: 3,
                  ),

                  const SizedBox(height: 16),

                  // Landmark field (optional)
                  AppTextField(
                    label: 'Landmark (Optional)',
                    hint: 'Near or opposite to...',
                    controller: controller.landmarkController,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                  ),

                  const SizedBox(height: 16),

                  // City and State row
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'City',
                          hint: 'Enter city',
                          controller: controller.cityController,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTextField(
                          label: 'State',
                          hint: 'Enter state',
                          controller: controller.stateController,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Pincode field
                  AppTextField(
                    label: 'Pincode',
                    hint: 'Enter 6-digit pincode',
                    controller: controller.pincodeController,
                    type: AppTextFieldType.number,
                    maxLength: 6,
                    textInputAction: TextInputAction.done,
                  ),

                  const SizedBox(height: 16),

                  // Set as default switch
                  Obx(() => Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? theme.colorScheme.surfaceContainerHighest
                              : theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: SwitchListTile(
                          title: Text(
                            'Set as default address',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          subtitle: Text(
                            'This address will be auto-selected for bookings',
                            style: AppTextStyles.caption.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          value: controller.isDefault.value,
                          onChanged: (value) => controller.isDefault.value = value,
                          activeTrackColor: theme.colorScheme.primaryContainer,
                          inactiveTrackColor: isDark
                              ? theme.colorScheme.surfaceContainerHigh
                              : theme.colorScheme.surfaceContainerHigh,
                          thumbColor: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              return theme.colorScheme.primary;
                            }
                            return theme.colorScheme.onSurfaceVariant;
                          }),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      )),

                  const SizedBox(height: 24),

                  // Save button
                  Obx(() => AppButton.primary(
                        text: controller.isEditMode
                            ? 'Update Address'
                            : 'Save Address',
                        onPressed: controller.isSaving.value
                            ? null
                            : controller.saveAddress,
                        isLoading: controller.isSaving.value,
                      )),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
