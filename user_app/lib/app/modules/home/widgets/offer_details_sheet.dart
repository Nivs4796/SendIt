import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/coupon_model.dart';
import '../../../routes/app_routes.dart';

class OfferDetailsSheet extends StatelessWidget {
  final CouponModel coupon;
  final List<Color> gradientColors;

  const OfferDetailsSheet({
    super.key,
    required this.coupon,
    required this.gradientColors,
  });

  static void show(BuildContext context, CouponModel coupon, List<Color> colors) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OfferDetailsSheet(
        coupon: coupon,
        gradientColors: colors,
      ),
    );
  }

  void _copyCode(BuildContext context) {
    Clipboard.setData(ClipboardData(text: coupon.code));
    Get.snackbar(
      'Code Copied!',
      'Use code ${coupon.code} at checkout',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Theme.of(context).colorScheme.primary,
      colorText: Theme.of(context).colorScheme.onPrimary,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  void _useNow() {
    Get.back(); // Close bottom sheet
    Get.toNamed(Routes.createBooking, arguments: {'couponCode': coupon.code});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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

          // Gradient header
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    coupon.bannerIcon,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        coupon.bannerTitle,
                        style: AppTextStyles.h2.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        coupon.bannerSubtitle,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Coupon code
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.dividerColor,
                style: BorderStyle.solid,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Promo Code',
                        style: AppTextStyles.caption.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        coupon.code,
                        style: AppTextStyles.h4.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => _copyCode(context),
                  icon: const Icon(Icons.copy, size: 18),
                  label: const Text('Copy'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    side: BorderSide(color: theme.colorScheme.primary),
                  ),
                ),
              ],
            ),
          ),

          // Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (coupon.minOrderAmount != null && coupon.minOrderAmount! > 0)
                  _buildDetailRow(
                    context,
                    icon: Icons.shopping_cart_outlined,
                    label: 'Minimum Order',
                    value: '\u20B9${coupon.minOrderAmount!.toInt()}',
                  ),
                if (coupon.maxDiscount != null &&
                    coupon.discountType == DiscountType.percentage)
                  _buildDetailRow(
                    context,
                    icon: Icons.savings_outlined,
                    label: 'Maximum Discount',
                    value: '\u20B9${coupon.maxDiscount!.toInt()}',
                  ),
                if (coupon.expiryDisplay != null)
                  _buildDetailRow(
                    context,
                    icon: Icons.schedule_outlined,
                    label: 'Validity',
                    value: coupon.expiryDisplay!,
                    valueColor: coupon.isExpired ? Colors.red : null,
                  ),
              ],
            ),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Maybe Later'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _useNow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Use Now'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: valueColor ?? theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
