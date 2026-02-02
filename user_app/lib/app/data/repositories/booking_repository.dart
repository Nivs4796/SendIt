import '../models/api_response.dart';
import '../models/booking_model.dart';
import '../models/vehicle_type_model.dart';
import '../models/price_calculation_model.dart';
import '../providers/api_client.dart';
import '../../core/constants/api_constants.dart';

class BookingRepository {
  final ApiClient _apiClient = ApiClient();

  /// Get all available vehicle types
  /// GET /vehicles/types
  /// Response: { "success": true, "data": [...] }
  Future<ApiResponse<List<VehicleTypeModel>>> getVehicleTypes() async {
    final response = await _apiClient.get(ApiConstants.vehicleTypes);

    final apiResponse = ApiResponse<List<dynamic>>.fromJson(
      response.data,
      (data) => data as List<dynamic>,
    );

    if (apiResponse.success && apiResponse.data != null) {
      final vehicleTypes = apiResponse.data!
          .map((json) => VehicleTypeModel.fromJson(json))
          .toList();

      return ApiResponse(
        success: true,
        message: apiResponse.message,
        data: vehicleTypes,
      );
    }

    return ApiResponse(
      success: false,
      message: apiResponse.message ?? 'Failed to get vehicle types',
    );
  }

  /// Calculate price for a booking
  /// POST /bookings/calculate-price
  /// Body: { "pickupLat": 23.0, "pickupLng": 72.5, "dropLat": 23.1, "dropLng": 72.6, "vehicleTypeId": "..." }
  /// Response: { "success": true, "data": { "distance": 5.2, "baseFare": 50, ... } }
  Future<ApiResponse<PriceCalculationModel>> calculatePrice({
    required double pickupLat,
    required double pickupLng,
    required double dropLat,
    required double dropLng,
    required String vehicleTypeId,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.calculatePrice,
      data: {
        'pickupLat': pickupLat,
        'pickupLng': pickupLng,
        'dropLat': dropLat,
        'dropLng': dropLng,
        'vehicleTypeId': vehicleTypeId,
      },
    );

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (data) => data as Map<String, dynamic>,
    );

    if (apiResponse.success && apiResponse.data != null) {
      final priceCalculation =
          PriceCalculationModel.fromJson(apiResponse.data!);

      return ApiResponse(
        success: true,
        message: apiResponse.message,
        data: priceCalculation,
      );
    }

    return ApiResponse(
      success: false,
      message: apiResponse.message ?? 'Failed to calculate price',
    );
  }

  /// Create a new booking
  /// POST /bookings
  /// Body: CreateBookingRequest
  /// Response: { "success": true, "data": { "id": "...", "bookingNumber": "...", ... } }
  Future<ApiResponse<BookingModel>> createBooking(
      CreateBookingRequest request) async {
    final response = await _apiClient.post(
      ApiConstants.bookings,
      data: request.toJson(),
    );

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (data) => data as Map<String, dynamic>,
    );

    if (apiResponse.success && apiResponse.data != null) {
      final booking = BookingModel.fromJson(apiResponse.data!);

      return ApiResponse(
        success: true,
        message: apiResponse.message,
        data: booking,
      );
    }

    return ApiResponse(
      success: false,
      message: apiResponse.message ?? 'Failed to create booking',
    );
  }

  /// Get a specific booking by ID
  /// GET /bookings/{id}
  /// Response: { "success": true, "data": { "id": "...", "bookingNumber": "...", ... } }
  Future<ApiResponse<BookingModel>> getBooking(String id) async {
    final response = await _apiClient.get('${ApiConstants.bookings}/$id');

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (data) => data as Map<String, dynamic>,
    );

    if (apiResponse.success && apiResponse.data != null) {
      final booking = BookingModel.fromJson(apiResponse.data!);

      return ApiResponse(
        success: true,
        message: apiResponse.message,
        data: booking,
      );
    }

    return ApiResponse(
      success: false,
      message: apiResponse.message ?? 'Failed to get booking',
    );
  }

  /// Get current user's bookings with pagination and optional status filter
  /// GET /bookings/my-bookings?page=1&limit=10&status=PENDING
  /// Response: { "success": true, "data": [...], "meta": { "page": 1, "totalPages": 5 } }
  Future<ApiResponse<List<BookingModel>>> getMyBookings({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };

    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }

    final response = await _apiClient.get(
      ApiConstants.myBookings,
      queryParameters: queryParams,
    );

    final apiResponse = ApiResponse<List<dynamic>>.fromJson(
      response.data,
      (data) => data as List<dynamic>,
    );

    if (apiResponse.success && apiResponse.data != null) {
      final bookings = apiResponse.data!
          .map((json) => BookingModel.fromJson(json))
          .toList();

      return ApiResponse(
        success: true,
        message: apiResponse.message,
        data: bookings,
        meta: apiResponse.meta,
      );
    }

    return ApiResponse(
      success: false,
      message: apiResponse.message ?? 'Failed to get bookings',
    );
  }

  /// Cancel a booking
  /// POST /bookings/{id}/cancel
  /// Body: { "reason": "..." } (optional)
  /// Response: { "success": true, "data": { "id": "...", "status": "CANCELLED", ... } }
  Future<ApiResponse<BookingModel>> cancelBooking(
    String id, {
    String? reason,
  }) async {
    final data = <String, dynamic>{};
    if (reason != null && reason.isNotEmpty) {
      data['reason'] = reason;
    }

    final response = await _apiClient.post(
      '${ApiConstants.bookings}/$id/cancel',
      data: data.isNotEmpty ? data : null,
    );

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (data) => data as Map<String, dynamic>,
    );

    if (apiResponse.success && apiResponse.data != null) {
      final booking = BookingModel.fromJson(apiResponse.data!);

      return ApiResponse(
        success: true,
        message: apiResponse.message,
        data: booking,
      );
    }

    return ApiResponse(
      success: false,
      message: apiResponse.message ?? 'Failed to cancel booking',
    );
  }

  /// Rate a delivery
  /// POST /bookings/{id}/rate
  /// Body: { "rating": 5, "review": "Great service!" }
  /// Response: { "success": true, "message": "Rating submitted successfully" }
  Future<ApiResponse<void>> rateDelivery(
    String bookingId, {
    required int rating,
    String? review,
  }) async {
    final data = <String, dynamic>{
      'rating': rating,
    };
    if (review != null && review.isNotEmpty) {
      data['review'] = review;
    }

    final response = await _apiClient.post(
      '${ApiConstants.bookings}/$bookingId/rate',
      data: data,
    );

    final apiResponse = ApiResponse<void>.fromJson(
      response.data,
      null,
    );

    if (apiResponse.success) {
      return ApiResponse(
        success: true,
        message: apiResponse.message ?? 'Rating submitted successfully',
      );
    }

    return ApiResponse(
      success: false,
      message: apiResponse.message ?? 'Failed to submit rating',
    );
  }
}
