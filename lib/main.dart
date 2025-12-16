import 'package:device/views/route_component.dart';
import 'package:device/services/notification_service.dart';
import 'package:flutter/material.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Request notification permission
  final hasPermission = await notificationService.hasPermission();
  if (!hasPermission) {
    await notificationService.requestPermission();
  }

  // Note: Background service will be started when user enables it in settings
  // or when monitoring is needed. You can optionally start it here:
  //await notificationService.startBackgroundService();

  runApp(RouteComponent());
}