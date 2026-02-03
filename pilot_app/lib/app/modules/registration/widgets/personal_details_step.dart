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
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal Details',
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tell us about yourself',
            style: AppTextStyles.bodyMedium.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),

          // Profile Photo
          Center(
            child: Obx(() => GestureDetector(
              onTap: () => _showImagePicker(context),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
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
                        Icons.camera_alt_rounded,
                        size: 32,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      )
                    : null,
              ),
            )),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Add Photo',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Full Name
          AppTextField(
            controller: controller.nameController,
            label: 'Full Name',
            hint: 'Enter your full name',
            prefixIcon: const Icon(Icons.person_outline),
            textCapitalization: TextCapitalization.words,
          ),

          const SizedBox(height: 16),

          // Email
          AppTextField(
            controller: controller.emailController,
            label: 'Email Address',
            hint: 'Enter your email',
            prefixIcon: const Icon(Icons.email_outlined),
            type: AppTextFieldType.email,
          ),

          const SizedBox(height: 16),

          // Date of Birth
          GestureDetector(
            onTap: () => _selectDateOfBirth(context),
            child: AbsorbPointer(
              child: Obx(() => AppTextField(
                label: 'Date of Birth',
                hint: 'Select your date of birth',
                prefixIcon: const Icon(Icons.calendar_today_outlined),
                controller: TextEditingController(
                  text: controller.dateOfBirth.value != null
                      ? DateFormat('dd MMM yyyy').format(controller.dateOfBirth.value!)
                      : '',
                ),
                suffixIcon: const Icon(Icons.arrow_drop_down),
              )),
            ),
          ),

          const SizedBox(height: 16),

          // Address
          AppTextField(
            controller: controller.addressController,
            label: 'Full Address',
            hint: 'Enter your full address',
            prefixIcon: const Icon(Icons.location_on_outlined),
            maxLines: 2,
          ),

          const SizedBox(height: 16),

          // City & State
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: controller.cityController,
                  label: 'City',
                  hint: 'City',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppTextField(
                  controller: controller.stateController,
                  label: 'State',
                  hint: 'State',
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Pincode
          AppTextField(
            controller: controller.pincodeController,
            label: 'Pincode',
            hint: 'Enter pincode',
            type: AppTextFieldType.number,
            maxLength: 6,
          ),

          const SizedBox(height: 24),
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
                controller.pickImage(type: 'profile', source: ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Get.back();
                controller.pickImage(type: 'profile', source: ImageSource.gallery);
              },
            ),
          ],
        ),
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
    );

    if (date != null) {
      controller.dateOfBirth.value = date;
    }
  }
}
