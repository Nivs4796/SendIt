import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import '../controllers/registration_controller.dart';

class BankDetailsStep extends GetView<RegistrationController> {
  const BankDetailsStep({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildSectionHeader(
            theme,
            icon: Icons.account_balance_rounded,
            title: 'Bank Details',
            subtitle: 'Where should we send your earnings?',
          ),

          const SizedBox(height: 16),

          // Earnings Info Card
          _buildEarningsInfoCard(theme),

          const SizedBox(height: 20),

          // Account Details Section
          Text(
            'Account Information',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 16),

          _buildFormCard(
            theme,
            children: [
              // Account Holder Name
              AppTextField(
                controller: controller.accountHolderController,
                label: 'Account Holder Name',
                hint: 'Name as per bank records',
                prefixIcon: const Icon(Icons.person_outline_rounded),
                textCapitalization: TextCapitalization.words,
              ),

              const SizedBox(height: 20),

              // Bank Name
              AppTextField(
                controller: controller.bankNameController,
                label: 'Bank Name',
                hint: 'e.g., State Bank of India',
                prefixIcon: const Icon(Icons.account_balance_outlined),
              ),

              const SizedBox(height: 20),

              // Account Number
              AppTextField(
                controller: controller.accountNumberController,
                label: 'Account Number',
                hint: 'Enter your account number',
                prefixIcon: const Icon(Icons.numbers_rounded),
                type: AppTextFieldType.number,
                obscureText: true,
              ),

              const SizedBox(height: 20),

              // Confirm Account Number
              AppTextField(
                controller: controller.confirmAccountNumberController,
                label: 'Confirm Account Number',
                hint: 'Re-enter to confirm',
                prefixIcon: const Icon(Icons.check_circle_outline_rounded),
                type: AppTextFieldType.number,
              ),

              const SizedBox(height: 20),

              // IFSC Code
              AppTextField(
                controller: controller.ifscController,
                label: 'IFSC Code',
                hint: 'e.g., SBIN0001234',
                prefixIcon: const Icon(Icons.qr_code_rounded),
                textCapitalization: TextCapitalization.characters,
                maxLength: 11,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Supporting Document
          Text(
            'Supporting Document',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Optional but helps verify your account faster',
            style: AppTextStyles.bodySmall.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 16),

          _buildDocumentUpload(context, theme),

          const SizedBox(height: 16),

          // Security Note
          _buildSecurityNote(theme),

          const SizedBox(height: 20),

          // Final Step Note
          _buildFinalStepNote(theme),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.h4.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard(ThemeData theme, {required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildEarningsInfoCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.success.withValues(alpha: 0.15),
            AppColors.success.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.monetization_on_rounded,
              color: AppColors.success,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weekly Payouts',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your earnings will be transferred directly to this account every week',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentUpload(BuildContext context, ThemeData theme) {
    return Obx(() {
      final isUploaded = controller.cancelledChequeFile.value != null;
      
      return GestureDetector(
        onTap: () => _showImagePicker(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isUploaded
                ? AppColors.success.withValues(alpha: 0.05)
                : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isUploaded
                  ? AppColors.success.withValues(alpha: 0.5)
                  : theme.colorScheme.outline.withValues(alpha: 0.2),
              width: isUploaded ? 2 : 1,
              style: isUploaded ? BorderStyle.solid : BorderStyle.solid,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isUploaded
                      ? AppColors.success.withValues(alpha: 0.15)
                      : AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isUploaded ? Icons.check_circle_rounded : Icons.receipt_long_rounded,
                  color: isUploaded ? AppColors.success : AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cancelled Cheque / Passbook',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isUploaded
                          ? '✓ Document uploaded'
                          : 'Front page showing account details',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isUploaded
                            ? AppColors.success
                            : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        fontWeight: isUploaded ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isUploaded
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isUploaded ? Icons.edit_rounded : Icons.add_rounded,
                  color: isUploaded ? AppColors.success : AppColors.primary,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSecurityNote(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_rounded,
              color: Colors.blue.shade600,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '256-bit Encryption',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your bank details are encrypted and stored securely',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.blue.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalStepNote(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.celebration_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Almost Done!',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'This is the final step. Review your information and submit your application.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showImagePicker(BuildContext context) {
    final theme = Theme.of(context);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Upload Bank Document',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Cancelled cheque or passbook front page',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildPickerOption(
                      theme,
                      icon: Icons.camera_alt_rounded,
                      label: 'Camera',
                      onTap: () {
                        Get.back();
                        controller.pickImage(type: 'cancelled_cheque', source: ImageSource.camera);
                      },
                    ),
                    _buildPickerOption(
                      theme,
                      icon: Icons.photo_library_rounded,
                      label: 'Gallery',
                      onTap: () {
                        Get.back();
                        controller.pickImage(type: 'cancelled_cheque', source: ImageSource.gallery);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPickerOption(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 32,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
