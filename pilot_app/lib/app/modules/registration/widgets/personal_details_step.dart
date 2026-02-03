import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import '../controllers/registration_controller.dart';

class PersonalDetailsStep extends GetView<RegistrationController> {
  const PersonalDetailsStep({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.spacingLg,
        vertical: AppTheme.spacingSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header + Profile Photo
          Row(
            children: [
              Obx(() => _buildProfilePhoto(theme)),
              SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Personal Details', style: AppTextStyles.h4),
                    Text(
                      'Let\'s get to know you',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: AppTheme.spacingMd),

          // Full Name
          AppTextField(
            controller: controller.nameController,
            label: 'Full Name',
            hint: 'Enter your full name',
            prefixIcon: const Icon(Icons.person_outline),
            textCapitalization: TextCapitalization.words,
          ),

          SizedBox(height: AppTheme.spacingSm),

          // Email
          AppTextField(
            controller: controller.emailController,
            label: 'Email',
            hint: 'your.email@example.com',
            prefixIcon: const Icon(Icons.email_outlined),
            type: AppTextFieldType.email,
          ),

          SizedBox(height: AppTheme.spacingSm),

          // Date of Birth
          GestureDetector(
            onTap: () => _selectDateOfBirth(context),
            child: AbsorbPointer(
              child: Obx(() => AppTextField(
                controller: TextEditingController(
                  text: controller.dateOfBirth.value != null
                      ? DateFormat('dd MMM yyyy').format(controller.dateOfBirth.value!)
                      : '',
                ),
                label: 'Date of Birth',
                hint: 'Select date',
                prefixIcon: const Icon(Icons.calendar_today_outlined),
                suffixIcon: const Icon(Icons.arrow_drop_down, size: 20),
              )),
            ),
          ),

          SizedBox(height: AppTheme.spacingMd),

          // Address Section
          Text('Address', style: AppTextStyles.labelLarge),
          SizedBox(height: AppTheme.spacingSm),

          AppTextField(
            controller: controller.addressController,
            label: 'Street Address',
            hint: 'Enter address',
            prefixIcon: const Icon(Icons.home_outlined),
          ),

          SizedBox(height: AppTheme.spacingSm),

          // City & State Row
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: controller.cityController,
                  label: 'City',
                  hint: 'City',
                ),
              ),
              SizedBox(width: AppTheme.spacingSm),
              Expanded(
                child: AppTextField(
                  controller: controller.stateController,
                  label: 'State',
                  hint: 'State',
                ),
              ),
            ],
          ),

          SizedBox(height: AppTheme.spacingSm),

          // Pincode
          AppTextField(
            controller: controller.pincodeController,
            label: 'PIN Code',
            hint: '6-digit PIN',
            prefixIcon: const Icon(Icons.pin_drop_outlined),
            type: AppTextFieldType.number,
            maxLength: 6,
          ),

          SizedBox(height: AppTheme.spacingSm),
        ],
      ),
    );
  }

  Widget _buildProfilePhoto(ThemeData theme) {
    return GestureDetector(
      onTap: () => _showImagePicker(Get.context!),
      child: Stack(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 2,
              ),
              image: controller.profilePhoto.value != null
                  ? DecorationImage(
                      image: FileImage(controller.profilePhoto.value!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: controller.profilePhoto.value == null
                ? Icon(
                    Icons.person_rounded,
                    size: 24,
                    color: AppColors.primary.withValues(alpha: 0.5),
                  )
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.camera_alt, size: 10, color: Colors.white),
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
        padding: EdgeInsets.all(AppTheme.spacingLg),
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
            SizedBox(height: AppTheme.spacingMd),
            Text('Choose Photo', style: AppTextStyles.h4),
            SizedBox(height: AppTheme.spacingMd),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPickerOption(
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  onTap: () {
                    Get.back();
                    controller.pickImage(type: 'profile', source: ImageSource.camera);
                  },
                ),
                _buildPickerOption(
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  onTap: () {
                    Get.back();
                    controller.pickImage(type: 'profile', source: ImageSource.gallery);
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
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          SizedBox(height: AppTheme.spacingXs),
          Text(label, style: AppTextStyles.labelMedium),
        ],
      ),
    );
  }

  Future<void> _selectDateOfBirth(BuildContext context) async {
    final now = DateTime.now();
    final maxDate = DateTime(now.year - 16, now.month, now.day);
    final minDate = DateTime(now.year - 70, now.month, now.day);

    final date = await showDatePicker(
      context: context,
      initialDate: controller.dateOfBirth.value ?? maxDate,
      firstDate: minDate,
      lastDate: maxDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      controller.dateOfBirth.value = date;
    }
  }
}
