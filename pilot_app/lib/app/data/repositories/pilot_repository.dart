import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;

import '../models/pilot_model.dart';
import '../models/earnings_model.dart';
import '../providers/api_client.dart';
import '../providers/api_exceptions.dart';
import '../../core/constants/api_constants.dart';
import '../../services/storage_service.dart';

/// Repository for pilot-related operations
class PilotRepository {
  final ApiClient _api = Get.find<ApiClient>();
  final StorageService _storage = Get.find<StorageService>();

  /// Get pilot profile
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _api.get(ApiConstants.pilotProfile);

      if (response.statusCode == 200 && response.data['success'] == true) {
        final pilotData = response.data['data'];
        _storage.pilot = pilotData;

        return {
          'success': true,
          'pilot': PilotModel.fromJson(pilotData),
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to get profile',
      };
    } on UnauthorizedException {
      return {
        'success': false,
        'message': 'Session expired',
        'unauthorized': true,
      };
    } on ApiException catch (e) {
      return {
        'success': false,
        'message': e.message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to get profile',
      };
    }
  }

  /// Update online/offline status
  Future<Map<String, dynamic>> updateOnlineStatus(bool isOnline) async {
    try {
      final response = await _api.patch(
        ApiConstants.pilotStatus,
        data: {'isOnline': isOnline},
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'isOnline': isOnline,
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to update status',
      };
    } on ApiException catch (e) {
      return {
        'success': false,
        'message': e.message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to update status',
      };
    }
  }

  /// Update pilot location
  Future<bool> updateLocation({
    required double lat,
    required double lng,
  }) async {
    try {
      final response = await _api.patch(
        ApiConstants.pilotLocation,
        data: {'lat': lat, 'lng': lng},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Get pilot earnings
  Future<Map<String, dynamic>> getEarnings({
    int page = 1,
    int limit = 20,
    String? period, // today, week, month
  }) async {
    try {
      final response = await _api.get(
        ApiConstants.pilotEarnings,
        queryParameters: {
          'page': page,
          'limit': limit,
          if (period != null) 'period': period,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        
        return {
          'success': true,
          'earnings': EarningsModel.fromJson(data['summary'] ?? data),
          'transactions': data['transactions'] ?? [],
          'pagination': data['pagination'],
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to get earnings',
      };
    } on ApiException catch (e) {
      return {
        'success': false,
        'message': e.message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to get earnings',
      };
    }
  }

  /// Get pilot bookings/jobs history
  Future<Map<String, dynamic>> getBookings({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    try {
      final response = await _api.get(
        ApiConstants.pilotBookings,
        queryParameters: {
          'page': page,
          'limit': limit,
          if (status != null) 'status': status,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return {
          'success': true,
          'bookings': response.data['data']['bookings'] ?? [],
          'pagination': response.data['data']['pagination'],
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to get bookings',
      };
    } on ApiException catch (e) {
      return {
        'success': false,
        'message': e.message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to get bookings',
      };
    }
  }

  /// Update pilot profile
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> updates) async {
    try {
      final response = await _api.patch(
        ApiConstants.pilotProfile,
        data: updates,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final pilotData = response.data['data'];
        _storage.pilot = pilotData;

        return {
          'success': true,
          'pilot': PilotModel.fromJson(pilotData),
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to update profile',
      };
    } on ApiException catch (e) {
      return {
        'success': false,
        'message': e.message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to update profile',
      };
    }
  }

  /// Upload profile photo
  Future<Map<String, dynamic>> uploadProfilePhoto(File photo) async {
    try {
      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(
          photo.path,
          filename: photo.path.split('/').last,
        ),
      });

      final response = await _api.uploadFile(
        ApiConstants.pilotProfilePhoto,
        formData: formData,
      );

      if (response.data['success'] == true) {
        return {
          'success': true,
          'photoUrl': response.data['data']['url'],
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to upload photo',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to upload photo',
      };
    }
  }

  /// Delete pilot account
  Future<Map<String, dynamic>> deleteAccount() async {
    try {
      final response = await _api.delete(ApiConstants.pilotProfile);

      if (response.statusCode == 200) {
        return {'success': true};
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to delete account',
      };
    } on ApiException catch (e) {
      return {
        'success': false,
        'message': e.message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to delete account',
      };
    }
  }
}
