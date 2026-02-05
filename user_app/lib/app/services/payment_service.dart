import 'dart:async';

import 'package:get/get.dart';
import '../core/constants/app_constants.dart';
import '../data/repositories/wallet_repository.dart';
import '../data/repositories/payment_repository.dart';
import '../data/providers/api_exceptions.dart';
import 'razorpay_service.dart';

/// Result model for payment operations
class PaymentResult {
  final bool success;
  final String? transactionId;
  final String? errorMessage;
  final PaymentMethod method;
  final double amount;
  final String? razorpayOrderId;
  final String? razorpayPaymentId;

  PaymentResult({
    required this.success,
    this.transactionId,
    this.errorMessage,
    required this.method,
    required this.amount,
    this.razorpayOrderId,
    this.razorpayPaymentId,
  });

  factory PaymentResult.success({
    required PaymentMethod method,
    required double amount,
    String? transactionId,
    String? razorpayOrderId,
    String? razorpayPaymentId,
  }) {
    return PaymentResult(
      success: true,
      transactionId: transactionId,
      method: method,
      amount: amount,
      razorpayOrderId: razorpayOrderId,
      razorpayPaymentId: razorpayPaymentId,
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
  final PaymentRepository _paymentRepository = PaymentRepository();
  late final RazorpayService _razorpayService;

  /// Observable for tracking payment processing state
  final RxBool isProcessing = false.obs;

  /// Currently selected payment method
  final Rx<PaymentMethod> selectedMethod = PaymentMethod.wallet.obs;

  /// Current user info for Razorpay prefill
  String _userPhone = '';
  String _userEmail = '';
  String _userName = '';

  @override
  void onInit() {
    super.onInit();
    // RazorpayService should be initialized before PaymentService
    _razorpayService = Get.find<RazorpayService>();
  }

  /// Set user info for Razorpay checkout prefill
  void setUserInfo({
    required String phone,
    required String email,
    required String name,
  }) {
    _userPhone = phone;
    _userEmail = email;
    _userName = name;
  }

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
              'Insufficient wallet balance. Please add ₹${shortfall.toStringAsFixed(2)} to continue.',
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

  /// Initiate Razorpay payment for booking
  /// Returns a Future that completes when payment is done
  Future<PaymentResult> initiateRazorpayPayment({
    required double amount,
    required String bookingId,
    String? description,
    PaymentMethod method = PaymentMethod.upi,
  }) async {
    try {
      isProcessing.value = true;

      // Step 1: Create Razorpay order on backend
      final orderResponse = await _paymentRepository.createOrder(
        bookingId: bookingId,
        amount: amount,
      );

      if (!orderResponse.success || orderResponse.data == null) {
        return PaymentResult.failure(
          method: method,
          amount: amount,
          errorMessage: orderResponse.message ?? 'Failed to create payment order',
        );
      }

      final orderId = orderResponse.data!['orderId'] as String;
      final amountInPaise = orderResponse.data!['amount'] as int;

      // Step 2: Open Razorpay checkout
      final paymentResponse = await _openRazorpayCheckout(
        orderId: orderId,
        amountInPaise: amountInPaise,
        description: description ?? 'Booking #$bookingId',
      );

      if (!paymentResponse.success) {
        return PaymentResult.failure(
          method: method,
          amount: amount,
          errorMessage: paymentResponse.errorMessage ?? 'Payment failed',
        );
      }

      // Step 3: Verify payment with backend
      final verifyResponse = await _paymentRepository.verifyPayment(
        orderId: orderId,
        paymentId: paymentResponse.paymentId!,
        signature: paymentResponse.signature!,
      );

      if (!verifyResponse.success ||
          verifyResponse.data == null ||
          !(verifyResponse.data!['verified'] as bool)) {
        return PaymentResult.failure(
          method: method,
          amount: amount,
          errorMessage: 'Payment verification failed. Please contact support.',
        );
      }

      return PaymentResult.success(
        method: method,
        amount: amount,
        transactionId: paymentResponse.paymentId,
        razorpayOrderId: orderId,
        razorpayPaymentId: paymentResponse.paymentId,
      );
    } on ApiException catch (e) {
      return PaymentResult.failure(
        method: method,
        amount: amount,
        errorMessage: e.message,
      );
    } on NetworkException {
      return PaymentResult.failure(
        method: method,
        amount: amount,
        errorMessage: 'No internet connection',
      );
    } catch (e) {
      return PaymentResult.failure(
        method: method,
        amount: amount,
        errorMessage: 'Payment failed: ${e.toString()}',
      );
    } finally {
      isProcessing.value = false;
    }
  }

  /// Add money to wallet via Razorpay
  /// Returns updated wallet balance on success
  Future<Map<String, dynamic>> addMoneyViaRazorpay({
    required double amount,
  }) async {
    try {
      isProcessing.value = true;

      // Step 1: Create Razorpay order for wallet topup
      final orderResponse = await _paymentRepository.createWalletOrder(
        amount: amount,
      );

      if (!orderResponse.success || orderResponse.data == null) {
        return {
          'success': false,
          'error': orderResponse.message ?? 'Failed to create order',
        };
      }

      final orderId = orderResponse.data!['orderId'] as String;
      final amountInPaise = orderResponse.data!['amount'] as int;

      // Step 2: Open Razorpay checkout
      final paymentResponse = await _openRazorpayCheckout(
        orderId: orderId,
        amountInPaise: amountInPaise,
        description: 'Wallet Top-up',
      );

      if (!paymentResponse.success) {
        return {
          'success': false,
          'error': paymentResponse.errorMessage ?? 'Payment failed',
        };
      }

      // Step 3: Verify payment with backend
      final verifyResponse = await _paymentRepository.verifyWalletPayment(
        orderId: orderId,
        paymentId: paymentResponse.paymentId!,
        signature: paymentResponse.signature!,
      );

      if (!verifyResponse.success ||
          verifyResponse.data == null ||
          !(verifyResponse.data!['verified'] as bool)) {
        return {
          'success': false,
          'error': 'Payment verification failed. Please contact support.',
        };
      }

      return {
        'success': true,
        'balance': verifyResponse.data!['balance'] as double,
        'amountAdded': verifyResponse.data!['amountAdded'] as double,
        'paymentId': paymentResponse.paymentId,
      };
    } on ApiException catch (e) {
      return {
        'success': false,
        'error': e.message,
      };
    } on NetworkException {
      return {
        'success': false,
        'error': 'No internet connection',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Payment failed: ${e.toString()}',
      };
    } finally {
      isProcessing.value = false;
    }
  }

  /// Open Razorpay checkout and wait for result
  Future<RazorpayPaymentResponse> _openRazorpayCheckout({
    required String orderId,
    required int amountInPaise,
    required String description,
  }) async {
    final completer = Completer<RazorpayPaymentResponse>();

    _razorpayService.openCheckout(
      orderId: orderId,
      amountInPaise: amountInPaise,
      description: description,
      userPhone: _userPhone.isNotEmpty ? _userPhone : '9999999999',
      userEmail: _userEmail.isNotEmpty ? _userEmail : 'user@sendit.app',
      userName: _userName.isNotEmpty ? _userName : 'SendIt User',
      onComplete: (response) {
        completer.complete(response);
      },
    );

    return completer.future;
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
        return initiateRazorpayPayment(
          amount: amount,
          bookingId: bookingId,
          description: description,
          method: method,
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
        return true; // Now available with Razorpay!
    }
  }
}
