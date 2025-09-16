import 'package:device/routes/route_handlers.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

class Routes {
  static String root ='/home';

  static String login = '/login';

  static void configureRoutes(FluroRouter router){
    router.define(root, handler: rootHandler);
    router.define(login, handler: loginHandler);

    // Fallback route
    router.notFoundHandler = Handler(
      handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
        return Scaffold(
          body: Center(
            child: Text('Route not found'),
          ),
        );
      },
    );
  }
}