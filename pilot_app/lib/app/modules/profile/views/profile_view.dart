import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../routes/app_routes.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Obx(() {
        if (controller.isLoading.value && controller.pilot.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Custom App Bar with Profile Header
              _buildSliverAppBar(theme),

              // Body Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Stats Cards
                      _buildStatsSection(theme),
                      const SizedBox(height: 24),

                      // Account Section
                      _buildSectionTitle('Account', theme),
                      const SizedBox(height: 12),
                      _buildAccountSection(theme),
                      const SizedBox(height: 24),

                      // Preferences Section
                      _buildSectionTitle('Preferences', theme),
                      const SizedBox(height: 12),
                      _buildPreferencesSection(theme),
                      const SizedBox(height: 24),

                      // Support Section
                      _buildSectionTitle('Support', theme),
                      const SizedBox(height: 12),
                      _buildSupportSection(theme),
                      const SizedBox(height: 24),

                      // Logout & Delete
                      _buildDangerSection(theme),
                      const SizedBox(height: 24),

                      // App Version
                      Text(
                        'SendIt Pilot v1.0.0',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSliverAppBar(ThemeData theme) {
    final pilot = controller.pilot.value;
    final dateFormat = DateFormat('MMM yyyy');

    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: AppColors.primary,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
        ),
        onPressed: () => Get.back(),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.edit_outlined, color: Colors.white, size: 20),
          ),
          onPressed: () => _showEditProfileSheet(theme),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.primary.withValues(alpha: 0.85),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                // Avatar
                GestureDetector(
                  onTap: controller.uploadProfilePhoto,
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.5),
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
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            color: AppColors.primary,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Name
                Text(
                  pilot?.name ?? 'Pilot',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),

                // Phone
                Text(
                  pilot?.phone ?? '',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 12),

                // Badges Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Verified Badge
                    if (pilot?.isVerified == true)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.verified,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Verified',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(width: 8),

                    // Rating Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star,
                            size: 14,
                            color: Colors.amber,
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

                    // Member Since
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            dateFormat.format(pilot?.createdAt ?? DateTime.now()),
                            style: AppTextStyles.labelSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(ThemeData theme) {
    final pilot = controller.pilot.value;
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            theme,
            icon: Icons.local_shipping_outlined,
            value: '${pilot?.totalRides ?? 0}',
            label: 'Total Rides',
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            theme,
            icon: Icons.star_outline,
            value: pilot?.rating?.toStringAsFixed(1) ?? '0.0',
            label: 'Rating',
            color: Colors.amber,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            theme,
            icon: Icons.emoji_events_outlined,
            value: _getExperienceText(pilot?.createdAt),
            label: 'Experience',
            color: Colors.purple,
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
    ThemeData theme, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
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
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: AppTextStyles.titleSmall.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
        ),
      ),
    );
  }

  Widget _buildAccountSection(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildMenuItem(
            theme,
            icon: Icons.two_wheeler_outlined,
            iconColor: Colors.blue,
            title: 'My Vehicles',
            subtitle: 'Manage your vehicles',
            onTap: () => Get.toNamed(Routes.vehicles),
          ),
          _buildDivider(theme),
          _buildMenuItem(
            theme,
            icon: Icons.description_outlined,
            iconColor: Colors.orange,
            title: 'Documents',
            subtitle: 'View and update documents',
            onTap: () => Get.toNamed(Routes.documents),
          ),
          _buildDivider(theme),
          _buildMenuItem(
            theme,
            icon: Icons.account_balance_outlined,
            iconColor: Colors.green,
            title: 'Bank Details',
            subtitle: 'Payment account settings',
            onTap: () => Get.toNamed(Routes.bankDetails),
          ),
          _buildDivider(theme),
          _buildMenuItem(
            theme,
            icon: Icons.history_outlined,
            iconColor: Colors.teal,
            title: 'Job History',
            subtitle: 'View past deliveries',
            onTap: () => Get.toNamed(Routes.jobHistory),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildMenuItem(
            theme,
            icon: Icons.notifications_outlined,
            iconColor: Colors.purple,
            title: 'Notifications',
            subtitle: 'Notification preferences',
            onTap: () => Get.toNamed(Routes.notifications),
          ),
          _buildDivider(theme),
          _buildMenuItem(
            theme,
            icon: Icons.language_outlined,
            iconColor: Colors.teal,
            title: 'Language',
            subtitle: 'English',
            trailing: const Icon(Icons.chevron_right, size: 20),
            onTap: () => _showComingSoon('Language'),
          ),
          _buildDivider(theme),
          _buildMenuItem(
            theme,
            icon: Icons.dark_mode_outlined,
            iconColor: Colors.indigo,
            title: 'Dark Mode',
            subtitle: 'System default',
            trailing: Switch(
              value: false,
              onChanged: (val) => _showComingSoon('Dark Mode'),
              activeColor: AppColors.primary,
            ),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildMenuItem(
            theme,
            icon: Icons.help_outline,
            iconColor: Colors.cyan,
            title: 'Help & Support',
            subtitle: 'Get help and FAQs',
            onTap: () => Get.toNamed(Routes.help),
          ),
          _buildDivider(theme),
          _buildMenuItem(
            theme,
            icon: Icons.card_giftcard_outlined,
            iconColor: Colors.amber,
            title: 'Rewards & Referrals',
            subtitle: 'Earn rewards and refer friends',
            onTap: () => Get.toNamed(Routes.rewards),
          ),
          _buildDivider(theme),
          _buildMenuItem(
            theme,
            icon: Icons.privacy_tip_outlined,
            iconColor: Colors.grey,
            title: 'Privacy Policy',
            subtitle: 'Read our privacy policy',
            onTap: () => _showComingSoon('Privacy Policy'),
          ),
          _buildDivider(theme),
          _buildMenuItem(
            theme,
            icon: Icons.article_outlined,
            iconColor: Colors.grey,
            title: 'Terms of Service',
            subtitle: 'Read terms and conditions',
            onTap: () => _showComingSoon('Terms of Service'),
          ),
          _buildDivider(theme),
          _buildMenuItem(
            theme,
            icon: Icons.info_outline,
            iconColor: Colors.blueGrey,
            title: 'About',
            subtitle: 'About SendIt Pilot',
            onTap: () => _showAboutDialog(theme),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(ThemeData theme) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.local_shipping, color: AppColors.primary),
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
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '© 2024 SendIt. All rights reserved.',
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

  Widget _buildDangerSection(ThemeData theme) {
    return Column(
      children: [
        // Logout Button
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: _buildMenuItem(
            theme,
            icon: Icons.logout,
            iconColor: Colors.orange,
            title: 'Logout',
            subtitle: 'Sign out of your account',
            titleColor: Colors.orange,
            onTap: controller.logout,
          ),
        ),
        const SizedBox(height: 12),

        // Delete Account Button
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.red.withValues(alpha: 0.2),
            ),
          ),
          child: _buildMenuItem(
            theme,
            icon: Icons.delete_forever_outlined,
            iconColor: Colors.red,
            title: 'Delete Account',
            subtitle: 'Permanently delete your account',
            titleColor: Colors.red,
            onTap: controller.deleteAccount,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    ThemeData theme, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
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
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              trailing ??
                  Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    size: 22,
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 62),
      child: Divider(
        height: 1,
        color: theme.dividerColor.withValues(alpha: 0.5),
      ),
    );
  }

  void _showComingSoon(String feature) {
    Get.snackbar(
      'Coming Soon',
      '$feature will be available soon!',
      backgroundColor: Colors.blue.shade100,
      colorText: Colors.blue.shade900,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  void _showEditProfileSheet(ThemeData theme) {
    final pilot = controller.pilot.value;
    final nameController = TextEditingController(text: pilot?.name);
    final emailController = TextEditingController(text: pilot?.email);
    final emergencyController =
        TextEditingController(text: pilot?.emergencyContact);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Edit Profile',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Name Field
            _buildTextField(
              controller: nameController,
              label: 'Full Name',
              icon: Icons.person_outline,
              theme: theme,
            ),
            const SizedBox(height: 16),

            // Email Field
            _buildTextField(
              controller: emailController,
              label: 'Email Address',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              theme: theme,
            ),
            const SizedBox(height: 16),

            // Emergency Contact Field
            _buildTextField(
              controller: emergencyController,
              label: 'Emergency Contact',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              theme: theme,
            ),
            const SizedBox(height: 24),

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
                            );
                            if (success) Get.back();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
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
            const SizedBox(height: 16),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ThemeData theme,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary, size: 22),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
