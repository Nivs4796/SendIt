import '../models/api_response.dart';
import '../providers/api_client.dart';
import '../../core/constants/api_constants.dart';

/// Repository for handling payment-related API calls.
/// Manages Razorpay order creation and payment verification.
class PaymentRepository {
  final ApiClient _apiClient = ApiClient();

  /// Create a Razorpay order for booking payment
  /// POST /payments/create-order
  /// Body: { "bookingId": "...", "amount": 299.00 }
  /// Response: { 
  ///   "success": true, 
  ///   "data": { 
  ///     "orderId": "order_XXXXX",
  ///     "amount": 29900,
  ///     "currency": "INR",
  ///     "receipt": "booking_XXXXX"
  ///   } 
  /// }
  Future<ApiResponse<Map<String, dynamic>>> createOrder({
    required String bookingId,
    required double amount,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.createPaymentOrder,
      data: {
        'bookingId': bookingId,
        'amount': amount,
      },
    );

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (data) => data as Map<String, dynamic>,
    );

    if (apiResponse.success && apiResponse.data != null) {
      return ApiResponse(
        success: true,
        message: apiResponse.message,
        data: {
          'orderId': apiResponse.data!['orderId'] as String,
          'amount': apiResponse.data!['amount'] as int,
          'currency': apiResponse.data!['currency'] as String? ?? 'INR',
          'receipt': apiResponse.data!['receipt'] as String?,
        },
      );
    }

    return ApiResponse(
      success: false,
      message: apiResponse.message ?? 'Failed to create payment order',
    );
  }

  /// Create a Razorpay order for wallet top-up
  /// POST /payments/wallet-order
  /// Body: { "amount": 500.00 }
  /// Response: { 
  ///   "success": true, 
  ///   "data": { 
  ///     "orderId": "order_XXXXX",
  ///     "amount": 50000,
  ///     "currency": "INR"
  ///   } 
  /// }
  Future<ApiResponse<Map<String, dynamic>>> createWalletOrder({
    required double amount,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.createWalletOrder,
      data: {
        'amount': amount,
      },
    );

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (data) => data as Map<String, dynamic>,
    );

    if (apiResponse.success && apiResponse.data != null) {
      return ApiResponse(
        success: true,
        message: apiResponse.message,
        data: {
          'orderId': apiResponse.data!['orderId'] as String,
          'amount': apiResponse.data!['amount'] as int,
          'currency': apiResponse.data!['currency'] as String? ?? 'INR',
        },
      );
    }

    return ApiResponse(
      success: false,
      message: apiResponse.message ?? 'Failed to create wallet order',
    );
  }

  /// Verify payment after Razorpay checkout success
  /// POST /payments/verify
  /// Body: { 
  ///   "orderId": "order_XXXXX",
  ///   "paymentId": "pay_XXXXX",
  ///   "signature": "..."
  /// }
  /// Response: { 
  ///   "success": true, 
  ///   "data": { 
  ///     "verified": true,
  ///     "bookingId": "...",
  ///     "paymentStatus": "COMPLETED"
  ///   } 
  /// }
  Future<ApiResponse<Map<String, dynamic>>> verifyPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.verifyPayment,
      data: {
        'orderId': orderId,
        'paymentId': paymentId,
        'signature': signature,
      },
    );

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (data) => data as Map<String, dynamic>,
    );

    if (apiResponse.success && apiResponse.data != null) {
      return ApiResponse(
        success: true,
        message: apiResponse.message,
        data: {
          'verified': apiResponse.data!['verified'] as bool? ?? false,
          'bookingId': apiResponse.data!['bookingId'] as String?,
          'paymentStatus': apiResponse.data!['paymentStatus'] as String?,
          'walletBalance': apiResponse.data!['walletBalance'] != null
              ? (apiResponse.data!['walletBalance'] as num).toDouble()
              : null,
        },
      );
    }

    return ApiResponse(
      success: false,
      message: apiResponse.message ?? 'Payment verification failed',
    );
  }

  /// Verify wallet top-up payment
  /// POST /payments/wallet-verify
  /// Body: { 
  ///   "orderId": "order_XXXXX",
  ///   "paymentId": "pay_XXXXX",
  ///   "signature": "..."
  /// }
  /// Response: { 
  ///   "success": true, 
  ///   "data": { 
  ///     "verified": true,
  ///     "balance": 1500.00,
  ///     "amountAdded": 500.00
  ///   } 
  /// }
  Future<ApiResponse<Map<String, dynamic>>> verifyWalletPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.verifyWalletPayment,
      data: {
        'orderId': orderId,
        'paymentId': paymentId,
        'signature': signature,
      },
    );

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (data) => data as Map<String, dynamic>,
    );

    if (apiResponse.success && apiResponse.data != null) {
      return ApiResponse(
        success: true,
        message: apiResponse.message,
        data: {
          'verified': apiResponse.data!['verified'] as bool? ?? false,
          'balance': (apiResponse.data!['balance'] as num?)?.toDouble() ?? 0.0,
          'amountAdded':
              (apiResponse.data!['amountAdded'] as num?)?.toDouble() ?? 0.0,
        },
      );
    }

    return ApiResponse(
      success: false,
      message: apiResponse.message ?? 'Wallet payment verification failed',
    );
  }

  /// Get payment status by order ID
  /// GET /payments/status/:orderId
  /// Response: { 
  ///   "success": true, 
  ///   "data": { 
  ///     "status": "COMPLETED",
  ///     "paymentId": "pay_XXXXX",
  ///     "amount": 299.00
  ///   } 
  /// }
  Future<ApiResponse<Map<String, dynamic>>> getPaymentStatus(
    String orderId,
  ) async {
    final response = await _apiClient.get(
      '${ApiConstants.paymentStatus}/$orderId',
    );

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (data) => data as Map<String, dynamic>,
    );

    if (apiResponse.success && apiResponse.data != null) {
      return ApiResponse(
        success: true,
        message: apiResponse.message,
        data: apiResponse.data,
      );
    }

    return ApiResponse(
      success: false,
      message: apiResponse.message ?? 'Failed to get payment status',
    );
  }
}
