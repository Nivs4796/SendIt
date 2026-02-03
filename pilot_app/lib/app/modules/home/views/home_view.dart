import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../routes/app_routes.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(theme),
              
              const SizedBox(height: 24),

              // Online/Offline Toggle
              _buildOnlineToggle(theme),

              const SizedBox(height: 24),

              // Stats Cards
              _buildStatsSection(theme),

              const SizedBox(height: 24),

              // Active Vehicle
              _buildActiveVehicle(theme),

              const SizedBox(height: 24),

              // Quick Actions
              _buildQuickActions(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() => Text(
                'Hey ${controller.pilot.value?.name.split(' ').first ?? 'Pilot'},',
                style: AppTextStyles.h3.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              )),
              Text(
                controller.greeting,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Get.toNamed(Routes.notifications),
          icon: Icon(
            Icons.notifications_outlined,
            color: theme.colorScheme.onSurface,
          ),
        ),
        IconButton(
          onPressed: () => Get.toNamed(Routes.profile),
          icon: Icon(
            Icons.person_outline,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildOnlineToggle(ThemeData theme) {
    return Obx(() => Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: controller.isOnline.value
            ? LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.8),
                ],
              )
            : null,
        color: controller.isOnline.value ? null : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.isOnline.value ? "You're Online" : "You're Offline",
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: controller.isOnline.value
                        ? Colors.white
                        : theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  controller.isOnline.value
                      ? 'Ready to receive orders'
                      : 'Go online to start earning',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: controller.isOnline.value
                        ? Colors.white.withValues(alpha: 0.8)
                        : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                if (!controller.isOnline.value && controller.missedOrderValue.value > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    'You missed ₹${controller.missedOrderValue.value.toStringAsFixed(0)} today',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          GestureDetector(
            onTap: controller.isLoading.value ? null : controller.toggleOnlineStatus,
            child: Container(
              width: 64,
              height: 36,
              decoration: BoxDecoration(
                color: controller.isOnline.value
                    ? Colors.white
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Stack(
                children: [
                  AnimatedAlign(
                    duration: const Duration(milliseconds: 200),
                    alignment: controller.isOnline.value
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      width: 28,
                      height: 28,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: controller.isOnline.value
                            ? AppColors.primary
                            : theme.colorScheme.outline,
                        shape: BoxShape.circle,
                      ),
                      child: controller.isLoading.value
                          ? const Padding(
                              padding: EdgeInsets.all(6),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildStatsSection(ThemeData theme) {
    return Column(
      children: [
        // Tab Selector
        Obx(() => Row(
          children: [
            _buildStatTab(theme, 'Today', 0),
            const SizedBox(width: 12),
            _buildStatTab(theme, 'This Week', 1),
          ],
        )),
        const SizedBox(height: 16),
        // Stats Grid
        Obx(() => Row(
          children: [
            Expanded(
              child: _buildStatCard(
                theme,
                icon: Icons.currency_rupee,
                label: 'Earnings',
                value: '₹${controller.selectedStatsTab.value == 0 ? controller.todayEarnings.value.toStringAsFixed(0) : controller.weekEarnings.value.toStringAsFixed(0)}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                theme,
                icon: Icons.access_time,
                label: 'Hours',
                value: '${controller.selectedStatsTab.value == 0 ? controller.todayHours.value.toStringAsFixed(1) : controller.weekHours.value.toStringAsFixed(1)}h',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                theme,
                icon: Icons.local_shipping_outlined,
                label: 'Rides',
                value: '${controller.selectedStatsTab.value == 0 ? controller.todayRides.value : controller.weekRides.value}',
              ),
            ),
          ],
        )),
      ],
    );
  }

  Widget _buildStatTab(ThemeData theme, String label, int index) {
    final isSelected = controller.selectedStatsTab.value == index;
    return GestureDetector(
      onTap: () => controller.selectedStatsTab.value = index,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: isSelected ? Colors.white : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
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

  Widget _buildActiveVehicle(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.two_wheeler,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '2 Wheeler - EV',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Active',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'GJ-01-AB-1234',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Change',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildQuickAction(theme, Icons.account_balance_wallet_outlined, 'Wallet', Routes.wallet)),
            const SizedBox(width: 12),
            Expanded(child: _buildQuickAction(theme, Icons.bar_chart, 'Earnings', Routes.earnings)),
            const SizedBox(width: 12),
            Expanded(child: _buildQuickAction(theme, Icons.two_wheeler_outlined, 'Vehicles', Routes.vehicles)),
            const SizedBox(width: 12),
            Expanded(child: _buildQuickAction(theme, Icons.card_giftcard, 'Rewards', Routes.rewards)),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAction(ThemeData theme, IconData icon, String label, String route) {
    return GestureDetector(
      onTap: () => Get.toNamed(route),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}
