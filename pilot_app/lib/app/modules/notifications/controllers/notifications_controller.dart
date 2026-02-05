import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import '../../../data/repositories/notifications_repository.dart';

class NotificationsController extends GetxController {
  final NotificationsRepository _repository = NotificationsRepository();

  // State
  final isLoading = true.obs;
  final isLoadingMore = false.obs;
  final notifications = <NotificationItem>[].obs;
  final unreadCount = 0.obs;

  // Pagination
  int _currentPage = 1;
  bool _hasMore = true;

  // Settings
  final pushEnabled = true.obs;
  final jobAlertsEnabled = true.obs;
  final earningsAlertsEnabled = true.obs;
  final promoAlertsEnabled = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  /// Load notifications
  Future<void> loadNotifications({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      notifications.clear();
    }

    if (!_hasMore || isLoadingMore.value) return;

    try {
      if (_currentPage == 1) {
        isLoading.value = true;
      } else {
        isLoadingMore.value = true;
      }

      final response = await _repository.getNotifications(page: _currentPage);
      
      // Convert repository model to local model
      final newNotifications = response.notifications.map((n) => NotificationItem(
        id: n.id,
        type: NotificationType.values.firstWhere(
          (t) => t.name == n.type.name,
          orElse: () => NotificationType.system,
        ),
        title: n.title,
        message: n.message,
        timestamp: n.timestamp,
        isRead: n.isRead,
        actionUrl: n.actionUrl,
      )).toList();

      if (_currentPage == 1) {
        notifications.value = newNotifications;
      } else {
        notifications.addAll(newNotifications);
      }
      
      unreadCount.value = notifications.where((n) => !n.isRead).length;
      _hasMore = response.hasMore;
      _currentPage++;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load notifications',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  /// Load more notifications
  void loadMore() {
    if (_hasMore && !isLoadingMore.value) {
      loadNotifications();
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    final index = notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1 && !notifications[index].isRead) {
      // Optimistic update
      notifications[index] = notifications[index].copyWith(isRead: true);
      unreadCount.value = notifications.where((n) => !n.isRead).length;
      
      // Sync with server
      await _repository.markAsRead(notificationId);
    }
  }

  /// Mark all as read
  Future<void> markAllAsRead() async {
    // Optimistic update
    for (var i = 0; i < notifications.length; i++) {
      notifications[i] = notifications[i].copyWith(isRead: true);
    }
    unreadCount.value = 0;
    
    // Sync with server
    await _repository.markAllAsRead();
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    final wasUnread = notifications.firstWhereOrNull((n) => n.id == notificationId)?.isRead == false;
    notifications.removeWhere((n) => n.id == notificationId);
    if (wasUnread) {
      unreadCount.value = notifications.where((n) => !n.isRead).length;
    }
    
    // Sync with server
    await _repository.deleteNotification(notificationId);
  }

  /// Update notification settings
  Future<void> updateSettings({
    bool? pushEnabled,
    bool? jobAlerts,
    bool? earningsAlerts,
    bool? promoAlerts,
  }) async {
    if (pushEnabled != null) this.pushEnabled.value = pushEnabled;
    if (jobAlerts != null) jobAlertsEnabled.value = jobAlerts;
    if (earningsAlerts != null) earningsAlertsEnabled.value = earningsAlerts;
    if (promoAlerts != null) promoAlertsEnabled.value = promoAlerts;

    // Save to server
    await _repository.updateSettings(
      pushEnabled: this.pushEnabled.value,
      jobAlerts: jobAlertsEnabled.value,
      earningsAlerts: earningsAlertsEnabled.value,
      promoAlerts: promoAlertsEnabled.value,
    );
  }

  /// Refresh notifications
  Future<void> refresh() => loadNotifications(refresh: true);
}

/// Notification types
enum NotificationType { job, earning, bonus, promo, system }

/// Notification item model
class NotificationItem {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String? actionUrl;

  NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.actionUrl,
  });

  NotificationItem copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? message,
    DateTime? timestamp,
    bool? isRead,
    String? actionUrl,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      actionUrl: actionUrl ?? this.actionUrl,
    );
  }
}
