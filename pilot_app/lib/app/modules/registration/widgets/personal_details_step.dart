import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../controllers/registration_controller.dart';

class PersonalDetailsStep extends GetView<RegistrationController> {
  const PersonalDetailsStep({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header + Profile Photo Row
          Row(
            children: [
              Obx(() => _buildCompactProfilePhoto(theme)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Personal Details', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    Text('Let\'s get to know you', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Full Name
          _buildCompactField(
            controller: controller.nameController,
            label: 'Full Name',
            hint: 'Enter your full name',
            icon: Icons.person_outline,
          ),

          const SizedBox(height: 8),

          // Email
          _buildCompactField(
            controller: controller.emailController,
            label: 'Email',
            hint: 'your.email@example.com',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),

          const SizedBox(height: 8),

          // Date of Birth
          GestureDetector(
            onTap: () => _selectDateOfBirth(context),
            child: AbsorbPointer(
              child: Obx(() => _buildCompactField(
                controller: TextEditingController(
                  text: controller.dateOfBirth.value != null
                      ? DateFormat('dd MMM yyyy').format(controller.dateOfBirth.value!)
                      : '',
                ),
                label: 'Date of Birth',
                hint: 'Select date',
                icon: Icons.calendar_today_outlined,
                suffixIcon: Icons.arrow_drop_down,
              )),
            ),
          ),

          const SizedBox(height: 10),

          // Address Section Header
          Text('Address', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),

          // Street Address
          _buildCompactField(
            controller: controller.addressController,
            label: 'Street Address',
            hint: 'Enter address',
            icon: Icons.home_outlined,
          ),

          const SizedBox(height: 8),

          // City & State Row
          Row(
            children: [
              Expanded(
                child: _buildCompactField(
                  controller: controller.cityController,
                  label: 'City',
                  hint: 'City',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildCompactField(
                  controller: controller.stateController,
                  label: 'State',
                  hint: 'State',
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Pincode
          _buildCompactField(
            controller: controller.pincodeController,
            label: 'PIN Code',
            hint: '6-digit PIN',
            icon: Icons.pin_drop_outlined,
            keyboardType: TextInputType.number,
            maxLength: 6,
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildCompactField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? icon,
    IconData? suffixIcon,
    TextInputType? keyboardType,
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
            maxLength: maxLength,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.3)),
              prefixIcon: icon != null ? Icon(icon, size: 16, color: AppColors.primary) : null,
              suffixIcon: suffixIcon != null ? Icon(suffixIcon, size: 18, color: Colors.white54) : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: icon != null ? 0 : 10, vertical: 12),
              counterText: '',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactProfilePhoto(ThemeData theme) {
    return GestureDetector(
      onTap: () => _showImagePicker(Get.context!),
      child: Stack(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.1),
                  AppColors.primary.withValues(alpha: 0.05),
                ],
              ),
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
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.camera_alt_rounded, size: 10, color: Colors.white),
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
                const SizedBox(height: 16),
                Text(
                  'Choose Photo',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
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
