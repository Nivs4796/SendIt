import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/booking_model.dart';
import '../controllers/orders_controller.dart';

/// Order details view showing complete order information
/// Includes status, locations, package details, driver info, and payment breakdown
class OrderDetailsView extends GetView<OrdersController> {
  const OrderDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Obx(() {
          final order = controller.selectedOrder.value;
          return Text('Order #${order?.bookingNumber ?? ''}');
        }),
        centerTitle: true,
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: Obx(() {
        final order = controller.selectedOrder.value;

        if (order == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 64,
                  color: theme.hintColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'Order not found',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: theme.colorScheme.primary,
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                color: theme.colorScheme.primary,
                onRefresh: () => controller.getOrderById(order.id),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Card
                      _buildStatusCard(context, order),
                      const SizedBox(height: 16),

                      // Locations Card
                      _buildLocationsCard(context, order),
                      const SizedBox(height: 16),

                      // Package Details Card
                      _buildPackageCard(context, order),
                      const SizedBox(height: 16),

                      // Driver Card (if pilot exists)
                      if (order.pilot != null) ...[
                        _buildDriverCard(context, order),
                        const SizedBox(height: 16),
                      ],

                      // Payment Card
                      _buildPaymentCard(context, order),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Action Buttons
            _buildActionButtons(context, order),
          ],
        );
      }),
    );
  }

  /// Build status card with colored background, icon, and description
  Widget _buildStatusCard(BuildContext context, BookingModel order) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final statusColor = _getStatusColor(order.status);
    final statusIcon = _getStatusIcon(order.status);
    final statusDescription = _getStatusDescription(order.status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Status Icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: isDark ? 0.3 : 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              statusIcon,
              color: statusColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),

          // Status Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.statusDisplay,
                  style: AppTextStyles.h4.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusDescription,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark
                        ? theme.colorScheme.onSurface.withValues(alpha: 0.7)
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build locations card with pickup and drop addresses
  Widget _buildLocationsCard(BuildContext context, BookingModel order) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: isDark ? 16 : 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delivery Route',
            style: AppTextStyles.labelLarge.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),

          // Pickup Location
          _buildLocationRow(
            context,
            icon: Icons.circle,
            iconColor: AppColors.success,
            label: 'Pickup',
            address: order.pickupAddress?.formattedAddress ??
                order.pickupAddress?.address ??
                'Pickup location',
            time: order.pickedUpAt,
          ),

          // Connecting Line
          Padding(
            padding: const EdgeInsets.only(left: 11),
            child: Container(
              width: 2,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.success,
                    theme.colorScheme.primary,
                  ],
                ),
              ),
            ),
          ),

          // Drop Location
          _buildLocationRow(
            context,
            icon: Icons.location_on,
            iconColor: theme.colorScheme.primary,
            label: 'Drop',
            address: order.dropAddress?.formattedAddress ??
                order.dropAddress?.address ??
                'Drop location',
            time: order.deliveredAt,
          ),
        ],
      ),
    );
  }

  /// Build individual location row with icon, label, address, and optional time
  Widget _buildLocationRow(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String address,
    DateTime? time,
  }) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: iconColor,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (time != null)
                    Text(
                      DateFormat('hh:mm a').format(time),
                      style: AppTextStyles.caption.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                address,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build package details card with type, vehicle, and distance chips
  Widget _buildPackageCard(BuildContext context, BookingModel order) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: isDark ? 16 : 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Package Details',
            style: AppTextStyles.labelLarge.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),

          // Detail Chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildDetailChip(
                context,
                icon: _getPackageTypeIcon(order.packageType),
                label: _getPackageTypeLabel(order.packageType),
              ),
              _buildDetailChip(
                context,
                icon: Icons.two_wheeler_rounded,
                label: order.vehicleType?.name ?? 'Vehicle',
              ),
              _buildDetailChip(
                context,
                icon: Icons.straighten_rounded,
                label: '${order.distance.toStringAsFixed(1)} km',
              ),
            ],
          ),

          // Package Description
          if (order.packageDescription != null &&
              order.packageDescription!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Description',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order.packageDescription!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build detail chip with icon and label
  Widget _buildDetailChip(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  /// Build driver card with avatar, name, rating, and vehicle number
  Widget _buildDriverCard(BuildContext context, BookingModel order) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final pilot = order.pilot!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: isDark ? 16 : 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delivery Partner',
            style: AppTextStyles.labelLarge.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              // Avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    width: 2,
                  ),
                  image: pilot.avatar != null
                      ? DecorationImage(
                          image: NetworkImage(pilot.avatar!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: pilot.avatar == null
                    ? Icon(
                        Icons.person_rounded,
                        size: 28,
                        color: theme.colorScheme.primary,
                      )
                    : null,
              ),
              const SizedBox(width: 16),

              // Driver Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pilot.name,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 16,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          pilot.rating.toStringAsFixed(1),
                          style: AppTextStyles.labelMedium.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (pilot.vehicleNumber != null) ...[
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              pilot.vehicleNumber!,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Call Button
              if (order.isActive)
                IconButton(
                  onPressed: () {
                    // TODO: Implement call functionality
                  },
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.phone_rounded,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build payment card with fare breakdown
  Widget _buildPaymentCard(BuildContext context, BookingModel order) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: isDark ? 16 : 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payment Details',
                style: AppTextStyles.labelLarge.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getPaymentStatusColor(order.paymentStatus)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getPaymentIcon(order.paymentMethod),
                      size: 14,
                      color: _getPaymentStatusColor(order.paymentStatus),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getPaymentMethodLabel(order.paymentMethod),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: _getPaymentStatusColor(order.paymentStatus),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Fare Breakdown
          _buildPaymentRow(context, 'Base Fare', order.baseFare),
          const SizedBox(height: 8),
          _buildPaymentRow(context, 'Distance Fare', order.distanceFare),
          const SizedBox(height: 8),
          _buildPaymentRow(context, 'Taxes', order.taxes),
          if (order.discount > 0) ...[
            const SizedBox(height: 8),
            _buildPaymentRow(
              context,
              'Discount',
              -order.discount,
              valueColor: AppColors.success,
            ),
          ],

          const SizedBox(height: 12),
          Divider(color: theme.dividerColor),
          const SizedBox(height: 12),

          // Total
          _buildPaymentRow(
            context,
            'Total Amount',
            order.totalAmount,
            isBold: true,
          ),
        ],
      ),
    );
  }

  /// Build payment row with label and value
  Widget _buildPaymentRow(
    BuildContext context,
    String label,
    double value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    final theme = Theme.of(context);
    final isNegative = value < 0;
    final displayValue = isNegative ? -value : value;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: (isBold ? AppTextStyles.labelLarge : AppTextStyles.bodyMedium)
              .copyWith(
            color: isBold
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          '${isNegative ? '-' : ''}\u20B9${displayValue.toStringAsFixed(2)}',
          style: (isBold ? AppTextStyles.priceSmall : AppTextStyles.bodyMedium)
              .copyWith(
            color: valueColor ??
                (isBold
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurfaceVariant),
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Build action buttons at the bottom
  Widget _buildActionButtons(BuildContext context, BookingModel order) {
    final theme = Theme.of(context);

    // No buttons for cancelled orders
    if (order.isCancelled) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: order.isActive
          ? AppButton.primary(
              text: 'Track Order',
              icon: Icons.location_on_outlined,
              onPressed: () => controller.trackOrder(order),
            )
          : Row(
              children: [
                Expanded(
                  child: AppButton.outline(
                    text: 'Rate Delivery',
                    icon: Icons.star_outline_rounded,
                    onPressed: () => _showRatingDialog(context, order),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton.primary(
                    text: 'Rebook',
                    icon: Icons.replay_rounded,
                    onPressed: () => controller.rebookOrder(order),
                  ),
                ),
              ],
            ),
    );
  }

  /// Show rating dialog with star picker and review text field
  void _showRatingDialog(BuildContext context, BookingModel order) {
    final theme = Theme.of(context);
    final selectedRating = 0.obs;
    final reviewController = TextEditingController();
    final isSubmitting = false.obs;

    Get.dialog(
      AlertDialog(
        backgroundColor: theme.dialogBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Rate Your Delivery',
          style: AppTextStyles.h4.copyWith(
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'How was your delivery experience?',
              style: AppTextStyles.bodyMedium.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Star Rating
            Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final starNumber = index + 1;
                    return GestureDetector(
                      onTap: () => selectedRating.value = starNumber,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          selectedRating.value >= starNumber
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 40,
                          color: selectedRating.value >= starNumber
                              ? AppColors.accent
                              : theme.hintColor,
                        ),
                      ),
                    );
                  }),
                )),
            const SizedBox(height: 20),

            // Review Text Field
            TextField(
              controller: reviewController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Write a review (optional)',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: theme.hintColor,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.dividerColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.dividerColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
              style: AppTextStyles.bodyMedium.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    'Cancel',
                    style: AppTextStyles.button.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Obx(() => ElevatedButton(
                      onPressed: selectedRating.value > 0 && !isSubmitting.value
                          ? () async {
                              isSubmitting.value = true;
                              final success = await controller.rateDelivery(
                                order.id,
                                selectedRating.value,
                                review: reviewController.text.isNotEmpty
                                    ? reviewController.text
                                    : null,
                              );
                              isSubmitting.value = false;
                              if (success) {
                                Get.back();
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        disabledBackgroundColor: theme.disabledColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: isSubmitting.value
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: theme.colorScheme.onPrimary,
                              ),
                            )
                          : Text(
                              'Submit',
                              style: AppTextStyles.button.copyWith(
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                    )),
              ),
            ],
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      ),
    );
  }

  // ==================== Helper Methods ====================

  /// Get status color based on booking status
  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return AppColors.statusPending;
      case BookingStatus.accepted:
        return AppColors.statusAccepted;
      case BookingStatus.arrivedPickup:
        return AppColors.statusAccepted;
      case BookingStatus.pickedUp:
        return AppColors.statusPickedUp;
      case BookingStatus.inTransit:
        return AppColors.statusInTransit;
      case BookingStatus.arrivedDrop:
        return AppColors.statusInTransit;
      case BookingStatus.delivered:
        return AppColors.statusDelivered;
      case BookingStatus.cancelled:
        return AppColors.statusCancelled;
    }
  }

  /// Get status icon based on booking status
  IconData _getStatusIcon(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Icons.schedule_rounded;
      case BookingStatus.accepted:
        return Icons.check_circle_outline_rounded;
      case BookingStatus.arrivedPickup:
        return Icons.person_pin_circle_rounded;
      case BookingStatus.pickedUp:
        return Icons.inventory_2_rounded;
      case BookingStatus.inTransit:
        return Icons.local_shipping_rounded;
      case BookingStatus.arrivedDrop:
        return Icons.location_on_rounded;
      case BookingStatus.delivered:
        return Icons.task_alt_rounded;
      case BookingStatus.cancelled:
        return Icons.cancel_rounded;
    }
  }

  /// Get status description based on booking status
  String _getStatusDescription(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return 'Looking for a delivery partner nearby';
      case BookingStatus.accepted:
        return 'Delivery partner is on the way to pickup';
      case BookingStatus.arrivedPickup:
        return 'Delivery partner has arrived at pickup location';
      case BookingStatus.pickedUp:
        return 'Package has been picked up';
      case BookingStatus.inTransit:
        return 'Package is on the way to destination';
      case BookingStatus.arrivedDrop:
        return 'Delivery partner has arrived at destination';
      case BookingStatus.delivered:
        return 'Package has been delivered successfully';
      case BookingStatus.cancelled:
        return 'This order has been cancelled';
    }
  }

  /// Get payment method icon
  IconData _getPaymentIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return Icons.payments_rounded;
      case PaymentMethod.upi:
        return Icons.account_balance_rounded;
      case PaymentMethod.card:
        return Icons.credit_card_rounded;
      case PaymentMethod.wallet:
        return Icons.account_balance_wallet_rounded;
      case PaymentMethod.netbanking:
        return Icons.account_balance_rounded;
    }
  }

  /// Get payment method label
  String _getPaymentMethodLabel(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.upi:
        return 'UPI';
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.wallet:
        return 'Wallet';
      case PaymentMethod.netbanking:
        return 'Net Banking';
    }
  }

  /// Get payment status color
  Color _getPaymentStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return AppColors.warning;
      case PaymentStatus.completed:
        return AppColors.success;
      case PaymentStatus.failed:
        return AppColors.error;
      case PaymentStatus.refunded:
        return AppColors.info;
    }
  }

  /// Get package type icon
  IconData _getPackageTypeIcon(PackageType type) {
    switch (type) {
      case PackageType.document:
        return Icons.description_rounded;
      case PackageType.parcel:
        return Icons.inventory_2_rounded;
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

  /// Get package type label
  String _getPackageTypeLabel(PackageType type) {
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
