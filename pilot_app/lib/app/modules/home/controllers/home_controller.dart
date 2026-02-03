import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/pilot_model.dart';
import '../../../data/models/vehicle_model.dart';
import '../../../data/models/earnings_model.dart';
import '../../../data/models/job_model.dart';
import '../../../data/repositories/pilot_repository.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../services/storage_service.dart';
import '../../../services/socket_service.dart';
import '../../../services/location_service.dart';
import '../../jobs/controllers/jobs_controller.dart';

class HomeController extends GetxController {
  late PilotRepository _pilotRepository;
  late AuthRepository _authRepository;
  late StorageService _storage;
  late SocketService _socketService;
  late LocationService _locationService;
  late JobsController _jobsController;

  // Pilot state
  final Rx<PilotModel?> pilot = Rx<PilotModel?>(null);
  final isOnline = false.obs;
  final isLoading = false.obs;
  final isLoadingStats = false.obs;

  // Earnings
  final Rx<EarningsModel?> todayEarnings = Rx<EarningsModel?>(null);
  final Rx<EarningsModel?> weekEarnings = Rx<EarningsModel?>(null);
  final missedOrderValue = 0.0.obs;

  // Active vehicle
  final Rx<VehicleModel?> activeVehicle = Rx<VehicleModel?>(null);

  // Selected stats tab (0 = Today, 1 = This Week)
  final selectedStatsTab = 0.obs;

  // Error state
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _pilotRepository = PilotRepository();
    _authRepository = AuthRepository();
    _storage = Get.find<StorageService>();
    _socketService = Get.find<SocketService>();
    _locationService = Get.find<LocationService>();
    _jobsController = Get.find<JobsController>();
    
    _loadPilotData();
    _loadEarnings();
  }

  /// Load pilot data from storage or API
  Future<void> _loadPilotData() async {
    try {
      isLoading.value = true;
      
      // First try from storage
      final localPilot = _authRepository.currentPilot;
      if (localPilot != null) {
        pilot.value = localPilot;
        isOnline.value = localPilot.isOnline;
      }

      // Then refresh from API
      final response = await _pilotRepository.getProfile();
      if (response['success'] == true) {
        pilot.value = response['pilot'] as PilotModel;
        isOnline.value = pilot.value?.isOnline ?? false;
      }
    } catch (e) {
      // Use local data if API fails
    } finally {
      isLoading.value = false;
    }
  }

  /// Load earnings from API
  Future<void> _loadEarnings() async {
    try {
      isLoadingStats.value = true;
      errorMessage.value = '';

      // Load today's earnings
      final todayResponse = await _pilotRepository.getEarnings(period: 'today');
      if (todayResponse['success'] == true) {
        todayEarnings.value = todayResponse['earnings'] as EarningsModel?;
      }

      // Load week's earnings
      final weekResponse = await _pilotRepository.getEarnings(period: 'week');
      if (weekResponse['success'] == true) {
        weekEarnings.value = weekResponse['earnings'] as EarningsModel?;
      }

      // Calculate missed order value (mock for now)
      missedOrderValue.value = 1850.0;
    } catch (e) {
      // Use mock data if API fails
      _loadMockStats();
    } finally {
      isLoadingStats.value = false;
    }
  }

  /// Load mock stats as fallback
  void _loadMockStats() {
    todayEarnings.value = EarningsModel(
      totalEarnings: 980.0,
      totalHours: 4.5,
      totalRides: 8,
      period: 'today',
    );
    
    weekEarnings.value = EarningsModel(
      totalEarnings: 4500.0,
      totalHours: 32.0,
      totalRides: 45,
      period: 'week',
    );
  }

  /// Toggle online/offline status
  Future<void> toggleOnlineStatus() async {
    try {
      isLoading.value = true;
      
      final newStatus = !isOnline.value;
      final response = await _pilotRepository.updateOnlineStatus(newStatus);
      
      if (response['success'] == true) {
        isOnline.value = newStatus;
        
        if (newStatus) {
          // Start location tracking
          _startLocationTracking();
          // Connect to WebSocket
          _connectWebSocket();
          
          Get.snackbar(
            'You\'re Online',
            'You will now receive delivery requests',
            snackPosition: SnackPosition.BOTTOM,
          );
        } else {
          // Stop location tracking
          _stopLocationTracking();
          // Disconnect WebSocket
          _disconnectWebSocket();
          
          Get.snackbar(
            'You\'re Offline',
            'You won\'t receive new delivery requests',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        Get.snackbar('Error', response['message'] ?? 'Failed to update status');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update status');
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh all data
  Future<void> refreshData() async {
    await Future.wait([
      _loadPilotData(),
      _loadEarnings(),
    ]);
  }

  void _startLocationTracking() {
    _locationService.startTracking();
  }

  void _stopLocationTracking() {
    _locationService.stopTracking();
  }

  void _connectWebSocket() {
    _socketService.connect();
    
    // Emit online status with active vehicle
    final vehicleId = activeVehicle.value?.id ?? pilot.value?.id;
    if (vehicleId != null) {
      _socketService.emitOnline(vehicleId);
    }
  }

  void _disconnectWebSocket() {
    _socketService.emitOffline();
    _socketService.disconnect();
  }
  
  /// Check if there's an active job
  bool get hasActiveJob => _jobsController.activeJob.value != null;
  
  /// Get active job
  JobModel? get activeJob => _jobsController.activeJob.value;

  /// Get current earnings based on selected tab
  EarningsModel? get currentEarnings {
    return selectedStatsTab.value == 0 ? todayEarnings.value : weekEarnings.value;
  }

  /// Get greeting based on time of day
  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}
