import 'package:device/services/auth_service.dart';
import 'package:device/services/event_bus_service.dart';
import 'package:device/events/auth_events.dart';
import 'package:device/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:device/l10n/app_localizations.dart';

void main() {
  try {
    // Configure Fluro routes
    AppRoutes.configureRoutes();
    runApp(const MyApp());
  } catch (e, stackTrace) {
    print('Error starting app: $e');
    print('Stack trace: $stackTrace');
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Failed to start app: $e'),
          ),
        ),
      ),
    );
  }
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
  bool _isLoggedIn = false;
  bool _isCheckingLogin = true;

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void initState() {
    super.initState();
    _checkLoginState();
  }

  Future<void> _checkLoginState() async {
    try {
      final isLoggedIn = await AuthService.isLoggedIn();
      if (mounted) {
        setState(() {
          _isLoggedIn = isLoggedIn;
          _isCheckingLogin = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
          _isCheckingLogin = false;
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Device Manager',
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
      supportedLocales: const [Locale('en'), Locale('zh')],
      locale: _locale,
      initialRoute: AppRoutes.root,
      onGenerateRoute: AppRoutes.router.generator,
    );
  }
}
