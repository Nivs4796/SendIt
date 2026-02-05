import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;

import '../models/pilot_model.dart';
import '../providers/api_client.dart';
import '../providers/api_exceptions.dart';
import '../../core/constants/api_constants.dart';
import '../../services/storage_service.dart';

/// Repository for handling pilot authentication
class AuthRepository {
  final ApiClient _api = Get.find<ApiClient>();
  final StorageService _storage = Get.find<StorageService>();

  /// Check if pilot is logged in
  bool get isLoggedIn => _storage.isLoggedIn;

  /// Get current pilot from storage
  PilotModel? get currentPilot {
    try {
      final pilotJson = _storage.pilot;
      if (pilotJson != null) {
        return PilotModel.fromJson(pilotJson);
      }
    } catch (e) {
      debugPrint('⚠️ Error parsing stored pilot data: $e');
      // Clear invalid data
      _storage.pilot = null;
    }
    return null;
  }

  /// Get auth token
  String? get token => _storage.token;

  /// Send OTP to phone number
  Future<Map<String, dynamic>> sendOtp({
    required String phone,
    required String countryCode,
  }) async {
    try {
      final response = await _api.post(
        ApiConstants.sendOtp,
        data: {
          'phone': '$countryCode$phone',
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': response.data['message'] ?? 'OTP sent successfully',
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to send OTP',
      };
    } on ApiException catch (e) {
      return {
        'success': false,
        'message': e.message,
      };
    } on NetworkException {
      return {
        'success': false,
        'message': 'No internet connection. Please try again.',
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Request timed out. Please try again.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred. Please try again.',
      };
    }
  }

  /// Verify OTP
  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String countryCode,
    required String otp,
  }) async {
    try {
      final response = await _api.post(
        ApiConstants.verifyOtp,
        data: {
          'phone': '$countryCode$phone',
          'otp': otp,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        
        // Debug: Print what we're saving
        debugPrint('📦 Saving auth data...');
        debugPrint('📦 Token from API: ${data['token']?.toString().substring(0, 20)}...');
        
        // Save token
        _storage.token = data['token'];
        if (data['refreshToken'] != null) {
          _storage.refreshToken = data['refreshToken'];
        }
        
        // Verify token was saved
        debugPrint('📦 Token saved, verifying: ${_storage.token?.toString().substring(0, 20)}...');
        debugPrint('📦 isLoggedIn after save: ${_storage.isLoggedIn}');
        
        // Save phone number for registration
        _storage.phone = '$countryCode$phone';

        // Check if new user or existing pilot
        final isNewUser = data['isNewUser'] ?? true;
        
        if (!isNewUser && data['pilot'] != null) {
          // Save pilot data
          _storage.pilot = data['pilot'];
          
          final pilot = PilotModel.fromJson(data['pilot']);
          
          return {
            'success': true,
            'is_new_user': false,
            'pilot': pilot,
          };
        }

        return {
          'success': true,
          'is_new_user': true,
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Invalid OTP',
      };
    } on ApiException catch (e) {
      return {
        'success': false,
        'message': e.message,
      };
    } on NetworkException {
      return {
        'success': false,
        'message': 'No internet connection. Please try again.',
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Request timed out. Please try again.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Verification failed. Please try again.',
      };
    }
  }

  /// Register new pilot
  Future<Map<String, dynamic>> registerPilot({
    required Map<String, dynamic> personalDetails,
    required Map<String, dynamic> vehicleDetails,
    required Map<String, dynamic> documents,
    required Map<String, dynamic> bankDetails,
  }) async {
    try {
      final response = await _api.post(
        ApiConstants.pilotRegister,
        data: {
          ...personalDetails,
          'vehicle': vehicleDetails,
          'documents': documents,
          'bankDetails': bankDetails,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data['data'];
        
        // Save pilot data
        if (data != null && data['pilot'] != null) {
          _storage.pilot = data['pilot'];
        }

        return {
          'success': true,
          'message': 'Registration submitted successfully',
          'pilot': data?['pilot'] != null ? PilotModel.fromJson(data['pilot']) : null,
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Registration failed',
      };
    } on ApiException catch (e) {
      return {
        'success': false,
        'message': e.message,
      };
    } on NetworkException {
      return {
        'success': false,
        'message': 'No internet connection. Please try again.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Registration failed. Please try again.',
      };
    }
  }

  /// Get pilot profile
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _api.get(ApiConstants.pilotProfile);

      if (response.statusCode == 200 && response.data['success'] == true) {
        // API returns {data: {pilot: {...}}} - extract the pilot object
        final data = response.data['data'];
        final pilotData = data['pilot'] ?? data;
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
        'message': 'Session expired. Please login again.',
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

  /// Update pilot online status
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
  Future<Map<String, dynamic>> updateLocation({
    required double lat,
    required double lng,
  }) async {
    try {
      final response = await _api.patch(
        ApiConstants.pilotLocation,
        data: {'lat': lat, 'lng': lng},
      );

      return {
        'success': response.statusCode == 200,
      };
    } catch (e) {
      return {'success': false};
    }
  }

  /// Check verification status
  Future<Map<String, dynamic>> checkVerificationStatus() async {
    try {
      final response = await _api.get(ApiConstants.pilotProfile);

      if (response.statusCode == 200 && response.data['success'] == true) {
        // API returns {data: {pilot: {...}}} - extract the pilot object
        final data = response.data['data'];
        final pilotData = data['pilot'] ?? data;
        _storage.pilot = pilotData;

        final pilot = PilotModel.fromJson(pilotData);
        return {
          'success': true,
          'status': pilot.verificationStatus.value,
          'pilot': pilot,
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to check status',
      };
    } on ApiException catch (e) {
      return {
        'success': false,
        'message': e.message,
      };
    } catch (e) {
      // Return local pilot data if API fails
      final pilot = currentPilot;
      return {
        'success': pilot != null,
        'status': pilot?.verificationStatus.value ?? 'pending',
        'pilot': pilot,
      };
    }
  }

  /// Upload a single document file
  Future<Map<String, dynamic>> uploadDocument(File file) async {
    try {
      final fileName = file.path.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
      });

      final response = await _api.post(
        ApiConstants.uploadDocument,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return {
          'success': true,
          'url': response.data['data']['url'],
          'filename': response.data['data']['filename'],
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Upload failed',
      };
    } on ApiException catch (e) {
      return {
        'success': false,
        'message': e.message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to upload file',
      };
    }
  }

  /// Upload multiple pilot documents at once
  Future<Map<String, dynamic>> uploadPilotDocuments({
    File? idProof,
    File? drivingLicense,
    File? vehicleRC,
    File? insurance,
    File? parentalConsent,
    File? bankProof,
  }) async {
    try {
      final Map<String, MultipartFile> files = {};

      if (idProof != null) {
        files['idProof'] = await MultipartFile.fromFile(
          idProof.path,
          filename: idProof.path.split('/').last,
        );
      }
      if (drivingLicense != null) {
        files['drivingLicense'] = await MultipartFile.fromFile(
          drivingLicense.path,
          filename: drivingLicense.path.split('/').last,
        );
      }
      if (vehicleRC != null) {
        files['vehicleRC'] = await MultipartFile.fromFile(
          vehicleRC.path,
          filename: vehicleRC.path.split('/').last,
        );
      }
      if (insurance != null) {
        files['insurance'] = await MultipartFile.fromFile(
          insurance.path,
          filename: insurance.path.split('/').last,
        );
      }
      if (parentalConsent != null) {
        files['parentalConsent'] = await MultipartFile.fromFile(
          parentalConsent.path,
          filename: parentalConsent.path.split('/').last,
        );
      }
      if (bankProof != null) {
        files['bankProof'] = await MultipartFile.fromFile(
          bankProof.path,
          filename: bankProof.path.split('/').last,
        );
      }

      if (files.isEmpty) {
        return {
          'success': true,
          'uploaded': <String, String>{},
          'message': 'No files to upload',
        };
      }

      final formData = FormData.fromMap(files);

      final response = await _api.post(
        ApiConstants.uploadPilotDocuments,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return {
          'success': true,
          'uploaded': Map<String, String>.from(response.data['data']['uploaded'] ?? {}),
          'count': response.data['data']['count'] ?? 0,
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Upload failed',
      };
    } on ApiException catch (e) {
      return {
        'success': false,
        'message': e.message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to upload documents',
      };
    }
  }

  /// Upload pilot avatar
  Future<Map<String, dynamic>> uploadAvatar(File file) async {
    try {
      final fileName = file.path.split('/').last;
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
      });

      final response = await _api.post(
        ApiConstants.uploadAvatar,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return {
          'success': true,
          'avatar': response.data['data']['avatar'],
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Upload failed',
      };
    } on ApiException catch (e) {
      return {
        'success': false,
        'message': e.message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to upload avatar',
      };
    }
  }

  /// Logout
  Future<void> logout() async {
    _storage.clearAuth();
  }
}
