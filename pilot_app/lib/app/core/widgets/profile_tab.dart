import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../../routes/app_routes.dart';
import '../../modules/profile/controllers/profile_controller.dart';

/// Merged Menu+Profile tab content shown inline in HomeView's IndexedStack.
/// Uses AppColorScheme throughout. No Scaffold — HomeView provides it.
class ProfileTab extends GetView<ProfileController> {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);

    return Obx(() {
      if (controller.isLoading.value && controller.pilot.value == null) {
        return const Center(child: CircularProgressIndicator());
      }

      return RefreshIndicator(
        onRefresh: controller.refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Card
              _buildProfileCard(colors),
              const SizedBox(height: 20),

              // Stats Row
              _buildStatsRow(colors),
              const SizedBox(height: 24),

              // Quick Access
              _buildSectionTitle('Quick Access', colors),
              const SizedBox(height: 12),
              _buildQuickAccessSection(colors),
              const SizedBox(height: 24),

              // Account
              _buildSectionTitle('Account', colors),
              const SizedBox(height: 12),
              _buildAccountSection(colors),
              const SizedBox(height: 24),

              // Preferences
              _buildSectionTitle('Preferences', colors),
              const SizedBox(height: 12),
              _buildPreferencesSection(colors),
              const SizedBox(height: 24),

              // Support
              _buildSectionTitle('Support', colors),
              const SizedBox(height: 12),
              _buildSupportSection(colors),
              const SizedBox(height: 24),

              // Danger
              _buildDangerSection(colors),
              const SizedBox(height: 24),

              // App Version
              Center(
                child: Text(
                  'SendIt Pilot v1.0.0',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: colors.textHint,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildProfileCard(AppColorScheme colors) {
    final pilot = controller.pilot.value;
    final dateFormat = DateFormat('MMM yyyy');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primary,
            colors.primary.withValues(alpha: 0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              GestureDetector(
                onTap: controller.uploadProfilePhoto,
                child: Stack(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.5),
                          width: 2,
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
                                style: AppTextStyles.titleLarge.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          color: colors.primary,
                          size: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Name, Phone, Rating
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pilot?.name ?? 'Pilot',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pilot?.phone ?? '',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Rating badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                size: 14,
                                color: colors.accent,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${pilot?.rating?.toStringAsFixed(1) ?? '0.0'}',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Member since
                        if (pilot?.createdAt != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Since ${dateFormat.format(pilot!.createdAt)}',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Edit Profile button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Get.toNamed(Routes.editProfile),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.edit_outlined,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Edit Profile',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(AppColorScheme colors) {
    final pilot = controller.pilot.value;
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            colors,
            icon: Icons.local_shipping_outlined,
            value: '${pilot?.totalRides ?? 0}',
            label: 'Total Rides',
            color: colors.info,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            colors,
            icon: Icons.star_outline,
            value: pilot?.rating?.toStringAsFixed(1) ?? '0.0',
            label: 'Rating',
            color: colors.accent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            colors,
            icon: Icons.emoji_events_outlined,
            value: _getExperienceText(pilot?.createdAt),
            label: 'Experience',
            color: colors.primaryDark,
          ),
        ),
      ],
    );
  }

  String _getExperienceText(DateTime? joinDate) {
    if (joinDate == null) return '0d';
    final diff = DateTime.now().difference(joinDate);
    if (diff.inDays < 30) return '${diff.inDays}d';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}m';
    return '${(diff.inDays / 365).floor()}y';
  }

  Widget _buildStatCard(
    AppColorScheme colors, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, AppColorScheme colors) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: AppTextStyles.titleSmall.copyWith(
          fontWeight: FontWeight.bold,
          color: colors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildQuickAccessSection(AppColorScheme colors) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildMenuItem(
            colors,
            icon: Icons.account_balance_wallet_outlined,
            iconColor: colors.success,
            title: 'Earnings',
            subtitle: 'View your earnings',
            onTap: () => Get.toNamed(Routes.earnings),
          ),
          _buildDivider(colors),
          _buildMenuItem(
            colors,
            icon: Icons.wallet_outlined,
            iconColor: colors.info,
            title: 'Wallet',
            subtitle: 'Manage your wallet',
            onTap: () => Get.toNamed(Routes.wallet),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection(AppColorScheme colors) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildMenuItem(
            colors,
            icon: Icons.two_wheeler_outlined,
            iconColor: colors.info,
            title: 'My Vehicles',
            subtitle: 'Manage your vehicles',
            onTap: () => Get.toNamed(Routes.vehicles),
          ),
          _buildDivider(colors),
          _buildMenuItem(
            colors,
            icon: Icons.description_outlined,
            iconColor: colors.warning,
            title: 'Documents',
            subtitle: 'View and update documents',
            onTap: () => Get.toNamed(Routes.documents),
          ),
          _buildDivider(colors),
          _buildMenuItem(
            colors,
            icon: Icons.account_balance_outlined,
            iconColor: colors.success,
            title: 'Bank Details',
            subtitle: 'Payment account settings',
            onTap: () => Get.toNamed(Routes.bankDetails),
          ),
          _buildDivider(colors),
          _buildMenuItem(
            colors,
            icon: Icons.history_outlined,
            iconColor: colors.primaryDark,
            title: 'Job History',
            subtitle: 'View past deliveries',
            onTap: () => Get.toNamed(Routes.jobHistory),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection(AppColorScheme colors) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildMenuItem(
            colors,
            icon: Icons.notifications_outlined,
            iconColor: colors.primaryDark,
            title: 'Notifications',
            subtitle: 'Notification preferences',
            onTap: () => Get.toNamed(Routes.notifications),
          ),
          _buildDivider(colors),
          _buildMenuItem(
            colors,
            icon: Icons.language_outlined,
            iconColor: colors.primaryDark,
            title: 'Language',
            subtitle: 'English',
            onTap: () => _showComingSoon('Language'),
          ),
          _buildDivider(colors),
          _buildMenuItem(
            colors,
            icon: Icons.dark_mode_outlined,
            iconColor: colors.primaryDark,
            title: 'Dark Mode',
            subtitle: 'System default',
            onTap: () => _showComingSoon('Dark Mode'),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection(AppColorScheme colors) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildMenuItem(
            colors,
            icon: Icons.help_outline,
            iconColor: colors.info,
            title: 'Help & Support',
            subtitle: 'Get help and FAQs',
            onTap: () => Get.toNamed(Routes.help),
          ),
          _buildDivider(colors),
          _buildMenuItem(
            colors,
            icon: Icons.card_giftcard_outlined,
            iconColor: colors.accent,
            title: 'Rewards & Referrals',
            subtitle: 'Earn rewards and refer friends',
            onTap: () => Get.toNamed(Routes.rewards),
          ),
          _buildDivider(colors),
          _buildMenuItem(
            colors,
            icon: Icons.privacy_tip_outlined,
            iconColor: colors.textHint,
            title: 'Privacy Policy',
            subtitle: 'Read our privacy policy',
            onTap: () => _showComingSoon('Privacy Policy'),
          ),
          _buildDivider(colors),
          _buildMenuItem(
            colors,
            icon: Icons.article_outlined,
            iconColor: colors.textHint,
            title: 'Terms of Service',
            subtitle: 'Read terms and conditions',
            onTap: () => _showComingSoon('Terms of Service'),
          ),
          _buildDivider(colors),
          _buildMenuItem(
            colors,
            icon: Icons.info_outline,
            iconColor: colors.textSecondary,
            title: 'About',
            subtitle: 'About SendIt Pilot',
            onTap: () => _showAboutDialog(colors),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerSection(AppColorScheme colors) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: colors.surfaceVariant,
            borderRadius: BorderRadius.circular(16),
          ),
          child: _buildMenuItem(
            colors,
            icon: Icons.logout,
            iconColor: colors.warning,
            title: 'Logout',
            subtitle: 'Sign out of your account',
            titleColor: colors.warning,
            onTap: controller.logout,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: colors.error.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colors.error.withValues(alpha: 0.2),
            ),
          ),
          child: _buildMenuItem(
            colors,
            icon: Icons.delete_forever_outlined,
            iconColor: colors.error,
            title: 'Delete Account',
            subtitle: 'Permanently delete your account',
            titleColor: colors.error,
            onTap: controller.deleteAccount,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    AppColorScheme colors, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? titleColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: colors.textHint,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: colors.textHint,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(AppColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.only(left: 62),
      child: Divider(
        height: 1,
        color: colors.border.withValues(alpha: 0.5),
      ),
    );
  }

  void _showComingSoon(String feature) {
    Get.snackbar(
      'Coming Soon',
      '$feature will be available soon!',
      backgroundColor: AppColorScheme.of(Get.context!).info.withValues(alpha: 0.2),
      colorText: AppColorScheme.of(Get.context!).info,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  void _showAboutDialog(AppColorScheme colors) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.local_shipping, color: colors.primary),
            ),
            const SizedBox(width: 12),
            const Text('SendIt Pilot'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version 1.0.0',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'SendIt Pilot is the official app for delivery partners. Earn money by delivering packages in your city.',
              style: AppTextStyles.bodySmall.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '\u00a9 2024 SendIt. All rights reserved.',
              style: AppTextStyles.caption,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
