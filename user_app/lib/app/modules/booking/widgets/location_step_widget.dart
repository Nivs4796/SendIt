import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
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
            onTap: () => Get.toNamed(Routes.pickupLocation, arguments: {'isPickup': true}),
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
            onTap: () => Get.toNamed(Routes.dropLocation, arguments: {'isPickup': false}),
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
}
