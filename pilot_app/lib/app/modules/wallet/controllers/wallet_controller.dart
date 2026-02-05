import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/wallet_repository.dart';

class WalletController extends GetxController {
  final WalletRepository _repository = WalletRepository();

  // State
  final isLoading = true.obs;
  final wallet = Rxn<WalletModel>();
  final transactions = <WalletTransaction>[].obs;
  final bankAccounts = <BankAccount>[].obs;
  final isLoadingMore = false.obs;
  final isProcessing = false.obs;

  // Pagination
  int _currentPage = 1;
  bool _hasMore = true;

  // Selected bank account for withdrawal
  final selectedBankAccount = Rxn<BankAccount>();

  @override
  void onInit() {
    super.onInit();
    loadWallet();
    loadTransactions();
    loadBankAccounts();
  }

  /// Load wallet details
  Future<void> loadWallet() async {
    try {
      isLoading.value = true;
      wallet.value = await _repository.getWallet();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load wallet');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load transactions
  Future<void> loadTransactions({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      transactions.clear();
    }

    if (!_hasMore || isLoadingMore.value) return;

    try {
      isLoadingMore.value = true;
      final newTransactions = await _repository.getTransactions(page: _currentPage);
      
      if (newTransactions.isEmpty) {
        _hasMore = false;
      } else {
        transactions.addAll(newTransactions);
        _currentPage++;
      }
    } catch (e) {
      // Silently fail
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// Load bank accounts
  Future<void> loadBankAccounts() async {
    try {
      bankAccounts.value = await _repository.getBankAccounts();
      // Set primary as default selection
      selectedBankAccount.value = bankAccounts.firstWhereOrNull((b) => b.isPrimary);
    } catch (e) {
      // Silently fail
    }
  }

  /// Initiate withdrawal
  Future<bool> initiateWithdrawal(double amount) async {
    if (selectedBankAccount.value == null) {
      Get.snackbar('Error', 'Please select a bank account');
      return false;
    }

    if (amount <= 0) {
      Get.snackbar('Error', 'Please enter a valid amount');
      return false;
    }

    final balance = wallet.value?.balance ?? 0;
    if (amount > balance) {
      Get.snackbar('Error', 'Insufficient balance');
      return false;
    }

    try {
      isProcessing.value = true;
      final result = await _repository.initiateWithdrawal(
        amount: amount,
        bankAccountId: selectedBankAccount.value!.id,
      );

      Get.snackbar(
        'Withdrawal Initiated',
        'Transfer of ₹${amount.toStringAsFixed(0)} will be processed in ${result.estimatedTime}',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
      );

      // Refresh wallet
      await loadWallet();
      await loadTransactions(refresh: true);
      
      return true;
    } catch (e) {
      Get.snackbar(
        'Withdrawal Failed',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return false;
    } finally {
      isProcessing.value = false;
    }
  }

  // Note: Pilots don't add money to wallet - they earn from deliveries
  // Money is automatically credited when deliveries are completed

  /// Refresh all data
  Future<void> refreshAll() async {
    await Future.wait([
      loadWallet(),
      loadTransactions(refresh: true),
    ]);
  }
}
