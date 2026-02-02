import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/booking_model.dart';
import '../controllers/orders_controller.dart';

class OrdersView extends GetView<OrdersController> {
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('My Orders'),
        centerTitle: true,
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        surfaceTintColor: theme.appBarTheme.backgroundColor,
      ),
      body: RefreshIndicator(
        color: theme.colorScheme.primary,
        onRefresh: controller.refreshOrders,
        child: Column(
          children: [
            // Filter Tabs
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildFilterTabs(context),
            ),

            // Orders List
            Expanded(
              child: Obx(() => _buildOrdersList(context)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabs(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Obx(() {
        final selectedFilter = controller.selectedFilter.value;

        return Row(
          children: [
            _FilterChipWidget(
              label: 'All',
              isSelected: selectedFilter == OrderFilter.all,
              onTap: () => controller.setFilter(OrderFilter.all),
              isDark: isDark,
            ),
            const SizedBox(width: 8),
            _FilterChipWidget(
              label: 'Active',
              isSelected: selectedFilter == OrderFilter.active,
              onTap: () => controller.setFilter(OrderFilter.active),
              isDark: isDark,
            ),
            const SizedBox(width: 8),
            _FilterChipWidget(
              label: 'Completed',
              isSelected: selectedFilter == OrderFilter.completed,
              onTap: () => controller.setFilter(OrderFilter.completed),
              isDark: isDark,
            ),
            const SizedBox(width: 8),
            _FilterChipWidget(
              label: 'Cancelled',
              isSelected: selectedFilter == OrderFilter.cancelled,
              onTap: () => controller.setFilter(OrderFilter.cancelled),
              isDark: isDark,
            ),
          ],
        );
      }),
    );
  }

  Widget _buildOrdersList(BuildContext context) {
    final theme = Theme.of(context);

    // Loading state (initial load)
    if (controller.isLoading.value && controller.orders.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          color: theme.colorScheme.primary,
        ),
      );
    }

    // Error state
    if (controller.errorMessage.value.isNotEmpty && controller.orders.isEmpty) {
      return _buildErrorState(context);
    }

    // Empty state
    if (controller.orders.isEmpty) {
      return _buildEmptyState(context);
    }

    // Orders list
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: controller.orders.length + 1,
      itemBuilder: (context, index) {
        // Load more indicator at the end
        if (index == controller.orders.length) {
          return _buildLoadMoreIndicator(context);
        }

        final order = controller.orders[index];
        return Padding(
          padding: EdgeInsets.only(
            bottom: index == controller.orders.length - 1 ? 24 : 12,
          ),
          child: _buildOrderCard(context, order),
        );
      },
    );
  }

  Widget _buildOrderCard(BuildContext context, BookingModel order) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => controller.selectOrder(order),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: isDark
              ? Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Booking Number, Status, Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#${order.bookingNumber}',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatDate(order.createdAt),
                        style: AppTextStyles.caption.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(order.status),
              ],
            ),
            const SizedBox(height: 16),

            // Locations
            _buildLocationRow(
              context,
              icon: Icons.radio_button_checked,
              iconColor: AppColors.success,
              label: 'Pickup',
              address: order.pickupAddress?.fullAddress ?? 'Pickup location',
            ),
            Padding(
              padding: const EdgeInsets.only(left: 11),
              child: Container(
                width: 2,
                height: 20,
                color: theme.dividerColor,
              ),
            ),
            _buildLocationRow(
              context,
              icon: Icons.location_on,
              iconColor: AppColors.error,
              label: 'Drop',
              address: order.dropAddress?.fullAddress ?? 'Drop location',
            ),
            const SizedBox(height: 16),

            // Divider
            Divider(
              color: theme.dividerColor,
              height: 1,
            ),
            const SizedBox(height: 12),

            // Package and Vehicle Info
            Row(
              children: [
                // Package Type
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.inventory_2_outlined,
                          color: AppColors.info,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatPackageType(order.packageType),
                              style: AppTextStyles.labelMedium.copyWith(
                                color: theme.colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (order.vehicleType != null)
                              Text(
                                order.vehicleType!.name,
                                style: AppTextStyles.caption.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Price
                Text(
                  order.amountDisplay,
                  style: AppTextStyles.priceSmall.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Action Buttons
            _buildActionButtons(context, order),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationRow(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String address,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          color: iconColor,
          size: 22,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                address,
                style: AppTextStyles.bodySmall.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(BookingStatus status) {
    Color backgroundColor;
    Color textColor;
    String statusText;

    switch (status) {
      case BookingStatus.pending:
        backgroundColor = AppColors.warningLight;
        textColor = AppColors.warningDark;
        statusText = 'Pending';
        break;
      case BookingStatus.accepted:
      case BookingStatus.arrivedPickup:
      case BookingStatus.pickedUp:
      case BookingStatus.inTransit:
      case BookingStatus.arrivedDrop:
        backgroundColor = AppColors.infoLight;
        textColor = AppColors.infoDark;
        statusText = _getActiveStatusText(status);
        break;
      case BookingStatus.delivered:
        backgroundColor = AppColors.successLight;
        textColor = AppColors.successDark;
        statusText = 'Delivered';
        break;
      case BookingStatus.cancelled:
        backgroundColor = AppColors.errorLight;
        textColor = AppColors.errorDark;
        statusText = 'Cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statusText,
        style: AppTextStyles.labelSmall.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _getActiveStatusText(BookingStatus status) {
    switch (status) {
      case BookingStatus.accepted:
        return 'Accepted';
      case BookingStatus.arrivedPickup:
        return 'Driver Arrived';
      case BookingStatus.pickedUp:
        return 'Picked Up';
      case BookingStatus.inTransit:
        return 'In Transit';
      case BookingStatus.arrivedDrop:
        return 'Near Drop';
      default:
        return 'Active';
    }
  }

  Widget _buildActionButtons(BuildContext context, BookingModel order) {
    final theme = Theme.of(context);

    // Active order - show Track Order button
    if (order.isActive) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => controller.trackOrder(order),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.location_on_outlined, size: 20),
          label: Text(
            'Track Order',
            style: AppTextStyles.buttonSmall.copyWith(
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    // Completed order - show Details and Rebook buttons
    if (order.isCompleted) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => controller.selectOrder(order),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
                side: BorderSide(color: theme.colorScheme.primary),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Details',
                style: AppTextStyles.buttonSmall.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () => controller.rebookOrder(order),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Rebook',
                style: AppTextStyles.buttonSmall.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Cancelled order - show View Details button
    if (order.isCancelled) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () => controller.selectOrder(order),
          style: OutlinedButton.styleFrom(
            foregroundColor: theme.colorScheme.onSurfaceVariant,
            side: BorderSide(color: theme.dividerColor),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'View Details',
            style: AppTextStyles.buttonSmall.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildLoadMoreIndicator(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      if (!controller.hasMorePages.value) {
        return const SizedBox(height: 24);
      }

      if (controller.isLoadingMore.value) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        );
      }

      // Load More button
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: TextButton.icon(
            onPressed: controller.loadMoreOrders,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Load More'),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 48,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No orders yet',
              style: AppTextStyles.h4.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your orders will appear here once you book a delivery',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.errorLight.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Something went wrong',
              style: AppTextStyles.h4.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Obx(() => Text(
                  controller.errorMessage.value,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                )),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: controller.refreshOrders,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final orderDate = DateTime(date.year, date.month, date.day);

    if (orderDate == today) {
      return 'Today, ${_formatTime(date)}';
    } else if (orderDate == yesterday) {
      return 'Yesterday, ${_formatTime(date)}';
    } else {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} $period';
  }

  String _formatPackageType(PackageType type) {
    switch (type) {
      case PackageType.document:
        return 'Document';
      case PackageType.parcel:
        return 'Parcel';
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

class _FilterChipWidget extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _FilterChipWidget({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : isDark
                    ? theme.colorScheme.primary.withValues(alpha: 0.2)
                    : theme.dividerColor,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: isSelected
                ? Colors.white
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
