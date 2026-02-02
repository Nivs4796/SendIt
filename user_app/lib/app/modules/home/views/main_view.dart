import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/models/coupon_model.dart';
import '../controllers/home_controller.dart';
import '../widgets/offer_details_sheet.dart';

class MainView extends GetView<HomeController> {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'SendIt',
          style: AppTextStyles.h4.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Get.snackbar(
                'Coming Soon',
                'Notifications will be available in a future update',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: theme.colorScheme.primary,
                colorText: theme.colorScheme.onPrimary,
                margin: const EdgeInsets.all(16),
                borderRadius: 8,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: controller.goToProfile,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Location Selection Card
              _buildLocationCard(context),

              // Offers Banner Section
              _buildOffersBanner(context),

              // Active Delivery Section - Show after offers
              Obx(() {
                if (controller.isLoadingActive.value) {
                  return _buildActiveDeliveriesLoading(context);
                }
                if (controller.activeDeliveries.isNotEmpty) {
                  return _buildActiveDeliverySection(context);
                }
                return const SizedBox.shrink();
              }),

              // Vehicle Type Selection
              _buildVehicleTypeSection(context),

              // Quick Services Grid
              _buildQuickServicesSection(context),

              // Recent Deliveries
              Obx(() {
                if (controller.recentOrders.isNotEmpty) {
                  return _buildRecentDeliveriesSection(context);
                }
                return const SizedBox.shrink();
              }),

              const SizedBox(height: 24), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationCard(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: controller.goToCreateBooking,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.local_shipping,
                    color: theme.colorScheme.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Send a package',
                        style: AppTextStyles.h4.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Fast & reliable delivery',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: theme.colorScheme.primary,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOffersBanner(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Text(
            'Offers & Deals',
            style: AppTextStyles.h4.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        SizedBox(
          height: 140,
          child: Obx(() {
            if (controller.isLoadingCoupons.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.availableCoupons.isEmpty) {
              return Center(
                child: Text(
                  'No offers available',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            }

            return ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: controller.availableCoupons.length,
              itemBuilder: (context, index) {
                final coupon = controller.availableCoupons[index];
                return _buildDynamicOfferCard(context, coupon, index);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildDynamicOfferCard(BuildContext context, CouponModel coupon, int index) {
    final gradientColors = coupon.getBannerGradient(index);

    return Container(
      width: 220,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => OfferDetailsSheet.show(context, coupon, gradientColors),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        coupon.bannerIcon,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        coupon.code,
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coupon.bannerTitle,
                      style: AppTextStyles.h3.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      coupon.bannerSubtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleTypeSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Text(
            'Choose Vehicle',
            style: AppTextStyles.h4.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        SizedBox(
          height: 120,
          child: Obx(() {
            if (controller.isLoadingVehicles.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.vehicleTypes.isEmpty) {
              // Show default vehicle types
              return ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _VehicleTypeCard(
                    icon: Icons.two_wheeler,
                    name: 'Bike',
                    description: 'Up to 10 kg',
                    price: '₹30',
                    onTap: controller.goToCreateBooking,
                  ),
                  _VehicleTypeCard(
                    icon: Icons.electric_rickshaw,
                    name: 'Auto',
                    description: 'Up to 50 kg',
                    price: '₹50',
                    onTap: controller.goToCreateBooking,
                  ),
                  _VehicleTypeCard(
                    icon: Icons.local_shipping,
                    name: 'Mini Truck',
                    description: 'Up to 200 kg',
                    price: '₹100',
                    onTap: controller.goToCreateBooking,
                  ),
                  _VehicleTypeCard(
                    icon: Icons.fire_truck,
                    name: 'Truck',
                    description: 'Up to 500 kg',
                    price: '₹200',
                    onTap: controller.goToCreateBooking,
                  ),
                ],
              );
            }

            return ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: controller.vehicleTypes.length,
              itemBuilder: (context, index) {
                final vehicle = controller.vehicleTypes[index];
                return _VehicleTypeCard(
                  icon: _getVehicleIcon(vehicle.name),
                  name: vehicle.name,
                  description: vehicle.weightDisplay,
                  price: vehicle.basePriceDisplay,
                  onTap: () => controller.goToCreateBookingWithVehicle(vehicle),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  IconData _getVehicleIcon(String name) {
    final nameLower = name.toLowerCase();
    if (nameLower.contains('bike') || nameLower.contains('two')) {
      return Icons.two_wheeler;
    } else if (nameLower.contains('auto') || nameLower.contains('three')) {
      return Icons.electric_rickshaw;
    } else if (nameLower.contains('mini') || nameLower.contains('small')) {
      return Icons.local_shipping;
    } else if (nameLower.contains('truck') || nameLower.contains('large')) {
      return Icons.fire_truck;
    }
    return Icons.local_shipping;
  }

  Widget _buildActiveDeliveriesLoading(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildActiveDeliverySection(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.local_shipping,
                      color: Colors.orange,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Active Delivery',
                    style: AppTextStyles.h4.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: controller.goToOrders,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'View All',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Show only first active delivery in compact form
          ...controller.activeDeliveries
              .take(1)
              .map((booking) => _buildCompactActiveDeliveryCard(context, booking)),
        ],
      ),
    );
  }

  Widget _buildCompactActiveDeliveryCard(BuildContext context, BookingModel booking) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => controller.goToTracking(booking.id),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          children: [
            // Status indicator
            Container(
              width: 8,
              height: 50,
              decoration: BoxDecoration(
                color: _getStatusColor(booking.status),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            // Route info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _getStatusColor(booking.status).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          controller.getStatusText(booking.status),
                          style: AppTextStyles.caption.copyWith(
                            color: _getStatusColor(booking.status),
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '#${booking.bookingNumber.length > 6 ? booking.bookingNumber.substring(0, 6).toUpperCase() : booking.bookingNumber.toUpperCase()}',
                        style: AppTextStyles.caption.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${booking.pickupAddress?.shortAddress ?? "Pickup"} → ${booking.dropAddress?.shortAddress ?? "Drop"}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Track button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.gps_fixed,
                    size: 14,
                    color: theme.colorScheme.onPrimary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Track',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
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

  Widget _buildQuickServicesSection(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Services',
            style: AppTextStyles.h4.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _QuickServiceCard(
                  icon: Icons.flash_on,
                  title: 'Express',
                  subtitle: 'Same day',
                  color: Colors.orange,
                  onTap: controller.goToCreateBooking,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickServiceCard(
                  icon: Icons.schedule,
                  title: 'Schedule',
                  subtitle: 'Plan ahead',
                  color: Colors.blue,
                  onTap: controller.goToCreateBooking,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickServiceCard(
                  icon: Icons.repeat,
                  title: 'Rebook',
                  subtitle: 'Past orders',
                  color: Colors.purple,
                  onTap: controller.goToOrders,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentDeliveriesSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Deliveries',
                style: AppTextStyles.h4.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              TextButton(
                onPressed: controller.goToOrders,
                child: Text(
                  'See All',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...controller.recentOrders
            .map((order) => _buildRecentDeliveryItem(context, order)),
      ],
    );
  }

  Widget _buildRecentDeliveryItem(BuildContext context, BookingModel order) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => controller.goToOrderDetails(order.id),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.dropAddress?.shortAddress ?? 'Delivered',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  order.amountDisplay,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Rebook',
                  style: AppTextStyles.caption.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.accepted:
      case BookingStatus.arrivedPickup:
        return Colors.blue;
      case BookingStatus.pickedUp:
      case BookingStatus.inTransit:
      case BookingStatus.arrivedDrop:
      case BookingStatus.delivered:
        return Colors.green;
      case BookingStatus.cancelled:
        return Colors.red;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

// Vehicle Type Card Widget
class _VehicleTypeCard extends StatelessWidget {
  final IconData icon;
  final String name;
  final String description;
  final String price;
  final VoidCallback onTap;

  const _VehicleTypeCard({
    required this.icon,
    required this.name,
    required this.description,
    required this.price,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 100,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  name,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  description,
                  style: AppTextStyles.caption.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Quick Service Card Widget
class _QuickServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickServiceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: AppTextStyles.labelMedium.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                subtitle,
                style: AppTextStyles.caption.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

