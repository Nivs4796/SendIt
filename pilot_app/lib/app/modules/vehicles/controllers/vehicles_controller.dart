import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/vehicle_model.dart';
import '../../../data/repositories/vehicle_repository.dart';

class VehiclesController extends GetxController {
  final VehicleRepository _repository = VehicleRepository();

  // State
  final isLoading = true.obs;
  final vehicles = <VehicleModel>[].obs;
  final isProcessing = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadVehicles();
  }

  /// Load all vehicles
  Future<void> loadVehicles() async {
    try {
      isLoading.value = true;
      vehicles.value = await _repository.getVehicles();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load vehicles');
    } finally {
      isLoading.value = false;
    }
  }

  /// Set vehicle as active
  Future<bool> setActiveVehicle(String vehicleId) async {
    try {
      isProcessing.value = true;
      await _repository.setActiveVehicle(vehicleId);
      
      // Update local state
      for (var v in vehicles) {
        v = v.copyWith(isActive: v.id == vehicleId);
      }
      vehicles.refresh();
      
      Get.snackbar(
        'Vehicle Activated',
        'This vehicle is now your active vehicle',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
      );
      
      await loadVehicles(); // Refresh from server
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return false;
    } finally {
      isProcessing.value = false;
    }
  }

  /// Delete vehicle
  Future<bool> deleteVehicle(String vehicleId) async {
    try {
      isProcessing.value = true;
      await _repository.deleteVehicle(vehicleId);
      
      vehicles.removeWhere((v) => v.id == vehicleId);
      
      Get.snackbar(
        'Vehicle Removed',
        'Vehicle has been removed from your account',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return false;
    } finally {
      isProcessing.value = false;
    }
  }

  /// Add new vehicle
  Future<bool> addVehicle({
    required String vehicleType,
    required String registrationNumber,
    required String make,
    required String model,
    required int year,
    required String color,
    String? insuranceNumber,
    DateTime? insuranceExpiry,
  }) async {
    try {
      isProcessing.value = true;
      final vehicle = await _repository.addVehicle(
        vehicleType: vehicleType,
        registrationNumber: registrationNumber,
        make: make,
        model: model,
        year: year,
        color: color,
        insuranceNumber: insuranceNumber,
        insuranceExpiry: insuranceExpiry,
      );
      
      vehicles.add(vehicle);
      
      Get.snackbar(
        'Vehicle Added',
        'Your vehicle has been added successfully',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return false;
    } finally {
      isProcessing.value = false;
    }
  }

  /// Get active vehicle
  VehicleModel? get activeVehicle => vehicles.firstWhereOrNull((v) => v.isActive);

  /// Refresh data
  Future<void> refresh() => loadVehicles();
}
