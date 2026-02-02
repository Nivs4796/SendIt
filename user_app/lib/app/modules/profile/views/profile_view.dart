import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../routes/app_routes.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // Profile Header
              _buildProfileHeader(),

              const SizedBox(height: 16),

              // Account Section
              _buildMenuSection(
                title: 'Account',
                items: [
                  _MenuItem(
                    icon: Icons.person_outline_rounded,
                    title: 'Personal Information',
                    onTap: () => Get.toNamed(Routes.personalInfo),
                  ),
                  _MenuItem(
                    icon: Icons.location_on_outlined,
                    title: 'Saved Addresses',
                    onTap: () => Get.toNamed(Routes.savedAddresses),
                  ),
                  _MenuItem(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Wallet',
                    onTap: () => Get.toNamed(Routes.wallet),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Support Section
              _buildMenuSection(
                title: 'Support',
                items: [
                  _MenuItem(
                    icon: Icons.help_outline_rounded,
                    title: 'Help & Support',
                    onTap: () => _showComingSoon('Help & Support'),
                  ),
                  _MenuItem(
                    icon: Icons.description_outlined,
                    title: 'Terms & Conditions',
                    onTap: () => _showComingSoon('Terms & Conditions'),
                  ),
                  _MenuItem(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    onTap: () => _showComingSoon('Privacy Policy'),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Actions Section
              _buildMenuSection(
                title: 'Actions',
                items: [
                  _MenuItem(
                    icon: Icons.logout_rounded,
                    title: 'Logout',
                    iconColor: AppColors.warning,
                    titleColor: AppColors.warning,
                    onTap: controller.logout,
                  ),
                  _MenuItem(
                    icon: Icons.delete_outline_rounded,
                    title: 'Delete Account',
                    iconColor: AppColors.error,
                    titleColor: AppColors.error,
                    onTap: controller.deleteAccount,
                    showDivider: false,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // App Version
              Text(
                'Version 1.0.0',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Obx(() {
        final user = controller.user.value;
        final avatarUrl = _getAvatarUrl(user?.avatar);

        return Row(
          children: [
            // Avatar
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 2,
                ),
                image: avatarUrl != null
                    ? DecorationImage(
                        image: NetworkImage(avatarUrl),
                        fit: BoxFit.cover,
                        onError: (_, __) {},
                      )
                    : null,
              ),
              child: avatarUrl == null
                  ? const Icon(
                      Icons.person_rounded,
                      size: 36,
                      color: AppColors.primary,
                    )
                  : null,
            ),

            const SizedBox(width: 16),

            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.userName.isNotEmpty
                        ? controller.userName
                        : 'User',
                    style: AppTextStyles.h4,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    controller.userPhone.isNotEmpty
                        ? controller.userPhone
                        : 'No phone number',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (controller.userEmail.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      controller.userEmail,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textHint,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Edit Button
            IconButton(
              onPressed: () => Get.toNamed(Routes.personalInfo),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit_rounded,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildMenuSection({
    required String title,
    required List<_MenuItem> items,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              title,
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ...items.map((item) => _buildMenuItem(item)),
        ],
      ),
    );
  }

  Widget _buildMenuItem(_MenuItem item) {
    return Column(
      children: [
        ListTile(
          leading: Icon(
            item.icon,
            color: item.iconColor ?? AppColors.textPrimary,
            size: 24,
          ),
          title: Text(
            item.title,
            style: AppTextStyles.bodyMedium.copyWith(
              color: item.titleColor ?? AppColors.textPrimary,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: item.iconColor ?? AppColors.textSecondary,
            size: 24,
          ),
          onTap: item.onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        if (item.showDivider)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Divider(
              height: 1,
              color: AppColors.border,
            ),
          ),
      ],
    );
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

  void _showComingSoon(String feature) {
    Get.snackbar(
      'Coming Soon',
      '$feature will be available soon!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primary,
      colorText: AppColors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? titleColor;
  final bool showDivider;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
    this.titleColor,
    this.showDivider = true,
  });
}
