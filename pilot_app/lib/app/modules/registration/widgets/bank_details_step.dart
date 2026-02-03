import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import '../controllers/registration_controller.dart';

class BankDetailsStep extends GetView<RegistrationController> {
  const BankDetailsStep({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bank Details',
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your bank account for earnings withdrawal',
            style: AppTextStyles.bodyMedium.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),

          // Account Holder Name
          AppTextField(
            controller: controller.accountHolderController,
            label: 'Account Holder Name',
            hint: 'Name as per bank account',
            prefixIcon: Icon(Icons.person_outline),
            textCapitalization: TextCapitalization.words,
          ),

          const SizedBox(height: 16),

          // Bank Name
          AppTextField(
            controller: controller.bankNameController,
            label: 'Bank Name',
            hint: 'e.g., State Bank of India',
            prefixIcon: Icon(Icons.account_balance_outlined),
          ),

          const SizedBox(height: 16),

          // Account Number
          AppTextField(
            controller: controller.accountNumberController,
            label: 'Account Number',
            hint: 'Enter account number',
            prefixIcon: Icon(Icons.credit_card_outlined),
            type: AppTextFieldType.number,
            obscureText: true,
          ),

          const SizedBox(height: 16),

          // Confirm Account Number
          AppTextField(
            controller: controller.confirmAccountNumberController,
            label: 'Confirm Account Number',
            hint: 'Re-enter account number',
            prefixIcon: Icon(Icons.credit_card_outlined),
            type: AppTextFieldType.number,
          ),

          const SizedBox(height: 16),

          // IFSC Code
          AppTextField(
            controller: controller.ifscController,
            label: 'IFSC Code',
            hint: 'e.g., SBIN0001234',
            prefixIcon: Icon(Icons.code_outlined),
            textCapitalization: TextCapitalization.characters,
          ),

          const SizedBox(height: 24),

          // Cancelled Cheque Upload
          Text(
            'Cancelled Cheque / Passbook (Optional)',
            style: AppTextStyles.labelLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Obx(() => GestureDetector(
            onTap: () => _showImagePicker(context),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                border: Border.all(
                  color: controller.cancelledChequeFile.value != null
                      ? AppColors.primary
                      : theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: controller.cancelledChequeFile.value != null
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                    child: Icon(
                      controller.cancelledChequeFile.value != null
                          ? Icons.check_circle
                          : Icons.upload_file,
                      color: controller.cancelledChequeFile.value != null
                          ? AppColors.primary
                          : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Upload Document',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          controller.cancelledChequeFile.value != null
                              ? 'Uploaded'
                              : 'Cancelled cheque or passbook front page',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: controller.cancelledChequeFile.value != null
                                ? AppColors.primary
                                : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ],
              ),
            ),
          )),

          const SizedBox(height: 24),

          // Security Note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.security,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your bank details are encrypted and secure',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showImagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Get.back();
                controller.pickImage(type: 'cancelled_cheque', source: ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Get.back();
                controller.pickImage(type: 'cancelled_cheque', source: ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}
