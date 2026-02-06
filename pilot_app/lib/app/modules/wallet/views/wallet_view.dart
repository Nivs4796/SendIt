import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/wallet_repository.dart';
import '../controllers/wallet_controller.dart';

class WalletView extends GetView<WalletController> {
  const WalletView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Wallet'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.wallet.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.refreshAll,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Balance Card
                _buildBalanceCard(colors),
                const SizedBox(height: 20),

                // Quick Actions
                _buildQuickActions(colors),
                const SizedBox(height: 20),

                // Earnings Summary
                _buildEarningsSummary(colors),
                const SizedBox(height: 20),

                // Transactions
                _buildTransactionsList(colors),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildBalanceCard(AppColorScheme colors) {
    final wallet = controller.wallet.value;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E3A5F),
            const Color(0xFF2E5A8F),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available Balance',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              Icon(
                Icons.account_balance_wallet,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            wallet?.balanceDisplay ?? '₹0.00',
            style: AppTextStyles.displaySmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          if ((wallet?.pendingAmount ?? 0) > 0) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colors.accent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '₹${wallet!.pendingAmount.toStringAsFixed(0)} pending',
                style: AppTextStyles.labelSmall.copyWith(
                  color: colors.accent,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActions(AppColorScheme colors) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            colors,
            icon: Icons.arrow_downward,
            label: 'Withdraw',
            color: colors.success,
            onTap: () => _showWithdrawSheet(colors),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            colors,
            icon: Icons.trending_up,
            label: 'Earnings',
            color: colors.info,
            onTap: () => Get.toNamed('/earnings'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            colors,
            icon: Icons.history,
            label: 'History',
            color: colors.warning,
            onTap: () {
              // Already showing transactions below
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    AppColorScheme colors, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: colors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(label, style: AppTextStyles.labelSmall),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsSummary(AppColorScheme colors) {
    final wallet = controller.wallet.value;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${wallet?.todayEarnings.toStringAsFixed(0) ?? '0'}',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.success,
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 40, color: colors.border),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This Week',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${wallet?.weekEarnings.toStringAsFixed(0) ?? '0'}',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(AppColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Transactions',
          style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Obx(() {
          final transactions = controller.transactions;
          if (transactions.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: colors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 48,
                      color: colors.textHint,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No transactions yet',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              return _buildTransactionItem(colors, transactions[index]);
            },
          );
        }),
      ],
    );
  }

  Widget _buildTransactionItem(AppColorScheme colors, WalletTransaction transaction) {
    final timeFormat = DateFormat('MMM d, h:mm a');
    final isCredit = transaction.isCredit;

    IconData icon;
    Color color;
    switch (transaction.type) {
      case WalletTransactionType.credit:
        icon = Icons.arrow_downward;
        color = colors.success;
        break;
      case WalletTransactionType.bonus:
        icon = Icons.star;
        color = colors.accent;
        break;
      case WalletTransactionType.withdrawal:
        icon = Icons.account_balance;
        color = colors.info;
        break;
      case WalletTransactionType.debit:
        icon = Icons.arrow_upward;
        color = colors.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
                ),
                Row(
                  children: [
                    Text(
                      timeFormat.format(transaction.timestamp),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    if (transaction.status != TransactionStatus.completed) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: colors.warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          transaction.status.name,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: colors.warning,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Text(
            transaction.amountDisplay,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: isCredit ? colors.success : colors.error,
            ),
          ),
        ],
      ),
    );
  }

  void _showWithdrawSheet(AppColorScheme colors) {
    final amountController = TextEditingController();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Withdraw to Bank',
              style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Amount field
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixText: '₹ ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Bank account selection
            Text('Select Bank Account', style: AppTextStyles.labelMedium),
            const SizedBox(height: 8),
            Obx(() {
              final accounts = controller.bankAccounts;
              return Column(
                children: accounts.map((account) {
                  final isSelected = controller.selectedBankAccount.value?.id == account.id;
                  return GestureDetector(
                    onTap: () => controller.selectedBankAccount.value = account,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colors.primary.withValues(alpha: 0.1)
                            : colors.surfaceVariant,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? colors.primary : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.account_balance,
                            color: isSelected ? colors.primary : colors.textPrimary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  account.bankName,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  account.accountNumber,
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (account.isPrimary)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: colors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Primary',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: colors.primary,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            }),
            const SizedBox(height: 20),

            // Withdraw button
            Obx(() => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.isProcessing.value
                    ? null
                    : () async {
                        final amount = double.tryParse(amountController.text) ?? 0;
                        final success = await controller.initiateWithdrawal(amount);
                        if (success) Get.back();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: controller.isProcessing.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text('Withdraw', style: TextStyle(color: colors.textOnPrimary)),
              ),
            )),
            const SizedBox(height: 16),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // Note: Pilots don't add money - they earn from deliveries
  // The Earnings button now navigates to the earnings screen

  Widget _buildPaymentOption(AppColorScheme colors, String label, String value, RxString selected) {
    final isSelected = selected.value == value;
    return GestureDetector(
      onTap: () => selected.value = value,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primary.withValues(alpha: 0.1)
              : colors.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? colors.primary : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? colors.primary : colors.textHint,
            ),
            const SizedBox(width: 12),
            Text(label, style: AppTextStyles.bodyMedium),
          ],
        ),
      ),
    );
  }
}
