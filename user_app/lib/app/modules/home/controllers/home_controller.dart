import 'package:get/get.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/models/vehicle_type_model.dart';
import '../../../data/models/coupon_model.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../../data/repositories/coupon_repository.dart';
import '../../../routes/app_routes.dart';
import '../../../core/constants/app_constants.dart';

class HomeController extends GetxController {
  final BookingRepository _bookingRepository = BookingRepository();
  final CouponRepository _couponRepository = CouponRepository();

  // Active deliveries (in progress)
  final activeDeliveries = <BookingModel>[].obs;
  final isLoadingActive = false.obs;

  // Recent orders
  final recentOrders = <BookingModel>[].obs;
  final isLoadingRecent = false.obs;

  // Vehicle types for quick selection
  final vehicleTypes = <VehicleTypeModel>[].obs;
  final isLoadingVehicles = false.obs;

  // Available coupons/offers
  final availableCoupons = <CouponModel>[].obs;
  final isLoadingCoupons = false.obs;

  // Error state
  final errorMessage = Rx<String?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchVehicleTypes();
    fetchActiveDeliveries();
    fetchRecentOrders();
    fetchAvailableCoupons();
  }

  /// Fetch available vehicle types
  Future<void> fetchVehicleTypes() async {
    try {
      isLoadingVehicles.value = true;
      final response = await _bookingRepository.getVehicleTypes();
      if (response.success && response.data != null) {
        vehicleTypes.value = response.data!;
      }
    } catch (e) {
      // Silent fail for vehicle types
    } finally {
      isLoadingVehicles.value = false;
    }
  }

  /// Fetch available coupons for offers section
  Future<void> fetchAvailableCoupons() async {
    try {
      isLoadingCoupons.value = true;
      final response = await _couponRepository.getAvailableCoupons();
      if (response.success && response.data != null) {
        availableCoupons.value = response.data!;
      }
    } catch (e) {
      // Silent fail for coupons
    } finally {
      isLoadingCoupons.value = false;
    }
  }

  /// Navigate to booking with selected vehicle type
  void goToCreateBookingWithVehicle(VehicleTypeModel vehicle) {
    Get.toNamed(Routes.createBooking, arguments: {'selectedVehicle': vehicle});
  }

  @override
  void onReady() {
    super.onReady();
    // Refresh data when returning to home
    ever(Get.routing.obs, (_) {
      if (Get.currentRoute == Routes.home || Get.currentRoute == Routes.main) {
        refreshData();
      }
    });
  }

  /// Fetch active deliveries (pending, confirmed, in_transit)
  Future<void> fetchActiveDeliveries() async {
    try {
      isLoadingActive.value = true;
      errorMessage.value = null;

      final response = await _bookingRepository.getMyBookings(
        page: 1,
        limit: 5,
      );

      if (response.success && response.data != null) {
        // Filter for active bookings only
        activeDeliveries.value = response.data!
            .where((booking) => booking.isActive)
            .toList();
      }
    } catch (e) {
      errorMessage.value = 'Failed to load active deliveries';
    } finally {
      isLoadingActive.value = false;
    }
  }

  /// Fetch recent completed orders
  Future<void> fetchRecentOrders() async {
    try {
      isLoadingRecent.value = true;

      final response = await _bookingRepository.getMyBookings(
        status: 'DELIVERED',
        page: 1,
        limit: 3,
      );

      if (response.success && response.data != null) {
        recentOrders.value = response.data!;
      }
    } catch (e) {
      // Silent fail for recent orders
    } finally {
      isLoadingRecent.value = false;
    }
  }

  /// Refresh all data
  Future<void> refreshData() async {
    await Future.wait([
      fetchVehicleTypes(),
      fetchActiveDeliveries(),
      fetchRecentOrders(),
      fetchAvailableCoupons(),
    ]);
  }

  /// Navigate to create booking
  void goToCreateBooking() {
    Get.toNamed(Routes.createBooking);
  }

  /// Navigate to orders list
  void goToOrders() {
    Get.toNamed(Routes.orders);
  }

  /// Navigate to tracking for a specific booking
  void goToTracking(String bookingId) {
    Get.toNamed(Routes.tracking, arguments: {'bookingId': bookingId});
  }

  /// Navigate to order details
  void goToOrderDetails(String bookingId) {
    Get.toNamed(Routes.orderDetails, arguments: {'bookingId': bookingId});
  }

  /// Navigate to wallet
  void goToWallet() {
    Get.toNamed(Routes.wallet);
  }

  /// Navigate to saved addresses
  void goToAddresses() {
    Get.toNamed(Routes.savedAddresses);
  }

  /// Navigate to profile
  void goToProfile() {
    Get.toNamed(Routes.profile);
  }

  /// Check if user has active deliveries
  bool get hasActiveDeliveries => activeDeliveries.isNotEmpty;

  /// Get status display text for a booking status
  String getStatusText(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return 'Finding Driver';
      case BookingStatus.accepted:
        return 'Driver Assigned';
      case BookingStatus.arrivedPickup:
        return 'Driver Arrived';
      case BookingStatus.pickedUp:
        return 'Picked Up';
      case BookingStatus.inTransit:
        return 'On the Way';
      case BookingStatus.arrivedDrop:
        return 'Almost There';
      case BookingStatus.delivered:
        return 'Delivered';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }
}
