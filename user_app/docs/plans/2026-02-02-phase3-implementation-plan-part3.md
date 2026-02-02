# Phase 3 Implementation Plan - Part 3

> **Continuation of:** `2026-02-02-phase3-implementation-plan-part2.md`

---

## Track D: Orders Module

### Task 13: Create OrdersBinding

**Files:**
- Create: `lib/app/modules/orders/bindings/orders_binding.dart`

**Step 1: Create the binding file**

```dart
import 'package:get/get.dart';
import '../controllers/orders_controller.dart';

class OrdersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrdersController>(() => OrdersController());
  }
}
```

**Step 2: Commit**

```bash
git add lib/app/modules/orders/bindings/orders_binding.dart
git commit -m "feat(orders): add OrdersBinding"
```

---

### Task 14: Create OrdersController

**Files:**
- Create: `lib/app/modules/orders/controllers/orders_controller.dart`

**Step 1: Create the controller file**

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../../data/providers/api_exceptions.dart';
import '../../../routes/app_routes.dart';

enum OrderFilter { all, active, completed, cancelled }

class OrdersController extends GetxController {
  final BookingRepository _bookingRepository = BookingRepository();

  // Observable state
  final orders = <BookingModel>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final errorMessage = ''.obs;

  // Pagination
  final currentPage = 1.obs;
  final hasMorePages = true.obs;
  static const int _pageLimit = 10;

  // Filter
  final selectedFilter = OrderFilter.all.obs;

  // Selected order for details
  final selectedOrder = Rx<BookingModel?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  /// Get filter status string for API
  String? get _filterStatus {
    switch (selectedFilter.value) {
      case OrderFilter.active:
        return 'active';
      case OrderFilter.completed:
        return 'completed';
      case OrderFilter.cancelled:
        return 'cancelled';
      case OrderFilter.all:
      default:
        return null;
    }
  }

  /// Fetch orders with optional refresh
  Future<void> fetchOrders({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      hasMorePages.value = true;
      orders.clear();
    }

    if (!hasMorePages.value) return;

    try {
      if (refresh || orders.isEmpty) {
        isLoading.value = true;
      } else {
        isLoadingMore.value = true;
      }
      errorMessage.value = '';

      final response = await _bookingRepository.getMyBookings(
        page: currentPage.value,
        limit: _pageLimit,
        status: _filterStatus,
      );

      if (response.success && response.data != null) {
        final newOrders = response.data!;

        if (refresh || currentPage.value == 1) {
          orders.value = newOrders;
        } else {
          orders.addAll(newOrders);
        }

        // Check pagination
        if (response.meta != null) {
          hasMorePages.value = currentPage.value < response.meta!.totalPages;
          if (hasMorePages.value) {
            currentPage.value++;
          }
        } else {
          hasMorePages.value = newOrders.length >= _pageLimit;
          if (hasMorePages.value) {
            currentPage.value++;
          }
        }
      } else {
        final message = response.message ?? 'Failed to fetch orders';
        errorMessage.value = message;
        _showError(message);
      }
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      _showError(e.message);
    } on NetworkException {
      errorMessage.value = 'No internet connection';
      _showError('No internet connection');
    } catch (e) {
      errorMessage.value = 'Something went wrong';
      _showError('Something went wrong');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  /// Load more orders (pagination)
  Future<void> loadMoreOrders() async {
    if (!isLoadingMore.value && hasMorePages.value) {
      await fetchOrders();
    }
  }

  /// Set filter and refresh orders
  void setFilter(OrderFilter filter) {
    if (selectedFilter.value != filter) {
      selectedFilter.value = filter;
      fetchOrders(refresh: true);
    }
  }

  /// Select order for details view
  void selectOrder(BookingModel order) {
    selectedOrder.value = order;
    Get.toNamed(Routes.orderDetails);
  }

  /// Navigate to tracking for active order
  void trackOrder(BookingModel order) {
    Get.toNamed(
      Routes.orderTracking,
      arguments: {'bookingId': order.id},
    );
  }

  /// Rebook a previous order
  Future<void> rebookOrder(BookingModel order) async {
    // Navigate to create booking with pre-filled data
    Get.toNamed(
      Routes.pickupLocation,
      arguments: {
        'rebookFrom': order,
      },
    );
  }

  /// Refresh orders
  Future<void> refreshOrders() async {
    await fetchOrders(refresh: true);
  }

  /// Get order by ID (refresh from server)
  Future<BookingModel?> getOrderById(String id) async {
    try {
      final response = await _bookingRepository.getBooking(id);
      if (response.success && response.data != null) {
        // Update in local list if exists
        final index = orders.indexWhere((o) => o.id == id);
        if (index >= 0) {
          orders[index] = response.data!;
        }
        return response.data;
      }
    } catch (e) {
      print('Error fetching order: $e');
    }
    return null;
  }

  /// Rate a completed delivery
  Future<void> rateDelivery(String bookingId, int rating, {String? review}) async {
    try {
      final response = await _bookingRepository.rateDelivery(
        bookingId,
        rating: rating,
        review: review,
      );

      if (response.success) {
        _showSuccess('Thank you for your feedback!');
        // Refresh the order to get updated state
        await getOrderById(bookingId);
      } else {
        _showError(response.message ?? 'Failed to submit rating');
      }
    } catch (e) {
      _showError('Failed to submit rating');
    }
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  void _showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }
}
```

**Step 2: Commit**

```bash
git add lib/app/modules/orders/controllers/orders_controller.dart
git commit -m "feat(orders): add OrdersController with pagination and filtering"
```

---

### Task 15: Create OrdersView

**Files:**
- Create: `lib/app/modules/orders/views/orders_view.dart`

**Step 1: Create the view file**

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/booking_model.dart';
import '../controllers/orders_controller.dart';

class OrdersView extends GetView<OrdersController> {
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filter Tabs
          _buildFilterTabs(context),

          // Orders List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.orders.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.errorMessage.isNotEmpty && controller.orders.isEmpty) {
                return _buildErrorState(context);
              }

              if (controller.orders.isEmpty) {
                return _buildEmptyState(context);
              }

              return RefreshIndicator(
                onRefresh: controller.refreshOrders,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.orders.length + 1,
                  itemBuilder: (context, index) {
                    if (index == controller.orders.length) {
                      return _buildLoadMoreIndicator();
                    }
                    return _buildOrderCard(context, controller.orders[index]);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(BuildContext context) {
    final theme = Theme.of(context);

    final filters = [
      (OrderFilter.all, 'All'),
      (OrderFilter.active, 'Active'),
      (OrderFilter.completed, 'Completed'),
      (OrderFilter.cancelled, 'Cancelled'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(color: theme.dividerColor),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Obx(() => Row(
          children: filters.map((filter) {
            final isSelected = controller.selectedFilter.value == filter.$1;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(filter.$2),
                selected: isSelected,
                onSelected: (_) => controller.setFilter(filter.$1),
                backgroundColor: theme.cardColor,
                selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                labelStyle: AppTextStyles.labelMedium.copyWith(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                ),
                side: BorderSide(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.dividerColor,
                ),
              ),
            );
          }).toList(),
        )),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, BookingModel order) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => controller.selectOrder(order),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status & Date Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatusBadge(context, order.status),
                Text(
                  _formatDate(order.createdAt),
                  style: AppTextStyles.caption.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Locations
            Row(
              children: [
                const Icon(Icons.trip_origin, color: Colors.green, size: 14),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order.pickupAddress?.shortAddress ?? 'Pickup Location',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Icon(
                Icons.more_vert,
                size: 12,
                color: theme.dividerColor,
              ),
            ),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red, size: 14),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order.dropAddress?.shortAddress ?? 'Drop Location',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Package & Vehicle
            Row(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  order.packageType.name.capitalize!,
                  style: AppTextStyles.caption.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.two_wheeler,
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  order.vehicleType?.name ?? 'Vehicle',
                  style: AppTextStyles.caption.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),

            const Divider(height: 24),

            // Price & Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.amountDisplay,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    if (order.isActive)
                      TextButton(
                        onPressed: () => controller.trackOrder(order),
                        child: const Text('Track Order'),
                      )
                    else if (order.isCompleted) ...[
                      TextButton(
                        onPressed: () => controller.selectOrder(order),
                        child: const Text('Details'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () => controller.rebookOrder(order),
                        child: const Text('Rebook'),
                      ),
                    ] else
                      TextButton(
                        onPressed: () => controller.selectOrder(order),
                        child: const Text('View Details'),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, BookingStatus status) {
    Color backgroundColor;
    Color textColor;
    String text = status.name.capitalize!;

    switch (status) {
      case BookingStatus.pending:
        backgroundColor = Colors.orange.withOpacity(0.2);
        textColor = Colors.orange;
        break;
      case BookingStatus.accepted:
      case BookingStatus.arrivedPickup:
      case BookingStatus.pickedUp:
      case BookingStatus.inTransit:
      case BookingStatus.arrivedDrop:
        backgroundColor = Colors.blue.withOpacity(0.2);
        textColor = Colors.blue;
        text = 'In Progress';
        break;
      case BookingStatus.delivered:
        backgroundColor = Colors.green.withOpacity(0.2);
        textColor = Colors.green;
        break;
      case BookingStatus.cancelled:
        backgroundColor = Colors.red.withOpacity(0.2);
        textColor = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Obx(() {
      if (controller.isLoadingMore.value) {
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      if (controller.hasMorePages.value) {
        return TextButton(
          onPressed: controller.loadMoreOrders,
          child: const Text('Load More'),
        );
      }

      return const SizedBox(height: 16);
    });
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No orders yet',
            style: AppTextStyles.titleMedium.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your orders will appear here',
            style: AppTextStyles.bodyMedium.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 60,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            controller.errorMessage.value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => controller.fetchOrders(refresh: true),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Today, ${DateFormat('h:mm a').format(date)}';
    } else if (diff.inDays == 1) {
      return 'Yesterday, ${DateFormat('h:mm a').format(date)}';
    } else if (diff.inDays < 7) {
      return DateFormat('EEE, h:mm a').format(date);
    } else {
      return DateFormat('MMM d, h:mm a').format(date);
    }
  }
}
```

**Step 2: Commit**

```bash
git add lib/app/modules/orders/views/orders_view.dart
git commit -m "feat(orders): add OrdersView with filter tabs and order cards"
```

---

### Task 16: Create OrderDetailsView

**Files:**
- Create: `lib/app/modules/orders/views/order_details_view.dart`

**Step 1: Create the view file**

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../data/models/booking_model.dart';
import '../controllers/orders_controller.dart';

class OrderDetailsView extends GetView<OrdersController> {
  const OrderDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
          'Order #${controller.selectedOrder.value?.bookingNumber ?? ''}',
        )),
        centerTitle: true,
      ),
      body: Obx(() {
        final order = controller.selectedOrder.value;
        if (order == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Card
              _buildStatusCard(context, order),

              const SizedBox(height: 20),

              // Locations Card
              _buildLocationsCard(context, order),

              const SizedBox(height: 20),

              // Package Details
              _buildPackageCard(context, order),

              const SizedBox(height: 20),

              // Driver Info (if assigned)
              if (order.pilot != null)
                _buildDriverCard(context, order.pilot!),

              if (order.pilot != null)
                const SizedBox(height: 20),

              // Payment Details
              _buildPaymentCard(context, order),

              const SizedBox(height: 20),

              // Actions
              if (order.isActive)
                AppButton(
                  text: 'Track Order',
                  onPressed: () => controller.trackOrder(order),
                )
              else if (order.isCompleted)
                Column(
                  children: [
                    AppButton(
                      text: 'Rate Delivery',
                      onPressed: () => _showRatingDialog(context, order.id),
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      text: 'Rebook',
                      onPressed: () => controller.rebookOrder(order),
                      type: AppButtonType.outlined,
                    ),
                  ],
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatusCard(BuildContext context, BookingModel order) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getStatusColor(order.status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(order.status).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getStatusIcon(order.status),
            color: _getStatusColor(order.status),
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.statusDisplay,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: _getStatusColor(order.status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _getStatusDescription(order),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationsCard(BuildContext context, BookingModel order) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Locations',
            style: AppTextStyles.titleSmall.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),

          // Pickup
          _buildLocationRow(
            context: context,
            icon: Icons.trip_origin,
            iconColor: Colors.green,
            label: 'PICKUP',
            address: order.pickupAddress?.fullAddress ?? 'N/A',
            time: order.pickedUpAt != null
                ? 'Picked up at ${DateFormat('h:mm a').format(order.pickedUpAt!)}'
                : null,
          ),

          Padding(
            padding: const EdgeInsets.only(left: 11),
            child: Container(
              width: 2,
              height: 30,
              color: theme.dividerColor,
            ),
          ),

          // Drop
          _buildLocationRow(
            context: context,
            icon: Icons.location_on,
            iconColor: Colors.red,
            label: 'DROP',
            address: order.dropAddress?.fullAddress ?? 'N/A',
            time: order.deliveredAt != null
                ? 'Delivered at ${DateFormat('h:mm a').format(order.deliveredAt!)}'
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRow({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String label,
    required String address,
    String? time,
  }) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                address,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              if (time != null) ...[
                const SizedBox(height: 4),
                Text(
                  time,
                  style: AppTextStyles.caption.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPackageCard(BuildContext context, BookingModel order) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Package Details',
            style: AppTextStyles.titleSmall.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildDetailChip(
                context,
                icon: Icons.inventory_2_outlined,
                label: order.packageType.name.capitalize!,
              ),
              const SizedBox(width: 12),
              _buildDetailChip(
                context,
                icon: Icons.two_wheeler,
                label: order.vehicleType?.name ?? 'Vehicle',
              ),
              const SizedBox(width: 12),
              _buildDetailChip(
                context,
                icon: Icons.straighten,
                label: '${order.distance.toStringAsFixed(1)} km',
              ),
            ],
          ),
          if (order.packageDescription != null &&
              order.packageDescription!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Description: ${order.packageDescription}',
              style: AppTextStyles.bodySmall.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailChip(BuildContext context,
      {required IconData icon, required String label}) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverCard(BuildContext context, PilotInfo pilot) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Driver',
            style: AppTextStyles.titleSmall.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                backgroundImage: pilot.avatar != null
                    ? NetworkImage(pilot.avatar!)
                    : null,
                child: pilot.avatar == null
                    ? Icon(
                        Icons.person,
                        color: theme.colorScheme.primary,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pilot.name,
                      style: AppTextStyles.titleSmall.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          pilot.rating.toStringAsFixed(1),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (pilot.vehicleNumber != null) ...[
                          const SizedBox(width: 12),
                          Text(
                            pilot.vehicleNumber!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
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

  Widget _buildPaymentCard(BuildContext context, BookingModel order) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment',
            style: AppTextStyles.titleSmall.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          _buildPaymentRow(context, 'Base Fare', '₹${order.baseFare.toStringAsFixed(0)}'),
          _buildPaymentRow(context, 'Distance Fare', '₹${order.distanceFare.toStringAsFixed(0)}'),
          if (order.taxes > 0)
            _buildPaymentRow(context, 'Taxes', '₹${order.taxes.toStringAsFixed(0)}'),
          if (order.discount > 0)
            _buildPaymentRow(context, 'Discount', '-₹${order.discount.toStringAsFixed(0)}', isDiscount: true),
          const Divider(height: 24),
          _buildPaymentRow(
            context,
            'Total',
            order.amountDisplay,
            isTotal: true,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                _getPaymentIcon(order.paymentMethod),
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                'Paid via ${order.paymentMethod.name.capitalize}',
                style: AppTextStyles.caption.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(BuildContext context, String label, String value,
      {bool isTotal = false, bool isDiscount = false}) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: (isTotal ? AppTextStyles.titleSmall : AppTextStyles.bodyMedium).copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: (isTotal ? AppTextStyles.titleSmall : AppTextStyles.bodyMedium).copyWith(
              color: isDiscount
                  ? Colors.green
                  : isTotal
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog(BuildContext context, String bookingId) {
    int selectedRating = 5;
    final reviewController = TextEditingController();

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Rate Your Delivery'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      onPressed: () => setState(() => selectedRating = index + 1),
                      icon: Icon(
                        index < selectedRating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 36,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: reviewController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Write a review (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  controller.rateDelivery(
                    bookingId,
                    selectedRating,
                    review: reviewController.text.isNotEmpty
                        ? reviewController.text
                        : null,
                  );
                },
                child: const Text('Submit'),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.accepted:
      case BookingStatus.arrivedPickup:
      case BookingStatus.pickedUp:
      case BookingStatus.inTransit:
      case BookingStatus.arrivedDrop:
        return Colors.blue;
      case BookingStatus.delivered:
        return Colors.green;
      case BookingStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Icons.access_time;
      case BookingStatus.accepted:
      case BookingStatus.arrivedPickup:
      case BookingStatus.pickedUp:
      case BookingStatus.inTransit:
      case BookingStatus.arrivedDrop:
        return Icons.local_shipping;
      case BookingStatus.delivered:
        return Icons.check_circle;
      case BookingStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _getStatusDescription(BookingModel order) {
    switch (order.status) {
      case BookingStatus.pending:
        return 'Waiting for driver to accept';
      case BookingStatus.accepted:
        return 'Driver is on the way to pickup';
      case BookingStatus.arrivedPickup:
        return 'Driver has arrived at pickup location';
      case BookingStatus.pickedUp:
        return 'Package has been picked up';
      case BookingStatus.inTransit:
        return 'Package is on the way to destination';
      case BookingStatus.arrivedDrop:
        return 'Driver has arrived at drop location';
      case BookingStatus.delivered:
        return 'Package delivered successfully';
      case BookingStatus.cancelled:
        return order.cancelReason ?? 'Order was cancelled';
    }
  }

  IconData _getPaymentIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.wallet:
        return Icons.account_balance_wallet;
      case PaymentMethod.cash:
        return Icons.money;
      case PaymentMethod.upi:
        return Icons.qr_code;
      case PaymentMethod.card:
        return Icons.credit_card;
      case PaymentMethod.netbanking:
        return Icons.account_balance;
    }
  }
}
```

**Step 2: Commit**

```bash
git add lib/app/modules/orders/views/order_details_view.dart
git commit -m "feat(orders): add OrderDetailsView with status, locations, driver, and payment info"
```

---

## Track E: Tracking Module

### Task 17: Create TrackingBinding

**Files:**
- Create: `lib/app/modules/tracking/bindings/tracking_binding.dart`

**Step 1: Create the binding file**

```dart
import 'package:get/get.dart';
import '../controllers/tracking_controller.dart';

class TrackingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TrackingController>(() => TrackingController());
  }
}
```

**Step 2: Commit**

```bash
git add lib/app/modules/tracking/bindings/tracking_binding.dart
git commit -m "feat(tracking): add TrackingBinding"
```

---

### Task 18: Create TrackingController

**Files:**
- Create: `lib/app/modules/tracking/controllers/tracking_controller.dart`

**Step 1: Create the controller file**

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../../services/socket_service.dart';
import '../../../services/maps_service.dart';
import '../../../routes/app_routes.dart';

class TrackingController extends GetxController {
  final BookingRepository _bookingRepository = BookingRepository();
  late final SocketService _socketService;
  late final MapsService _mapsService;

  // Map controller
  GoogleMapController? mapController;

  // Observable state
  final booking = Rx<BookingModel?>(null);
  final isLoading = true.obs;
  final errorMessage = ''.obs;

  // Driver location
  final driverLocation = Rx<LatLng?>(null);
  final driverHeading = 0.0.obs;

  // ETA
  final currentEta = 0.obs; // minutes
  final currentDistance = 0.0.obs; // km

  // Route
  final routePolyline = <LatLng>[].obs;

  // Socket connection
  final isConnected = false.obs;

  // Markers
  final markers = <Marker>{}.obs;

  // Stream subscriptions
  StreamSubscription? _locationSubscription;
  StreamSubscription? _statusSubscription;
  StreamSubscription? _etaSubscription;
  StreamSubscription? _completedSubscription;
  StreamSubscription? _cancelledSubscription;

  String? _bookingId;

  @override
  void onInit() {
    super.onInit();
    _socketService = Get.find<SocketService>();
    _mapsService = Get.find<MapsService>();

    // Get booking ID from arguments
    final args = Get.arguments as Map<String, dynamic>?;
    _bookingId = args?['bookingId'];

    if (_bookingId != null) {
      _loadBooking();
      _connectToTracking();
    } else {
      errorMessage.value = 'Invalid booking ID';
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _disconnectTracking();
    mapController?.dispose();
    super.onClose();
  }

  /// Load booking details
  Future<void> _loadBooking() async {
    try {
      isLoading.value = true;
      final response = await _bookingRepository.getBooking(_bookingId!);

      if (response.success && response.data != null) {
        booking.value = response.data!;
        _updateMarkers();
      } else {
        errorMessage.value = response.message ?? 'Failed to load booking';
      }
    } catch (e) {
      errorMessage.value = 'Something went wrong';
    } finally {
      isLoading.value = false;
    }
  }

  /// Connect to socket for real-time updates
  void _connectToTracking() {
    // Connect socket if not connected
    _socketService.connect();

    // Join booking room
    _socketService.joinBookingRoom(_bookingId!);

    // Listen to driver location updates
    _locationSubscription = _socketService.onDriverLocation.listen((data) {
      if (data.bookingId == _bookingId) {
        driverLocation.value = data.location;
        driverHeading.value = data.heading;
        _updateDriverMarker();
      }
    });

    // Listen to status updates
    _statusSubscription = _socketService.onStatusUpdate.listen((data) {
      if (data.bookingId == _bookingId) {
        _updateStatus(data.status);
      }
    });

    // Listen to ETA updates
    _etaSubscription = _socketService.onEtaUpdate.listen((data) {
      if (data.bookingId == _bookingId) {
        currentEta.value = data.etaMinutes;
        currentDistance.value = data.distanceKm;
      }
    });

    // Listen for booking completion
    _completedSubscription = _socketService.onBookingCompleted.listen((bookingId) {
      if (bookingId == _bookingId) {
        _showCompletionDialog();
      }
    });

    // Listen for booking cancellation
    _cancelledSubscription = _socketService.onBookingCancelled.listen((data) {
      if (data['bookingId'] == _bookingId) {
        _showCancellationDialog(data['reason'] ?? 'Booking was cancelled');
      }
    });

    // Update connection status
    isConnected.value = _socketService.isConnected.value;
    _socketService.isConnected.listen((connected) {
      isConnected.value = connected;
    });
  }

  /// Disconnect from tracking
  void _disconnectTracking() {
    _locationSubscription?.cancel();
    _statusSubscription?.cancel();
    _etaSubscription?.cancel();
    _completedSubscription?.cancel();
    _cancelledSubscription?.cancel();

    if (_bookingId != null) {
      _socketService.leaveBookingRoom(_bookingId!);
    }
  }

  /// Update booking status
  void _updateStatus(BookingStatus status) {
    if (booking.value != null) {
      // Create updated booking with new status
      // In real app, you'd refetch from server for accurate data
      _loadBooking(); // Refresh booking data
    }
  }

  /// Update map markers
  void _updateMarkers() {
    final currentBooking = booking.value;
    if (currentBooking == null) return;

    final newMarkers = <Marker>{};

    // Pickup marker
    if (currentBooking.pickupAddress != null) {
      newMarkers.add(Marker(
        markerId: const MarkerId('pickup'),
        position: LatLng(
          currentBooking.pickupAddress!.lat,
          currentBooking.pickupAddress!.lng,
        ),
        icon: _mapsService.pickupMarker,
        infoWindow: const InfoWindow(title: 'Pickup'),
      ));
    }

    // Drop marker
    if (currentBooking.dropAddress != null) {
      newMarkers.add(Marker(
        markerId: const MarkerId('drop'),
        position: LatLng(
          currentBooking.dropAddress!.lat,
          currentBooking.dropAddress!.lng,
        ),
        icon: _mapsService.dropMarker,
        infoWindow: const InfoWindow(title: 'Drop'),
      ));
    }

    // Driver marker
    if (driverLocation.value != null) {
      newMarkers.add(Marker(
        markerId: const MarkerId('driver'),
        position: driverLocation.value!,
        icon: _mapsService.driverMarker,
        rotation: driverHeading.value,
        anchor: const Offset(0.5, 0.5),
        infoWindow: InfoWindow(
          title: currentBooking.pilot?.name ?? 'Driver',
        ),
      ));
    }

    markers.value = newMarkers;
  }

  /// Update driver marker only
  void _updateDriverMarker() {
    final currentMarkers = Set<Marker>.from(markers);
    currentMarkers.removeWhere((m) => m.markerId.value == 'driver');

    if (driverLocation.value != null) {
      currentMarkers.add(Marker(
        markerId: const MarkerId('driver'),
        position: driverLocation.value!,
        icon: _mapsService.driverMarker,
        rotation: driverHeading.value,
        anchor: const Offset(0.5, 0.5),
        infoWindow: InfoWindow(
          title: booking.value?.pilot?.name ?? 'Driver',
        ),
      ));
    }

    markers.value = currentMarkers;

    // Animate camera to driver
    if (mapController != null && driverLocation.value != null) {
      mapController!.animateCamera(
        CameraUpdate.newLatLng(driverLocation.value!),
      );
    }
  }

  /// Set map controller
  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _fitBoundsToRoute();
  }

  /// Fit map bounds to show entire route
  void _fitBoundsToRoute() {
    final currentBooking = booking.value;
    if (currentBooking == null || mapController == null) return;

    if (currentBooking.pickupAddress != null && currentBooking.dropAddress != null) {
      final pickup = LatLng(
        currentBooking.pickupAddress!.lat,
        currentBooking.pickupAddress!.lng,
      );
      final drop = LatLng(
        currentBooking.dropAddress!.lat,
        currentBooking.dropAddress!.lng,
      );

      mapController!.animateCamera(
        _mapsService.fitBounds(pickup, drop),
      );
    }
  }

  /// Center map on driver
  void centerOnDriver() {
    if (mapController != null && driverLocation.value != null) {
      mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(driverLocation.value!, 16),
      );
    }
  }

  /// Call driver
  Future<void> callDriver() async {
    final phone = booking.value?.pilot?.phone;
    if (phone != null) {
      final uri = Uri.parse('tel:$phone');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    }
  }

  /// Open chat with driver (placeholder)
  void openChat() {
    Get.snackbar(
      'Coming Soon',
      'In-app chat will be available soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Show delivery completion dialog
  void _showCompletionDialog() {
    Get.dialog(
      AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 12),
            Text('Delivered!'),
          ],
        ),
        content: const Text(
          'Your package has been delivered successfully. Would you like to rate your delivery?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              Get.offNamed(Routes.orders);
            },
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.offNamed(Routes.orderDetails, arguments: {
                'bookingId': _bookingId,
              });
            },
            child: const Text('Rate Now'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// Show cancellation dialog
  void _showCancellationDialog(String reason) {
    Get.dialog(
      AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.cancel, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text('Cancelled'),
          ],
        ),
        content: Text('Your booking has been cancelled.\n\nReason: $reason'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.offNamed(Routes.main);
            },
            child: const Text('OK'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// Refresh booking data
  Future<void> refreshBooking() async {
    await _loadBooking();
  }

  /// Get formatted ETA string
  String get etaDisplay {
    if (currentEta.value <= 0) return 'Calculating...';
    if (currentEta.value < 60) return '${currentEta.value} min';
    final hours = currentEta.value ~/ 60;
    final mins = currentEta.value % 60;
    return '${hours}h ${mins}m';
  }

  /// Get formatted distance string
  String get distanceDisplay {
    if (currentDistance.value <= 0) return '--';
    return '${currentDistance.value.toStringAsFixed(1)} km';
  }
}
```

**Step 2: Commit**

```bash
git add lib/app/modules/tracking/controllers/tracking_controller.dart
git commit -m "feat(tracking): add TrackingController with socket events and map management"
```

---

### Task 19: Create TrackingView

**Files:**
- Create: `lib/app/modules/tracking/views/tracking_view.dart`

**Step 1: Create the view file** (due to length, this is a condensed version)

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/booking_model.dart';
import '../controllers/tracking_controller.dart';

class TrackingView extends GetView<TrackingController> {
  const TrackingView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(child: Text(controller.errorMessage.value));
        }

        final booking = controller.booking.value;
        if (booking == null) {
          return const Center(child: Text('Booking not found'));
        }

        return Stack(
          children: [
            // Map
            Positioned.fill(
              child: Obx(() => GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    booking.pickupAddress?.lat ?? AppConstants.defaultLat,
                    booking.pickupAddress?.lng ?? AppConstants.defaultLng,
                  ),
                  zoom: 14,
                ),
                markers: controller.markers,
                polylines: controller.routePolyline.isNotEmpty
                    ? {
                        Polyline(
                          polylineId: const PolylineId('route'),
                          points: controller.routePolyline,
                          color: theme.colorScheme.primary,
                          width: 4,
                        ),
                      }
                    : {},
                onMapCreated: controller.onMapCreated,
                myLocationEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
              )),
            ),

            // Back Button
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 16,
              child: CircleAvatar(
                backgroundColor: theme.cardColor,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Get.back(),
                ),
              ),
            ),

            // Center on Driver Button
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              right: 16,
              child: CircleAvatar(
                backgroundColor: theme.cardColor,
                child: IconButton(
                  icon: const Icon(Icons.my_location),
                  onPressed: controller.centerOnDriver,
                ),
              ),
            ),

            // Bottom Sheet
            DraggableScrollableSheet(
              initialChildSize: 0.4,
              minChildSize: 0.25,
              maxChildSize: 0.7,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                        color: theme.shadowColor.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
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

                      // ETA Card
                      _buildEtaCard(context, booking),
                      const SizedBox(height: 16),

                      // Status
                      _buildStatusCard(context, booking),
                      const SizedBox(height: 16),

                      // Driver Info
                      if (booking.pilot != null)
                        _buildDriverCard(context, booking.pilot!),

                      // OTP (show when near drop)
                      if (booking.status == BookingStatus.arrivedDrop ||
                          booking.status == BookingStatus.inTransit)
                        _buildOtpCard(context, booking),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      }),
    );
  }

  Widget _buildEtaCard(BuildContext context, BookingModel booking) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              const Icon(Icons.timer, size: 24),
              const SizedBox(height: 4),
              Obx(() => Text(
                controller.etaDisplay,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              )),
              Text(
                'ETA',
                style: AppTextStyles.caption.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          Container(
            width: 1,
            height: 40,
            color: theme.dividerColor,
          ),
          Column(
            children: [
              const Icon(Icons.straighten, size: 24),
              const SizedBox(height: 4),
              Obx(() => Text(
                controller.distanceDisplay,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              )),
              Text(
                'Away',
                style: AppTextStyles.caption.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, BookingModel booking) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                booking.statusDisplay,
                style: AppTextStyles.titleSmall.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Status timeline would go here
          _buildStatusTimeline(context, booking),
        ],
      ),
    );
  }

  Widget _buildStatusTimeline(BuildContext context, BookingModel booking) {
    final statuses = [
      (BookingStatus.accepted, 'Accepted'),
      (BookingStatus.arrivedPickup, 'Arrived'),
      (BookingStatus.pickedUp, 'Picked Up'),
      (BookingStatus.inTransit, 'In Transit'),
      (BookingStatus.delivered, 'Delivered'),
    ];

    final currentIndex = statuses.indexWhere((s) => s.$1 == booking.status);

    return Row(
      children: statuses.asMap().entries.map((entry) {
        final index = entry.key;
        final status = entry.value;
        final isCompleted = index <= currentIndex;
        final isLast = index == statuses.length - 1;

        return Expanded(
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: isCompleted ? Colors.green : Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                child: isCompleted
                    ? const Icon(Icons.check, size: 12, color: Colors.white)
                    : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    height: 2,
                    color: isCompleted ? Colors.green : Colors.grey.shade300,
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDriverCard(BuildContext context, PilotInfo pilot) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: pilot.avatar != null
                ? NetworkImage(pilot.avatar!)
                : null,
            child: pilot.avatar == null
                ? const Icon(Icons.person)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pilot.name,
                  style: AppTextStyles.titleSmall,
                ),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      pilot.rating.toStringAsFixed(1),
                      style: AppTextStyles.bodySmall,
                    ),
                    if (pilot.vehicleNumber != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        pilot.vehicleNumber!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: controller.callDriver,
            icon: Icon(Icons.call, color: theme.colorScheme.primary),
          ),
          IconButton(
            onPressed: controller.openChat,
            icon: Icon(Icons.chat, color: theme.colorScheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpCard(BuildContext context, BookingModel booking) {
    final theme = Theme.of(context);
    final otp = booking.deliveryOtp ?? '----';

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            'Delivery OTP',
            style: AppTextStyles.labelMedium.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: otp.split('').map((digit) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 40,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.colorScheme.primary),
                ),
                child: Center(
                  child: Text(
                    digit,
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Text(
            'Share this OTP with driver for delivery',
            style: AppTextStyles.caption.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
```

**Step 2: Commit**

```bash
git add lib/app/modules/tracking/views/tracking_view.dart
git commit -m "feat(tracking): add TrackingView with live map, status, driver info, and OTP"
```

---

## Track F: Integration

### Task 20: Update Routes and App Pages

**Files:**
- Modify: `lib/app/routes/app_pages.dart`

**Step 1: Add new routes**

Add the following imports and routes to `app_pages.dart`:

```dart
// Add imports at top
import '../modules/booking/bindings/booking_binding.dart';
import '../modules/booking/views/create_booking_view.dart';
import '../modules/booking/views/vehicle_selection_view.dart';
import '../modules/booking/views/payment_view.dart';
import '../modules/booking/views/finding_driver_view.dart';
import '../modules/orders/bindings/orders_binding.dart';
import '../modules/orders/views/orders_view.dart';
import '../modules/orders/views/order_details_view.dart';
import '../modules/tracking/bindings/tracking_binding.dart';
import '../modules/tracking/views/tracking_view.dart';

// Add routes in routes list:

    // Booking Routes
    GetPage(
      name: Routes.pickupLocation,
      page: () => const CreateBookingView(),
      binding: BookingBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.vehicleSelection,
      page: () => const VehicleSelectionView(),
      binding: BookingBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.reviewBooking,
      page: () => const PaymentView(),
      binding: BookingBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.findingDriver,
      page: () => const FindingDriverView(),
      binding: BookingBinding(),
      transition: Transition.fadeIn,
    ),

    // Orders Routes
    GetPage(
      name: Routes.orders,
      page: () => const OrdersView(),
      binding: OrdersBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.orderDetails,
      page: () => const OrderDetailsView(),
      binding: OrdersBinding(),
      transition: Transition.rightToLeft,
    ),

    // Tracking Route
    GetPage(
      name: Routes.orderTracking,
      page: () => const TrackingView(),
      binding: TrackingBinding(),
      transition: Transition.fadeIn,
    ),
```

**Step 2: Commit**

```bash
git add lib/app/routes/app_pages.dart
git commit -m "feat(routes): add booking, orders, and tracking routes"
```

---

### Task 21: Register Services in Main

**Files:**
- Modify: `lib/main.dart`

**Step 1: Register services**

Add service initialization in main.dart before runApp:

```dart
// In main() function, before runApp():

  // Initialize services
  await Get.putAsync(() => LocationService().init());
  Get.put(SocketService());
  await Get.putAsync(() => MapsService().init());
  Get.put(PaymentService());
```

**Step 2: Commit**

```bash
git add lib/main.dart
git commit -m "feat(main): register location, socket, maps, and payment services"
```

---

### Task 22: Final Integration Commit

**Step 1: Run flutter analyze**

```bash
cd /Users/sotsys386/Nirav/claude_projects/SendIt/user_app && flutter analyze
```

**Step 2: Fix any issues and commit**

```bash
git add .
git commit -m "feat: complete Phase 3 - Booking, Orders, and Tracking modules"
```

---

## Post-Implementation Checklist

- [ ] All services registered in main.dart
- [ ] All routes added to app_pages.dart
- [ ] Google Maps API key configured
- [ ] Socket server URL correct
- [ ] Backend APIs available and tested
- [ ] flutter analyze passes with no errors
- [ ] App builds successfully on iOS and Android

---

## Summary

**Total Tasks:** 22
**Total New Files:** ~25
**Estimated Lines of Code:** ~4,000

**Files Created:**
- Services: 4 (location, socket, maps, payment)
- Models: 1 (price_calculation)
- Repository: 1 (booking)
- Controllers: 3 (booking, orders, tracking)
- Views: 7 (create_booking, vehicle_selection, payment, finding_driver, orders, order_details, tracking)
- Bindings: 3 (booking, orders, tracking)

**Files Modified:**
- app_pages.dart (routes)
- main.dart (service registration)
