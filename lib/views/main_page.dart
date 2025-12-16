import 'dart:async';

import 'package:device/events/event_bus.dart';
import 'package:device/routes/app_routes.dart';
import 'package:device/services/notification_service.dart';
import 'package:device/services/websocket_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'device_page.dart';
import 'mine_page.dart';
import 'dashboard_page.dart';
import '../config/app_colors.dart';
import '../l10n/app_localizations.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  int _selectedIndex = 0;

  final id = 'device-page-alert';
  final topic = '/alarm/device/alert/publish';

  late final NotificationService _notificationService;

  StreamSubscription? _deviceAlertSubscription;

  AppLocalizations get _l10n {
    try {
      return AppLocalizations.of(context)!;
    } catch (e) {
      // Fallback when context is not ready
      return lookupAppLocalizations(const Locale('zh'));
    }
  }

  @override
  void initState() {
    super.initState();

    // Add lifecycle observer
    WidgetsBinding.instance.addObserver(this);

    _initializeNotifications();
    _initializeWebSocket();
    _setupEventListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Reconnect WebSocket when app comes to foreground
    if (state == AppLifecycleState.resumed) {
      if (!WebSocketService.isConnected) {
        _initializeWebSocket();
      }
    }
  }

  Future<void> _initializeNotifications() async {
    try {
      _notificationService = NotificationService();
      await _notificationService.initialize();
      await _notificationService.requestPermission();
    } catch (e) {
      // Silent fail - notifications are optional
    }
  }

  Future<void> _initializeWebSocket() async {
    try {
      // Connect to WebSocket
      final connected = await WebSocketService.connect();

      if (!connected) {
        await Future.delayed(const Duration(seconds: 3));
        await _initializeWebSocket();
        return;
      }

      // Wait a bit for connection to stabilize
      await Future.delayed(const Duration(milliseconds: 500));

      // Subscribe to device alerts
      _subscribeToDeviceAlerts();

      print('WebSocket initialized and subscribed successfully');
    } catch (e) {
      print('Failed to initialize WebSocket: $e');
    }
  }

  void _subscribeToDeviceAlerts() {
    _deviceAlertSubscription = WebSocketService.subscribe(id, topic).listen(
      (message) {
        if (mounted) {
          //print('====>device alert notice: $message');
          _handleDeviceAlert(message);
        }
      },
      onError: (error) {
        print('WebSocket device alert error: $error');
      },
    );
  }

  void _handleDeviceAlert(Map<String, dynamic> message) {
    try {
      final timestamp = message['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch;
      final notificationId = timestamp % 1000000; // Use timestamp for unique ID

      final payload = message['payload'];
      if (payload == null) return;

      final deviceId = payload['deviceId']?.toString() ?? 'Unknown';
      final productId = payload['productId']?.toString() ?? 'Unknown product';
      final deviceName = payload['deviceName']?.toString() ?? 'Unknown Device';
      final level = payload['level']?.toString() ?? 'notice';
      //final content = payload['content']?.toString() ?? '';
      final code = payload['code']?.toString() ?? '';

      // Show notification
      _notificationService.showDeviceAlert(
        id: notificationId,
        deviceId: deviceId,
        productId: productId,
        deviceName: deviceName,
        message: _getContent(code),
        severity: level,
      );
    } catch (e) {
      print('Error handling device alert: $e');
    }
  }

  String _getContent(String code) {
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

  void _unsubscribeFromWebSocket() {
    _deviceAlertSubscription?.cancel();
    WebSocketService.unsubscribe(id, topic);
  }

  void _setupEventListeners() {
    EventBus.instance.addListener(EventKeys.logout, _onLogout);
  }

  void _onLogout() {
    AppRoutes.goToLogin(context);
  }

  @override
  void dispose() {
    // Remove lifecycle observer
    WidgetsBinding.instance.removeObserver(this);

    EventBus.instance.removeListener(EventKeys.logout, _onLogout);

    // Clean up WebSocket subscriptions
    _unsubscribeFromWebSocket();

    super.dispose();
  }

  Widget _getCurrentPage() {
    switch (_selectedIndex) {
      case 0:
        return const DevicePage();
      case 1:
        return const DashboardPage();
      case 2:
        return const MinePage();
      default:
        return const DevicePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getCurrentPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const FaIcon(FontAwesomeIcons.house, size: 20),
            activeIcon: const FaIcon(FontAwesomeIcons.solidHouse, size: 20),
            label: _l10n.iot,
          ),
          BottomNavigationBarItem(
            icon: const FaIcon(FontAwesomeIcons.chartPie, size: 20),
            activeIcon: const FaIcon(FontAwesomeIcons.chartPie, size: 20),
            label: _l10n.dashboard,
          ),
          BottomNavigationBarItem(
            icon: const FaIcon(FontAwesomeIcons.user, size: 20),
            activeIcon: const FaIcon(FontAwesomeIcons.solidUser, size: 20),
            label: _l10n.mine,
          ),
        ],
      ),
    );
  }
}
