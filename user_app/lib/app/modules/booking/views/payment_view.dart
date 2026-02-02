import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/widgets.dart';
import '../controllers/booking_controller.dart';

/// PaymentView - Review & Pay screen for booking confirmation.
/// Displays booking summary, payment method selection, coupon application,
/// and final price calculation.
class PaymentView extends GetView<BookingController> {
  const PaymentView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Review & Pay'),
        centerTitle: true,
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Booking Summary Card
                  _buildBookingSummary(context),

                  const SizedBox(height: 24),

                  // Payment Methods Section
                  Text(
                    'Payment Method',
                    style: AppTextStyles.h4.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildPaymentMethods(context),

                  const SizedBox(height: 24),

                  // Coupon Section
                  _buildCouponSection(context),

                  const SizedBox(height: 24),

                  // Final Price Card
                  _buildFinalPrice(context),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Bottom Confirm Button
          _buildBottomButton(context),
        ],
      ),
    );
  }

  /// Builds the booking summary card with locations, package type, and vehicle.
  Widget _buildBookingSummary(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
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
            'Booking Summary',
            style: AppTextStyles.labelLarge.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),

          // Pickup Location
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.success.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                  ),
                  Container(
                    width: 2,
                    height: 40,
                    color: theme.dividerColor,
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pickup',
                      style: AppTextStyles.caption.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Obx(() => Text(
                          controller.pickupAddress.value.isNotEmpty
                              ? controller.pickupAddress.value
                              : 'Not selected',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        )),
                  ],
                ),
              ),
            ],
          ),

          // Drop Location
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Drop',
                      style: AppTextStyles.caption.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Obx(() => Text(
                          controller.dropAddress.value.isNotEmpty
                              ? controller.dropAddress.value
                              : 'Not selected',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        )),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Divider(color: theme.dividerColor),
          const SizedBox(height: 12),

          // Package Type & Vehicle
          Row(
            children: [
              // Package Type
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.inventory_2_outlined,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Package',
                            style: AppTextStyles.caption.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Obx(() => Text(
                                _getPackageTypeName(
                                    controller.selectedPackageType.value),
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: theme.colorScheme.onSurface,
                                ),
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Vehicle
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.local_shipping_outlined,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vehicle',
                            style: AppTextStyles.caption.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Obx(() => Text(
                                controller.selectedVehicle.value?.name ??
                                    'Not selected',
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: theme.colorScheme.onSurface,
                                ),
                                overflow: TextOverflow.ellipsis,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the payment methods section with Wallet, Cash, and UPI options.
  Widget _buildPaymentMethods(BuildContext context) {
    return Column(
      children: [
        // Wallet Payment Option
        Obx(() => _buildPaymentOption(
              context,
              icon: Icons.account_balance_wallet,
              title: 'Wallet',
              subtitle:
                  'Balance: \u20B9${controller.walletBalance.value.toStringAsFixed(2)}',
              isSelected:
                  controller.selectedPaymentMethod.value == PaymentMethod.wallet,
              isDisabled: !controller.hasSufficientBalance.value,
              warning: !controller.hasSufficientBalance.value
                  ? 'Insufficient balance'
                  : null,
              onTap: controller.hasSufficientBalance.value
                  ? () => controller.selectPaymentMethod(PaymentMethod.wallet)
                  : null,
            )),

        const SizedBox(height: 12),

        // Cash on Delivery Option
        Obx(() => _buildPaymentOption(
              context,
              icon: Icons.money,
              title: 'Cash on Delivery',
              subtitle: 'Pay when your package is delivered',
              isSelected:
                  controller.selectedPaymentMethod.value == PaymentMethod.cash,
              isDisabled: false,
              onTap: () => controller.selectPaymentMethod(PaymentMethod.cash),
            )),

        const SizedBox(height: 12),

        // UPI Option (Coming Soon)
        _buildPaymentOption(
          context,
          icon: Icons.qr_code,
          title: 'UPI',
          subtitle: 'Coming soon',
          isSelected: false,
          isDisabled: true,
          onTap: null,
        ),
      ],
    );
  }

  /// Builds a single payment option card.
  Widget _buildPaymentOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required bool isDisabled,
    String? warning,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDisabled
              ? theme.disabledColor.withValues(alpha: 0.05)
              : isSelected
                  ? theme.colorScheme.primary.withValues(alpha: 0.1)
                  : theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : isDark
                    ? theme.colorScheme.primary.withValues(alpha: 0.15)
                    : theme.dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Icon Container
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isDisabled
                    ? theme.disabledColor.withValues(alpha: 0.1)
                    : isSelected
                        ? theme.colorScheme.primary.withValues(alpha: 0.2)
                        : theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 24,
                color: isDisabled
                    ? theme.disabledColor
                    : isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.primary.withValues(alpha: 0.8),
              ),
            ),

            const SizedBox(width: 16),

            // Title and Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: isDisabled
                          ? theme.disabledColor
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: isDisabled
                          ? theme.disabledColor
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (warning != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          size: 14,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          warning,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Checkmark for selected option
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 16,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Builds the coupon section with apply coupon functionality.
  Widget _buildCouponSection(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      final hasCoupon = controller.couponCode.value.isNotEmpty;

      return GestureDetector(
        onTap: () => _showCouponDialog(context),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: hasCoupon
                ? AppColors.successLight.withValues(alpha: isDark ? 0.2 : 1.0)
                : theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasCoupon
                  ? AppColors.success
                  : isDark
                      ? theme.colorScheme.primary.withValues(alpha: 0.15)
                      : theme.dividerColor,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: hasCoupon
                      ? AppColors.success.withValues(alpha: 0.2)
                      : theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.local_offer_outlined,
                  size: 20,
                  color: hasCoupon
                      ? AppColors.success
                      : theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasCoupon ? controller.couponCode.value : 'Apply Coupon',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: hasCoupon
                            ? AppColors.successDark
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    if (hasCoupon && controller.couponDiscount.value > 0)
                      Text(
                        'You save \u20B9${controller.couponDiscount.value.toStringAsFixed(2)}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.success,
                        ),
                      ),
                  ],
                ),
              ),
              if (hasCoupon)
                GestureDetector(
                  onTap: () => controller.applyCoupon(''),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: AppColors.error,
                    ),
                  ),
                )
              else
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Add',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  /// Builds the final price breakdown card.
  Widget _buildFinalPrice(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
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
            'Price Details',
            style: AppTextStyles.labelLarge.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),

          // Subtotal
          Obx(() => _buildPriceRow(
                context,
                label: 'Subtotal',
                value:
                    '\u20B9${controller.priceCalculation.value?.totalAmount.toStringAsFixed(2) ?? '0.00'}',
              )),

          const SizedBox(height: 8),

          // Distance
          Obx(() {
            final distance = controller.priceCalculation.value?.distance ?? 0.0;
            return _buildPriceRow(
              context,
              label: 'Distance',
              value: '${distance.toStringAsFixed(1)} km',
              isSubtle: true,
            );
          }),

          // Discount (if coupon applied)
          Obx(() {
            if (controller.couponDiscount.value > 0) {
              return Column(
                children: [
                  const SizedBox(height: 8),
                  _buildPriceRow(
                    context,
                    label: 'Discount',
                    value:
                        '-\u20B9${controller.couponDiscount.value.toStringAsFixed(2)}',
                    valueColor: AppColors.success,
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          }),

          const SizedBox(height: 12),
          Divider(color: theme.dividerColor),
          const SizedBox(height: 12),

          // Total
          Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: AppTextStyles.h4.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    controller.finalAmountDisplay,
                    style: AppTextStyles.h3.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }

  /// Builds a single price row with label and value.
  Widget _buildPriceRow(
    BuildContext context, {
    required String label,
    required String value,
    Color? valueColor,
    bool isSubtle = false,
  }) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: (isSubtle ? AppTextStyles.caption : AppTextStyles.bodyMedium)
              .copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style:
              (isSubtle ? AppTextStyles.caption : AppTextStyles.labelMedium)
                  .copyWith(
            color: valueColor ?? theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  /// Builds the bottom confirm button.
  Widget _buildBottomButton(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        16 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
          top: BorderSide(
            color: isDark
                ? theme.colorScheme.primary.withValues(alpha: 0.15)
                : theme.dividerColor,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Obx(() => AppButton.primary(
            text: 'Confirm Booking \u2022 ${controller.finalAmountDisplay}',
            isLoading: controller.bookingState.value == BookingState.creatingBooking,
            isDisabled: !controller.canProceedToPayment,
            onPressed: controller.createBooking,
            icon: Icons.check_circle_outline_rounded,
          )),
    );
  }

  /// Shows the coupon input dialog.
  void _showCouponDialog(BuildContext context) {
    final theme = Theme.of(context);
    final couponController = TextEditingController();

    Get.dialog(
      AlertDialog(
        backgroundColor: theme.scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Apply Coupon',
          style: AppTextStyles.h4.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              controller: couponController,
              label: 'Coupon Code',
              hint: 'Enter coupon code',
              prefixIcon: const Icon(Icons.local_offer_outlined),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 8),
            Text(
              'Try "FIRST10" for 10% discount',
              style: AppTextStyles.caption.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: AppTextStyles.labelLarge.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final code = couponController.text.trim();
              if (code.isNotEmpty) {
                controller.applyCoupon(code);
              }
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  /// Gets the display name for a package type.
  String _getPackageTypeName(PackageType type) {
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
