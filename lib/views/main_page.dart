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

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final id = 'app-alert-notification';
  final topic = '/alarm/device/alert/notification';

  late final NotificationService _notificationService;
  
  StreamSubscription<Map<String, dynamic>>? _webSocketSubscription;

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

    _initializeNotification();

    _setupEventListeners();
  }

Future<void> _initializeNotification() async {
    try {
      _notificationService = NotificationService();
 
      // Subscribe to WebSocket topic for real-time notifications
      await _subscribeToWebSocket();
    } catch (e) {
      // Silent fail - notifications are optional
      print('Initialize notification error: $e');
    }
  }

  Future<void> _subscribeToWebSocket() async {
    try {
      // Unsubscribe from WebSocket and cancel subscription
      _webSocketSubscription?.cancel();
      WebSocketService.unsubscribe(id, topic);

      // Subscribe to the alert notification topic
      final stream = WebSocketService.subscribe(id, topic);

      // Listen to incoming WebSocket messages
      _webSocketSubscription = stream.listen(
        (message) {
          _handleWebSocketMessage(message);
        },
        onError: (error) {
          print('WebSocket subscription error: $error');
        },
      );
    } catch (e) {
      print('WebSocket subscription failed: $e');
    }
  }

  void _handleWebSocketMessage(Map<String, dynamic> message) {
    try {
      final type = message['type'] as String?;
      final data = message['payload'];

      if (type == 'result' || type == 'message') {
        // Handle incoming alert notification
        // You can trigger a notification count refresh or show a local notification
        if (mounted) {
          _notificationService.showDeviceAlert(
            id: DateTime.now().microsecond, 
            title: data['deviceName'], 
            body: _getBody(data['code']),
            payload: data,
          );
        }
      }
    } catch (e) {
      print('Error handling WebSocket message: $e');
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

  void _setupEventListeners() {
    EventBus.instance.addListener(EventKeys.logout, _onLogout);
  }

  void _onLogout() {
    AppRoutes.goToLogin(context);
  }

  @override
  void dispose() {
    EventBus.instance.removeListener(EventKeys.logout, _onLogout);

    // Unsubscribe from WebSocket and cancel subscription
    _webSocketSubscription?.cancel();
    WebSocketService.unsubscribe(id, topic);
    
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
