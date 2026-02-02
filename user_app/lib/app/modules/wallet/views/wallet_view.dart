import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/wallet_model.dart';
import '../controllers/wallet_controller.dart';

class WalletView extends GetView<WalletController> {
  const WalletView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: controller.refreshAll,
        child: CustomScrollView(
          slivers: [
            // App Bar
            const SliverAppBar(
              title: Text('Wallet'),
              centerTitle: true,
              backgroundColor: AppColors.white,
              elevation: 0,
              pinned: true,
              surfaceTintColor: AppColors.white,
            ),

            // Balance Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildBalanceCard(),
              ),
            ),

            // Filter Chips
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildFilterChips(),
              ),
            ),

            // Transaction History Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Text(
                  'Transaction History',
                  style: AppTextStyles.h4,
                ),
              ),
            ),

            // Transaction List
            Obx(() => _buildTransactionList()),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Wallet Balance',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Obx(() => Text(
                controller.balanceDisplay,
                style: AppTextStyles.h1.copyWith(
                  color: AppColors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              )),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showAddMoneySheet(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.white,
                foregroundColor: AppColors.primary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_circle_outline_rounded, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Add Money',
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.primary,
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

  Widget _buildFilterChips() {
    return Obx(() {
      final selectedFilter = controller.selectedFilter.value;

      return Row(
        children: [
          _FilterChip(
            label: 'All',
            isSelected: selectedFilter == null,
            onTap: () => controller.setFilter(null),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Credit',
            isSelected: selectedFilter == 'CREDIT',
            onTap: () => controller.setFilter('CREDIT'),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Debit',
            isSelected: selectedFilter == 'DEBIT',
            onTap: () => controller.setFilter('DEBIT'),
          ),
        ],
      );
    });
  }

  Widget _buildTransactionList() {
    if (controller.isLoading.value && controller.transactions.isEmpty) {
      return const SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    }

    if (controller.transactions.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.receipt_long_rounded,
                size: 64,
                color: AppColors.textHint,
              ),
              const SizedBox(height: 16),
              Text(
                'No transactions yet',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add money to your wallet to get started',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          // Show load more indicator at the end
          if (index == controller.transactions.length) {
            if (controller.hasMorePages.value) {
              // Trigger load more
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!controller.isLoadingMore.value) {
                  controller.fetchTransactions();
                }
              });

              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }

          final transaction = controller.transactions[index];
          return Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              index == 0 ? 0 : 8,
              16,
              index == controller.transactions.length - 1 ? 24 : 8,
            ),
            child: _TransactionTile(transaction: transaction),
          );
        },
        childCount: controller.transactions.length + 1,
      ),
    );
  }

  void _showAddMoneySheet() {
    // Clear any previous input
    controller.amountController.clear();
    controller.clearError();

    Get.bottomSheet(
      _AddMoneySheet(controller: controller),
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: isSelected ? AppColors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final WalletTransactionModel transaction;

  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.isCredit;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Leading Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isCredit
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
              color: isCredit ? AppColors.success : AppColors.error,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),

          // Title and Date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getTransactionTitle(),
                  style: AppTextStyles.labelLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(transaction.createdAt),
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),

          // Amount and Status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                transaction.amountDisplay,
                style: AppTextStyles.labelLarge.copyWith(
                  color: isCredit ? AppColors.success : AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              _buildStatusBadge(),
            ],
          ),
        ],
      ),
    );
  }

  String _getTransactionTitle() {
    if (transaction.description != null && transaction.description!.isNotEmpty) {
      return transaction.description!;
    }

    switch (transaction.referenceType?.toUpperCase()) {
      case 'TOPUP':
        return 'Wallet Top-up';
      case 'BOOKING':
        return 'Booking Payment';
      case 'REFUND':
        return 'Refund';
      case 'BONUS':
        return 'Bonus Credit';
      default:
        return transaction.isCredit ? 'Credit' : 'Payment';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final transactionDate = DateTime(date.year, date.month, date.day);

    if (transactionDate == today) {
      return 'Today';
    } else if (transactionDate == yesterday) {
      return 'Yesterday';
    } else {
      final difference = today.difference(transactionDate).inDays;
      if (difference < 7) {
        return '$difference days ago';
      }
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  }

  Widget _buildStatusBadge() {
    Color backgroundColor;
    Color textColor;
    String statusText;

    switch (transaction.status) {
      case WalletTxnStatus.pending:
        backgroundColor = AppColors.warningLight;
        textColor = AppColors.warningDark;
        statusText = 'Pending';
        break;
      case WalletTxnStatus.completed:
        backgroundColor = AppColors.successLight;
        textColor = AppColors.successDark;
        statusText = 'Completed';
        break;
      case WalletTxnStatus.failed:
        backgroundColor = AppColors.errorLight;
        textColor = AppColors.errorDark;
        statusText = 'Failed';
        break;
      case WalletTxnStatus.reversed:
        backgroundColor = AppColors.infoLight;
        textColor = AppColors.infoDark;
        statusText = 'Reversed';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        statusText,
        style: AppTextStyles.labelSmall.copyWith(
          color: textColor,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _AddMoneySheet extends StatelessWidget {
  final WalletController controller;

  const _AddMoneySheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              'Add Money to Wallet',
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: 8),
            Text(
              'Enter amount or select a quick option',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 24),

            // Amount Input with currency prefix
            AppCurrencyField.inr(
              controller: controller.amountController,
              label: 'Amount',
              hint: 'Enter amount',
              minValue: 1,
              maxValue: 100000,
            ),
            const SizedBox(height: 16),

            // Predefined Amounts
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.predefinedAmounts.map((amount) {
                return GestureDetector(
                  onTap: () => controller.selectPredefinedAmount(amount),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      '\u20B9$amount',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Info Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.infoLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.info.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.info,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This is a simulated payment. Money will be added to your wallet instantly.',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.infoDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Error Message
            Obx(() {
              if (controller.errorMessage.value.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.errorLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: AppColors.error,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            controller.errorMessage.value,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),

            // Add Money Button
            Obx(() => AppButton.primary(
                  text: 'Add Money',
                  isLoading: controller.isAddingMoney.value,
                  onPressed: controller.addMoney,
                  icon: Icons.account_balance_wallet_outlined,
                )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
