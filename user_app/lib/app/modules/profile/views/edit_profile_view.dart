import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/widgets.dart';
import '../controllers/profile_controller.dart';

class EditProfileView extends GetView<ProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Personal Information'),
        centerTitle: true,
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar Section
            _buildAvatarSection(),

            const SizedBox(height: 32),

            // Form Fields
            _buildFormFields(),

            const SizedBox(height: 32),

            // Save Button
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: controller.showAvatarPicker,
            child: Stack(
              children: [
                // Avatar Container
                Obx(() {
                  final selectedFile = controller.selectedAvatarFile.value;
                  final avatarUrl = _getAvatarUrl(controller.userAvatar);

                  return Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        width: 3,
                      ),
                      image: selectedFile != null
                          ? DecorationImage(
                              image: FileImage(selectedFile),
                              fit: BoxFit.cover,
                            )
                          : avatarUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(avatarUrl),
                                  fit: BoxFit.cover,
                                  onError: (_, __) {},
                                )
                              : null,
                    ),
                    child: selectedFile == null && avatarUrl == null
                        ? const Icon(
                            Icons.person_rounded,
                            size: 48,
                            color: AppColors.primary,
                          )
                        : null,
                  );
                }),

                // Camera Badge
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.white,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 18,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Tap to change photo',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        // Phone Number (Read-only)
        Obx(() => AppTextField(
              label: 'Phone Number',
              hint: 'Phone number',
              controller: TextEditingController(text: controller.userPhone),
              enabled: false,
              prefixIcon: const Icon(
                Icons.phone_rounded,
                color: AppColors.textSecondary,
              ),
            )),

        const SizedBox(height: 20),

        // Full Name
        AppTextField.name(
          controller: controller.nameController,
          prefixIcon: const Icon(
            Icons.person_outline_rounded,
            color: AppColors.textSecondary,
          ),
        ),

        const SizedBox(height: 20),

        // Email (Optional)
        AppTextField.email(
          label: 'Email (Optional)',
          hint: 'Enter your email',
          controller: controller.emailController,
          prefixIcon: const Icon(
            Icons.email_outlined,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Obx(() => AppButton.primary(
          text: 'Save Changes',
          isLoading: controller.isUpdating.value,
          onPressed: controller.updateProfile,
        ));
  }

  String? _getAvatarUrl(String? avatar) {
    if (avatar == null || avatar.isEmpty) return null;

    if (avatar.startsWith('http')) {
      return avatar;
    }

    // Remove '/api/v1' from baseUrl and append avatar path
    final baseUrl = ApiConstants.baseUrl.replaceAll('/api/v1', '');
    return '$baseUrl$avatar';
  }
}
