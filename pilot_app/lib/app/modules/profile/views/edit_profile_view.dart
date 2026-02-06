import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../controllers/profile_controller.dart';

class EditProfileView extends GetView<ProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);
    final pilot = controller.pilot.value;

    final nameController = TextEditingController(text: pilot?.name);
    final emailController = TextEditingController(text: pilot?.email);
    final emergencyController =
        TextEditingController(text: pilot?.emergencyContact);

    final selectedDob = Rxn<DateTime>(pilot?.dateOfBirth);
    final selectedGender = RxnString();

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            // Avatar section
            _buildAvatarSection(colors),
            const SizedBox(height: 32),

            // Name
            _buildTextField(
              controller: nameController,
              label: 'Full Name',
              icon: Icons.person_outline,
              colors: colors,
            ),
            const SizedBox(height: 16),

            // Email
            _buildTextField(
              controller: emailController,
              label: 'Email Address',
              icon: Icons.email_outlined,
              colors: colors,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            // Emergency Contact
            _buildTextField(
              controller: emergencyController,
              label: 'Emergency Contact',
              icon: Icons.phone_outlined,
              colors: colors,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            // Date of Birth
            Obx(() => GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDob.value ??
                          DateTime.now().subtract(const Duration(days: 6570)),
                      firstDate: DateTime(1950),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      selectedDob.value = picked;
                    }
                  },
                  child: AbsorbPointer(
                    child: TextField(
                      controller: TextEditingController(
                        text: selectedDob.value != null
                            ? DateFormat('dd MMM yyyy')
                                .format(selectedDob.value!)
                            : '',
                      ),
                      decoration: InputDecoration(
                        labelText: 'Date of Birth',
                        prefixIcon: Icon(Icons.cake_outlined,
                            color: colors.primary, size: 22),
                        suffixIcon: Icon(Icons.calendar_today,
                            color: colors.textHint, size: 18),
                        filled: true,
                        fillColor: colors.surfaceVariant,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide:
                              BorderSide(color: colors.primary, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                      ),
                    ),
                  ),
                )),
            const SizedBox(height: 16),

            // Gender
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Gender',
                style: AppTextStyles.labelMedium.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Obx(() => Row(
                  children: ['Male', 'Female', 'Other'].map((gender) {
                    final isSelected = selectedGender.value == gender;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(gender),
                        selected: isSelected,
                        onSelected: (_) => selectedGender.value = gender,
                        selectedColor: colors.primary.withValues(alpha: 0.15),
                        backgroundColor: colors.surfaceVariant,
                        labelStyle: AppTextStyles.labelMedium.copyWith(
                          color:
                              isSelected ? colors.primary : colors.textPrimary,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? colors.primary
                              : colors.border,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }).toList(),
                )),
            const SizedBox(height: 32),

            // Save Button
            Obx(() => SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: controller.isProcessing.value
                        ? null
                        : () async {
                            final success = await controller.updateProfile(
                              name: nameController.text,
                              email: emailController.text,
                              emergencyContact: emergencyController.text,
                              dateOfBirth: selectedDob.value != null
                                  ? DateFormat('yyyy-MM-dd')
                                      .format(selectedDob.value!)
                                  : null,
                              gender: selectedGender.value,
                            );
                            if (success) Get.back();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: controller.isProcessing.value
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Save Changes',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                )),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection(AppColorScheme colors) {
    final pilot = controller.pilot.value;

    return Center(
      child: GestureDetector(
        onTap: controller.uploadProfilePhoto,
        child: Stack(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.primary.withValues(alpha: 0.3),
                  width: 3,
                ),
              ),
              child: pilot?.profilePhotoUrl != null
                  ? ClipOval(
                      child: Image.network(
                        pilot!.profilePhotoUrl!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Center(
                      child: Text(
                        pilot?.name.substring(0, 1).toUpperCase() ?? 'P',
                        style: AppTextStyles.displayMedium.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required AppColorScheme colors,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: colors.primary, size: 22),
        filled: true,
        fillColor: colors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
