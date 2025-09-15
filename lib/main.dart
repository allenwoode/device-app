import 'package:device/views/login_page.dart';
import 'package:device/views/main_page.dart';
import 'package:device/services/auth_service.dart';
import 'package:device/services/event_bus_service.dart';
import 'package:device/events/auth_events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:device/l10n/app_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
  
  // ignore: library_private_types_in_public_api
  static _MyAppState? of(BuildContext context) => context.findAncestorStateOfType<_MyAppState>();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('zh');

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //title: 'Device Manager',
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
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('zh'),
      ],
      locale: _locale,
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
        print('===========> event listener: Authentication expired, logging out user');
        setState(() {
          _isLoggedIn = false;
        });
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
