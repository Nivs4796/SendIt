import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/registration_controller.dart';

class DocumentsStep extends GetView<RegistrationController> {
  const DocumentsStep({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upload Documents',
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload required documents for verification',
            style: AppTextStyles.bodyMedium.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),

          // ID Proof
          _buildDocumentUpload(
            context,
            title: 'ID Proof *',
            subtitle: 'Aadhar Card / PAN Card / Passport',
            file: controller.idProofFile,
            type: 'id_proof',
          ),

          const SizedBox(height: 16),

          // Driving License (conditional)
          Obx(() {
            if (!controller.requiresLicense) {
              return const SizedBox.shrink();
            }
            return Column(
              children: [
                _buildDocumentUpload(
                  context,
                  title: 'Driving License *',
                  subtitle: 'Valid driving license',
                  file: controller.drivingLicenseFile,
                  type: 'driving_license',
                ),
                const SizedBox(height: 16),
                _buildDocumentUpload(
                  context,
                  title: 'Vehicle RC *',
                  subtitle: 'Registration Certificate',
                  file: controller.vehicleRcFile,
                  type: 'vehicle_rc',
                ),
                const SizedBox(height: 16),
                _buildDocumentUpload(
                  context,
                  title: 'Insurance (Optional)',
                  subtitle: 'Vehicle insurance certificate',
                  file: controller.insuranceFile,
                  type: 'insurance',
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
              children: [
                _buildDocumentUpload(
                  context,
                  title: 'Parental Consent Form *',
                  subtitle: 'Signed consent from parent/guardian',
                  file: controller.parentalConsentFile,
                  type: 'parental_consent',
                ),
                const SizedBox(height: 16),
              ],
            );
          }),

          // Info Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'All documents will be verified within 24-48 hours',
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

  Widget _buildDocumentUpload(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Rx<dynamic> file,
    required String type,
  }) {
    final theme = Theme.of(context);

    return Obx(() => GestureDetector(
      onTap: () => _showImagePicker(context, type),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: file.value != null
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
                color: file.value != null
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Icon(
                file.value != null ? Icons.check_circle : Icons.upload_file,
                color: file.value != null
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
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    file.value != null ? 'Uploaded' : subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: file.value != null
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
    ));
  }

  void _showImagePicker(BuildContext context, String type) {
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
                controller.pickImage(type: type, source: ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Get.back();
                controller.pickImage(type: type, source: ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}
