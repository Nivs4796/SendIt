import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/wallet_repository.dart';
import '../controllers/wallet_controller.dart';

class WithdrawView extends GetView<WalletController> {
  const WithdrawView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);
    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Withdraw'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final balance = controller.wallet.value?.balance ?? 0;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Available Balance Card
                _buildBalanceCard(colors, balance),
                const SizedBox(height: 24),

                // Amount Input
                Text(
                  'Enter Amount',
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildAmountInput(colors, amountController, balance, formKey),
                const SizedBox(height: 16),

                // Quick Amount Chips
                _buildQuickAmounts(colors, amountController, balance),
                const SizedBox(height: 24),

                // Bank Account Selection
                Text(
                  'Select Bank Account',
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildBankAccounts(colors),
                const SizedBox(height: 24),

                // Withdrawal Info
                _buildWithdrawalInfo(colors),
                const SizedBox(height: 24),

                // Withdraw Button
                _buildWithdrawButton(colors, amountController, formKey),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildBalanceCard(AppColorScheme colors, double balance) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.success,
            colors.primaryDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.account_balance_wallet,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available Balance',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${balance.toStringAsFixed(2)}',
                  style: AppTextStyles.displaySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountInput(
    AppColorScheme colors,
    TextEditingController amountController,
    double balance,
    GlobalKey<FormState> formKey,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: TextFormField(
        controller: amountController,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: AppTextStyles.displaySmall.copyWith(
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          prefixText: '₹ ',
          prefixStyle: AppTextStyles.displaySmall.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.primary,
          ),
          hintText: '0',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: colors.surfaceVariant,
          contentPadding: const EdgeInsets.all(20),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Enter amount';
          }
          final amount = double.tryParse(value) ?? 0;
          if (amount < 100) {
            return 'Minimum withdrawal is ₹100';
          }
          if (amount > balance) {
            return 'Insufficient balance';
          }
          if (amount > 50000) {
            return 'Maximum withdrawal is ₹50,000';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildQuickAmounts(
    AppColorScheme colors,
    TextEditingController amountController,
    double balance,
  ) {
    final amounts = [500, 1000, 2000, 5000];
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: amounts.map((amount) {
        final isDisabled = amount > balance;
        return GestureDetector(
          onTap: isDisabled
              ? null
              : () => amountController.text = amount.toString(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isDisabled
                  ? colors.surfaceVariant.withValues(alpha: 0.5)
                  : colors.surfaceVariant,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDisabled
                    ? Colors.transparent
                    : colors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              '₹$amount',
              style: AppTextStyles.labelMedium.copyWith(
                color: isDisabled
                    ? colors.textHint
                    : colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBankAccounts(AppColorScheme colors) {
    return Obx(() {
      final accounts = controller.bankAccounts;

      if (accounts.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colors.warning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(
              color: colors.warning.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.account_balance_outlined,
                size: 40,
                color: colors.warning,
              ),
              const SizedBox(height: 12),
              Text(
                'No Bank Account Added',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.warning,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Add a bank account to withdraw your earnings',
                style: AppTextStyles.labelSmall.copyWith(
                  color: colors.warning,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () => Get.toNamed('/profile/bank'),
                icon: const Icon(Icons.add),
                label: const Text('Add Bank Account'),
                style: TextButton.styleFrom(
                  foregroundColor: colors.warning,
                ),
              ),
            ],
          ),
        );
      }

      return Column(
        children: accounts.map((account) {
          final isSelected = controller.selectedBankAccount.value?.id == account.id;
          return GestureDetector(
            onTap: () => controller.selectedBankAccount.value = account,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? colors.primary.withValues(alpha: 0.1)
                    : colors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                border: Border.all(
                  color: isSelected
                      ? colors.primary
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: colors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.account_balance,
                      color: colors.info,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                account.bankName,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (account.isPrimary)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'PRIMARY',
                                  style: AppTextStyles.caption.copyWith(
                                    color: colors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 9,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Text(
                          account.accountNumber,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: colors.textSecondary,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Radio<String>(
                    value: account.id,
                    groupValue: controller.selectedBankAccount.value?.id,
                    onChanged: (value) {
                      controller.selectedBankAccount.value = account;
                    },
                    activeColor: colors.primary,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildWithdrawalInfo(AppColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.info.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: colors.info.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: colors.info),
              const SizedBox(width: 8),
              Text(
                'Withdrawal Information',
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Minimum withdrawal', '₹100'),
          _buildInfoRow('Maximum withdrawal', '₹50,000'),
          _buildInfoRow('Processing time', '1-2 business days'),
          _buildInfoRow('Withdrawal fee', 'Free'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColorScheme.of(Get.context!).info,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColorScheme.of(Get.context!).info,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawButton(
    AppColorScheme colors,
    TextEditingController amountController,
    GlobalKey<FormState> formKey,
  ) {
    return Obx(() {
      final hasAccount = controller.selectedBankAccount.value != null;
      final isProcessing = controller.isProcessing.value;

      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isProcessing || !hasAccount
              ? null
              : () async {
                  if (formKey.currentState!.validate()) {
                    final amount = double.tryParse(amountController.text) ?? 0;
                    final success = await controller.initiateWithdrawal(amount);
                    if (success) {
                      Get.back();
                    }
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primary,
            foregroundColor: colors.textOnPrimary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            disabledBackgroundColor: colors.textDisabled,
          ),
          child: isProcessing
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  hasAccount ? 'Withdraw' : 'Add Bank Account First',
                  style: AppTextStyles.button.copyWith(
                    fontSize: 16,
                  ),
                ),
        ),
      );
    });
  }
}
