import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/bank_repository.dart';
import '../controllers/bank_controller.dart';

class BankDetailsView extends GetView<BankController> {
  const BankDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Bank Accounts'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.accounts.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                _buildHeaderCard(theme),
                const SizedBox(height: 20),

                // Bank Accounts List
                _buildAccountsList(theme),
              ],
            ),
          ),
        );
      }),
      // Add Bank FAB
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddBankSheet(context, theme),
        icon: const Icon(Icons.add),
        label: const Text('Add Bank'),
      ),
    );
  }

  Widget _buildHeaderCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.indigo,
            Colors.indigo.shade700,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.account_balance,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Bank Accounts',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Manage accounts for withdrawals',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            final primary = controller.primaryAccount;
            if (primary == null) {
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.amber.shade200,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Add a bank account to withdraw your earnings',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Colors.amber.shade200,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Colors.greenAccent,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Primary: ${primary.bankName} (${primary.maskedAccountNumber})',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAccountsList(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Saved Accounts',
          style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Obx(() {
          final accounts = controller.accounts;
          if (accounts.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.account_balance_outlined,
                      size: 48,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No bank accounts added',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Add a bank account to start withdrawing',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
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
            itemCount: accounts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _buildAccountCard(theme, accounts[index]);
            },
          );
        }),
      ],
    );
  }

  Widget _buildAccountCard(ThemeData theme, BankAccountModel account) {
    final dateFormat = DateFormat('dd MMM yyyy');

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: account.isPrimary
            ? Border.all(color: AppColors.primary.withValues(alpha: 0.5), width: 1.5)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showAccountOptions(theme, account),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Bank Icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.indigo.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.account_balance,
                          color: Colors.indigo,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Bank Info
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
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'PRIMARY',
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 9,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            account.maskedAccountNumber,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Options
                    IconButton(
                      icon: Icon(
                        Icons.more_vert,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      onPressed: () => _showAccountOptions(theme, account),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Details Row
                Row(
                  children: [
                    _buildDetailChip(
                      theme,
                      Icons.person_outline,
                      account.accountHolderName,
                    ),
                    const SizedBox(width: 8),
                    _buildDetailChip(
                      theme,
                      Icons.code,
                      account.ifscCode,
                    ),
                  ],
                ),

                if (account.branchName != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        account.branchName!,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ],

                if (account.createdAt != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Added on ${dateFormat.format(account.createdAt!)}',
                    style: AppTextStyles.caption.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailChip(ThemeData theme, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTextStyles.caption.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  void _showAccountOptions(ThemeData theme, BankAccountModel account) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Account Header
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.indigo.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.account_balance,
                    color: Colors.indigo,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account.bankName,
                        style: AppTextStyles.titleSmall.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        account.maskedAccountNumber,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Options
            if (!account.isPrimary)
              _buildOptionTile(
                theme,
                icon: Icons.star_outline,
                title: 'Set as Primary',
                subtitle: 'Use this account for withdrawals',
                onTap: () {
                  Get.back();
                  controller.setPrimaryAccount(account);
                },
              ),
            _buildOptionTile(
              theme,
              icon: Icons.delete_outline,
              title: 'Delete Account',
              subtitle: account.isPrimary
                  ? 'Cannot delete primary account'
                  : 'Remove this bank account',
              isDestructive: true,
              isDisabled: account.isPrimary,
              onTap: account.isPrimary
                  ? null
                  : () {
                      Get.back();
                      controller.deleteAccount(account);
                    },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    bool isDestructive = false,
    bool isDisabled = false,
  }) {
    final color = isDisabled
        ? theme.colorScheme.onSurface.withValues(alpha: 0.3)
        : isDestructive
            ? Colors.red
            : theme.colorScheme.onSurface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                        color: color,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: color.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: color.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddBankSheet(BuildContext context, ThemeData theme) {
    // Clear form
    controller.accountHolderController.clear();
    controller.accountNumberController.clear();
    controller.confirmAccountController.clear();
    controller.ifscController.clear();
    controller.bankNameController.clear();
    controller.branchNameController.clear();
    controller.setAsPrimary.value = controller.accounts.isEmpty;
    controller.ifscResult.value = null;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Form(
          key: controller.formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  'Add Bank Account',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your bank account details for withdrawals',
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: 24),

                // Account Holder Name
                TextFormField(
                  controller: controller.accountHolderController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Account Holder Name',
                    hintText: 'As per bank records',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter account holder name' : null,
                ),
                const SizedBox(height: 16),

                // Account Number
                TextFormField(
                  controller: controller.accountNumberController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Account Number',
                    hintText: 'Enter account number',
                    prefixIcon: const Icon(Icons.numbers),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter account number';
                    if (v.length < 9) return 'Invalid account number';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Confirm Account Number
                TextFormField(
                  controller: controller.confirmAccountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Confirm Account Number',
                    hintText: 'Re-enter account number',
                    prefixIcon: const Icon(Icons.numbers),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Confirm account number';
                    if (v != controller.accountNumberController.text) {
                      return 'Account numbers do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // IFSC Code with Lookup
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: controller.ifscController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          labelText: 'IFSC Code',
                          hintText: 'e.g., HDFC0001234',
                          prefixIcon: const Icon(Icons.code),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Enter IFSC code';
                          if (v.length != 11) return 'Invalid IFSC code';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Obx(() => SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: controller.isLookingUpIfsc.value
                                ? null
                                : controller.lookupIfsc,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: controller.isLookingUpIfsc.value
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.search),
                          ),
                        )),
                  ],
                ),
                const SizedBox(height: 16),

                // Bank Name (auto-filled from IFSC)
                TextFormField(
                  controller: controller.bankNameController,
                  decoration: InputDecoration(
                    labelText: 'Bank Name',
                    hintText: 'Will be auto-filled from IFSC',
                    prefixIcon: const Icon(Icons.account_balance),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter bank name' : null,
                ),
                const SizedBox(height: 16),

                // Branch Name (optional)
                TextFormField(
                  controller: controller.branchNameController,
                  decoration: InputDecoration(
                    labelText: 'Branch Name (Optional)',
                    hintText: 'Will be auto-filled from IFSC',
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Set as Primary
                Obx(() => CheckboxListTile(
                      value: controller.setAsPrimary.value,
                      onChanged: (v) => controller.setAsPrimary.value = v ?? false,
                      title: const Text('Set as primary account'),
                      subtitle: const Text(
                        'This account will be used for withdrawals',
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      activeColor: AppColors.primary,
                    )),
                const SizedBox(height: 24),

                // Add Button
                Obx(() => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: controller.isProcessing.value
                            ? null
                            : controller.addBankAccount,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
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
                            : const Text('Add Bank Account'),
                      ),
                    )),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
