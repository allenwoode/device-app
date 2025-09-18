import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import '../views/main_page.dart';
import '../views/login_page.dart';
import '../views/instance/device_detail_page.dart';
import '../views/instance/function_page.dart';
import '../views/instance/device_usage_page.dart';
import '../views/instance/device_alert_page.dart';
import '../views/instance/device_log_page.dart';

class AppRoutes {
  static final FluroRouter router = FluroRouter();

  // Route paths
  static const String root = '/';
  static const String login = '/login';
  static const String main = '/main';
  static const String deviceDetail = '/device-detail';
  static const String function = '/function';
  static const String deviceUsage = '/device-usage';
  static const String deviceAlert = '/device-alert';
  static const String deviceLog = '/device-log';

  // Route handlers
  static final Handler _rootHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      return const MainPage();
    },
  );

  static final Handler _loginHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      return const LoginPage();
    },
  );

  static final Handler _mainHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      return const MainPage();
    },
  );

  static final Handler _deviceDetailHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      final deviceId = params['deviceId']?.first ?? '';
      final productId = params['productId']?.first ?? '';
      
      if (deviceId.isEmpty || productId.isEmpty) {
        return const Scaffold(
          body: Center(
            child: Text('Invalid device parameters'),
          ),
        );
      }
      
      return DeviceDetailPage(
        deviceId: deviceId,
        productId: productId,
      );
    },
  );

  static final Handler _functionHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      final deviceId = params['deviceId']?.first ?? '';
      final productId = params['productId']?.first ?? '';
      final numString = params['num']?.first;
      final num = numString != null ? int.tryParse(numString) : null;

      if (deviceId.isEmpty || productId.isEmpty) {
        return const Scaffold(
          body: Center(
            child: Text('Invalid function parameters'),
          ),
        );
      }

      return FunctionPage(
        deviceId: deviceId,
        productId: productId,
        num: num,
      );
    },
  );

  static final Handler _deviceUsageHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      final deviceId = params['deviceId']?.first ?? '';
      final productId = params['productId']?.first ?? '';
      final numString = params['num']?.first;
      final num = numString != null ? int.tryParse(numString) : null;

      if (deviceId.isEmpty || productId.isEmpty) {
        return const Scaffold(
          body: Center(
            child: Text('Invalid device usage parameters'),
          ),
        );
      }

      return DeviceUsagePage(
        deviceId: deviceId, 
        productId: productId, 
        num: num
      );
    },
  );

  static final Handler _deviceAlertHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      final deviceId = params['deviceId']?.first ?? '';
      final productId = params['productId']?.first ?? '';

      if (deviceId.isEmpty || productId.isEmpty) {
        return const Scaffold(
          body: Center(
            child: Text('Invalid device alert parameters'),
          ),
        );
      }

      return DeviceAlertPage(deviceId: deviceId, productId: productId);
    },
  );

  static final Handler _deviceLogHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      final deviceId = params['deviceId']?.first ?? '';
      final productId = params['productId']?.first ?? '';

      if (deviceId.isEmpty || productId.isEmpty) {
        return const Scaffold(
          body: Center(
            child: Text('Invalid device log parameters'),
          ),
        );
      }

      return DeviceLogPage(deviceId: deviceId, productId: productId,);
    },
  );

  // Configure routes
  static void configureRoutes() {

    router.define(
      root,
      handler: _rootHandler,
      transitionType: TransitionType.fadeIn,
    );

    router.define(
      login,
      handler: _loginHandler,
      transitionType: TransitionType.fadeIn,
    );

    router.define(
      main,
      handler: _mainHandler,
      transitionType: TransitionType.fadeIn,
    );

    router.define(
      '$deviceDetail/:deviceId/:productId',
      handler: _deviceDetailHandler,
      transitionType: TransitionType.cupertino,
    );

    router.define(
      '$function/:deviceId/:productId/:num',
      handler: _functionHandler,
      transitionType: TransitionType.cupertino,
    );

    router.define(
      '$deviceUsage/:deviceId/:productId/:num',
      handler: _deviceUsageHandler,
      transitionType: TransitionType.cupertino,
    );

    router.define(
      '$deviceAlert/:deviceId/:productId',
      handler: _deviceAlertHandler,
      transitionType: TransitionType.cupertino,
    );

    router.define(
      '$deviceLog/:deviceId/:productId',
      handler: _deviceLogHandler,
      transitionType: TransitionType.cupertino,
    );

    // Fallback route
    router.notFoundHandler = Handler(
      handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
        return const Scaffold(
          body: Center(
            child: Text('Route not found'),
          ),
        );
      },
    );
  }

  // Navigation helper methods
  static Future<dynamic> navigateTo(
    BuildContext context,
    String path, {
    bool replace = false,
    bool clearStack = false,
    TransitionType? transition,
  }) {
    if (clearStack) {
      return router.navigateTo(
        context,
        path,
        transition: transition ?? TransitionType.fadeIn,
        clearStack: true,
      );
    } else if (replace) {
      return router.navigateTo(
        context,
        path,
        transition: transition ?? TransitionType.fadeIn,
        replace: true,
      );
    } else {
      return router.navigateTo(
        context,
        path,
        transition: transition ?? TransitionType.cupertino,
      );
    }
  }

  static void pop(BuildContext context) {
    router.pop(context);
  }

  // Specific navigation methods
  static Future<dynamic> goToLogin(BuildContext context, {bool clearStack = true}) {
    return navigateTo(context, login, clearStack: clearStack);
  }

  static Future<dynamic> goToMain(BuildContext context, {bool clearStack = true}) {
    return navigateTo(context, main, clearStack: clearStack);
  }

  static Future<dynamic> goToDeviceDetail(
    BuildContext context,
    String deviceId,
    String productId,
  ) {
    return navigateTo(context, '$deviceDetail/$deviceId/$productId');
  }

  static Future<dynamic> goToDeviceFunction(
    BuildContext context,
    String deviceId,
    String productId,
    int? num,
  ) {
    //final numParam = num?.toString() ?? '0';
    return navigateTo(context, '$function/$deviceId/$productId/$num');
  }

  static Future<dynamic> goToDeviceUsage(
    BuildContext context,
    String deviceId,
    String productId,
    int? num,
  ) {
    return navigateTo(context, '$deviceUsage/$deviceId/$productId/$num');
  }

  static Future<dynamic> goToDeviceAlert(
    BuildContext context,
    String deviceId,
    String productId,
  ) {
    return navigateTo(context, '$deviceAlert/$deviceId/$productId');
  }

  static Future<dynamic> goToDeviceLog(
    BuildContext context,
    String deviceId,
    String productId,
  ) {
    return navigateTo(context, '$deviceLog/$deviceId/$productId');
  }
}