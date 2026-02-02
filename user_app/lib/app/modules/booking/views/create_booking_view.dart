import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../routes/app_routes.dart';
import '../controllers/booking_controller.dart';

/// View for creating a new booking
/// Allows user to select pickup/drop locations, package type, and description
class CreateBookingView extends GetView<BookingController> {
  const CreateBookingView({super.key});

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
                  // Pickup Location Card
                  _buildLocationCard(
                    context: context,
                    title: 'Pickup Location',
                    icon: Icons.trip_origin_rounded,
                    iconColor: theme.colorScheme.primary,
                    controller: controller.pickupController,
                    addressObservable: controller.pickupAddress,
                    showCurrentButton: true,
                    onTap: () => _showLocationPicker(context, isPickup: true),
                    onCurrentPressed: controller.useCurrentLocationAsPickup,
                  ),

                  const SizedBox(height: 16),

                  // Drop Location Card
                  _buildLocationCard(
                    context: context,
                    title: 'Drop Location',
                    icon: Icons.location_on_rounded,
                    iconColor: theme.colorScheme.error,
                    controller: controller.dropController,
                    addressObservable: controller.dropAddress,
                    showCurrentButton: false,
                    onTap: () => _showLocationPicker(context, isPickup: false),
                  ),

                  const SizedBox(height: 24),

                  // Package Type Section
                  Text(
                    'Package Type',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildPackageTypeSelector(context),

                  const SizedBox(height: 24),

                  // Package Description Section
                  Text(
                    'Package Description (Optional)',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildPackageDescriptionField(context),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Bottom fixed button
          _buildBottomButton(context),
        ],
      ),
    );
  }

  /// Builds a location selection card with icon, title, optional current button, and tap-to-select
  Widget _buildLocationCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color iconColor,
    required TextEditingController controller,
    required RxString addressObservable,
    required bool showCurrentButton,
    required VoidCallback onTap,
    VoidCallback? onCurrentPressed,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: isDark
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),

            const SizedBox(width: 12),

            // Title and address field
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (showCurrentButton && onCurrentPressed != null)
                        Obx(() => TextButton.icon(
                              onPressed: this.controller.isLoading
                                  ? null
                                  : onCurrentPressed,
                              icon: Icon(
                                Icons.my_location_rounded,
                                size: 16,
                                color: theme.colorScheme.primary,
                              ),
                              label: Text(
                                'Current',
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            )),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Tap to select location field
                  Obx(() => GestureDetector(
                        onTap: onTap,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? theme.colorScheme.surfaceContainerHighest
                                : theme.colorScheme.surfaceContainerHighest,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusSmall),
                            border: Border.all(
                              color: theme.colorScheme.outline.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  addressObservable.value.isEmpty
                                      ? 'Tap to select location'
                                      : addressObservable.value,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: addressObservable.value.isEmpty
                                        ? theme.hintColor
                                        : theme.colorScheme.onSurface,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: theme.hintColor,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the package type selector with selectable chips
  Widget _buildPackageTypeSelector(BuildContext context) {
    return Obx(() => Wrap(
          spacing: 10,
          runSpacing: 10,
          children: PackageType.values
              .where((type) => type != PackageType.other)
              .map((type) => _buildPackageChip(
                    context: context,
                    type: type,
                    isSelected:
                        controller.selectedPackageType.value == type,
                    onTap: () => controller.selectPackageType(type),
                  ))
              .toList(),
        ));
  }

  /// Builds an individual package type chip
  Widget _buildPackageChip({
    required BuildContext context,
    required PackageType type,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : isDark
                  ? theme.colorScheme.surfaceContainerHighest
                  : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getPackageTypeIcon(type),
              size: 20,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              _getPackageTypeName(type),
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the package description multiline text field
  Widget _buildPackageDescriptionField(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHighest
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: TextField(
        controller: controller.packageDescriptionController,
        maxLines: 3,
        minLines: 3,
        style: AppTextStyles.bodyMedium.copyWith(
          color: theme.colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: 'Describe your package (e.g., fragile items, special handling instructions)',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: theme.hintColor,
          ),
          contentPadding: const EdgeInsets.all(16),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }

  /// Builds the bottom continue button
  Widget _buildBottomButton(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Obx(() => AppButton.primary(
            text: 'Continue',
            onPressed:
                controller.canProceedToVehicle ? _onContinuePressed : null,
            isLoading: controller.isLoading,
            isDisabled: !controller.canProceedToVehicle,
          )),
    );
  }

  /// Navigates to location picker based on pickup/drop selection
  void _showLocationPicker(BuildContext context, {required bool isPickup}) {
    if (isPickup) {
      Get.toNamed(Routes.pickupLocation, arguments: {'isPickup': true});
    } else {
      Get.toNamed(Routes.dropLocation, arguments: {'isPickup': false});
    }
  }

  /// Handles continue button press
  void _onContinuePressed() {
    Get.toNamed(Routes.vehicleSelection);
  }

  /// Returns the icon for a package type
  IconData _getPackageTypeIcon(PackageType type) {
    switch (type) {
      case PackageType.parcel:
        return Icons.inventory_2_rounded;
      case PackageType.document:
        return Icons.description_rounded;
      case PackageType.food:
        return Icons.restaurant_rounded;
      case PackageType.grocery:
        return Icons.shopping_basket_rounded;
      case PackageType.medicine:
        return Icons.medical_services_rounded;
      case PackageType.fragile:
        return Icons.warning_amber_rounded;
      case PackageType.other:
        return Icons.category_rounded;
    }
  }

  /// Returns the display name for a package type
  String _getPackageTypeName(PackageType type) {
    switch (type) {
      case PackageType.parcel:
        return 'Parcel';
      case PackageType.document:
        return 'Document';
      case PackageType.food:
        return 'Food';
      case PackageType.grocery:
        return 'Grocery';
      case PackageType.medicine:
        return 'Medicine';
      case PackageType.fragile:
        return 'Fragile';
      case PackageType.other:
        return 'Other';
    }
  }
}
