import 'package:get/get.dart' hide Response;
import '../providers/api_client.dart';
import '../providers/api_exceptions.dart';
import '../../core/constants/api_constants.dart';
import '../../core/config/app_config.dart';

class WalletRepository {
  final ApiClient _api = Get.find<ApiClient>();

  /// Get wallet balance and details
  /// GET /wallet/pilot/balance
  Future<WalletModel> getWallet() async {
    try {
      final response = await _api.get(ApiConstants.walletBalance);
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        return WalletModel.fromJson(response.data['data']);
      }
      
      throw ApiException(
        message: response.data['message'] ?? 'Failed to load wallet',
        statusCode: response.statusCode,
      );
    } on ApiException {
      rethrow;
    } on NetworkException {
      // Mock data for development only
      if (AppConfig.enableMockData) return _getMockWallet();
      rethrow;
    } on TimeoutException {
      if (AppConfig.enableMockData) return _getMockWallet();
      throw ApiException(message: 'Request timed out');
    } catch (e) {
      // Fallback to mock data in development only
      if (AppConfig.enableMockData) return _getMockWallet();
      throw ApiException(message: 'Failed to load wallet');
    }
  }

  /// Get wallet transactions
  /// GET /wallet/pilot/transactions
  Future<List<WalletTransaction>> getTransactions({
    int page = 1,
    int limit = 20,
    String? type, // 'credit', 'debit', 'withdrawal', 'bonus'
  }) async {
    try {
      final params = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (type != null) params['type'] = type;

      final response = await _api.get(
        ApiConstants.walletTransactions,
        queryParameters: params,
      );
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        // Handle both array and object with transactions key
        final List<dynamic> transactions = data is List 
            ? data 
            : (data['transactions'] ?? []);
        return transactions
            .map((e) => WalletTransaction.fromJson(e))
            .toList();
      }
      
      throw ApiException(
        message: response.data['message'] ?? 'Failed to load transactions',
        statusCode: response.statusCode,
      );
    } on ApiException {
      rethrow;
    } on NetworkException {
      if (AppConfig.enableMockData) return _getMockTransactions();
      rethrow;
    } on TimeoutException {
      if (AppConfig.enableMockData) return _getMockTransactions();
      throw ApiException(message: 'Request timed out');
    } catch (e) {
      if (AppConfig.enableMockData) return _getMockTransactions();
      throw ApiException(message: 'Failed to load transactions');
    }
  }

  /// Initiate withdrawal
  /// POST /wallet/pilot/withdraw
  Future<WithdrawalResult> initiateWithdrawal({
    required double amount,
    required String bankAccountId,
  }) async {
    try {
      final response = await _api.post(
        ApiConstants.withdrawRequest,
        data: {
          'amount': amount,
          'bankAccountId': bankAccountId,
        },
      );
      
      if ((response.statusCode == 200 || response.statusCode == 201) && 
          response.data['success'] == true) {
        return WithdrawalResult.fromJson(response.data['data']);
      }
      
      throw ApiException(
        message: response.data['message'] ?? 'Withdrawal failed',
        statusCode: response.statusCode,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Withdrawal failed: $e');
    }
  }

  /// Get withdrawal history
  /// GET /wallet/pilot/withdrawals
  Future<List<WithdrawalRecord>> getWithdrawals({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _api.get(
        '/wallet/pilot/withdrawals',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final List<dynamic> withdrawals = data is List 
            ? data 
            : (data['withdrawals'] ?? []);
        return withdrawals
            .map((e) => WithdrawalRecord.fromJson(e))
            .toList();
      }
      
      throw ApiException(
        message: response.data['message'] ?? 'Failed to load withdrawals',
        statusCode: response.statusCode,
      );
    } on ApiException {
      rethrow;
    } on NetworkException {
      if (AppConfig.enableMockData) return _getMockWithdrawals();
      rethrow;
    } on TimeoutException {
      if (AppConfig.enableMockData) return _getMockWithdrawals();
      throw ApiException(message: 'Request timed out');
    } catch (e) {
      if (AppConfig.enableMockData) return _getMockWithdrawals();
      throw ApiException(message: 'Failed to load withdrawals');
    }
  }

  /// Get bank accounts (for withdrawal selection)
  /// GET /pilots/bank-accounts
  Future<List<BankAccount>> getBankAccounts() async {
    try {
      final response = await _api.get('/pilots/bank-accounts');
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final List<dynamic> accounts = data is List 
            ? data 
            : (data['accounts'] ?? data['bankAccounts'] ?? []);
        return accounts
            .map((e) => BankAccount.fromJson(e))
            .toList();
      }
      
      throw ApiException(
        message: response.data['message'] ?? 'Failed to load bank accounts',
        statusCode: response.statusCode,
      );
    } on ApiException {
      rethrow;
    } on NetworkException {
      if (AppConfig.enableMockData) return _getMockBankAccounts();
      rethrow;
    } on TimeoutException {
      if (AppConfig.enableMockData) return _getMockBankAccounts();
      throw ApiException(message: 'Request timed out');
    } catch (e) {
      if (AppConfig.enableMockData) return _getMockBankAccounts();
      throw ApiException(message: 'Failed to load bank accounts');
    }
  }

  WalletModel _getMockWallet() {
    return WalletModel(
      balance: 4580.50,
      pendingAmount: 350.0,
      todayEarnings: 1250.0,
      weekEarnings: 8500.0,
      lastUpdated: DateTime.now(),
    );
  }

  List<WalletTransaction> _getMockTransactions() {
    final now = DateTime.now();
    return [
      WalletTransaction(
        id: '1',
        type: WalletTransactionType.credit,
        amount: 149.0,
        description: 'Delivery earnings - #SND-001',
        timestamp: now.subtract(const Duration(hours: 1)),
        status: TransactionStatus.completed,
      ),
      WalletTransaction(
        id: '2',
        type: WalletTransactionType.credit,
        amount: 100.0,
        description: 'Peak hour bonus',
        timestamp: now.subtract(const Duration(hours: 3)),
        status: TransactionStatus.completed,
      ),
      WalletTransaction(
        id: '3',
        type: WalletTransactionType.withdrawal,
        amount: 2000.0,
        description: 'Bank transfer to HDFC ****4521',
        timestamp: now.subtract(const Duration(days: 1)),
        status: TransactionStatus.processing,
      ),
      WalletTransaction(
        id: '4',
        type: WalletTransactionType.credit,
        amount: 89.0,
        description: 'Delivery earnings - #SND-002',
        timestamp: now.subtract(const Duration(days: 1, hours: 2)),
        status: TransactionStatus.completed,
      ),
      WalletTransaction(
        id: '5',
        type: WalletTransactionType.debit,
        amount: 50.0,
        description: 'Penalty - Late delivery',
        timestamp: now.subtract(const Duration(days: 2)),
        status: TransactionStatus.completed,
      ),
    ];
  }

  List<WithdrawalRecord> _getMockWithdrawals() {
    final now = DateTime.now();
    return [
      WithdrawalRecord(
        id: '1',
        amount: 2000.0,
        bankAccountNumber: '****4521',
        bankName: 'HDFC Bank',
        status: WithdrawalStatus.processing,
        requestedAt: now.subtract(const Duration(days: 1)),
      ),
      WithdrawalRecord(
        id: '2',
        amount: 3000.0,
        bankAccountNumber: '****4521',
        bankName: 'HDFC Bank',
        status: WithdrawalStatus.completed,
        requestedAt: now.subtract(const Duration(days: 5)),
        completedAt: now.subtract(const Duration(days: 4)),
      ),
    ];
  }

  List<BankAccount> _getMockBankAccounts() {
    return [
      BankAccount(
        id: '1',
        bankName: 'HDFC Bank',
        accountNumber: '****4521',
        accountHolderName: 'Pilot Name',
        ifscCode: 'HDFC0001234',
        isPrimary: true,
      ),
      BankAccount(
        id: '2',
        bankName: 'State Bank of India',
        accountNumber: '****7890',
        accountHolderName: 'Pilot Name',
        ifscCode: 'SBIN0001234',
        isPrimary: false,
      ),
    ];
  }
}

/// Wallet model
class WalletModel {
  final double balance;
  final double pendingAmount;
  final double todayEarnings;
  final double weekEarnings;
  final DateTime lastUpdated;

  WalletModel({
    required this.balance,
    this.pendingAmount = 0,
    this.todayEarnings = 0,
    this.weekEarnings = 0,
    required this.lastUpdated,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
      pendingAmount: (json['pendingAmount'] as num?)?.toDouble() ?? 0,
      todayEarnings: (json['todayEarnings'] as num?)?.toDouble() ?? 0,
      weekEarnings: (json['weekEarnings'] as num?)?.toDouble() ?? 0,
      lastUpdated: json['lastUpdated'] != null 
          ? DateTime.tryParse(json['lastUpdated'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String get balanceDisplay => '₹${balance.toStringAsFixed(2)}';
}

/// Wallet transaction types
enum WalletTransactionType { credit, debit, withdrawal, bonus }

enum TransactionStatus { pending, processing, completed, failed }

/// Wallet transaction
class WalletTransaction {
  final String id;
  final WalletTransactionType type;
  final double amount;
  final String description;
  final DateTime timestamp;
  final TransactionStatus status;
  final String? referenceId;

  WalletTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.timestamp,
    required this.status,
    this.referenceId,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      type: _parseTransactionType(json['type']),
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      description: json['description'] ?? json['note'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
          : (json['createdAt'] != null 
              ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
              : DateTime.now()),
      status: _parseTransactionStatus(json['status']),
      referenceId: json['referenceId'] ?? json['txnId'],
    );
  }

  static WalletTransactionType _parseTransactionType(dynamic type) {
    if (type == null) return WalletTransactionType.credit;
    final typeStr = type.toString().toLowerCase();
    switch (typeStr) {
      case 'credit':
      case 'earning':
      case 'earnings':
        return WalletTransactionType.credit;
      case 'debit':
      case 'penalty':
        return WalletTransactionType.debit;
      case 'withdrawal':
      case 'withdraw':
        return WalletTransactionType.withdrawal;
      case 'bonus':
      case 'incentive':
        return WalletTransactionType.bonus;
      default:
        return WalletTransactionType.credit;
    }
  }

  static TransactionStatus _parseTransactionStatus(dynamic status) {
    if (status == null) return TransactionStatus.completed;
    final statusStr = status.toString().toLowerCase();
    switch (statusStr) {
      case 'pending':
        return TransactionStatus.pending;
      case 'processing':
      case 'in_progress':
        return TransactionStatus.processing;
      case 'completed':
      case 'success':
      case 'successful':
        return TransactionStatus.completed;
      case 'failed':
      case 'failure':
      case 'rejected':
        return TransactionStatus.failed;
      default:
        return TransactionStatus.completed;
    }
  }

  bool get isCredit => type == WalletTransactionType.credit || type == WalletTransactionType.bonus;
  String get amountDisplay => '${isCredit ? '+' : '-'}₹${amount.toStringAsFixed(2)}';
}

/// Withdrawal status
enum WithdrawalStatus { pending, processing, completed, failed }

/// Withdrawal record
class WithdrawalRecord {
  final String id;
  final double amount;
  final String bankAccountNumber;
  final String bankName;
  final WithdrawalStatus status;
  final DateTime requestedAt;
  final DateTime? completedAt;
  final String? failureReason;

  WithdrawalRecord({
    required this.id,
    required this.amount,
    required this.bankAccountNumber,
    required this.bankName,
    required this.status,
    required this.requestedAt,
    this.completedAt,
    this.failureReason,
  });

  factory WithdrawalRecord.fromJson(Map<String, dynamic> json) {
    return WithdrawalRecord(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      bankAccountNumber: json['bankAccountNumber'] ?? json['accountNumber'] ?? '',
      bankName: json['bankName'] ?? '',
      status: _parseWithdrawalStatus(json['status']),
      requestedAt: json['requestedAt'] != null
          ? DateTime.tryParse(json['requestedAt'].toString()) ?? DateTime.now()
          : (json['createdAt'] != null 
              ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
              : DateTime.now()),
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'].toString())
          : null,
      failureReason: json['failureReason'] ?? json['reason'],
    );
  }

  static WithdrawalStatus _parseWithdrawalStatus(dynamic status) {
    if (status == null) return WithdrawalStatus.pending;
    final statusStr = status.toString().toLowerCase();
    switch (statusStr) {
      case 'pending':
        return WithdrawalStatus.pending;
      case 'processing':
      case 'in_progress':
        return WithdrawalStatus.processing;
      case 'completed':
      case 'success':
      case 'successful':
        return WithdrawalStatus.completed;
      case 'failed':
      case 'failure':
      case 'rejected':
        return WithdrawalStatus.failed;
      default:
        return WithdrawalStatus.pending;
    }
  }

  String get amountDisplay => '₹${amount.toStringAsFixed(2)}';
}

/// Bank account
class BankAccount {
  final String id;
  final String bankName;
  final String accountNumber;
  final String accountHolderName;
  final String ifscCode;
  final bool isPrimary;

  BankAccount({
    required this.id,
    required this.bankName,
    required this.accountNumber,
    required this.accountHolderName,
    required this.ifscCode,
    this.isPrimary = false,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      bankName: json['bankName'] ?? '',
      accountNumber: json['accountNumber'] ?? '',
      accountHolderName: json['accountHolderName'] ?? '',
      ifscCode: json['ifscCode'] ?? '',
      isPrimary: json['isPrimary'] as bool? ?? false,
    );
  }
}

/// Withdrawal result
class WithdrawalResult {
  final String transactionId;
  final double amount;
  final String status;
  final String estimatedTime;

  WithdrawalResult({
    required this.transactionId,
    required this.amount,
    required this.status,
    required this.estimatedTime,
  });

  factory WithdrawalResult.fromJson(Map<String, dynamic> json) {
    return WithdrawalResult(
      transactionId: (json['transactionId'] ?? json['id'] ?? json['_id'] ?? '').toString(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      status: json['status'] ?? 'pending',
      estimatedTime: json['estimatedTime'] ?? '1-2 business days',
    );
  }
}

/// Add money result (kept for compatibility)
class AddMoneyResult {
  final String orderId;
  final String paymentUrl;
  final double amount;

  AddMoneyResult({
    required this.orderId,
    required this.paymentUrl,
    required this.amount,
  });

  factory AddMoneyResult.fromJson(Map<String, dynamic> json) {
    return AddMoneyResult(
      orderId: json['orderId'] ?? '',
      paymentUrl: json['paymentUrl'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
    );
  }
}
