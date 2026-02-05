import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/map_location_picker.dart';
import '../../../routes/app_routes.dart';
import '../controllers/booking_controller.dart';

/// Step 1: Location selection widget for the unified booking flow.
/// Allows user to select pickup and drop locations.
class LocationStepWidget extends GetView<BookingController> {
  final bool isExpanded;
  final bool isCompleted;
  final VoidCallback onTap;

  const LocationStepWidget({
    super.key,
    required this.isExpanded,
    required this.isCompleted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
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
      onTap: onTap,
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
                    : theme.colorScheme.surfaceContainerHighest,
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
                        '1',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: isCompleted || isExpanded
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurfaceVariant,
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
                    'Pickup & Drop',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (!isExpanded && isCompleted)
                    Obx(() => Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '${_truncateAddress(controller.pickupAddress.value)} → ${_truncateAddress(controller.dropAddress.value)}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )),
                ],
              ),
            ),

            // Expand/collapse icon
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
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          // Pickup Location Card
          _buildLocationCard(
            context: context,
            title: 'Pickup Location',
            icon: Icons.trip_origin_rounded,
            iconColor: theme.colorScheme.primary,
            addressObservable: controller.pickupAddress,
            showCurrentButton: true,
            onTap: () => _showLocationPicker(context, isPickup: true),
            onCurrentPressed: controller.useCurrentLocationAsPickup,
          ),

          const SizedBox(height: 12),

          // Drop Location Card
          _buildLocationCard(
            context: context,
            title: 'Drop Location',
            icon: Icons.location_on_rounded,
            iconColor: theme.colorScheme.error,
            addressObservable: controller.dropAddress,
            showCurrentButton: false,
            onTap: () => _showLocationPicker(context, isPickup: false),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color iconColor,
    required RxString addressObservable,
    required bool showCurrentButton,
    required VoidCallback onTap,
    VoidCallback? onCurrentPressed,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
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
                        style: AppTextStyles.labelMedium.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (showCurrentButton && onCurrentPressed != null)
                        Obx(() => GestureDetector(
                              onTap: controller.isLoading
                                  ? null
                                  : onCurrentPressed,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.my_location_rounded,
                                    size: 14,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Current',
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
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
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: theme.scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: theme.colorScheme.outline.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  addressObservable.value.isEmpty
                                      ? 'Tap to select'
                                      : addressObservable.value,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: addressObservable.value.isEmpty
                                        ? theme.hintColor
                                        : theme.colorScheme.onSurface,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: theme.hintColor,
                                size: 18,
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

  String _truncateAddress(String address) {
    if (address.length <= 20) return address;
    return '${address.substring(0, 20)}...';
  }

  /// Shows bottom sheet with location selection options
  void _showLocationPicker(BuildContext context, {required bool isPickup}) {
    final theme = Theme.of(context);
    final title = isPickup ? 'Select Pickup Location' : 'Select Drop Location';

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Option 1: Choose on Map
            _buildLocationOption(
              context: context,
              icon: Icons.map_rounded,
              title: 'Choose on Map',
              subtitle: 'Pin exact location on map',
              onTap: () {
                Get.back(); // Close bottom sheet
                controller.openMapPicker(isPickup: isPickup);
              },
            ),

            const SizedBox(height: 12),

            // Option 2: Saved Addresses
            _buildLocationOption(
              context: context,
              icon: Icons.bookmark_rounded,
              title: 'Saved Addresses',
              subtitle: 'Select from your saved locations',
              onTap: () {
                Get.back(); // Close bottom sheet
                if (isPickup) {
                  Get.toNamed(Routes.pickupLocation, arguments: {'isPickup': true});
                } else {
                  Get.toNamed(Routes.dropLocation, arguments: {'isPickup': false});
                }
              },
            ),

            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  /// Builds a location option tile for the bottom sheet
  Widget _buildLocationOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: theme.dividerColor),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.hintColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
