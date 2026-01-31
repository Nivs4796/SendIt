import 'package:get/get.dart';
import '../models/user_model.dart';
import '../models/api_response.dart';
import '../providers/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../../services/storage_service.dart';

class AuthRepository {
  final ApiClient _apiClient = ApiClient();
  final StorageService _storage = Get.find<StorageService>();

  Future<ApiResponse> sendOtp(String phone) async {
    final response = await _apiClient.post(
      ApiConstants.sendOtp,
      data: {'phone': phone},
    );
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse<UserModel>> verifyOtp(String phone, String otp) async {
    final response = await _apiClient.post(
      ApiConstants.verifyOtp,
      data: {'phone': phone, 'otp': otp},
    );

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (data) => data as Map<String, dynamic>,
    );

    if (apiResponse.success && apiResponse.data != null) {
      // Store tokens
      _storage.token = apiResponse.data!['token'];
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
    return ApiResponse<UserModel>.fromJson(
      response.data,
      (data) => UserModel.fromJson(data),
    );
  }

  Future<ApiResponse<UserModel>> updateProfile({
    String? name,
    String? email,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;

    final response = await _apiClient.patch(
      ApiConstants.userProfile,
      data: data,
    );

    final apiResponse = ApiResponse<UserModel>.fromJson(
      response.data,
      (data) => UserModel.fromJson(data),
    );

    if (apiResponse.success && apiResponse.data != null) {
      _storage.user = apiResponse.data!.toJson();
    }

    return apiResponse;
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
