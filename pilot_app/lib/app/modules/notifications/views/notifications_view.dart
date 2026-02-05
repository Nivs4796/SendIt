import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/notifications_controller.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Notifications'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          actions: [
            Obx(() {
              if (controller.unreadCount.value > 0) {
                return TextButton(
                  onPressed: controller.markAllAsRead,
                  child: const Text('Mark all read'),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
          bottom: TabBar(
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Settings'),
            ],
            labelColor: AppColors.primary,
            unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            indicatorColor: AppColors.primary,
          ),
        ),
        body: TabBarView(
          children: [
            _buildNotificationsList(theme),
            _buildSettings(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList(ThemeData theme) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.notifications.isEmpty) {
        return _buildEmptyState(theme);
      }

      return RefreshIndicator(
        onRefresh: controller.refresh,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.notifications.length,
          itemBuilder: (context, index) {
            return _buildNotificationItem(theme, controller.notifications[index]);
          },
        ),
      );
    });
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No Notifications',
            style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "You're all caught up!",
            style: AppTextStyles.bodyMedium.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(ThemeData theme, NotificationItem notification) {
    final timeFormat = DateFormat('h:mm a');
    final dateFormat = DateFormat('MMM d');
    final isToday = DateTime.now().difference(notification.timestamp).inDays == 0;

    IconData icon;
    Color iconColor;
    switch (notification.type) {
      case NotificationType.job:
        icon = Icons.local_shipping;
        iconColor = Colors.blue;
        break;
      case NotificationType.earning:
        icon = Icons.account_balance_wallet;
        iconColor = Colors.green;
        break;
      case NotificationType.bonus:
        icon = Icons.star;
        iconColor = Colors.amber;
        break;
      case NotificationType.promo:
        icon = Icons.local_offer;
        iconColor = Colors.purple;
        break;
      case NotificationType.system:
        icon = Icons.info;
        iconColor = Colors.grey;
        break;
    }

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => controller.deleteNotification(notification.id),
      child: GestureDetector(
        onTap: () => controller.markAsRead(notification.id),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notification.isRead
                ? theme.colorScheme.surfaceContainerHighest
                : AppColors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: notification.isRead
                ? null
                : Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isToday
                          ? timeFormat.format(notification.timestamp)
                          : dateFormat.format(notification.timestamp),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettings(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notification Preferences',
            style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: Column(
              children: [
                Obx(() => SwitchListTile(
                  title: const Text('Push Notifications'),
                  subtitle: const Text('Receive push notifications'),
                  value: controller.pushEnabled.value,
                  onChanged: (v) => controller.updateSettings(pushEnabled: v),
                  activeColor: AppColors.primary,
                )),
                Divider(height: 1, indent: 16, endIndent: 16, color: theme.dividerColor),
                Obx(() => SwitchListTile(
                  title: const Text('Job Alerts'),
                  subtitle: const Text('New delivery opportunities'),
                  value: controller.jobAlertsEnabled.value,
                  onChanged: (v) => controller.updateSettings(jobAlerts: v),
                  activeColor: AppColors.primary,
                )),
                Divider(height: 1, indent: 16, endIndent: 16, color: theme.dividerColor),
                Obx(() => SwitchListTile(
                  title: const Text('Earnings Updates'),
                  subtitle: const Text('Payment and wallet updates'),
                  value: controller.earningsAlertsEnabled.value,
                  onChanged: (v) => controller.updateSettings(earningsAlerts: v),
                  activeColor: AppColors.primary,
                )),
                Divider(height: 1, indent: 16, endIndent: 16, color: theme.dividerColor),
                Obx(() => SwitchListTile(
                  title: const Text('Promotions'),
                  subtitle: const Text('Special offers and bonuses'),
                  value: controller.promoAlertsEnabled.value,
                  onChanged: (v) => controller.updateSettings(promoAlerts: v),
                  activeColor: AppColors.primary,
                )),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Note: You will always receive critical notifications about your active deliveries and account security.',
            style: AppTextStyles.labelSmall.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
