import 'dart:io';
import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../providers/api_client.dart';
import '../models/api_response.dart';

class UploadRepository {
  final ApiClient _apiClient = ApiClient();

  /// Upload user avatar
  /// Returns the avatar URL on success
  Future<ApiResponse<String>> uploadAvatar(File imageFile) async {
    try {
      final fileName = imageFile.path.split('/').last;
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      final response = await _apiClient.uploadFile(
        ApiConstants.uploadAvatar,
        formData: formData,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final avatarUrl = response.data['data']['avatar'] as String;
        return ApiResponse<String>(
          success: true,
          data: avatarUrl,
          message: response.data['message'],
        );
      }

      return ApiResponse<String>(
        success: false,
        message: response.data['message'] ?? 'Failed to upload avatar',
      );
    } catch (e) {
      return ApiResponse<String>(
        success: false,
        message: e.toString(),
      );
    }
  }
}
