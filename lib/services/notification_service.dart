import 'dart:async';
import 'dart:ui';
import 'package:device/services/websocket_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
//import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device/models/notification_models.dart';
import 'package:device/events/event_bus.dart';
import 'package:device/routes/app_routes.dart';

/// Notification service for managing local notifications and background service.

/// Internal class to store monitored device information
// class _MonitoredDevice {
//   final String deviceId;
//   final String productId;
//   final String deviceName;

//   _MonitoredDevice({
//     required this.deviceId,
//     required this.productId,
//     required this.deviceName,
//   });
// }

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool _backgroundServiceRunning = false;

  // Callback for when a notification is received
  void Function()? onNotificationReceived;

  // Store notifications
  final List<NotificationItem> _notifications_list = [];

  // WebSocket alert monitoring
  //StreamSubscription? _alertSubscription;
  //bool _isMonitoringAlerts = false;
  //final Map<String, _MonitoredDevice> _monitoredDevices = {};

  /// Get all notifications
  List<NotificationItem> get notifications =>
      List.unmodifiable(_notifications_list);

  /// Get unread notification count
  int get unreadCount => _notifications_list.where((n) => !n.isRead).length;

  /// Check if background service is running
  bool get isBackgroundServiceRunning => _backgroundServiceRunning;

  /// Check and sync the actual background service state
  Future<bool> checkBackgroundServiceState() async {
    try {
      final service = FlutterBackgroundService();
      final isRunning = await service.isRunning();
      _backgroundServiceRunning = isRunning;
      return isRunning;
    } catch (e) {
      // Background service is optional - silently fail if not configured
      print('Background service not available: $e');
      _backgroundServiceRunning = false;
      return false;
    }
  }

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

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_initialized) return;

    // Android initialization settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/app_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    // Combined initialization settings
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialize the plugin
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Check and sync background service state on initialization (optional)
    try {
      await checkBackgroundServiceState();
    } catch (e) {
      print('Background service check failed during initialization: $e');
      // Continue initialization even if background service is not available
    }

    _initialized = true;
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;

    // Parse payload format: "device_alert:deviceId:productId" or "device_severe:deviceId:productId"
    final parts = payload.split(':');
    if (parts.length >= 3) {
      //final type = parts[0]; // device_alert or device_severe
      final deviceId = parts[1];
      final productId = parts[2];

      // Get the current context for navigation
      // We need to use a global navigator key to navigate from background
      final context = AppRoutes.navigatorKey.currentContext;
      if (context != null) {
        // Navigate to device detail page
        AppRoutes.goToDeviceDetail(context, deviceId, productId);
      } else {
        print('Cannot navigate: no context available');
      }
    } else {
      print('Invalid notification payload format: $payload');
    }
  }

  /// Request notification permission (Android 13+ and iOS)
  Future<bool> requestPermission() async {
    // iOS-specific permission request using flutter_local_notifications
    final iosImplementation = _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();

    if (iosImplementation != null) {
      // For iOS, request permissions using the native implementation
      final granted = await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    // Android permission request using permission_handler
    if (await Permission.notification.isGranted) {
      return true;
    }

    final status = await Permission.notification.request();
    return status.isGranted;
  }

  /// Check if notification permission is granted
  Future<bool> hasPermission() async {
    // iOS-specific permission check using flutter_local_notifications
    final iosImplementation = _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();

    if (iosImplementation != null) {
      // For iOS, request permissions (won't show dialog if already determined)
      // This returns the current permission status
      final granted = await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    // Android check using permission_handler
    return await Permission.notification.isGranted;
  }

  // Initialize and start background service
  Future<void> startBackgroundService() async {
    try {
      // Check actual service state first
      final service = FlutterBackgroundService();
      final isRunning = await service.isRunning();

      if (isRunning) {
        print('Background service already running');
        _backgroundServiceRunning = true;
        return;
      }

      // Ensure notification service is initialized first
      if (!_initialized) {
        await initialize();
      }

      // Create notification channel for background service
      await createBackgroundServiceChannel();

      // Configure background service
      await service.configure(
        iosConfiguration: IosConfiguration(
          autoStart: false,
          onForeground: onStart,
          onBackground: onIosBackground,
        ),
        androidConfiguration: AndroidConfiguration(
          onStart: onStart,
          isForegroundMode: true,
          autoStart: false,
          autoStartOnBoot: false,
          notificationChannelId: 'device_background_service',
          initialNotificationTitle: 'Device Monitor',
          initialNotificationContent: 'Initializing...',
          foregroundServiceNotificationId: 888,
          foregroundServiceTypes: [AndroidForegroundType.dataSync],
        ),
      );

      // Start the service
      await service.startService();

      // Wait a bit and verify it started
      await Future.delayed(const Duration(milliseconds: 500));
      final started = await service.isRunning();
      _backgroundServiceRunning = started;

      if (started) {
        print('Background service started successfully');
      } else {
        print('Background service failed to start');
      }
    } catch (e) {
      print('Failed to start background service: $e');
      _backgroundServiceRunning = false;
    }
  }

  // Create notification channel for background service
  Future<void> createBackgroundServiceChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'device_background_service', // id must match notificationChannelId
      'Device Background Service', // channel name
      description:
          'This notification appears when device monitoring service is running',
      importance: Importance.low,
      showBadge: false,
      playSound: false,
      enableVibration: false,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    print('Background service notification channel created');
  }

  // Request background service to start monitoring a device
  // Future<void> requestMonitoringDevice(
  //   String deviceId,
  //   String productId,
  //   String deviceName,
  // ) async {
  //   try {
  //     // Check actual service state
  //     final isRunning = await checkBackgroundServiceState();

  //     if (!isRunning) {
  //       print('Background service not running, starting it first...');
  //       await startBackgroundService();
  //       // Wait a bit for service to initialize
  //       await Future.delayed(const Duration(seconds: 2));

  //       // Verify service started
  //       final started = await checkBackgroundServiceState();
  //       if (!started) {
  //         print('Failed to start background service for monitoring');
  //         return;
  //       }
  //     }

  //     final service = FlutterBackgroundService();
  //     service.invoke('startMonitoring', {
  //       'deviceId': deviceId,
  //       'productId': productId,
  //       'deviceName': deviceName,
  //     });
  //     print('Requested background service to monitor device: $deviceName');
  //   } catch (e) {
  //     print('Failed to request monitoring: $e');
  //   }
  // }

  /// Request background service to stop monitoring a device
  // Future<void> requestStopMonitoringDevice(String deviceId) async {
  //   try {
  //     // Check actual service state
  //     final isRunning = await checkBackgroundServiceState();
  //     if (!isRunning) {
  //       print('Background service not running, cannot stop monitoring');
  //       return;
  //     }

  //     final service = FlutterBackgroundService();
  //     service.invoke('stopMonitoring', {
  //       'deviceId': deviceId,
  //     });
  //     print('Requested background service to stop monitoring device: $deviceId');
  //   } catch (e) {
  //     print('Failed to request stop monitoring: $e');
  //   }
  // }

  /// Request monitoring for multiple devices
  // Future<void> requestMonitoringMultipleDevices(List<Map<String, String>> devices) async {
  //   for (var device in devices) {
  //     final deviceId = device['id'];
  //     final productId = device['productId'];
  //     final deviceName = device['name'];
  //     if (deviceId != null && productId != null && deviceName != null) {
  //       await requestMonitoringDevice(deviceId, productId, deviceName);
  //       // Small delay between requests
  //       await Future.delayed(const Duration(milliseconds: 100));
  //     }
  //   }
  // }

  // Stop background service
  Future<void> stopBackgroundService() async {
    try {
      final service = FlutterBackgroundService();
      final isRunning = await service.isRunning();

      if (!isRunning) {
        print('Background service not running');
        _backgroundServiceRunning = false;
        return;
      }

      service.invoke('stopService');

      // Wait a bit and verify it stopped
      await Future.delayed(const Duration(milliseconds: 500));
      final stopped = !(await service.isRunning());
      _backgroundServiceRunning = !stopped;

      if (stopped) {
        print('Background service stopped successfully');
      } else {
        print('Background service may still be running');
      }
    } catch (e) {
      print('Failed to stop background service: $e');
      // Assume it stopped on error
      _backgroundServiceRunning = false;
    }
  }

  /// Start foreground task (Android)
  // Future<void> startForegroundTask() async {
  //   if (!Platform.isAndroid) return;

  //   // Initialize foreground task
  //   FlutterForegroundTask.init(
  //     androidNotificationOptions: AndroidNotificationOptions(
  //       channelId: 'device_foreground_service',
  //       channelName: 'Device Monitor Service',
  //       channelDescription: 'This notification appears when the device monitoring service is running.',
  //       channelImportance: NotificationChannelImportance.LOW,
  //       priority: NotificationPriority.LOW,
  //       //iconData: const NotificationIconData(
  //       //  resType: ResourceType.mipmap,
  //       //  resPrefix: ResourcePrefix.none,
  //       //  name: 'app_launcher',
  //       //),
  //     ),

  //     iosNotificationOptions: const IOSNotificationOptions(
  //       showNotification: true,
  //       playSound: false,
  //     ),

  //     foregroundTaskOptions: ForegroundTaskOptions(
  //       eventAction: ForegroundTaskEventAction.repeat(5000),
  //       autoRunOnBoot: false,
  //       autoRunOnMyPackageReplaced: false,
  //       allowWakeLock: true,
  //       allowWifiLock: true,
  //     ),
  //   );

  //   // Set task handler
  //   FlutterForegroundTask.setTaskHandler(ForegroundTaskHandler());

  //   // Start foreground task
  //   await FlutterForegroundTask.startService(
  //     notificationTitle: 'Device Monitor',
  //     notificationText: 'Monitoring your devices',
  //   );

  //   print('Foreground task started');
  // }

  /// Stop foreground task
  // Future<void> stopForegroundTask() async {
  //   if (!Platform.isAndroid) return;

  //   await FlutterForegroundTask.stopService();
  //   print('Foreground task stopped');
  // }

  /// Show a simple notification
  // Future<void> showNotification({
  //   required int id,
  //   required String title,
  //   required String body,
  //   String? payload,
  // }) async {
  //   if (!_initialized) {
  //     await initialize();
  //   }

  //   // Check permission
  //   if (!await hasPermission()) {
  //     final granted = await requestPermission();
  //     if (!granted) {
  //       throw Exception('Notification permission denied');
  //     }
  //   }

  //   const AndroidNotificationDetails androidDetails =
  //       AndroidNotificationDetails(
  //         'default_channel', // channel id
  //         'Default Notifications', // channel name
  //         channelDescription: 'Default notification channel',
  //         importance: Importance.high,
  //         priority: Priority.high,
  //         showWhen: true,
  //         icon: '@mipmap/app_launcher',
  //       );

  //   const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
  //     presentAlert: true,
  //     presentBadge: true,
  //     presentSound: true,
  //   );

  //   const NotificationDetails notificationDetails = NotificationDetails(
  //     android: androidDetails,
  //     iOS: iosDetails,
  //   );

  //   await _notifications.show(
  //     id,
  //     title,
  //     body,
  //     notificationDetails,
  //     payload: payload,
  //   );

  //   // Add to notifications list
  //   final notificationItem = NotificationItem(
  //     id: id,
  //     title: title,
  //     body: body,
  //     payload: payload,
  //     timestamp: DateTime.now(),
  //     isRead: false,
  //   );
  //   _notifications_list.insert(0, notificationItem);

  //   // Notify listeners that a notification was received
  //   onNotificationReceived?.call();

  //   // Broadcast notification event to all pages via EventBus
  //   EventBus.instance.commit(EventKeys.notificationReceived, notificationItem);
  //   EventBus.instance.commit(EventKeys.notificationCountChanged, unreadCount);
  // }

  /// Show a notification with custom sound and vibration
  Future<void> showNotificationWithSound({
    required int id,
    required String title,
    required String body,
    Map<String, dynamic>? payload,
    bool enableVibration = true,
    bool playSound = true,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    // Check permission
    if (!await hasPermission()) {
      final granted = await requestPermission();
      if (!granted) {
        throw Exception('Notification permission denied');
      }
    }

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'alert_channel', // channel id
          'Alert Notifications', // channel name
          channelDescription: 'Important alert notifications',
          importance: Importance.max,
          priority: Priority.max,
          showWhen: true,
          enableVibration: enableVibration,
          playSound: playSound,
          icon: '@mipmap/app_launcher',
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload.toString(),
    );

    // Add to notifications list
    final notificationItem = NotificationItem(
      id: id,
      title: title,
      body: body,
      payload: payload,
      timestamp: DateTime.now(),
      isRead: false,
    );
    _notifications_list.insert(0, notificationItem);

    // Notify listeners that a notification was received
    onNotificationReceived?.call();

    // Broadcast notification event to all pages via EventBus
    EventBus.instance.commit(EventKeys.notificationReceived, notificationItem);
    EventBus.instance.commit(EventKeys.notificationCountChanged, unreadCount);
  }

  /// Show a device alert notification
  Future<void> showDeviceAlert({
    required int id,
    required String title,
    required String body,
    Map<String, dynamic>? payload,
  }) async {
    //final title = '🔔' + title;
    // Format: "type:deviceId:productId"

    await showNotificationWithSound(
      id: id,
      title: '🔔 $title',
      body: body,
      payload: payload,
      enableVibration: true,
      playSound: true,
    );
  }
}

// Background service entry point
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  // Initialize notification service
  final notificationService = NotificationService();
  try {
    await notificationService.initialize();
    // Ensure channel is created in the background service context too
    await notificationService.createBackgroundServiceChannel();
  } catch (e) {
    print('Background service: Failed to initialize notifications: $e');
  }

  // Connect to WebSocket
  bool wsConnected = false;
  try {
    wsConnected = await WebSocketService.connect();
    print('Background service WebSocket connected: $wsConnected');
  } catch (e) {
    print('Background service: Failed to connect WebSocket: $e');
  }

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) async {
    try {
      // Disconnect WebSocket
      await WebSocketService.disconnect();
    } catch (e) {
      print('Error during service cleanup: $e');
    }

    // Stop the service
    service.stopSelf();
  });

  // Handle device monitoring requests
  // service.on('startMonitoring').listen((event) async {
  //   if (event != null && event is Map) {
  //     final deviceId = event['deviceId'] as String?;
  //     final productId = event['productId'] as String?;
  //     final deviceName = event['deviceName'] as String?;
  //     if (deviceId != null && productId != null && deviceName != null) {
  //       await notificationService.startMonitoringAlerts(deviceId, productId, deviceName);
  //       print('Background service: Started monitoring $deviceName');
  //     }
  //   }
  // });

  // service.on('stopMonitoring').listen((event) async {
  //   if (event != null && event is Map) {
  //     final deviceId = event['deviceId'] as String?;
  //     if (deviceId != null) {
  //       await notificationService.stopMonitoringAlerts(deviceId);
  //       print('Background service: Stopped monitoring device $deviceId');
  //     }
  //   }
  // });

  // Periodic task to keep service alive and maintain WebSocket connection
  Timer.periodic(const Duration(seconds: 30), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        // Update notification with connection status
        final wsStatus = WebSocketService.isConnected ? 'Connected' : 'Disconnected';
        service.setForegroundNotificationInfo(
          title: "Device Monitor",
          content: "Monitoring device alerts • $wsStatus",
        );
      }
    }

    // Check WebSocket connection and reconnect if needed
    if (!WebSocketService.isConnected) {
      print(
        'Background service: WebSocket disconnected, attempting to reconnect...',
      );
      try {
        final connected = await WebSocketService.connect();
        if (connected) {
          print('Background service: Reconnected and resubscribed');
        }
      } catch (e) {
        print('Background service: Reconnection failed: $e');
      }
    }

    print('Background service running: ${DateTime.now()}');

    service.invoke('update');
  });
}

// iOS background handler
@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  return true;
}

  // Foreground task callback for Android
  // @pragma('vm:entry-point')
  // void foregroundTaskCallback() {
  //   // This callback is called periodically (interval defined in ForegroundTaskOptions)
  //   FlutterForegroundTask.setTaskHandler(ForegroundTaskHandler());
  // }

  // class ForegroundTaskHandler extends TaskHandler {

  //   @override
  //   Future<void> onStart(DateTime timestamp, TaskStarter starter) {
  //     // TODO: implement onStart
  //     throw UnimplementedError();
  //   }

  //   @override
  //   void onRepeatEvent(DateTime timestamp) {
  //     // This is called at the interval specified in ForegroundTaskOptions
  //     print('Foreground task event at $timestamp');
  //   }

  //   @override
  //   Future<void> onDestroy(DateTime timestamp) {
  //     // TODO: implement onDestroy
  //     throw UnimplementedError();
  //   }

