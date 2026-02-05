import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import '../data/providers/api_client.dart';
import '../core/constants/api_constants.dart';
import 'storage_service.dart';

// Background message handler - must be top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Background message: ${message.messageId}');
}

class NotificationService extends GetxService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  String? _fcmToken;
  String? get fcmToken => _fcmToken;
  
  final RxBool hasPermission = false.obs;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    // Set background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    // Request permission
    await requestPermission();
    
    // Get FCM token
    await _getToken();
    
    // Listen for token refresh
    _messaging.onTokenRefresh.listen((token) {
      _fcmToken = token;
      _sendTokenToServer(token);
    });
    
    // Initialize local notifications
    await _initLocalNotifications();
    
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
    
    // Check if app was opened from notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  Future<void> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    
    hasPermission.value = settings.authorizationStatus == AuthorizationStatus.authorized;
    debugPrint('Notification permission: ${settings.authorizationStatus}');
  }

  Future<void> _getToken() async {
    try {
      _fcmToken = await _messaging.getToken();
      debugPrint('FCM Token: $_fcmToken');
      if (_fcmToken != null) {
        await _sendTokenToServer(_fcmToken!);
      }
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
    }
  }

  Future<void> _sendTokenToServer(String token) async {
    try {
      // Only send if user is logged in
      final storageService = Get.find<StorageService>();
      final authToken = storageService.token;
      
      if (authToken == null || authToken.isEmpty) {
        debugPrint('Not logged in, skipping FCM token registration');
        return;
      }

      final apiClient = Get.find<ApiClient>();
      await apiClient.post(
        ApiConstants.fcmRegister,
        data: {'fcmToken': token},
      );
      debugPrint('✅ FCM token registered with server');
    } catch (e) {
      debugPrint('❌ Failed to register FCM token: $e');
    }
  }
  
  /// Call this after login to register FCM token
  Future<void> registerTokenAfterLogin() async {
    if (_fcmToken != null) {
      await _sendTokenToServer(_fcmToken!);
    }
  }
  
  /// Call this on logout to clear FCM token
  Future<void> clearTokenOnLogout() async {
    try {
      final apiClient = Get.find<ApiClient>();
      await apiClient.delete(ApiConstants.fcmClearToken);
      debugPrint('✅ FCM token cleared from server');
    } catch (e) {
      debugPrint('❌ Failed to clear FCM token: $e');
    }
  }

  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        _handleLocalNotificationTap(response.payload);
      },
    );
    
    // Create notification channel for Android
    const channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );
    
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Foreground message: ${message.notification?.title}');
    
    final notification = message.notification;
    if (notification != null) {
      _showLocalNotification(
        title: notification.title ?? 'SendIt',
        body: notification.body ?? '',
        payload: jsonEncode(message.data),
      );
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('Notification tapped: ${message.data}');
    _navigateBasedOnData(message.data);
  }

  void _handleLocalNotificationTap(String? payload) {
    if (payload != null) {
      try {
        final data = jsonDecode(payload) as Map<String, dynamic>;
        _navigateBasedOnData(data);
      } catch (e) {
        debugPrint('Error parsing notification payload: $e');
      }
    }
  }

  void _navigateBasedOnData(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    final id = data['id'] as String?;
    
    switch (type) {
      case 'booking':
      case 'order':
        if (id != null) Get.toNamed('/orders/details', arguments: {'id': id});
        break;
      case 'wallet':
        Get.toNamed('/wallet');
        break;
      default:
        Get.toNamed('/notifications');
    }
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  // Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  // Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }
}
