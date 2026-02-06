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
                child: Icon(Icons.description_rounded, color: colors.primary, size: 18),
              ),
              SizedBox(width: AppTheme.spacingSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Upload Documents', style: AppTextStyles.h4),
                    Text('We need these for verification', style: AppTextStyles.caption),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: AppTheme.spacingMd),

          // Progress
          _buildProgress(colors),

          SizedBox(height: AppTheme.spacingMd),

          // Required Documents
          Text('Required Documents', style: AppTextStyles.labelLarge),
          SizedBox(height: AppTheme.spacingSm),

          _buildDocCard(
            context,
            icon: Icons.badge_rounded,
            title: 'ID Proof',
            subtitle: 'Aadhar, PAN, or Passport',
            file: controller.idProofFile,
            type: 'id_proof',
          ),

          SizedBox(height: AppTheme.spacingSm),

          // Conditional documents
          Obx(() {
            if (!controller.requiresLicense) return const SizedBox.shrink();
            return Column(
              children: [
                _buildDocCard(
                  context,
                  icon: Icons.credit_card_rounded,
                  title: 'Driving License',
                  subtitle: 'Valid driving license',
                  file: controller.drivingLicenseFile,
                  type: 'driving_license',
                ),
                SizedBox(height: AppTheme.spacingSm),
                _buildDocCard(
                  context,
                  icon: Icons.receipt_long_rounded,
                  title: 'Vehicle RC',
                  subtitle: 'Registration Certificate',
                  file: controller.vehicleRcFile,
                  type: 'vehicle_rc',
                ),
                SizedBox(height: AppTheme.spacingSm),
              ],
            );
          }),

          // Parental consent
          Obx(() {
            if (!controller.isMinor) return const SizedBox.shrink();
            return Column(
              children: [
                _buildDocCard(
                  context,
                  icon: Icons.family_restroom_rounded,
                  title: 'Parental Consent',
                  subtitle: 'Signed consent from parent',
                  file: controller.parentalConsentFile,
                  type: 'parental_consent',
                ),
                SizedBox(height: AppTheme.spacingSm),
              ],
            );
          }),

          // Info
          _buildInfoCard(colors),

          SizedBox(height: AppTheme.spacingMd),
        ],
      ),
    );
  }

  Widget _buildProgress(AppColorScheme colors) {
    return Obx(() {
      int uploaded = 0;
      int total = 1;

      if (controller.idProofFile.value != null) uploaded++;

      if (controller.requiresLicense) {
        total += 2;
        if (controller.drivingLicenseFile.value != null) uploaded++;
        if (controller.vehicleRcFile.value != null) uploaded++;
      }

      if (controller.isMinor) {
        total += 1;
        if (controller.parentalConsentFile.value != null) uploaded++;
      }

      final progress = total > 0 ? uploaded / total : 0.0;

      return Container(
        padding: EdgeInsets.all(AppTheme.spacingSm),
        decoration: BoxDecoration(
          color: colors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Progress', style: AppTextStyles.labelMedium),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingSm, vertical: 2),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Text(
                    '$uploaded / $total',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppTheme.spacingSm),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: colors.border.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation(colors.primary),
                minHeight: 4,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildDocCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Rx<dynamic> file,
    required String type,
  }) {
    final colors = AppColorScheme.of(context);

    return Obx(() {
      final isUploaded = file.value != null;

      return GestureDetector(
        onTap: () => _showPicker(context, type),
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
                  isUploaded ? Icons.check_circle_rounded : icon,
                  color: isUploaded ? colors.success : colors.primary,
                  size: 18,
                ),
              ),
              SizedBox(width: AppTheme.spacingSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.labelLarge),
                    Text(
                      isUploaded ? '✓ Uploaded' : subtitle,
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

  Widget _buildInfoCard(AppColorScheme colors) {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacingSm),
      decoration: BoxDecoration(
        color: colors.info.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        border: Border.all(color: colors.info.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: colors.info, size: 16),
          SizedBox(width: AppTheme.spacingSm),
          Expanded(
            child: Text(
              'Clear photos • Verification: 24-48h',
              style: AppTextStyles.caption.copyWith(color: colors.info),
            ),
          ),
        ],
      ),
    );
  }

  void _showPicker(BuildContext context, String type) {
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
                    controller.pickImage(type: type, source: ImageSource.camera);
                  },
                ),
                _buildPickerOption(
                  colors: colors,
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  onTap: () {
                    Get.back();
                    controller.pickImage(type: type, source: ImageSource.gallery);
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
