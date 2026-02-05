import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/bank_repository.dart';
import '../../../routes/app_routes.dart';

class BankController extends GetxController {
  final BankRepository _repository = BankRepository();

  // State
  final isLoading = true.obs;
  final isProcessing = false.obs;
  final accounts = <BankAccountModel>[].obs;

  // Add bank form
  final formKey = GlobalKey<FormState>();
  final accountHolderController = TextEditingController();
  final accountNumberController = TextEditingController();
  final confirmAccountController = TextEditingController();
  final ifscController = TextEditingController();
  final bankNameController = TextEditingController();
  final branchNameController = TextEditingController();
  final setAsPrimary = false.obs;

  // IFSC lookup
  final isLookingUpIfsc = false.obs;
  final ifscResult = Rxn<IfscResult>();

  @override
  void onInit() {
    super.onInit();
    loadBankAccounts();
  }

  @override
  void onClose() {
    accountHolderController.dispose();
    accountNumberController.dispose();
    confirmAccountController.dispose();
    ifscController.dispose();
    bankNameController.dispose();
    branchNameController.dispose();
    super.onClose();
  }

  /// Load bank accounts
  Future<void> loadBankAccounts() async {
    try {
      isLoading.value = true;
      accounts.value = await _repository.getBankAccounts();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load bank accounts',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Lookup IFSC code
  Future<void> lookupIfsc() async {
    final ifsc = ifscController.text.trim().toUpperCase();
    if (ifsc.length != 11) {
      Get.snackbar(
        'Invalid IFSC',
        'Please enter a valid 11-character IFSC code',
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade900,
      );
      return;
    }

    try {
      isLookingUpIfsc.value = true;
      final result = await _repository.lookupIfsc(ifsc);
      
      if (result != null) {
        ifscResult.value = result;
        bankNameController.text = result.bankName;
        branchNameController.text = result.branchName;
        Get.snackbar(
          'IFSC Found',
          '${result.bankName} - ${result.branchName}',
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
        );
      } else {
        ifscResult.value = null;
        Get.snackbar(
          'IFSC Not Found',
          'Please check the IFSC code and try again',
          backgroundColor: Colors.orange.shade100,
          colorText: Colors.orange.shade900,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Lookup Failed',
        'Could not verify IFSC code',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      isLookingUpIfsc.value = false;
    }
  }

  /// Add new bank account
  Future<void> addBankAccount() async {
    if (!formKey.currentState!.validate()) return;

    // Validate account numbers match
    if (accountNumberController.text != confirmAccountController.text) {
      Get.snackbar(
        'Mismatch',
        'Account numbers do not match',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
    }

    try {
      isProcessing.value = true;

      final newAccount = await _repository.addBankAccount(
        accountHolderName: accountHolderController.text.trim(),
        accountNumber: accountNumberController.text.trim(),
        ifscCode: ifscController.text.trim().toUpperCase(),
        bankName: bankNameController.text.trim(),
        branchName: branchNameController.text.trim().isNotEmpty
            ? branchNameController.text.trim()
            : null,
        setAsPrimary: setAsPrimary.value,
      );

      // Update local list
      if (setAsPrimary.value) {
        // Mark all others as non-primary
        for (var i = 0; i < accounts.length; i++) {
          if (accounts[i].isPrimary) {
            accounts[i] = BankAccountModel(
              id: accounts[i].id,
              accountHolderName: accounts[i].accountHolderName,
              accountNumber: accounts[i].accountNumber,
              ifscCode: accounts[i].ifscCode,
              bankName: accounts[i].bankName,
              branchName: accounts[i].branchName,
              isPrimary: false,
              createdAt: accounts[i].createdAt,
            );
          }
        }
      }
      accounts.add(newAccount);

      // Clear form
      _clearForm();

      Get.back();
      Get.snackbar(
        'Success',
        'Bank account added successfully',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
      );
    } catch (e) {
      Get.snackbar(
        'Failed',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  /// Set account as primary
  Future<void> setPrimaryAccount(BankAccountModel account) async {
    if (account.isPrimary) return;

    try {
      isProcessing.value = true;
      await _repository.setPrimaryAccount(account.id);

      // Update local list
      for (var i = 0; i < accounts.length; i++) {
        final current = accounts[i];
        accounts[i] = BankAccountModel(
          id: current.id,
          accountHolderName: current.accountHolderName,
          accountNumber: current.accountNumber,
          ifscCode: current.ifscCode,
          bankName: current.bankName,
          branchName: current.branchName,
          isPrimary: current.id == account.id,
          createdAt: current.createdAt,
        );
      }

      Get.snackbar(
        'Primary Account Updated',
        '${account.bankName} is now your primary account',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
      );
    } catch (e) {
      Get.snackbar(
        'Failed',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  /// Delete bank account
  Future<void> deleteAccount(BankAccountModel account) async {
    if (account.isPrimary) {
      Get.snackbar(
        'Cannot Delete',
        'You cannot delete your primary account',
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade900,
      );
      return;
    }

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Bank Account'),
        content: Text(
          'Are you sure you want to delete ${account.bankName} (${account.maskedAccountNumber})?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      isProcessing.value = true;
      await _repository.deleteBankAccount(account.id);
      accounts.removeWhere((a) => a.id == account.id);

      Get.snackbar(
        'Deleted',
        'Bank account deleted successfully',
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade900,
      );
    } catch (e) {
      Get.snackbar(
        'Delete Failed',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  /// Navigate to add bank screen
  void goToAddBank() {
    _clearForm();
    Get.toNamed(Routes.bankDetails + '/add');
  }

  /// Clear form fields
  void _clearForm() {
    accountHolderController.clear();
    accountNumberController.clear();
    confirmAccountController.clear();
    ifscController.clear();
    bankNameController.clear();
    branchNameController.clear();
    setAsPrimary.value = false;
    ifscResult.value = null;
  }

  /// Refresh accounts
  Future<void> refresh() => loadBankAccounts();

  /// Get primary account
  BankAccountModel? get primaryAccount =>
      accounts.firstWhereOrNull((a) => a.isPrimary);
}
