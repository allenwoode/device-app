import 'package:device/views/login_page.dart';
import 'package:device/views/main_page.dart';
import 'package:device/services/auth_service.dart';
import 'package:device/services/event_bus_service.dart';
import 'package:device/events/auth_events.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        textTheme: GoogleFonts.robotoTextTheme(),
        appBarTheme: AppBarTheme(
          titleTextStyle: GoogleFonts.roboto(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            textStyle: GoogleFonts.roboto(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoggedIn = false;
  StreamSubscription<UnauthorizedEvent>? _unauthorizedSubscription;

  @override
  void initState() {
    super.initState();
    _checkLoginState();
    _setupEventListeners();
  }
  
  void _setupEventListeners() {
    _unauthorizedSubscription = EventBusService.on<UnauthorizedEvent>().listen((event) {
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
        });
        // Show a snackbar or dialog to inform user
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('登录已过期，请重新登录'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _unauthorizedSubscription?.cancel();
    super.dispose();
  }

  Future<void> _checkLoginState() async {
    if (!mounted) return;
    
    try {
      final isLoggedIn = await AuthService.isLoggedIn();
      if (mounted) {
        setState(() {
          _isLoggedIn = isLoggedIn;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return _isLoggedIn ? const MainPage() : const LoginPage();
  }
}
