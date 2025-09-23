import 'package:device/views/add_device_page.dart';
import 'package:device/views/device_manager.dart';
import 'package:device/views/unbind_device_page.dart';
import 'package:device/views/dashboard_usage_page.dart';
import 'package:device/views/feedback_page.dart';
import 'package:device/views/setting_page.dart';
import 'package:device/views/qr_scanner_page.dart';
import 'package:device/views/dashboard_alert_page.dart';
import 'package:device/views/dashboard_log_page.dart';
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
  static const String deviceManager = '/device-manager';
  static const String deviceBind = '/device-bind';
  static const String deviceUnbind = '/device-unbind';
  static const String dashboardUsage = '/dashboard-usage';
  static const String feedback = '/feedback';
  static const String settings = '/settings';
  static const String qrScanner = '/qr-scanner';
  static const String dashboardAlert = '/dashboard-alert';
  static const String dashboardDeviceLog = '/dashboard-device-log';

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

  static final Handler _deviceManagerHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      return DeviceManagerPage();
  });

  static final Handler _deviceBindHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      return AddDevicePage();
  });

  static final Handler _deviceUnbindHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      return UnbindDevicePage();
  });

  static final Handler _dashboardUsageHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      return const DashboardUsagePage();
  });

  static final Handler _feedbackHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      return const FeedbackPage();
  });

  static final Handler _settingsHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      return const SettingPage();
  });

  static final Handler _qrScannerHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      return const QRScannerPage();
  });

  static final Handler _dashboardAlertHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      return const DashboardAlertPage();
  });

  static final Handler _dashboardDeviceLogHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      return const DashboardLogPage();
  });

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

    router.define(
      deviceManager, 
      handler: _deviceManagerHandler, 
      transitionType: TransitionType.cupertino,
    );

    router.define(
      deviceBind, 
      handler: _deviceBindHandler, 
      transitionType: TransitionType.cupertino,
    );

    router.define(
      deviceUnbind,
      handler: _deviceUnbindHandler,
      transitionType: TransitionType.cupertino,
    );

    router.define(
      dashboardUsage,
      handler: _dashboardUsageHandler,
      transitionType: TransitionType.cupertino,
    );

    router.define(
      feedback,
      handler: _feedbackHandler,
      transitionType: TransitionType.cupertino,
    );

    router.define(
      settings,
      handler: _settingsHandler,
      transitionType: TransitionType.cupertino,
    );

    router.define(
      qrScanner,
      handler: _qrScannerHandler,
      transitionType: TransitionType.cupertino,
    );

    router.define(
      dashboardAlert,
      handler: _dashboardAlertHandler,
      transitionType: TransitionType.cupertino,
    );

    router.define(
      dashboardDeviceLog,
      handler: _dashboardDeviceLogHandler,
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

  static Future<dynamic> goToDeviceManager(
    BuildContext context,
  ) {
    return navigateTo(context, deviceManager);
  }

  static Future<dynamic> goToDeviceBind(BuildContext context) {
    return navigateTo(context, deviceBind);
  }

  static Future<dynamic> goToDeviceUnbind(BuildContext context) {
    return navigateTo(context, deviceUnbind);
  }

  static Future<dynamic> goToDashboardUsage(BuildContext context) {
    return navigateTo(context, dashboardUsage);
  }

  static Future<dynamic> goToFeedback(BuildContext context) {
    return navigateTo(context, feedback);
  }

  static Future<dynamic> goToSettings(BuildContext context) {
    return navigateTo(context, settings);
  }

  static Future<dynamic> goToQRScanner(BuildContext context) {
    return navigateTo(context, qrScanner);
  }

  static Future<dynamic> goToDashboardAlert(BuildContext context) {
    return navigateTo(context, dashboardAlert);
  }

  static Future<dynamic> goToDashboardDeviceLog(BuildContext context) {
    return navigateTo(context, dashboardDeviceLog);
  }
}