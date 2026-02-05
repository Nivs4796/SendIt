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
  /// Response: { "success": true, "data": { "types": [...] } }
  Future<ApiResponse<List<VehicleTypeModel>>> getVehicleTypes() async {
    try {
      final response = await _apiClient.get(ApiConstants.vehicleTypes);

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        // Backend wraps types in { types: [...] }
        final typesData = apiResponse.data!['types'] as List<dynamic>? ?? [];
        final vehicleTypes = typesData
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
    } catch (e) {
      return ApiResponse(
        success: false,
        message: e.toString(),
      );
    }
  }

  /// Calculate price for a booking using saved address IDs
  /// POST /bookings/calculate-price
  /// Body: { "vehicleTypeId": "...", "pickupAddressId": "...", "dropAddressId": "..." }
  /// Response: { "success": true, "data": { "distance": 5.2, "baseFare": 50, ... } }
  Future<ApiResponse<PriceCalculationModel>> calculatePrice({
    required String vehicleTypeId,
    required String pickupAddressId,
    required String dropAddressId,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.calculatePrice,
        data: {
          'vehicleTypeId': vehicleTypeId,
          'pickupAddressId': pickupAddressId,
          'dropAddressId': dropAddressId,
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
    } catch (e) {
      return ApiResponse(
        success: false,
        message: e.toString(),
      );
    }
  }

  /// Create a new booking
  /// POST /bookings
  /// Body: CreateBookingRequest
  /// Response: { "success": true, "data": { "booking": {...} } }
  Future<ApiResponse<BookingModel>> createBooking(
      CreateBookingRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.bookings,
        data: request.toJson(),
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        // Backend wraps booking in { booking: {...} }
        final bookingData = apiResponse.data!['booking'] ?? apiResponse.data!;
        final booking = BookingModel.fromJson(bookingData);

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
    } catch (e) {
      return ApiResponse(
        success: false,
        message: e.toString(),
      );
    }
  }

  /// Get a specific booking by ID
  /// GET /bookings/{id}
  /// Response: { "success": true, "data": { "booking": {...} } }
  Future<ApiResponse<BookingModel>> getBooking(String id) async {
    try {
      final response = await _apiClient.get('${ApiConstants.bookings}/$id');

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        // Backend wraps booking in { booking: {...} }
        final bookingData = apiResponse.data!['booking'] ?? apiResponse.data!;
        final booking = BookingModel.fromJson(bookingData);

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
    } catch (e) {
      return ApiResponse(
        success: false,
        message: e.toString(),
      );
    }
  }

  /// Get current user's bookings with pagination and optional status filter
  /// GET /bookings/my-bookings?page=1&limit=10&status=PENDING
  /// Response: { "success": true, "data": { "bookings": [...], "pagination": {...} } }
  Future<ApiResponse<List<BookingModel>>> getMyBookings({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    try {
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

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        // Backend returns { bookings: [...], pagination: {...} }
        final bookingsData = apiResponse.data!['bookings'] as List<dynamic>? ?? [];
        final bookings = bookingsData
            .map((json) => BookingModel.fromJson(json))
            .toList();

        return ApiResponse(
          success: true,
          message: apiResponse.message,
          data: bookings,
          meta: apiResponse.data!['pagination'],
        );
      }

      return ApiResponse(
        success: false,
        message: apiResponse.message ?? 'Failed to get bookings',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: e.toString(),
      );
    }
  }

  /// Cancel a booking
  /// POST /bookings/{id}/cancel
  /// Body: { "reason": "..." }
  /// Response: { "success": true, "data": { "booking": {...} } }
  Future<ApiResponse<BookingModel>> cancelBooking(
    String id, {
    required String reason,
  }) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.bookings}/$id/cancel',
        data: {'reason': reason},
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        // Backend wraps booking in { booking: {...} }
        final bookingData = apiResponse.data!['booking'] ?? apiResponse.data!;
        final booking = BookingModel.fromJson(bookingData);

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
    } catch (e) {
      return ApiResponse(
        success: false,
        message: e.toString(),
      );
    }
  }

  /// Retry driver assignment for a booking
  /// POST /bookings/{id}/retry-assignment
  /// Response: { "success": true, "message": "Assignment retry started" }
  Future<ApiResponse<void>> retryAssignment(String bookingId) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.bookings}/$bookingId/retry-assignment',
      );

      final apiResponse = ApiResponse<void>.fromJson(
        response.data,
        null,
      );

      if (apiResponse.success) {
        return ApiResponse(
          success: true,
          message: apiResponse.message ?? 'Assignment retry started',
        );
      }

      return ApiResponse(
        success: false,
        message: apiResponse.message ?? 'Failed to retry assignment',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: e.toString(),
      );
    }
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
    try {
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
    } catch (e) {
      return ApiResponse(
        success: false,
        message: e.toString(),
      );
    }
  }
}
