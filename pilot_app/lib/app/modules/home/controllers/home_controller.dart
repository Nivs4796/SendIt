import 'package:get/get.dart';

import '../../../data/models/pilot_model.dart';
import '../../../data/models/vehicle_model.dart';
import '../../../data/repositories/auth_repository.dart';

class HomeController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  // Pilot state
  final Rx<PilotModel?> pilot = Rx<PilotModel?>(null);
  final isOnline = false.obs;
  final isLoading = false.obs;

  // Stats
  final todayEarnings = 0.0.obs;
  final todayHours = 0.0.obs;
  final todayRides = 0.obs;
  final weekEarnings = 0.0.obs;
  final weekHours = 0.0.obs;
  final weekRides = 0.obs;
  final missedOrderValue = 0.0.obs;

  // Active vehicle
  final Rx<VehicleModel?> activeVehicle = Rx<VehicleModel?>(null);

  // Selected stats tab (0 = Today, 1 = This Week)
  final selectedStatsTab = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadPilotData();
    _loadStats();
  }

  Future<void> _loadPilotData() async {
    pilot.value = await _authRepository.getCurrentPilot();
  }

  Future<void> _loadStats() async {
    // TODO: Load from API
    // Simulated data
    todayEarnings.value = 980.0;
    todayHours.value = 4.5;
    todayRides.value = 8;
    
    weekEarnings.value = 4500.0;
    weekHours.value = 32.0;
    weekRides.value = 45;

    missedOrderValue.value = 1850.0;
  }

  /// Toggle online/offline status
  Future<void> toggleOnlineStatus() async {
    try {
      isLoading.value = true;
      
      // TODO: Call API to update status
      // await _pilotRepository.updateOnlineStatus(!isOnline.value);
      
      await Future.delayed(const Duration(milliseconds: 500));
      isOnline.value = !isOnline.value;

      if (isOnline.value) {
        // Start location tracking
        _startLocationTracking();
        // Connect to WebSocket
        _connectWebSocket();
      } else {
        // Stop location tracking
        _stopLocationTracking();
        // Disconnect WebSocket
        _disconnectWebSocket();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update status');
    } finally {
      isLoading.value = false;
    }
  }

  void _startLocationTracking() {
    // TODO: Implement background location tracking
  }

  void _stopLocationTracking() {
    // TODO: Stop location tracking
  }

  void _connectWebSocket() {
    // TODO: Connect to WebSocket for job dispatch
  }

  void _disconnectWebSocket() {
    // TODO: Disconnect WebSocket
  }

  /// Get greeting based on time of day
  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}
