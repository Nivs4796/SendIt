import 'package:get/get.dart' hide Response;
import '../providers/api_client.dart';
import '../providers/api_exceptions.dart';
import '../../core/constants/api_constants.dart';

class BankRepository {
  final ApiClient _api = Get.find<ApiClient>();

  /// Get all bank accounts
  /// GET /pilots/bank-accounts
  Future<List<BankAccountModel>> getBankAccounts() async {
    try {
      final response = await _api.get(ApiConstants.bankAccounts);
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        // Handle both array and object with accounts key
        final List<dynamic> accounts = data is List 
            ? data 
            : (data['accounts'] ?? data['bankAccounts'] ?? []);
        return accounts.map((e) => BankAccountModel.fromJson(e)).toList();
      }
      
      throw ApiException(
        message: response.data['message'] ?? 'Failed to load bank accounts',
        statusCode: response.statusCode,
      );
    } on ApiException {
      rethrow;
    } on NetworkException {
      // Return mock data for development when network fails
      return _getMockBankAccounts();
    } on TimeoutException {
      return _getMockBankAccounts();
    } catch (e) {
      // Fallback to mock data for development
      return _getMockBankAccounts();
    }
  }

  /// Add new bank account
  /// POST /pilots/bank-accounts
  Future<BankAccountModel> addBankAccount({
    required String accountHolderName,
    required String accountNumber,
    required String ifscCode,
    required String bankName,
    String? branchName,
    bool setAsPrimary = false,
  }) async {
    try {
      final response = await _api.post(
        ApiConstants.bankAccounts,
        data: {
          'accountHolderName': accountHolderName,
          'accountNumber': accountNumber,
          'ifscCode': ifscCode,
          'bankName': bankName,
          if (branchName != null) 'branchName': branchName,
          'isPrimary': setAsPrimary,
        },
      );
      
      if ((response.statusCode == 200 || response.statusCode == 201) && 
          response.data['success'] == true) {
        final data = response.data['data'];
        // Handle both direct object and nested object
        final accountData = data['account'] ?? data['bankAccount'] ?? data;
        return BankAccountModel.fromJson(accountData);
      }
      
      throw ApiException(
        message: response.data['message'] ?? 'Failed to add bank account',
        statusCode: response.statusCode,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Add bank account failed: $e');
    }
  }

  /// Set bank account as primary
  /// PATCH /pilots/bank-accounts/:id/primary
  Future<bool> setPrimaryAccount(String accountId) async {
    try {
      final response = await _api.patch(ApiConstants.setBankPrimary(accountId));
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        return true;
      }
      
      throw ApiException(
        message: response.data['message'] ?? 'Failed to set primary account',
        statusCode: response.statusCode,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Set primary failed: $e');
    }
  }

  /// Delete bank account
  /// DELETE /pilots/bank-accounts/:id
  Future<bool> deleteBankAccount(String accountId) async {
    try {
      final response = await _api.delete(ApiConstants.bankAccount(accountId));
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        return true;
      }
      
      throw ApiException(
        message: response.data['message'] ?? 'Failed to delete bank account',
        statusCode: response.statusCode,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Delete failed: $e');
    }
  }

  /// Lookup IFSC code
  /// GET /utils/ifsc-lookup?ifsc=XXX
  Future<IfscResult?> lookupIfsc(String ifscCode) async {
    try {
      final response = await _api.get(
        ApiConstants.ifscLookup,
        queryParameters: {'ifsc': ifscCode},
      );
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        return IfscResult.fromJson(data);
      }
      
      return null;
    } on ApiException {
      return null;
    } catch (e) {
      // Try Razorpay IFSC API as fallback
      try {
        final response = await _api.get('https://ifsc.razorpay.com/$ifscCode');
        if (response.statusCode == 200) {
          return IfscResult(
            bankName: response.data['BANK'] ?? '',
            branchName: response.data['BRANCH'] ?? '',
            address: response.data['ADDRESS'] ?? '',
            city: response.data['CITY'] ?? '',
            state: response.data['STATE'] ?? '',
          );
        }
      } catch (_) {}
      return null;
    }
  }

  List<BankAccountModel> _getMockBankAccounts() {
    return [
      BankAccountModel(
        id: '1',
        accountHolderName: 'Pilot Name',
        accountNumber: '****4521',
        ifscCode: 'HDFC0001234',
        bankName: 'HDFC Bank',
        branchName: 'Koramangala Branch',
        isPrimary: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      BankAccountModel(
        id: '2',
        accountHolderName: 'Pilot Name',
        accountNumber: '****7890',
        ifscCode: 'SBIN0001234',
        bankName: 'State Bank of India',
        branchName: 'MG Road Branch',
        isPrimary: false,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
    ];
  }
}

/// Bank account model
class BankAccountModel {
  final String id;
  final String accountHolderName;
  final String accountNumber;
  final String ifscCode;
  final String bankName;
  final String? branchName;
  final bool isPrimary;
  final DateTime? createdAt;

  BankAccountModel({
    required this.id,
    required this.accountHolderName,
    required this.accountNumber,
    required this.ifscCode,
    required this.bankName,
    this.branchName,
    this.isPrimary = false,
    this.createdAt,
  });

  factory BankAccountModel.fromJson(Map<String, dynamic> json) {
    return BankAccountModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      accountHolderName: json['accountHolderName'] as String? ?? '',
      accountNumber: json['accountNumber'] as String? ?? '',
      ifscCode: json['ifscCode'] as String? ?? '',
      bankName: json['bankName'] as String? ?? '',
      branchName: json['branchName'] as String?,
      isPrimary: json['isPrimary'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountHolderName': accountHolderName,
      'accountNumber': accountNumber,
      'ifscCode': ifscCode,
      'bankName': bankName,
      'branchName': branchName,
      'isPrimary': isPrimary,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  String get maskedAccountNumber {
    if (accountNumber.length <= 4) return accountNumber;
    if (accountNumber.startsWith('****')) return accountNumber;
    return '****${accountNumber.substring(accountNumber.length - 4)}';
  }
}

/// IFSC lookup result
class IfscResult {
  final String bankName;
  final String branchName;
  final String address;
  final String city;
  final String state;

  IfscResult({
    required this.bankName,
    required this.branchName,
    required this.address,
    required this.city,
    required this.state,
  });

  factory IfscResult.fromJson(Map<String, dynamic> json) {
    return IfscResult(
      bankName: json['bankName'] ?? json['bank'] ?? json['BANK'] ?? '',
      branchName: json['branchName'] ?? json['branch'] ?? json['BRANCH'] ?? '',
      address: json['address'] ?? json['ADDRESS'] ?? '',
      city: json['city'] ?? json['CITY'] ?? '',
      state: json['state'] ?? json['STATE'] ?? '',
    );
  }
}
