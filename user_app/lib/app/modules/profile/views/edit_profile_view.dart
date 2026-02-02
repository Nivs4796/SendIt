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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Personal Information'),
        centerTitle: true,
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Error Message
            _buildErrorMessage(context),

            // Avatar Section
            _buildAvatarSection(context),

            const SizedBox(height: 32),

            // Form Fields
            _buildFormFields(context),

            const SizedBox(height: 32),

            // Save Button
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorMessage(BuildContext context) {
    return Obx(() {
      if (controller.errorMessage.value.isEmpty) {
        return const SizedBox.shrink();
      }
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.errorLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.error,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                controller.errorMessage.value,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
            GestureDetector(
              onTap: controller.clearError,
              child: const Icon(
                Icons.close_rounded,
                color: AppColors.error,
                size: 18,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildAvatarSection(BuildContext context) {
    final theme = Theme.of(context);

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
                      color: theme.colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
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
                        ? Icon(
                            Icons.person_rounded,
                            size: 48,
                            color: theme.colorScheme.primary,
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
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.scaffoldBackgroundColor,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      size: 18,
                      color: theme.colorScheme.onPrimary,
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
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Phone Number (Read-only)
        Obx(() => AppTextField(
              label: 'Phone Number',
              hint: 'Phone number',
              controller: TextEditingController(text: controller.userPhone),
              enabled: false,
              prefixIcon: Icon(
                Icons.phone_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )),

        const SizedBox(height: 20),

        // Full Name
        AppTextField.name(
          controller: controller.nameController,
          prefixIcon: Icon(
            Icons.person_outline_rounded,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 20),

        // Email (Optional)
        AppTextField.email(
          label: 'Email (Optional)',
          hint: 'Enter your email',
          controller: controller.emailController,
          prefixIcon: Icon(
            Icons.email_outlined,
            color: theme.colorScheme.onSurfaceVariant,
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
