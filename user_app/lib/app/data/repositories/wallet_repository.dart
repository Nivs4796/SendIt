import '../models/api_response.dart';
import '../models/wallet_model.dart';
import '../providers/api_client.dart';
import '../../core/constants/api_constants.dart';

class WalletRepository {
  final ApiClient _apiClient = ApiClient();

  /// Get current wallet balance
  /// GET /wallet/balance
  /// Response: { "success": true, "data": { "balance": 1500.50 } }
  Future<ApiResponse<double>> getBalance() async {
    final response = await _apiClient.get(ApiConstants.walletBalance);

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (data) => data as Map<String, dynamic>,
    );

    if (apiResponse.success && apiResponse.data != null) {
      final balance = (apiResponse.data!['balance'] ?? 0).toDouble();

      return ApiResponse(
        success: true,
        message: apiResponse.message,
        data: balance,
      );
    }

    return ApiResponse(
      success: false,
      message: apiResponse.message ?? 'Failed to get wallet balance',
    );
  }

  /// Add money to wallet
  /// POST /wallet/add
  /// Body: { "amount": 500 }
  /// Response: { "success": true, "data": { "balance": 2000.50, "transaction": {...} } }
  /// Returns Map with balance and transaction
  Future<ApiResponse<Map<String, dynamic>>> addMoney(double amount) async {
    final response = await _apiClient.post(
      ApiConstants.addMoney,
      data: {'amount': amount},
    );

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (data) => data as Map<String, dynamic>,
    );

    if (apiResponse.success && apiResponse.data != null) {
      final balance = (apiResponse.data!['balance'] ?? 0).toDouble();
      final transactionData = apiResponse.data!['transaction'];
      WalletTransactionModel? transaction;

      if (transactionData != null) {
        transaction = WalletTransactionModel.fromJson(transactionData);
      }

      return ApiResponse(
        success: true,
        message: apiResponse.message,
        data: {
          'balance': balance,
          'transaction': transaction,
        },
      );
    }

    return ApiResponse(
      success: false,
      message: apiResponse.message ?? 'Failed to add money to wallet',
    );
  }

  /// Check if wallet has sufficient balance
  /// POST /wallet/check
  /// Body: { "amount": 200 }
  /// Response: { "success": true, "data": { "hasSufficientBalance": true, "currentBalance": 1500, "requiredAmount": 200, "shortfall": 0 } }
  Future<ApiResponse<Map<String, dynamic>>> checkBalance(double amount) async {
    final response = await _apiClient.post(
      ApiConstants.checkBalance,
      data: {'amount': amount},
    );

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (data) => data as Map<String, dynamic>,
    );

    if (apiResponse.success && apiResponse.data != null) {
      final data = apiResponse.data!;

      return ApiResponse(
        success: true,
        message: apiResponse.message,
        data: {
          'hasSufficientBalance': data['hasSufficientBalance'] ?? false,
          'currentBalance': (data['currentBalance'] ?? 0).toDouble(),
          'requiredAmount': (data['requiredAmount'] ?? 0).toDouble(),
          'shortfall': (data['shortfall'] ?? 0).toDouble(),
        },
      );
    }

    return ApiResponse(
      success: false,
      message: apiResponse.message ?? 'Failed to check wallet balance',
    );
  }

  /// Get wallet transactions with pagination and optional type filter
  /// GET /wallet/transactions?page=1&limit=10&type=CREDIT
  /// Response: { "success": true, "data": { "transactions": [...], "summary": { "totalCredits": 5000, "totalDebits": 2000 } }, "meta": { "page": 1, "totalPages": 5 } }
  /// Returns Map with transactions (List<WalletTransactionModel>) and summary
  Future<ApiResponse<Map<String, dynamic>>> getTransactions({
    int page = 1,
    int limit = 10,
    String? type,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };

    if (type != null && type.isNotEmpty) {
      queryParams['type'] = type;
    }

    final response = await _apiClient.get(
      ApiConstants.walletTransactions,
      queryParameters: queryParams,
    );

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (data) => data as Map<String, dynamic>,
    );

    if (apiResponse.success && apiResponse.data != null) {
      final transactionsData =
          apiResponse.data!['transactions'] as List<dynamic>?;
      final transactions = transactionsData
              ?.map((json) => WalletTransactionModel.fromJson(json))
              .toList() ??
          [];

      final summaryData =
          apiResponse.data!['summary'] as Map<String, dynamic>?;
      final summary = {
        'totalCredits': (summaryData?['totalCredits'] ?? 0).toDouble(),
        'totalDebits': (summaryData?['totalDebits'] ?? 0).toDouble(),
      };

      return ApiResponse(
        success: true,
        message: apiResponse.message,
        data: {
          'transactions': transactions,
          'summary': summary,
        },
        meta: apiResponse.meta,
      );
    }

    return ApiResponse(
      success: false,
      message: apiResponse.message ?? 'Failed to get wallet transactions',
    );
  }
}
