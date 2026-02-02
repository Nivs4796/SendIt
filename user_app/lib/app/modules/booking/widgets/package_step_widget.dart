import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/booking_controller.dart';

/// Step 2: Package details widget for the unified booking flow.
/// Allows user to select package type and add description.
class PackageStepWidget extends GetView<BookingController> {
  final bool isExpanded;
  final bool isCompleted;
  final bool isEnabled;
  final VoidCallback onTap;

  const PackageStepWidget({
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
                        '2',
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
                    'Package Details',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: isEnabled
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (!isExpanded && isCompleted)
                    Obx(() => Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            _getPackageTypeName(controller.selectedPackageType.value),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        )),
                  if (!isEnabled)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Complete previous step first',
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Package Type Label
          Text(
            'Package Type',
            style: AppTextStyles.labelMedium.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          // Package Type Chips
          Obx(() => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: PackageType.values
                    .where((type) => type != PackageType.other)
                    .map((type) => _buildPackageChip(
                          context: context,
                          type: type,
                          isSelected: controller.selectedPackageType.value == type,
                          onTap: () => controller.selectPackageType(type),
                        ))
                    .toList(),
              )),

          const SizedBox(height: 20),

          // Package Description Label
          Text(
            'Description (Optional)',
            style: AppTextStyles.labelMedium.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          // Package Description Field
          Container(
            decoration: BoxDecoration(
              color: isDark
                  ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: TextField(
              controller: controller.packageDescriptionController,
              maxLines: 2,
              minLines: 2,
              style: AppTextStyles.bodySmall.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: 'E.g., fragile items, special handling...',
                hintStyle: AppTextStyles.bodySmall.copyWith(
                  color: theme.hintColor,
                ),
                contentPadding: const EdgeInsets.all(12),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : isDark
                  ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                  : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getPackageTypeIcon(type),
              size: 16,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              _getPackageTypeName(type),
              style: AppTextStyles.labelSmall.copyWith(
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
