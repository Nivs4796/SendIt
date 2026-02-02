import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../../data/providers/api_exceptions.dart';
import '../../../routes/app_routes.dart';

/// Filter options for orders list
enum OrderFilter {
  all,
  active,
  completed,
  cancelled,
}

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
  final selectedFilter = Rx<OrderFilter>(OrderFilter.all);

  // Selected order for details view
  final selectedOrder = Rx<BookingModel?>(null);

  /// Get the API status string based on selected filter
  String? get _filterStatus {
    switch (selectedFilter.value) {
      case OrderFilter.all:
        return null;
      case OrderFilter.active:
        // Active orders: pending, accepted, arrivedPickup, pickedUp, inTransit, arrivedDrop
        // API should handle 'ACTIVE' as a special filter for non-terminal statuses
        return 'ACTIVE';
      case OrderFilter.completed:
        return 'DELIVERED';
      case OrderFilter.cancelled:
        return 'CANCELLED';
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  /// Fetch orders with pagination
  /// If refresh is true, resets to page 1 and clears existing list
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

        // Check if there are more pages
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

  /// Load more orders for pagination
  Future<void> loadMoreOrders() async {
    if (isLoadingMore.value || !hasMorePages.value) return;
    await fetchOrders();
  }

  /// Set filter and refresh orders
  void setFilter(OrderFilter filter) {
    if (selectedFilter.value != filter) {
      selectedFilter.value = filter;
      fetchOrders(refresh: true);
    }
  }

  /// Select an order and navigate to details
  void selectOrder(BookingModel order) {
    selectedOrder.value = order;
    Get.toNamed(
      Routes.orderDetails,
      arguments: {'orderId': order.id, 'order': order},
    );
  }

  /// Navigate to order tracking
  void trackOrder(BookingModel order) {
    Get.toNamed(
      Routes.orderTracking,
      arguments: {'orderId': order.id, 'order': order},
    );
  }

  /// Rebook an order - navigate to booking with prefilled data
  void rebookOrder(BookingModel order) {
    Get.toNamed(
      Routes.pickupLocation,
      arguments: {
        'rebookOrder': order,
        'pickupAddress': order.pickupAddress,
        'dropAddress': order.dropAddress,
        'vehicleTypeId': order.vehicleTypeId,
        'packageType': order.packageType,
        'packageDescription': order.packageDescription,
      },
    );
  }

  /// Pull to refresh
  Future<void> refreshOrders() async {
    await fetchOrders(refresh: true);
  }

  /// Fetch a single order by ID
  Future<BookingModel?> getOrderById(String id) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _bookingRepository.getBooking(id);

      if (response.success && response.data != null) {
        selectedOrder.value = response.data;

        // Update the order in the list if it exists
        final index = orders.indexWhere((o) => o.id == id);
        if (index != -1) {
          orders[index] = response.data!;
        }

        return response.data;
      } else {
        final message = response.message ?? 'Failed to fetch order';
        errorMessage.value = message;
        _showError(message);
        return null;
      }
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      _showError(e.message);
      return null;
    } on NetworkException {
      errorMessage.value = 'No internet connection';
      _showError('No internet connection');
      return null;
    } catch (e) {
      errorMessage.value = 'Something went wrong';
      _showError('Something went wrong');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// Rate a delivery
  Future<bool> rateDelivery(
    String bookingId,
    int rating, {
    String? review,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _bookingRepository.rateDelivery(
        bookingId,
        rating: rating,
        review: review,
      );

      if (response.success) {
        _showSuccess(response.message ?? 'Rating submitted successfully');

        // Refresh the order to get updated data
        await getOrderById(bookingId);

        return true;
      } else {
        final message = response.message ?? 'Failed to submit rating';
        errorMessage.value = message;
        _showError(message);
        return false;
      }
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      _showError(e.message);
      return false;
    } on NetworkException {
      errorMessage.value = 'No internet connection';
      _showError('No internet connection');
      return false;
    } catch (e) {
      errorMessage.value = 'Something went wrong';
      _showError('Something went wrong');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Show error snackbar
  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  /// Show success snackbar
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
