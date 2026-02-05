import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../core/config/app_config.dart';

/// Response model for Razorpay payment completion
class RazorpayPaymentResponse {
  final bool success;
  final String? paymentId;
  final String? orderId;
  final String? signature;
  final int? errorCode;
  final String? errorMessage;

  RazorpayPaymentResponse({
    required this.success,
    this.paymentId,
    this.orderId,
    this.signature,
    this.errorCode,
    this.errorMessage,
  });

  factory RazorpayPaymentResponse.success({
    required String paymentId,
    required String orderId,
    required String signature,
  }) {
    return RazorpayPaymentResponse(
      success: true,
      paymentId: paymentId,
      orderId: orderId,
      signature: signature,
    );
  }

  factory RazorpayPaymentResponse.failure({
    required int errorCode,
    required String errorMessage,
  }) {
    return RazorpayPaymentResponse(
      success: false,
      errorCode: errorCode,
      errorMessage: errorMessage,
    );
  }

  factory RazorpayPaymentResponse.cancelled() {
    return RazorpayPaymentResponse(
      success: false,
      errorCode: Razorpay.PAYMENT_CANCELLED,
      errorMessage: 'Payment was cancelled by user',
    );
  }
}

/// Service for handling Razorpay payment integration.
/// Singleton pattern to ensure only one instance exists.
class RazorpayService extends GetxService {
  late Razorpay _razorpay;

  // Callbacks for current payment
  Function(RazorpayPaymentResponse)? _onPaymentComplete;
  Function(ExternalWalletResponse)? _onExternalWallet;

  // Observable state
  final RxBool isPaymentInProgress = false.obs;

  // Razorpay key from environment configuration
  // Override via: flutter run --dart-define=RAZORPAY_KEY=rzp_live_XXXXXXXX
  // Test key format: rzp_test_XXXXXXXX
  // Live key format: rzp_live_XXXXXXXX
  static String get _razorpayKey => AppConfig.razorpayKey;

  // SendIt branding
  static const String _businessName = 'SendIt';
  static const String _themeColor = '#FF6B00';
  static const String _logoUrl = ''; // Add your logo URL here

  @override
  void onInit() {
    super.onInit();
    _initRazorpay();
  }

  @override
  void onClose() {
    _razorpay.clear();
    super.onClose();
  }

  /// Initialize Razorpay instance and set up event handlers
  void _initRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  /// Open Razorpay checkout for a booking payment
  /// 
  /// [orderId] - Razorpay order ID from backend (format: order_XXXXX)
  /// [amountInPaise] - Amount in PAISE (₹100 = 10000 paise)
  /// [description] - Payment description shown to user
  /// [userPhone] - User's phone number for prefill
  /// [userEmail] - User's email for prefill
  /// [userName] - User's name for prefill
  /// [onComplete] - Callback when payment completes (success or failure)
  /// [onExternalWallet] - Optional callback for external wallet selection
  void openCheckout({
    required String orderId,
    required int amountInPaise,
    required String description,
    required String userPhone,
    required String userEmail,
    required String userName,
    required Function(RazorpayPaymentResponse) onComplete,
    Function(ExternalWalletResponse)? onExternalWallet,
  }) {
    if (isPaymentInProgress.value) {
      debugPrint('RazorpayService: Payment already in progress');
      return;
    }

    // Store callbacks
    _onPaymentComplete = onComplete;
    _onExternalWallet = onExternalWallet;
    isPaymentInProgress.value = true;

    // Build checkout options
    final options = {
      'key': _razorpayKey,
      'amount': amountInPaise,
      'name': _businessName,
      'order_id': orderId,
      'description': description,
      'prefill': {
        'contact': userPhone,
        'email': userEmail,
        'name': userName,
      },
      'theme': {
        'color': _themeColor,
      },
      // Retry configuration
      'retry': {
        'enabled': true,
        'max_count': 1,
      },
      // Enable specific payment methods
      'method': {
        'upi': true,
        'card': true,
        'netbanking': true,
        'wallet': true,
        'emi': false,
        'paylater': false,
      },
    };

    // Add logo if available
    if (_logoUrl.isNotEmpty) {
      options['image'] = _logoUrl;
    }

    try {
      debugPrint('RazorpayService: Opening checkout for order $orderId');
      _razorpay.open(options);
    } catch (e) {
      debugPrint('RazorpayService: Error opening checkout: $e');
      isPaymentInProgress.value = false;
      _onPaymentComplete?.call(
        RazorpayPaymentResponse.failure(
          errorCode: -1,
          errorMessage: 'Failed to open payment gateway: $e',
        ),
      );
    }
  }

  /// Open Razorpay checkout for wallet top-up (without order_id)
  /// Used when adding money to wallet
  /// 
  /// [amountInPaise] - Amount in PAISE
  /// [userPhone] - User's phone number
  /// [userEmail] - User's email
  /// [userName] - User's name
  /// [notes] - Optional notes for the payment
  /// [onComplete] - Callback when payment completes
  void openWalletTopup({
    required int amountInPaise,
    required String userPhone,
    required String userEmail,
    required String userName,
    Map<String, dynamic>? notes,
    required Function(RazorpayPaymentResponse) onComplete,
  }) {
    if (isPaymentInProgress.value) {
      debugPrint('RazorpayService: Payment already in progress');
      return;
    }

    _onPaymentComplete = onComplete;
    _onExternalWallet = null;
    isPaymentInProgress.value = true;

    final options = {
      'key': _razorpayKey,
      'amount': amountInPaise,
      'name': _businessName,
      'description': 'Wallet Top-up',
      'prefill': {
        'contact': userPhone,
        'email': userEmail,
        'name': userName,
      },
      'theme': {
        'color': _themeColor,
      },
      'notes': notes ?? {'type': 'wallet_topup'},
      'method': {
        'upi': true,
        'card': true,
        'netbanking': true,
        'wallet': true,
        'emi': false,
        'paylater': false,
      },
    };

    try {
      debugPrint('RazorpayService: Opening wallet topup checkout');
      _razorpay.open(options);
    } catch (e) {
      debugPrint('RazorpayService: Error opening checkout: $e');
      isPaymentInProgress.value = false;
      _onPaymentComplete?.call(
        RazorpayPaymentResponse.failure(
          errorCode: -1,
          errorMessage: 'Failed to open payment gateway: $e',
        ),
      );
    }
  }

  /// Handle successful payment
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    debugPrint('RazorpayService: Payment success');
    debugPrint('  Payment ID: ${response.paymentId}');
    debugPrint('  Order ID: ${response.orderId}');
    debugPrint('  Signature: ${response.signature}');

    isPaymentInProgress.value = false;

    _onPaymentComplete?.call(
      RazorpayPaymentResponse.success(
        paymentId: response.paymentId ?? '',
        orderId: response.orderId ?? '',
        signature: response.signature ?? '',
      ),
    );

    // Clear callbacks
    _onPaymentComplete = null;
    _onExternalWallet = null;
  }

  /// Handle payment error
  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint('RazorpayService: Payment error');
    debugPrint('  Code: ${response.code}');
    debugPrint('  Message: ${response.message}');

    isPaymentInProgress.value = false;

    final errorMessage = _getErrorMessage(response.code ?? -1, response.message);

    _onPaymentComplete?.call(
      RazorpayPaymentResponse.failure(
        errorCode: response.code ?? -1,
        errorMessage: errorMessage,
      ),
    );

    // Clear callbacks
    _onPaymentComplete = null;
    _onExternalWallet = null;
  }

  /// Handle external wallet selection
  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('RazorpayService: External wallet selected: ${response.walletName}');

    // External wallet doesn't complete immediately - user will complete in wallet app
    // The payment status will be updated via webhook
    _onExternalWallet?.call(response);
  }

  /// Get user-friendly error message based on error code
  String _getErrorMessage(int code, String? rawMessage) {
    switch (code) {
      case Razorpay.NETWORK_ERROR:
        return 'Network error. Please check your internet connection and try again.';
      case Razorpay.INVALID_OPTIONS:
        return 'Payment configuration error. Please try again later.';
      case Razorpay.PAYMENT_CANCELLED:
        return 'Payment was cancelled.';
      case Razorpay.TLS_ERROR:
        return 'Secure connection error. Please try again.';
      case Razorpay.INCOMPATIBLE_PLUGIN:
        return 'Payment plugin error. Please update the app.';
      default:
        // Try to extract meaningful message from raw message
        if (rawMessage != null && rawMessage.isNotEmpty) {
          // Remove technical details, show only user-friendly part
          final userMessage = rawMessage.split(':').last.trim();
          if (userMessage.isNotEmpty && userMessage.length < 100) {
            return userMessage;
          }
        }
        return 'Payment failed. Please try again.';
    }
  }

  /// Convert rupees to paise
  static int rupeesToPaise(double rupees) {
    return (rupees * 100).round();
  }

  /// Convert paise to rupees
  static double paiseToRupees(int paise) {
    return paise / 100.0;
  }

  /// Check if Razorpay key is configured
  bool get isConfigured => _razorpayKey.isNotEmpty && _razorpayKey != 'rzp_test_XXXXXXXX';
}
