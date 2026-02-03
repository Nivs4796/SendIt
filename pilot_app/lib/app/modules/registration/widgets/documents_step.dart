import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../controllers/registration_controller.dart';

class DocumentsStep extends GetView<RegistrationController> {
  const DocumentsStep({super.key});

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
                child: Icon(Icons.description_rounded, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Upload Documents', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    Text('We need these for verification', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Progress indicator
          _buildUploadProgress(theme),

          const SizedBox(height: 12),

          // Required Documents Section
          Text('Required Documents', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),

          // ID Proof
          _buildDocumentCard(
            context,
            icon: Icons.badge_rounded,
            title: 'ID Proof',
            subtitle: 'Aadhar, PAN, or Passport',
            file: controller.idProofFile,
            type: 'id_proof',
          ),

          const SizedBox(height: 8),

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
                ),
                const SizedBox(height: 8),
                _buildDocumentCard(
                  context,
                  icon: Icons.receipt_long_rounded,
                  title: 'Vehicle RC',
                  subtitle: 'Registration Certificate',
                  file: controller.vehicleRcFile,
                  type: 'vehicle_rc',
                ),
                const SizedBox(height: 8),
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
                _buildDocumentCard(
                  context,
                  icon: Icons.family_restroom_rounded,
                  title: 'Parental Consent',
                  subtitle: 'Signed consent from parent',
                  file: controller.parentalConsentFile,
                  type: 'parental_consent',
                ),
                const SizedBox(height: 8),
              ],
            );
          }),

          // Info Box
          _buildInfoCard(theme),

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildUploadProgress(ThemeData theme) {
    return Obx(() {
      int uploadedCount = 0;
      int totalRequired = 1;

      if (controller.idProofFile.value != null) uploadedCount++;
      
      if (controller.requiresLicense) {
        totalRequired += 2;
        if (controller.drivingLicenseFile.value != null) uploadedCount++;
        if (controller.vehicleRcFile.value != null) uploadedCount++;
      }

      if (controller.isMinor) {
        totalRequired += 1;
        if (controller.parentalConsentFile.value != null) uploadedCount++;
      }

      final progress = totalRequired > 0 ? uploadedCount / totalRequired : 0.0;

      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Progress', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$uploadedCount / $totalRequired',
                    style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation(AppColors.primary),
                minHeight: 4,
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
  }) {
    final theme = Theme.of(context);
    
    return Obx(() {
      final isUploaded = file.value != null;
      
      return GestureDetector(
        onTap: () => _showImagePicker(context, type),
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
                  : theme.colorScheme.outline.withValues(alpha: 0.1),
              width: isUploaded ? 1.5 : 1,
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
                  isUploaded ? Icons.check_circle_rounded : icon,
                  color: isUploaded ? AppColors.success : AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    Text(
                      isUploaded ? '✓ Uploaded' : subtitle,
                      style: TextStyle(
                        fontSize: 10,
                        color: isUploaded ? AppColors.success : theme.colorScheme.onSurface.withValues(alpha: 0.6),
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

  Widget _buildInfoCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: Colors.blue.shade600, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tips', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.blue.shade700)),
                const SizedBox(height: 4),
                Text('• Clear, well-lit photos\n• Verification takes 24-48h', 
                  style: TextStyle(fontSize: 10, color: Colors.blue.shade600)),
              ],
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
                        controller.pickImage(type: type, source: ImageSource.camera);
                      },
                    ),
                    _buildPickerOption(
                      theme,
                      icon: Icons.photo_library_rounded,
                      label: 'Gallery',
                      onTap: () {
                        Get.back();
                        controller.pickImage(type: type, source: ImageSource.gallery);
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
