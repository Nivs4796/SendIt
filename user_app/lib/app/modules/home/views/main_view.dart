import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../routes/app_routes.dart';

class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('SendIt'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Get.snackbar(
                'Coming Soon',
                'Notifications will be available in a future update',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: theme.colorScheme.primary,
                colorText: theme.colorScheme.onPrimary,
                margin: const EdgeInsets.all(16),
                borderRadius: 8,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Get.toNamed(Routes.profile);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            _buildWelcomeCard(context),
            const SizedBox(height: 24),

            // Quick Actions Section
            Text(
              'Quick Actions',
              style: AppTextStyles.h4.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            _buildQuickActionsGrid(context),
            const SizedBox(height: 24),

            // Development Status Card
            _buildDevelopmentStatusCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, const Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to SendIt!',
            style: AppTextStyles.h2.copyWith(
              color: Colors.white,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your reliable delivery partner',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    final theme = Theme.of(context);

    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.1,
      children: [
        _QuickActionCard(
          icon: Icons.local_shipping,
          title: 'Book Now',
          subtitle: 'Send a package',
          onTap: () {
            Get.snackbar(
              'Coming Soon',
              'Booking flow in Sprint 1',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: theme.colorScheme.primary,
              colorText: theme.colorScheme.onPrimary,
              margin: const EdgeInsets.all(16),
              borderRadius: 8,
            );
          },
        ),
        _QuickActionCard(
          icon: Icons.history,
          title: 'My Orders',
          subtitle: 'View order history',
          onTap: () {
            Get.snackbar(
              'Coming Soon',
              'Orders in Sprint 2',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: theme.colorScheme.primary,
              colorText: theme.colorScheme.onPrimary,
              margin: const EdgeInsets.all(16),
              borderRadius: 8,
            );
          },
        ),
        _QuickActionCard(
          icon: Icons.account_balance_wallet,
          title: 'Wallet',
          subtitle: 'Manage payments',
          onTap: () {
            Get.toNamed(Routes.wallet);
          },
        ),
        _QuickActionCard(
          icon: Icons.location_on,
          title: 'Addresses',
          subtitle: 'Saved locations',
          onTap: () {
            Get.toNamed(Routes.savedAddresses);
          },
        ),
      ],
    );
  }

  Widget _buildDevelopmentStatusCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.primary.withValues(alpha: 0.1)
            : const Color(0xFFDBEAFE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Development Status',
                style: AppTextStyles.labelLarge.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildStatusItem(context, 'Auth Flow', true),
          const SizedBox(height: 8),
          _buildStatusItem(context, 'Profile & Wallet', true),
          const SizedBox(height: 8),
          _buildStatusItem(context, 'Booking Flow', false, subtitle: 'Sprint 1'),
          const SizedBox(height: 8),
          _buildStatusItem(context, 'Orders & Tracking', false, subtitle: 'Sprint 2'),
        ],
      ),
    );
  }

  Widget _buildStatusItem(BuildContext context, String title, bool isComplete, {String? subtitle}) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          isComplete ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isComplete
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurfaceVariant,
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isComplete
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (isComplete)
          Text(
            ' \u2713',
            style: AppTextStyles.bodyMedium.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        if (subtitle != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              subtitle,
              style: AppTextStyles.labelSmall.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? theme.colorScheme.primary.withValues(alpha: 0.15)
                  : theme.dividerColor,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                blurRadius: isDark ? 8 : 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: AppTextStyles.labelLarge.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTextStyles.caption.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
