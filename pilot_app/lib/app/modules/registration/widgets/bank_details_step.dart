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
    final colors = AppColorScheme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.spacingLg,
        vertical: AppTheme.spacingSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppTheme.spacingSm),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Icon(Icons.account_balance_rounded, color: colors.primary, size: 18),
              ),
              SizedBox(width: AppTheme.spacingSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bank Details', style: AppTextStyles.h4),
                    Text('For your earnings payout', style: AppTextStyles.caption),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: AppTheme.spacingMd),

          // Earnings Info
          _buildEarningsInfo(colors),

          SizedBox(height: AppTheme.spacingMd),

          // Form
          AppTextField(
            controller: controller.accountHolderController,
            label: 'Account Holder Name',
            hint: 'Name as per bank',
            prefixIcon: const Icon(Icons.person_outline),
            textCapitalization: TextCapitalization.words,
          ),

          SizedBox(height: AppTheme.spacingSm),

          AppTextField(
            controller: controller.bankNameController,
            label: 'Bank Name',
            hint: 'e.g., State Bank of India',
            prefixIcon: const Icon(Icons.account_balance_outlined),
          ),

          SizedBox(height: AppTheme.spacingSm),

          AppTextField(
            controller: controller.accountNumberController,
            label: 'Account Number',
            hint: 'Enter account number',
            prefixIcon: const Icon(Icons.numbers),
            type: AppTextFieldType.number,
            obscureText: true,
          ),

          SizedBox(height: AppTheme.spacingSm),

          AppTextField(
            controller: controller.confirmAccountNumberController,
            label: 'Confirm Account Number',
            hint: 'Re-enter to confirm',
            prefixIcon: const Icon(Icons.check_circle_outline),
            type: AppTextFieldType.number,
          ),

          SizedBox(height: AppTheme.spacingSm),

          AppTextField(
            controller: controller.ifscController,
            label: 'IFSC Code',
            hint: 'e.g., SBIN0001234',
            prefixIcon: const Icon(Icons.qr_code),
            textCapitalization: TextCapitalization.characters,
            maxLength: 11,
          ),

          SizedBox(height: AppTheme.spacingMd),

          // Optional Document
          Text('Optional Document', style: AppTextStyles.labelLarge),
          SizedBox(height: AppTheme.spacingSm),

          _buildDocUpload(context, colors),

          SizedBox(height: AppTheme.spacingMd),

          // Security Note
          _buildSecurityNote(colors),

          SizedBox(height: AppTheme.spacingSm),

          // Final Note
          _buildFinalNote(colors),

          SizedBox(height: AppTheme.spacingMd),
        ],
      ),
    );
  }

  Widget _buildEarningsInfo(AppColorScheme colors) {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacingSm),
      decoration: BoxDecoration(
        color: colors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: colors.success.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.monetization_on_rounded, color: colors.success, size: 20),
          SizedBox(width: AppTheme.spacingSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weekly Payouts',
                  style: AppTextStyles.labelLarge.copyWith(color: colors.success),
                ),
                Text(
                  'Earnings transferred every week',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocUpload(BuildContext context, AppColorScheme colors) {
    return Obx(() {
      final isUploaded = controller.cancelledChequeFile.value != null;

      return GestureDetector(
        onTap: () => _showPicker(context),
        child: Container(
          padding: EdgeInsets.all(AppTheme.spacingSm),
          decoration: BoxDecoration(
            color: isUploaded
                ? colors.success.withValues(alpha: 0.05)
                : colors.surfaceVariant.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(
              color: isUploaded
                  ? colors.success.withValues(alpha: 0.5)
                  : colors.border.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isUploaded
                      ? colors.success.withValues(alpha: 0.15)
                      : colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Icon(
                  isUploaded ? Icons.check_circle_rounded : Icons.receipt_long_rounded,
                  color: isUploaded ? colors.success : colors.primary,
                  size: 18,
                ),
              ),
              SizedBox(width: AppTheme.spacingSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cancelled Cheque / Passbook', style: AppTextStyles.labelLarge),
                    Text(
                      isUploaded ? '✓ Uploaded' : 'Helps verify faster',
                      style: AppTextStyles.caption.copyWith(
                        color: isUploaded ? colors.success : null,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isUploaded ? Icons.edit_rounded : Icons.add_rounded,
                color: isUploaded ? colors.success : colors.primary,
                size: 18,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSecurityNote(AppColorScheme colors) {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacingSm),
      decoration: BoxDecoration(
        color: colors.info.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        border: Border.all(color: colors.info.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_rounded, color: colors.info, size: 16),
          SizedBox(width: AppTheme.spacingSm),
          Expanded(
            child: Text(
              '256-bit encrypted & stored securely',
              style: AppTextStyles.caption.copyWith(color: colors.info),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalNote(AppColorScheme colors) {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacingSm),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.celebration_rounded, color: colors.primary, size: 18),
          SizedBox(width: AppTheme.spacingSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Almost Done!',
                  style: AppTextStyles.labelLarge.copyWith(color: colors.primary),
                ),
                Text('Review & submit your application', style: AppTextStyles.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPicker(BuildContext context) {
    final colors = AppColorScheme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 3,
              decoration: BoxDecoration(
                color: colors.border.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: AppTheme.spacingMd),
            Text('Upload Document', style: AppTextStyles.h4),
            SizedBox(height: AppTheme.spacingMd),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPickerOption(
                  colors: colors,
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  onTap: () {
                    Get.back();
                    controller.pickImage(type: 'cancelled_cheque', source: ImageSource.camera);
                  },
                ),
                _buildPickerOption(
                  colors: colors,
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  onTap: () {
                    Get.back();
                    controller.pickImage(type: 'cancelled_cheque', source: ImageSource.gallery);
                  },
                ),
              ],
            ),
            SizedBox(height: AppTheme.spacingSm),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerOption({
    required AppColorScheme colors,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: colors.primary),
          ),
          SizedBox(height: AppTheme.spacingXs),
          Text(label, style: AppTextStyles.labelMedium),
        ],
      ),
    );
  }
}
