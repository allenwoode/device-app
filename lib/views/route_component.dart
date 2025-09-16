import 'dart:async';

import 'package:device/events/auth_events.dart';
import 'package:device/routes/app_routes.dart';
import 'package:device/routes/application.dart';
import 'package:device/routes/navigator.dart';
import 'package:device/routes/routes.dart';
import 'package:device/services/event_bus_service.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

class RouteComponent extends StatefulWidget {
  const RouteComponent({super.key});

  @override
  State<RouteComponent> createState() => _RouteComponentState();
}

class _RouteComponentState extends State<RouteComponent> {
  
  StreamSubscription<UnauthorizedEvent>? _unauthorizedSubscription;
  
  @override
  void initState() {
    super.initState();
    //_router = FluroRouter();
    AppRoutes.configureRoutes();
    _setupEventListeners();
  }
  
  void _setupEventListeners() {
    _unauthorizedSubscription = EventBusService.on<UnauthorizedEvent>().listen((event) {
      if (mounted) {
        print('===========> event listener: Authentication expired, logging out');
        
        // Navigate to login page using Fluro router
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            AppRoutes.goToLogin(context, clearStack: true);
          }
        });
      }
    });
  }

@override
  void dispose() {
    _unauthorizedSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateRoute: AppRoutes.router.generator,
      initialRoute: '/',
    );
  }
}