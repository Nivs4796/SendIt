import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import '../models/vehicle_model.dart';
import '../providers/api_client.dart';

class VehicleRepository {
  final ApiClient _api = Get.find<ApiClient>();

  /// Get all vehicles for the pilot
  Future<List<VehicleModel>> getVehicles() async {
    try {
      final response = await _api.get('/pilots/vehicles');
      if (response.data['success'] == true) {
        return (response.data['data'] as List)
            .map((e) => VehicleModel.fromJson(e))
            .toList();
      }
      throw Exception(response.data['message'] ?? 'Failed to load vehicles');
    } catch (e) {
      // Mock data for development
      return _getMockVehicles();
    }
  }

  /// Get single vehicle details
  Future<VehicleModel> getVehicle(String vehicleId) async {
    try {
      final response = await _api.get('/pilots/vehicles/$vehicleId');
      if (response.data['success'] == true) {
        return VehicleModel.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Failed to load vehicle');
    } catch (e) {
      throw Exception('Failed to load vehicle: $e');
    }
  }

  /// Add new vehicle
  Future<VehicleModel> addVehicle({
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
      final response = await _api.post('/pilots/vehicles', data: {
        'vehicleType': vehicleType,
        'registrationNumber': registrationNumber,
        'make': make,
        'model': model,
        'year': year,
        'color': color,
        if (insuranceNumber != null) 'insuranceNumber': insuranceNumber,
        if (insuranceExpiry != null) 'insuranceExpiry': insuranceExpiry.toIso8601String(),
      });
      if (response.data['success'] == true) {
        return VehicleModel.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Failed to add vehicle');
    } catch (e) {
      throw Exception('Failed to add vehicle: $e');
    }
  }

  /// Update vehicle
  Future<VehicleModel> updateVehicle(String vehicleId, Map<String, dynamic> updates) async {
    try {
      final response = await _api.patch('/pilots/vehicles/$vehicleId', data: updates);
      if (response.data['success'] == true) {
        return VehicleModel.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Failed to update vehicle');
    } catch (e) {
      throw Exception('Failed to update vehicle: $e');
    }
  }

  /// Set vehicle as active
  Future<void> setActiveVehicle(String vehicleId) async {
    try {
      final response = await _api.post('/pilots/vehicles/$vehicleId/activate', data: {});
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to activate vehicle');
      }
    } catch (e) {
      throw Exception('Failed to activate vehicle: $e');
    }
  }

  /// Delete vehicle
  Future<void> deleteVehicle(String vehicleId) async {
    try {
      final response = await _api.delete('/pilots/vehicles/$vehicleId');
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to delete vehicle');
      }
    } catch (e) {
      throw Exception('Failed to delete vehicle: $e');
    }
  }

  /// Upload vehicle document
  Future<String> uploadDocument({
    required String vehicleId,
    required String documentType, // 'rc', 'insurance', 'puc', 'permit'
    required File file,
  }) async {
    try {
      final formData = FormData.fromMap({
        'type': documentType,
        'document': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      });

      final response = await _api.uploadFile(
        '/pilots/vehicles/$vehicleId/documents',
        formData: formData,
      );
      if (response.data['success'] == true) {
        return response.data['data']['url'] as String;
      }
      throw Exception(response.data['message'] ?? 'Failed to upload document');
    } catch (e) {
      throw Exception('Failed to upload document: $e');
    }
  }

  List<VehicleModel> _getMockVehicles() {
    return [
      VehicleModel(
        id: '1',
        pilotId: 'pilot-1',
        vehicleType: VehicleType.twoWheeler,
        registrationNumber: 'GJ-01-AB-1234',
        make: 'Honda',
        model: 'Activa',
        year: 2022,
        color: 'Black',
        isActive: true,
        isVerified: true,
        isElectric: false,
        insuranceNumber: 'INS-123456',
        insuranceExpiry: DateTime.now().add(const Duration(days: 180)),
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
        updatedAt: DateTime.now(),
      ),
      VehicleModel(
        id: '2',
        pilotId: 'pilot-1',
        vehicleType: VehicleType.twoWheeler,
        registrationNumber: 'GJ-01-CD-5678',
        make: 'Ola',
        model: 'S1 Pro',
        year: 2023,
        color: 'White',
        isActive: false,
        isVerified: true,
        isElectric: true,
        insuranceNumber: 'INS-789012',
        insuranceExpiry: DateTime.now().add(const Duration(days: 300)),
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      ),
    ];
  }
}
