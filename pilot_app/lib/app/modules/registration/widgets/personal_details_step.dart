import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
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
          // Header
          _buildSectionHeader(
            theme,
            icon: Icons.person_rounded,
            title: 'Personal Details',
            subtitle: 'Let\'s get to know you better',
          ),

          const SizedBox(height: 32),

          // Profile Photo
          Center(
            child: Obx(() => _buildProfilePhoto(theme)),
          ),

          const SizedBox(height: 32),

          // Form Card
          _buildFormCard(
            theme,
            children: [
              // Full Name
              AppTextField(
                controller: controller.nameController,
                label: 'Full Name',
                hint: 'Enter your full name',
                prefixIcon: const Icon(Icons.badge_outlined),
                textCapitalization: TextCapitalization.words,
              ),

              const SizedBox(height: 20),

              // Email
              AppTextField(
                controller: controller.emailController,
                label: 'Email Address',
                hint: 'your.email@example.com',
                prefixIcon: const Icon(Icons.alternate_email_rounded),
                type: AppTextFieldType.email,
              ),

              const SizedBox(height: 20),

              // Date of Birth
              GestureDetector(
                onTap: () => _selectDateOfBirth(context),
                child: AbsorbPointer(
                  child: Obx(() => AppTextField(
                    label: 'Date of Birth',
                    hint: 'Select your date of birth',
                    prefixIcon: const Icon(Icons.cake_outlined),
                    controller: TextEditingController(
                      text: controller.dateOfBirth.value != null
                          ? DateFormat('dd MMM yyyy').format(controller.dateOfBirth.value!)
                          : '',
                    ),
                    suffixIcon: Icon(
                      Icons.calendar_month_rounded,
                      color: AppColors.primary,
                    ),
                  )),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Address Section
          _buildSectionLabel(theme, 'Address Information'),
          const SizedBox(height: 16),

          _buildFormCard(
            theme,
            children: [
              // Address
              AppTextField(
                controller: controller.addressController,
                label: 'Street Address',
                hint: 'Enter your full address',
                prefixIcon: const Icon(Icons.home_outlined),
                maxLines: 2,
              ),

              const SizedBox(height: 20),

              // City & State Row
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: controller.cityController,
                      label: 'City',
                      hint: 'City',
                      prefixIcon: const Icon(Icons.location_city_rounded),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppTextField(
                      controller: controller.stateController,
                      label: 'State',
                      hint: 'State',
                      prefixIcon: const Icon(Icons.map_outlined),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Pincode
              AppTextField(
                controller: controller.pincodeController,
                label: 'PIN Code',
                hint: 'Enter 6-digit PIN',
                prefixIcon: const Icon(Icons.pin_drop_outlined),
                type: AppTextFieldType.number,
                maxLength: 6,
              ),
            ],
          ),

          const SizedBox(height: 32),
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

  Widget _buildSectionLabel(ThemeData theme, String label) {
    return Text(
      label,
      style: AppTextStyles.bodyMedium.copyWith(
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
      ),
    );
  }

  Widget _buildFormCard(ThemeData theme, {required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
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

  Widget _buildProfilePhoto(ThemeData theme) {
    return GestureDetector(
      onTap: () => _showImagePicker(Get.context!),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withValues(alpha: 0.1),
                      AppColors.primary.withValues(alpha: 0.05),
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 3,
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
                        size: 48,
                        color: AppColors.primary.withValues(alpha: 0.5),
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            controller.profilePhoto.value != null ? 'Change Photo' : 'Add Profile Photo',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
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
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
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
                const SizedBox(height: 24),
                Text(
                  'Choose Photo Source',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildPickerOption(
                      theme,
                      icon: Icons.camera_alt_rounded,
                      label: 'Camera',
                      onTap: () {
                        Get.back();
                        controller.pickImage(type: 'profile', source: ImageSource.camera);
                      },
                    ),
                    _buildPickerOption(
                      theme,
                      icon: Icons.photo_library_rounded,
                      label: 'Gallery',
                      onTap: () {
                        Get.back();
                        controller.pickImage(type: 'profile', source: ImageSource.gallery);
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
