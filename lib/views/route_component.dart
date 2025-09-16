import 'package:device/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

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