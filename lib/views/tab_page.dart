import 'package:device/events/event_bus.dart';
import 'package:device/routes/app_routes.dart';
import 'package:flutter/material.dart';

class TabPage extends StatefulWidget {
  const TabPage({super.key});

  @override
  State<TabPage> createState() => _TabPageState();
}

class _TabPageState extends State<TabPage> {

  @override
  void initState() {
    super.initState();
    _setupEventListeners();
  }

  void _setupEventListeners() {
    EventBus.instance.addListener(EventKeys.logout, () {
      // evict event listener
      EventBus.instance.removeListener(EventKeys.logout);

      // navigator to login page
      //Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      AppRoutes.goToMain(context);
    });
  }

  @override
  void dispose() {
    EventBus.instance.removeListener(EventKeys.logout);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Container(
        alignment: Alignment.bottomCenter, 
        child: TextButton(
          onPressed: () { EventBus.instance.commit(EventKeys.logout); }, 
          child: Text('主页')
          ),
        ),
    );
  }
}