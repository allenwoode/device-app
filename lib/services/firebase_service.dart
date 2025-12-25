
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:device/models/notification_models.dart';
import 'package:device/events/event_bus.dart';
import 'package:device/routes/app_routes.dart';
import 'package:device/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

// Top-level function to handle background messages
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
  print("Background Message Title: ${message.notification?.title}");
  print("Background Message Body: ${message.notification?.body}");
  print("Background Message Data: ${message.data}");
}

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  bool _initialized = false;

  // Store notifications
  final List<NotificationItem> _notifications_list = [];

  // Counter for generating notification IDs
  int _notificationIdCounter = 1000;

  // Track processed message IDs to prevent duplicates
  final Set<String> _processedMessageIds = {};

  AppLocalizations get _l10n {
    try {
      final context = AppRoutes.navigatorKey.currentContext;
      if (context != null) {
        return AppLocalizations.of(context)!;
      }
      return lookupAppLocalizations(const Locale('zh'));
    } catch (e) {
      // Fallback when context is not ready
      return lookupAppLocalizations(const Locale('zh'));
    }
  }

  /// Get all notifications
  List<NotificationItem> get notifications =>
      List.unmodifiable(_notifications_list);

  /// Get unread notification count
  int get unreadCount => _notifications_list.where((n) => !n.isRead).length;

  /// Mark notification as read
  void markAsRead(int id) {
    final index = _notifications_list.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications_list[index] = _notifications_list[index].copyWith(
        isRead: true,
      );
      // Notify all pages about count change
      EventBus.instance.commit(EventKeys.notificationCountChanged, unreadCount);
    }
  }

  /// Mark all notifications as read
  void markAllAsRead() {
    for (int i = 0; i < _notifications_list.length; i++) {
      _notifications_list[i] = _notifications_list[i].copyWith(isRead: true);
    }
    // Notify all pages about count change
    EventBus.instance.commit(EventKeys.notificationCountChanged, unreadCount);
  }

  /// Clear all notifications
  void clearAllNotifications() {
    _notifications_list.clear();
    // Notify all pages about count change
    EventBus.instance.commit(EventKeys.notificationCountChanged, unreadCount);
  }

  /// Add notification to list (with duplicate prevention)
  void _addNotification(RemoteMessage message, {String? title, String? body}) {
    // Prevent duplicates using message ID
    final messageId = message.messageId;
    if (messageId != null && _processedMessageIds.contains(messageId)) {
      print('Duplicate notification ignored: $messageId');
      return;
    }

    final notificationItem = NotificationItem(
      id: _notificationIdCounter++,
      title: title ?? message.notification?.title ?? 'Notification',
      body: body ?? message.notification?.body ?? '',
      payload: message.data,
      timestamp: DateTime.now(),
      isRead: false,
    );
    _notifications_list.insert(0, notificationItem);

    // Track this message ID
    if (messageId != null) {
      _processedMessageIds.add(messageId);
    }

    // Broadcast notification event to all pages via EventBus
    EventBus.instance.commit(EventKeys.notificationReceived, notificationItem);
    EventBus.instance.commit(EventKeys.notificationCountChanged, unreadCount);
  }

  /// Handle notification tap
  void _onNotificationTapped(RemoteMessage message, {String? title, String? body}) {

    // Add to notification list if not already added
    _addNotification(message, title: title, body: body);

    // Handle navigation based on data payload
    final data = message.data;
    if (data.isEmpty) return;

    // Parse payload format: {"type": "device_alert", "deviceId": "...", "productId": "..."}
    final type = data['type'] as String?;
    final deviceId = data['deviceId'] as String?;
    final productId = data['productId'] as String?;

    if (type != null && deviceId != null && productId != null) {
      // Get the current context for navigation
      final context = AppRoutes.navigatorKey.currentContext;
      if (context != null) {
        // Navigate to device detail page
        AppRoutes.goToDeviceDetail(context, deviceId, productId);
      } else {
        print('Cannot navigate: no context available');
      }
    } else {
      print('Invalid notification data format: $data');
    }
  }

  String _getBody(String code) {
      switch (code) {
        case '1001':
          return _l10n.deviceOnline;
        case '1002':
          return _l10n.deviceOffline;
        case '1003':
          return _l10n.lockTimeout;
      }
      return '';
  }

  Future<void> initialize() async {
    if (_initialized) return;

    await requestPermission();
    //getToken();

    // Register the background message handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Foreground message received!");
      print("Message Title: ${message.notification?.title}");
      print("Message Body: ${message.notification?.body}");
      print("Message Data: ${message.data}");

      // Transform title and body
      final title = '🔔 ${message.notification?.title}';
      final body = _getBody(message.data['code'] ?? '');

      // Add to notification list with transformed values
      _addNotification(message, title: title, body: body);
    });

    // Handle when user taps on notification when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Message opened app from background");
      print("Message Title: ${message.notification?.title}");
      print("Message Body: ${message.notification?.body}");
      print("Message Data: ${message.data}");

      // Transform title and body
      final title = message.notification?.title;
      final body = _getBody(message.data['code'] ?? '');

      // Handle tap (adds notification and navigates)
      _onNotificationTapped(message, title: title, body: body);
    });

    // Check if app was opened from a terminated state via notification
    RemoteMessage? initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      print("App opened from terminated state via notification");
      print("Message Title: ${initialMessage.notification?.title}");
      print("Message Body: ${initialMessage.notification?.body}");
      print("Message Data: ${initialMessage.data}");
    }

    _initialized = true;
  }


  Future<void> requestPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  void getToken() async {
    String? token = await messaging.getToken();
    print("FCM Token: $token");
  }
}