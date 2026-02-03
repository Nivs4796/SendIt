import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../controllers/registration_controller.dart';

class BankDetailsStep extends GetView<RegistrationController> {
  const BankDetailsStep({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.account_balance_rounded, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bank Details', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    Text('For your earnings payout', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Earnings Info Card
          _buildEarningsInfoCard(theme),

          const SizedBox(height: 12),

          // Account Details Form
          _buildFormCard(
            theme,
            children: [
              _buildCompactField(
                controller: controller.accountHolderController,
                label: 'Account Holder Name',
                hint: 'Name as per bank',
                icon: Icons.person_outline_rounded,
              ),

              const SizedBox(height: 10),

              _buildCompactField(
                controller: controller.bankNameController,
                label: 'Bank Name',
                hint: 'e.g., State Bank of India',
                icon: Icons.account_balance_outlined,
              ),

              const SizedBox(height: 10),

              _buildCompactField(
                controller: controller.accountNumberController,
                label: 'Account Number',
                hint: 'Enter account number',
                icon: Icons.numbers_rounded,
                keyboardType: TextInputType.number,
                obscureText: true,
              ),

              const SizedBox(height: 10),

              _buildCompactField(
                controller: controller.confirmAccountNumberController,
                label: 'Confirm Account Number',
                hint: 'Re-enter to confirm',
                icon: Icons.check_circle_outline_rounded,
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 10),

              _buildCompactField(
                controller: controller.ifscController,
                label: 'IFSC Code',
                hint: 'e.g., SBIN0001234',
                icon: Icons.qr_code_rounded,
                textCapitalization: TextCapitalization.characters,
                maxLength: 11,
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Supporting Document
          Text('Optional Document', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),

          _buildDocumentUpload(context, theme),

          const SizedBox(height: 10),

          // Security Note
          _buildSecurityNote(theme),

          const SizedBox(height: 10),

          // Final Step Note
          _buildFinalStepNote(theme),

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildCompactField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    TextCapitalization textCapitalization = TextCapitalization.none,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Container(
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            textCapitalization: textCapitalization,
            maxLength: maxLength,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.3)),
              prefixIcon: Icon(icon, size: 16, color: AppColors.primary),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              counterText: '',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard(ThemeData theme, {required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildEarningsInfoCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.monetization_on_rounded, color: AppColors.success, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Weekly Payouts', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.success)),
                Text('Earnings transferred every week', style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface.withValues(alpha: 0.7))),
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
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isUploaded
                ? AppColors.success.withValues(alpha: 0.05)
                : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isUploaded
                  ? AppColors.success.withValues(alpha: 0.5)
                  : theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isUploaded
                      ? AppColors.success.withValues(alpha: 0.15)
                      : AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isUploaded ? Icons.check_circle_rounded : Icons.receipt_long_rounded,
                  color: isUploaded ? AppColors.success : AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cancelled Cheque / Passbook', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    Text(
                      isUploaded ? '✓ Uploaded' : 'Helps verify faster',
                      style: TextStyle(
                        fontSize: 10,
                        color: isUploaded ? AppColors.success : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isUploaded ? Icons.edit_rounded : Icons.add_rounded,
                color: isUploaded ? AppColors.success : AppColors.primary,
                size: 18,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSecurityNote(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_rounded, color: Colors.blue.shade600, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '256-bit encrypted & stored securely',
              style: TextStyle(fontSize: 10, color: Colors.blue.shade600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalStepNote(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.celebration_rounded, color: AppColors.primary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Almost Done!', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                Text('Review & submit your application', style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface.withValues(alpha: 0.7))),
              ],
            ),
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
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 32,
                  height: 3,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                Text('Upload Document', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
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
                const SizedBox(height: 8),
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
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 22, color: AppColors.primary),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
