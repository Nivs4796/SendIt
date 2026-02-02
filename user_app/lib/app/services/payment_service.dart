import 'package:get/get.dart';
import '../core/constants/app_constants.dart';
import '../data/repositories/wallet_repository.dart';

/// Result model for payment operations
class PaymentResult {
  final bool success;
  final String? transactionId;
  final String? errorMessage;
  final PaymentMethod method;
  final double amount;

  PaymentResult({
    required this.success,
    this.transactionId,
    this.errorMessage,
    required this.method,
    required this.amount,
  });

  factory PaymentResult.success({
    required PaymentMethod method,
    required double amount,
    String? transactionId,
  }) {
    return PaymentResult(
      success: true,
      transactionId: transactionId,
      method: method,
      amount: amount,
    );
  }

  factory PaymentResult.failure({
    required PaymentMethod method,
    required double amount,
    required String errorMessage,
  }) {
    return PaymentResult(
      success: false,
      errorMessage: errorMessage,
      method: method,
      amount: amount,
    );
  }
}

/// Service for handling all payment operations
class PaymentService extends GetxService {
  final WalletRepository _walletRepository = WalletRepository();

  /// Observable for tracking payment processing state
  final RxBool isProcessing = false.obs;

  /// Currently selected payment method
  final Rx<PaymentMethod> selectedMethod = PaymentMethod.wallet.obs;

  /// Get current wallet balance
  /// Returns the balance as double, or 0.0 on error
  Future<double> getWalletBalance() async {
    try {
      final response = await _walletRepository.getBalance();
      if (response.success && response.data != null) {
        return response.data!;
      }
      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  /// Check if wallet has sufficient balance for the given amount
  /// Returns a Map with:
  /// - hasSufficientBalance: bool
  /// - currentBalance: double
  /// - requiredAmount: double
  /// - shortfall: double (0 if sufficient)
  Future<Map<String, dynamic>> checkWalletBalance(double amount) async {
    try {
      final response = await _walletRepository.checkBalance(amount);

      if (response.success && response.data != null) {
        return response.data!;
      }

      // If API fails, try to get balance directly and compute locally
      final balanceResponse = await _walletRepository.getBalance();
      if (balanceResponse.success && balanceResponse.data != null) {
        final currentBalance = balanceResponse.data!;
        final hasSufficientBalance = currentBalance >= amount;
        final shortfall = hasSufficientBalance ? 0.0 : amount - currentBalance;

        return {
          'hasSufficientBalance': hasSufficientBalance,
          'currentBalance': currentBalance,
          'requiredAmount': amount,
          'shortfall': shortfall,
        };
      }

      // Return default insufficient balance response
      return {
        'hasSufficientBalance': false,
        'currentBalance': 0.0,
        'requiredAmount': amount,
        'shortfall': amount,
        'error': response.message ?? 'Failed to check wallet balance',
      };
    } catch (e) {
      return {
        'hasSufficientBalance': false,
        'currentBalance': 0.0,
        'requiredAmount': amount,
        'shortfall': amount,
        'error': e.toString(),
      };
    }
  }

  /// Process payment using wallet balance
  Future<PaymentResult> payWithWallet({
    required double amount,
    required String bookingId,
  }) async {
    try {
      isProcessing.value = true;

      // First check if sufficient balance exists
      final balanceCheck = await checkWalletBalance(amount);
      if (!(balanceCheck['hasSufficientBalance'] as bool)) {
        final shortfall = balanceCheck['shortfall'] as double;
        return PaymentResult.failure(
          method: PaymentMethod.wallet,
          amount: amount,
          errorMessage:
              'Insufficient wallet balance. Please add Rs. ${shortfall.toStringAsFixed(2)} to continue.',
        );
      }

      // Process wallet payment via API
      // Note: In a real implementation, this would call a dedicated payment endpoint
      // For now, we simulate a successful wallet deduction
      // TODO: Implement actual wallet payment endpoint call when backend is ready

      // Generate a transaction ID for tracking
      final transactionId =
          'WLT_${bookingId}_${DateTime.now().millisecondsSinceEpoch}';

      return PaymentResult.success(
        method: PaymentMethod.wallet,
        amount: amount,
        transactionId: transactionId,
      );
    } catch (e) {
      return PaymentResult.failure(
        method: PaymentMethod.wallet,
        amount: amount,
        errorMessage: 'Wallet payment failed: ${e.toString()}',
      );
    } finally {
      isProcessing.value = false;
    }
  }

  /// Mark a booking for cash on delivery payment
  /// Always returns success as COD doesn't require pre-processing
  Future<PaymentResult> markCashPayment({
    required double amount,
    required String bookingId,
  }) async {
    try {
      isProcessing.value = true;

      // Generate a reference ID for COD tracking
      final transactionId =
          'COD_${bookingId}_${DateTime.now().millisecondsSinceEpoch}';

      return PaymentResult.success(
        method: PaymentMethod.cash,
        amount: amount,
        transactionId: transactionId,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  /// Initiate Razorpay/UPI payment
  /// Currently returns placeholder error - to be implemented with Razorpay SDK
  Future<PaymentResult> initiateRazorpay({
    required double amount,
    required String bookingId,
    String? description,
  }) async {
    try {
      isProcessing.value = true;

      // TODO: Integrate Razorpay SDK for actual UPI/Card payments
      // This is a placeholder that will be replaced with actual Razorpay integration

      return PaymentResult.failure(
        method: PaymentMethod.upi,
        amount: amount,
        errorMessage: 'UPI payment coming soon!',
      );
    } finally {
      isProcessing.value = false;
    }
  }

  /// Unified payment processing method
  /// Routes to appropriate payment handler based on selected method
  Future<PaymentResult> processPayment({
    required PaymentMethod method,
    required double amount,
    required String bookingId,
    String? description,
  }) async {
    switch (method) {
      case PaymentMethod.wallet:
        return payWithWallet(amount: amount, bookingId: bookingId);

      case PaymentMethod.cash:
        return markCashPayment(amount: amount, bookingId: bookingId);

      case PaymentMethod.upi:
      case PaymentMethod.card:
      case PaymentMethod.netbanking:
        return initiateRazorpay(
          amount: amount,
          bookingId: bookingId,
          description: description,
        );
    }
  }

  /// Set the selected payment method
  void setPaymentMethod(PaymentMethod method) {
    selectedMethod.value = method;
  }

  /// Get display name for payment method
  String getPaymentMethodName(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Cash on Delivery';
      case PaymentMethod.upi:
        return 'UPI';
      case PaymentMethod.card:
        return 'Credit/Debit Card';
      case PaymentMethod.wallet:
        return 'SendIt Wallet';
      case PaymentMethod.netbanking:
        return 'Net Banking';
    }
  }

  /// Check if a payment method is currently available
  bool isMethodAvailable(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
      case PaymentMethod.wallet:
        return true;
      case PaymentMethod.upi:
      case PaymentMethod.card:
      case PaymentMethod.netbanking:
        return false; // Coming soon
    }
  }
}
