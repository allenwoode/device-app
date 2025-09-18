import 'package:device/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';

class RouteComponent extends StatefulWidget {
  const RouteComponent({super.key});

  @override
  State<RouteComponent> createState() => _RouteComponentState();

  static _RouteComponentState? of(BuildContext context) => context.findAncestorStateOfType<_RouteComponentState>();
}

class _RouteComponentState extends State<RouteComponent> {
  Locale _locale = const Locale('zh');

  @override
  void initState() {
    super.initState();
    AppRoutes.configureRoutes();
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLocaleCode = prefs.getString('locale') ?? 'zh';
      if (mounted) {
        setState(() {
          _locale = Locale(savedLocaleCode);
        });
      }
    } catch (e) {
      print('Error loading saved locale in RouteComponent: $e');
      // Fallback to default locale on error
      if (mounted) {
        setState(() {
          _locale = const Locale('zh');
        });
      }
    }
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
    //_saveLocale(locale);
  }

  // Future<void> _saveLocale(Locale locale) async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     await prefs.setString('locale', locale.languageCode);
  //   } catch (e) {
  //     print('Error saving locale in RouteComponent: $e');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      supportedLocales: const [Locale('en'), Locale('zh')],
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      onGenerateRoute: AppRoutes.router.generator,
      initialRoute: '/',
    );
  }
}