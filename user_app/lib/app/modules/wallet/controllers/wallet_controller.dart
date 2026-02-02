import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/wallet_model.dart';
import '../../../data/repositories/wallet_repository.dart';
import '../../../data/providers/api_exceptions.dart';

class WalletController extends GetxController {
  final WalletRepository _walletRepository = WalletRepository();

  // Observable state
  final balance = 0.0.obs;
  final transactions = <WalletTransactionModel>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final isAddingMoney = false.obs;
  final errorMessage = ''.obs;

  // Pagination
  final currentPage = 1.obs;
  final hasMorePages = true.obs;
  static const int _pageLimit = 10;

  // Summary
  final totalCredits = 0.0.obs;
  final totalDebits = 0.0.obs;

  // Filter: null = all, 'CREDIT', 'DEBIT'
  final selectedFilter = Rx<String?>(null);

  // Add money form
  late TextEditingController amountController;
  final List<int> predefinedAmounts = [100, 200, 500, 1000, 2000, 5000];

  // Getters for formatted display
  String get balanceDisplay => _formatCurrency(balance.value);
  String get totalCreditsDisplay => _formatCurrency(totalCredits.value);
  String get totalDebitsDisplay => _formatCurrency(totalDebits.value);

  String _formatCurrency(double amount) {
    return '\u20B9${amount.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}';
  }

  @override
  void onInit() {
    super.onInit();
    amountController = TextEditingController();
    refreshAll();
  }

  @override
  void onClose() {
    amountController.dispose();
    super.onClose();
  }

  /// Fetch current wallet balance
  Future<void> fetchBalance() async {
    try {
      final response = await _walletRepository.getBalance();

      if (response.success && response.data != null) {
        balance.value = response.data!;
      } else {
        errorMessage.value = response.message ?? 'Failed to fetch balance';
      }
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } on NetworkException {
      errorMessage.value = 'No internet connection';
    } catch (e) {
      errorMessage.value = 'Something went wrong';
    }
  }

  /// Fetch transactions with pagination
  /// If refresh is true, resets to page 1 and clears existing list
  Future<void> fetchTransactions({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      hasMorePages.value = true;
      transactions.clear();
    }

    if (!hasMorePages.value) return;

    try {
      if (refresh || transactions.isEmpty) {
        isLoading.value = true;
      } else {
        isLoadingMore.value = true;
      }
      errorMessage.value = '';

      final response = await _walletRepository.getTransactions(
        page: currentPage.value,
        limit: _pageLimit,
        type: selectedFilter.value,
      );

      if (response.success && response.data != null) {
        final newTransactions =
            response.data!['transactions'] as List<WalletTransactionModel>;
        final summary = response.data!['summary'] as Map<String, dynamic>;

        if (refresh || currentPage.value == 1) {
          transactions.value = newTransactions;
        } else {
          transactions.addAll(newTransactions);
        }

        // Update summary
        totalCredits.value = summary['totalCredits'] ?? 0.0;
        totalDebits.value = summary['totalDebits'] ?? 0.0;

        // Check if there are more pages
        if (response.meta != null) {
          hasMorePages.value = currentPage.value < response.meta!.totalPages;
          if (hasMorePages.value) {
            currentPage.value++;
          }
        } else {
          hasMorePages.value = newTransactions.length >= _pageLimit;
          if (hasMorePages.value) {
            currentPage.value++;
          }
        }
      } else {
        errorMessage.value =
            response.message ?? 'Failed to fetch transactions';
      }
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } on NetworkException {
      errorMessage.value = 'No internet connection';
    } catch (e) {
      errorMessage.value = 'Something went wrong';
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  /// Set transaction filter and refresh list
  void setFilter(String? filter) {
    if (selectedFilter.value != filter) {
      selectedFilter.value = filter;
      fetchTransactions(refresh: true);
    }
  }

  /// Select a predefined amount for add money
  void selectPredefinedAmount(int amount) {
    amountController.text = amount.toString();
  }

  /// Add money to wallet
  Future<void> addMoney() async {
    final amountText = amountController.text.trim();

    if (amountText.isEmpty) {
      errorMessage.value = 'Please enter an amount';
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null) {
      errorMessage.value = 'Please enter a valid amount';
      return;
    }

    if (amount < 1) {
      errorMessage.value = 'Minimum amount is \u20B91';
      return;
    }

    if (amount > 100000) {
      errorMessage.value = 'Maximum amount is \u20B91,00,000';
      return;
    }

    try {
      isAddingMoney.value = true;
      errorMessage.value = '';

      final response = await _walletRepository.addMoney(amount);

      if (response.success && response.data != null) {
        // Update balance from response
        balance.value = response.data!['balance'] as double;

        // Clear form
        amountController.clear();

        // Close bottom sheet
        Get.back();

        // Show success message
        Get.snackbar(
          'Success',
          'Money added to wallet successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Refresh transactions to show the new one
        fetchTransactions(refresh: true);
      } else {
        errorMessage.value = response.message ?? 'Failed to add money';
      }
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } on NetworkException {
      errorMessage.value = 'No internet connection';
    } catch (e) {
      errorMessage.value = 'Something went wrong';
    } finally {
      isAddingMoney.value = false;
    }
  }

  /// Refresh both balance and transactions
  Future<void> refreshAll() async {
    isLoading.value = true;
    errorMessage.value = '';

    await Future.wait([
      fetchBalance(),
      fetchTransactions(refresh: true),
    ]);

    isLoading.value = false;
  }

  /// Clear error message
  void clearError() {
    errorMessage.value = '';
  }
}
