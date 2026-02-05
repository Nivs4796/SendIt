import 'package:get/get.dart' hide Response;
import '../providers/api_client.dart';
import '../providers/api_exceptions.dart';
import '../../core/constants/api_constants.dart';

class NotificationsRepository {
  final ApiClient _api = Get.find<ApiClient>();

  /// Get notifications with pagination
  /// GET /pilots/notifications
  Future<NotificationsResponse> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _api.get(
        ApiConstants.notifications,
        queryParameters: {'page': page, 'limit': limit},
      );
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        return NotificationsResponse.fromJson(response.data);
      }
      
      throw ApiException(
        message: response.data['message'] ?? 'Failed to load notifications',
        statusCode: response.statusCode,
      );
    } on ApiException {
      rethrow;
    } on NetworkException {
      // Return mock data for development when network fails
      return _getMockNotifications();
    } on TimeoutException {
      return _getMockNotifications();
    } catch (e) {
      // Fallback to mock data for development
      return _getMockNotifications();
    }
  }

  /// Mark notification as read
  /// PATCH /pilots/notifications/:id/read
  Future<bool> markAsRead(String notificationId) async {
    try {
      final response = await _api.patch(
        ApiConstants.notificationRead(notificationId),
      );
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        return true;
      }
      
      return false;
    } on ApiException {
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Mark all notifications as read
  /// PATCH /pilots/notifications/read-all
  Future<bool> markAllAsRead() async {
    try {
      final response = await _api.patch(ApiConstants.markAllNotificationsRead);
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        return true;
      }
      
      return false;
    } on ApiException {
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Delete notification
  /// DELETE /pilots/notifications/:id
  Future<bool> deleteNotification(String notificationId) async {
    try {
      final response = await _api.delete(
        '${ApiConstants.notifications}/$notificationId',
      );
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        return true;
      }
      
      return false;
    } on ApiException {
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Get notification settings
  /// GET /pilots/notification-settings
  Future<NotificationSettings> getSettings() async {
    try {
      final response = await _api.get(ApiConstants.notificationSettings);
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        return NotificationSettings.fromJson(response.data['data']);
      }
      
      throw ApiException(
        message: response.data['message'] ?? 'Failed to load settings',
        statusCode: response.statusCode,
      );
    } on ApiException {
      rethrow;
    } on NetworkException {
      return _getMockSettings();
    } on TimeoutException {
      return _getMockSettings();
    } catch (e) {
      return _getMockSettings();
    }
  }

  /// Update notification settings
  /// PATCH /pilots/notification-settings
  Future<bool> updateSettings({
    required bool pushEnabled,
    required bool jobAlerts,
    required bool earningsAlerts,
    required bool promoAlerts,
  }) async {
    try {
      final response = await _api.patch(
        ApiConstants.notificationSettings,
        data: {
          'pushEnabled': pushEnabled,
          'jobAlerts': jobAlerts,
          'earningsAlerts': earningsAlerts,
          'promoAlerts': promoAlerts,
        },
      );
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        return true;
      }
      
      return false;
    } on ApiException {
      return false;
    } catch (e) {
      return false;
    }
  }

  NotificationSettings _getMockSettings() {
    return NotificationSettings(
      pushEnabled: true,
      jobAlerts: true,
      earningsAlerts: true,
      promoAlerts: true,
    );
  }

  NotificationsResponse _getMockNotifications() {
    final now = DateTime.now();
    final notifications = [
      NotificationItemModel(
        id: '1',
        type: NotificationTypeModel.job,
        title: 'New Delivery Request',
        message: 'A new delivery request is available near you',
        timestamp: now.subtract(const Duration(minutes: 5)),
        isRead: false,
      ),
      NotificationItemModel(
        id: '2',
        type: NotificationTypeModel.earning,
        title: 'Payment Received',
        message: '₹149 has been added to your wallet',
        timestamp: now.subtract(const Duration(hours: 1)),
        isRead: false,
      ),
      NotificationItemModel(
        id: '3',
        type: NotificationTypeModel.bonus,
        title: 'Bonus Earned! 🎉',
        message: 'You earned a ₹100 bonus for completing 5 deliveries',
        timestamp: now.subtract(const Duration(hours: 3)),
        isRead: true,
      ),
      NotificationItemModel(
        id: '4',
        type: NotificationTypeModel.promo,
        title: 'Weekend Special',
        message: 'Earn 1.5x on all deliveries this weekend!',
        timestamp: now.subtract(const Duration(days: 1)),
        isRead: true,
      ),
      NotificationItemModel(
        id: '5',
        type: NotificationTypeModel.system,
        title: 'Document Verified',
        message: 'Your driving license has been verified successfully',
        timestamp: now.subtract(const Duration(days: 2)),
        isRead: true,
      ),
      NotificationItemModel(
        id: '6',
        type: NotificationTypeModel.job,
        title: 'Delivery Completed',
        message: 'You have successfully completed delivery #SND-001234',
        timestamp: now.subtract(const Duration(days: 2, hours: 3)),
        isRead: true,
      ),
      NotificationItemModel(
        id: '7',
        type: NotificationTypeModel.earning,
        title: 'Weekly Earnings Report',
        message: 'You earned ₹8,500 this week. Great job!',
        timestamp: now.subtract(const Duration(days: 3)),
        isRead: true,
      ),
    ];

    return NotificationsResponse(
      notifications: notifications,
      unreadCount: notifications.where((n) => !n.isRead).length,
      totalCount: notifications.length,
      hasMore: false,
    );
  }
}

/// Notification settings model
class NotificationSettings {
  final bool pushEnabled;
  final bool jobAlerts;
  final bool earningsAlerts;
  final bool promoAlerts;

  NotificationSettings({
    required this.pushEnabled,
    required this.jobAlerts,
    required this.earningsAlerts,
    required this.promoAlerts,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      pushEnabled: json['pushEnabled'] as bool? ?? true,
      jobAlerts: json['jobAlerts'] as bool? ?? true,
      earningsAlerts: json['earningsAlerts'] as bool? ?? true,
      promoAlerts: json['promoAlerts'] as bool? ?? true,
    );
  }
}

/// Notifications response
class NotificationsResponse {
  final List<NotificationItemModel> notifications;
  final int unreadCount;
  final int totalCount;
  final bool hasMore;

  NotificationsResponse({
    required this.notifications,
    required this.unreadCount,
    required this.totalCount,
    required this.hasMore,
  });

  factory NotificationsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    List<dynamic> notificationsList;
    
    // Handle different response formats
    if (data is List) {
      notificationsList = data;
    } else if (data is Map) {
      notificationsList = data['notifications'] ?? [];
    } else {
      notificationsList = [];
    }

    final notifications = notificationsList
        .map((e) => NotificationItemModel.fromJson(e))
        .toList();

    // Get meta info
    final meta = json['meta'] as Map<String, dynamic>?;
    
    return NotificationsResponse(
      notifications: notifications,
      unreadCount: json['unreadCount'] as int? ?? 
          (data is Map ? data['unreadCount'] as int? : null) ?? 
          notifications.where((n) => !n.isRead).length,
      totalCount: meta?['total'] as int? ?? 
          json['totalCount'] as int? ?? 
          notifications.length,
      hasMore: meta != null 
          ? (meta['page'] as int? ?? 1) < (meta['totalPages'] as int? ?? 1)
          : (json['hasMore'] as bool? ?? false),
    );
  }
}

/// Notification types
enum NotificationTypeModel { job, earning, bonus, promo, system }

/// Notification item model
class NotificationItemModel {
  final String id;
  final NotificationTypeModel type;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String? actionUrl;
  final Map<String, dynamic>? data;

  NotificationItemModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.actionUrl,
    this.data,
  });

  factory NotificationItemModel.fromJson(Map<String, dynamic> json) {
    return NotificationItemModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      type: _parseNotificationType(json['type']),
      title: json['title'] ?? '',
      message: json['message'] ?? json['body'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
          : (json['createdAt'] != null 
              ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
              : DateTime.now()),
      isRead: json['isRead'] as bool? ?? json['read'] as bool? ?? false,
      actionUrl: json['actionUrl'] as String?,
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  static NotificationTypeModel _parseNotificationType(dynamic type) {
    if (type == null) return NotificationTypeModel.system;
    final typeStr = type.toString().toLowerCase();
    switch (typeStr) {
      case 'job':
      case 'booking':
      case 'delivery':
        return NotificationTypeModel.job;
      case 'earning':
      case 'earnings':
      case 'payment':
        return NotificationTypeModel.earning;
      case 'bonus':
      case 'incentive':
        return NotificationTypeModel.bonus;
      case 'promo':
      case 'promotion':
      case 'offer':
        return NotificationTypeModel.promo;
      case 'system':
      case 'general':
      case 'info':
      default:
        return NotificationTypeModel.system;
    }
  }

  NotificationItemModel copyWith({
    String? id,
    NotificationTypeModel? type,
    String? title,
    String? message,
    DateTime? timestamp,
    bool? isRead,
    String? actionUrl,
    Map<String, dynamic>? data,
  }) {
    return NotificationItemModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      actionUrl: actionUrl ?? this.actionUrl,
      data: data ?? this.data,
    );
  }
}
