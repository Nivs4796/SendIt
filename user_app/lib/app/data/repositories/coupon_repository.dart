import '../models/api_response.dart';
import '../models/coupon_model.dart';
import '../providers/api_client.dart';
import '../../core/constants/api_constants.dart';

class CouponRepository {
  final ApiClient _apiClient = ApiClient();

  /// Get available coupons for user
  /// GET /coupons/available
  /// Response: { "success": true, "data": { "coupons": [...] } }
  Future<ApiResponse<List<CouponModel>>> getAvailableCoupons({
    double? orderAmount,
    String? vehicleTypeId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (orderAmount != null) {
        queryParams['orderAmount'] = orderAmount;
      }
      if (vehicleTypeId != null) {
        queryParams['vehicleTypeId'] = vehicleTypeId;
      }

      final response = await _apiClient.get(
        ApiConstants.availableCoupons,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        final couponsData =
            apiResponse.data!['coupons'] as List<dynamic>? ?? [];
        final coupons =
            couponsData.map((json) => CouponModel.fromJson(json)).toList();

        return ApiResponse(
          success: true,
          message: apiResponse.message,
          data: coupons,
        );
      }

      return ApiResponse(
        success: false,
        message: apiResponse.message ?? 'Failed to get available coupons',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: e.toString(),
      );
    }
  }

  /// Validate a coupon code
  /// POST /coupons/validate
  /// Body: { "code": "...", "orderAmount": 500, "vehicleTypeId": "..." }
  /// Response: { "success": true, "data": { "coupon": {...}, "discount": 50 } }
  Future<ApiResponse<Map<String, dynamic>>> validateCoupon({
    required String code,
    required double orderAmount,
    required String vehicleTypeId,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.validateCoupon,
        data: {
          'code': code,
          'orderAmount': orderAmount,
          'vehicleTypeId': vehicleTypeId,
        },
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        final couponData = apiResponse.data!['coupon'];
        final discount = (apiResponse.data!['discount'] ?? 0).toDouble();

        return ApiResponse(
          success: true,
          message: apiResponse.message,
          data: {
            'coupon': couponData != null ? CouponModel.fromJson(couponData) : null,
            'discount': discount,
          },
        );
      }

      return ApiResponse(
        success: false,
        message: apiResponse.message ?? 'Invalid coupon code',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: e.toString(),
      );
    }
  }
}
