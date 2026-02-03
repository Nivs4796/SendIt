import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../controllers/registration_controller.dart';

class DocumentsStep extends GetView<RegistrationController> {
  const DocumentsStep({super.key});

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
            icon: Icons.description_rounded,
            title: 'Upload Documents',
            subtitle: 'We need these for verification',
          ),

          const SizedBox(height: 16),

          // Progress indicator
          _buildUploadProgress(theme),

          const SizedBox(height: 20),

          // Required Documents Section
          Text(
            'Required Documents',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 16),

          // ID Proof
          _buildDocumentCard(
            context,
            icon: Icons.badge_rounded,
            title: 'ID Proof',
            subtitle: 'Aadhar Card, PAN Card, or Passport',
            file: controller.idProofFile,
            type: 'id_proof',
            isRequired: true,
          ),

          const SizedBox(height: 12),

          // Driving License (conditional)
          Obx(() {
            if (!controller.requiresLicense) {
              return const SizedBox.shrink();
            }
            return Column(
              children: [
                _buildDocumentCard(
                  context,
                  icon: Icons.credit_card_rounded,
                  title: 'Driving License',
                  subtitle: 'Valid driving license',
                  file: controller.drivingLicenseFile,
                  type: 'driving_license',
                  isRequired: true,
                ),
                const SizedBox(height: 12),
                _buildDocumentCard(
                  context,
                  icon: Icons.receipt_long_rounded,
                  title: 'Vehicle RC',
                  subtitle: 'Registration Certificate',
                  file: controller.vehicleRcFile,
                  type: 'vehicle_rc',
                  isRequired: true,
                ),
                const SizedBox(height: 16),
              ],
            );
          }),

          // Optional Documents Section
          Obx(() {
            if (!controller.requiresLicense && !controller.isMinor) {
              return const SizedBox.shrink();
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Optional Documents',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 16),
                if (controller.requiresLicense)
                  _buildDocumentCard(
                    context,
                    icon: Icons.shield_rounded,
                    title: 'Insurance',
                    subtitle: 'Vehicle insurance certificate',
                    file: controller.insuranceFile,
                    type: 'insurance',
                    isRequired: false,
                  ),
                const SizedBox(height: 16),
              ],
            );
          }),

          // Parental Consent (for minors)
          Obx(() {
            if (!controller.isMinor) {
              return const SizedBox.shrink();
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Minor Requirement',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 16),
                _buildDocumentCard(
                  context,
                  icon: Icons.family_restroom_rounded,
                  title: 'Parental Consent',
                  subtitle: 'Signed consent from parent/guardian',
                  file: controller.parentalConsentFile,
                  type: 'parental_consent',
                  isRequired: true,
                ),
                const SizedBox(height: 16),
              ],
            );
          }),

          // Info Box
          _buildInfoCard(theme),

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

  Widget _buildUploadProgress(ThemeData theme) {
    return Obx(() {
      int uploadedCount = 0;
      int totalRequired = 1; // ID Proof is always required

      if (controller.idProofFile.value != null) uploadedCount++;
      
      if (controller.requiresLicense) {
        totalRequired += 2; // DL + RC
        if (controller.drivingLicenseFile.value != null) uploadedCount++;
        if (controller.vehicleRcFile.value != null) uploadedCount++;
      }

      if (controller.isMinor) {
        totalRequired += 1; // Parental consent
        if (controller.parentalConsentFile.value != null) uploadedCount++;
      }

      final progress = totalRequired > 0 ? uploadedCount / totalRequired : 0.0;

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Upload Progress',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$uploadedCount / $totalRequired',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation(AppColors.primary),
                minHeight: 6,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildDocumentCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Rx<dynamic> file,
    required String type,
    required bool isRequired,
  }) {
    final theme = Theme.of(context);
    
    return Obx(() {
      final isUploaded = file.value != null;
      
      return GestureDetector(
        onTap: () => _showImagePicker(context, type),
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
                  : theme.colorScheme.outline.withValues(alpha: 0.1),
              width: isUploaded ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Icon Container
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isUploaded
                      ? AppColors.success.withValues(alpha: 0.15)
                      : AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isUploaded ? Icons.check_circle_rounded : icon,
                  color: isUploaded ? AppColors.success : AppColors.primary,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (isRequired) ...[
                          const SizedBox(width: 4),
                          Text(
                            '*',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: theme.colorScheme.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isUploaded ? '✓ Uploaded successfully' : subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isUploaded
                            ? AppColors.success
                            : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        fontWeight: isUploaded ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              // Action Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isUploaded
                      ? AppColors.success.withValues(alpha: 0.1)
                      : theme.colorScheme.surface,
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

  Widget _buildInfoCard(ThemeData theme) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.info_outline_rounded,
              color: Colors.blue.shade600,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Tips',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                _buildTipItem('Ensure all documents are clearly visible'),
                _buildTipItem('Photos should be well-lit and in focus'),
                _buildTipItem('Verification usually takes 24-48 hours'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.blue.shade600,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.blue.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showImagePicker(BuildContext context, String type) {
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
                  'Upload Document',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose how you want to add your document',
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
                      subtitle: 'Take a photo',
                      onTap: () {
                        Get.back();
                        controller.pickImage(type: type, source: ImageSource.camera);
                      },
                    ),
                    _buildPickerOption(
                      theme,
                      icon: Icons.photo_library_rounded,
                      label: 'Gallery',
                      subtitle: 'Choose existing',
                      onTap: () {
                        Get.back();
                        controller.pickImage(type: type, source: ImageSource.gallery);
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
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 28,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTextStyles.labelSmall.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
