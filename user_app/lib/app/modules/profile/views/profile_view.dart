import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/controllers/theme_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../routes/app_routes.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
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

              // Settings Section
              _buildSettingsSection(context),

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
              Builder(
                builder: (context) => Text(
                  'Version 1.0.0',
                  style: AppTextStyles.caption.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
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
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: isDark
                ? Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                blurRadius: isDark ? 16 : 10,
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
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
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
                      ? Icon(
                          Icons.person_rounded,
                          size: 36,
                          color: theme.colorScheme.primary,
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
                        style: AppTextStyles.h4.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        controller.userPhone.isNotEmpty
                            ? controller.userPhone
                            : 'No phone number',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (controller.userEmail.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          controller.userEmail,
                          style: AppTextStyles.caption.copyWith(
                            color: theme.hintColor,
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
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.edit_rounded,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            );
          }),
        );
      },
    );
  }

  Widget _buildMenuSection({
    required String title,
    required List<_MenuItem> items,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: isDark
                ? Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                blurRadius: isDark ? 16 : 10,
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
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              ...items.map((item) => _buildMenuItem(item, context)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(_MenuItem item, BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        ListTile(
          leading: Icon(
            item.icon,
            color: item.iconColor ?? theme.colorScheme.onSurface,
            size: 24,
          ),
          title: Text(
            item.title,
            style: AppTextStyles.bodyMedium.copyWith(
              color: item.titleColor ?? theme.colorScheme.onSurface,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: item.iconColor ?? theme.colorScheme.onSurfaceVariant,
            size: 24,
          ),
          onTap: item.onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        if (item.showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(
              height: 1,
              color: theme.dividerColor,
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

  Widget _buildSettingsSection(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: isDark
            ? Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: isDark ? 16 : 10,
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
              'Settings',
              style: AppTextStyles.labelLarge.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Obx(() => ListTile(
                leading: Icon(
                  ThemeController.to.themeIcon,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                title: Text(
                  'Theme',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  ThemeController.to.themeModeName,
                  style: AppTextStyles.caption.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 24,
                ),
                onTap: () => _showThemeSelector(context),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              )),
        ],
      ),
    );
  }

  void _showThemeSelector(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose Theme',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            Obx(() => _buildThemeOption(
                  context,
                  icon: Icons.dark_mode_rounded,
                  title: 'Dark',
                  subtitle: 'Always use dark theme',
                  isSelected:
                      ThemeController.to.themeMode.value == ThemeMode.dark,
                  onTap: () {
                    ThemeController.to.setDark();
                    Get.back();
                  },
                )),
            Obx(() => _buildThemeOption(
                  context,
                  icon: Icons.light_mode_rounded,
                  title: 'Light',
                  subtitle: 'Always use light theme',
                  isSelected:
                      ThemeController.to.themeMode.value == ThemeMode.light,
                  onTap: () {
                    ThemeController.to.setLight();
                    Get.back();
                  },
                )),
            Obx(() => _buildThemeOption(
                  context,
                  icon: Icons.brightness_auto_rounded,
                  title: 'System',
                  subtitle: 'Follow system settings',
                  isSelected:
                      ThemeController.to.themeMode.value == ThemeMode.system,
                  onTap: () {
                    ThemeController.to.setSystem();
                    Get.back();
                  },
                )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: isSelected
          ? Icon(
              Icons.check_circle_rounded,
              color: Theme.of(context).colorScheme.primary,
            )
          : null,
      onTap: onTap,
    );
  }

  void _showComingSoon(String feature) {
    final theme = Theme.of(Get.context!);
    Get.snackbar(
      'Coming Soon',
      '$feature will be available soon!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: theme.colorScheme.primary,
      colorText: theme.colorScheme.onPrimary,
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
