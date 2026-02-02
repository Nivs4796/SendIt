import 'package:get/get.dart';
import '../models/user_model.dart';
import '../models/api_response.dart';
import '../providers/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../../services/storage_service.dart';

class AuthRepository {
  final ApiClient _apiClient = ApiClient();
  final StorageService _storage = Get.find<StorageService>();

  Future<ApiResponse> sendOtp(String phone, {String countryCode = '+91'}) async {
    // Send phone with country code
    final fullPhone = '$countryCode$phone';
    final response = await _apiClient.post(
      ApiConstants.sendOtp,
      data: {'phone': fullPhone},
    );
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse<UserModel>> verifyOtp(String phone, String otp, {String countryCode = '+91'}) async {
    // Send phone with country code
    final fullPhone = '$countryCode$phone';
    final response = await _apiClient.post(
      ApiConstants.verifyOtp,
      data: {'phone': fullPhone, 'otp': otp},
    );

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (data) => data as Map<String, dynamic>,
    );

    if (apiResponse.success && apiResponse.data != null) {
      // Store tokens
      _storage.token = apiResponse.data!['accessToken'];
      _storage.refreshToken = apiResponse.data!['refreshToken'];

      // Parse and store user
      final user = UserModel.fromJson(apiResponse.data!['user']);
      _storage.user = user.toJson();

      return ApiResponse(
        success: true,
        message: apiResponse.message,
        data: user,
      );
    }

    return ApiResponse(
      success: false,
      message: apiResponse.message ?? 'Verification failed',
      code: apiResponse.code,
    );
  }

  Future<ApiResponse<UserModel>> getProfile() async {
    final response = await _apiClient.get(ApiConstants.userProfile);
    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (data) => data as Map<String, dynamic>,
    );

    if (apiResponse.success && apiResponse.data != null) {
      // API returns user nested inside data.user
      final userData = apiResponse.data!['user'] ?? apiResponse.data;
      final user = UserModel.fromJson(userData);
      return ApiResponse(
        success: true,
        message: apiResponse.message,
        data: user,
      );
    }

    return ApiResponse(
      success: false,
      message: apiResponse.message ?? 'Failed to get profile',
    );
  }

  Future<ApiResponse<UserModel>> updateProfile({
    String? name,
    String? email,
    String? avatar,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;
    if (avatar != null) data['avatar'] = avatar;

    final response = await _apiClient.patch(
      ApiConstants.userProfile,
      data: data,
    );

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (data) => data as Map<String, dynamic>,
    );

    if (apiResponse.success && apiResponse.data != null) {
      // API returns user nested inside data.user
      final userData = apiResponse.data!['user'] ?? apiResponse.data;
      final user = UserModel.fromJson(userData);
      _storage.user = user.toJson();

      return ApiResponse(
        success: true,
        message: apiResponse.message,
        data: user,
      );
    }

    return ApiResponse(
      success: false,
      message: apiResponse.message ?? 'Failed to update profile',
    );
  }

  void logout() {
    _storage.clearAuth();
  }

  bool get isLoggedIn => _storage.isLoggedIn;

  UserModel? get currentUser {
    final userData = _storage.user;
    if (userData != null) {
      return UserModel.fromJson(userData);
    }
    return null;
  }
}
