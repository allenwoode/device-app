// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Device Manager';

  @override
  String get login => 'Login';

  @override
  String get logout => 'Logout';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get loginButton => 'Login';

  @override
  String get loginProblem => 'Having trouble logging in?';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get accountAppeal => 'Account Appeal';

  @override
  String get cancel => 'Cancel';

  @override
  String welcome(String name) {
    return 'Welcome, $name!';
  }

  @override
  String get loginFailed => 'Login failed, please check username and password';

  @override
  String get networkError => 'Network error, please try again later';

  @override
  String get checkingLoginState => 'Checking login status...';

  @override
  String get startingApp => 'Starting app...';

  @override
  String get loginExpired => 'Login expired, please login again';

  @override
  String get pleaseEnterUsername => 'Please enter username';

  @override
  String get pleaseEnterPassword => 'Please enter password';

  @override
  String get passwordLogin => 'Password Login';

  @override
  String get devices => 'Devices';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get mine => 'Mine';

  @override
  String get iot => 'IoT';

  @override
  String get searchDeviceIdName => 'Search device ID/name';

  @override
  String get loadingDevicesFailed => 'Failed to load device data';

  @override
  String get networkConnectionFailed => 'Network connection failed';

  @override
  String get serverError => 'Server error';

  @override
  String get retry => 'Retry';

  @override
  String get noDeviceData => 'No device data';

  @override
  String get loadingMoreDevices => 'Loading more devices...';

  @override
  String allDevicesLoaded(int count) {
    return 'All devices loaded ($count total)';
  }

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';

  @override
  String get usageRate => 'Usage Rate';

  @override
  String get alerts => 'Alerts';

  @override
  String get operationLog => 'Operation Log';

  @override
  String get remoteSettings => 'Remote Settings';

  @override
  String get deviceOfflineCannotRemoteSet =>
      'Device offline, cannot perform remote settings';

  @override
  String get deviceLock => 'Device Lock';

  @override
  String get deviceUnlock => 'Device Unlock';

  @override
  String get notPowered => 'Not Powered';

  @override
  String get charging => 'Charging';

  @override
  String get fullyCharged => 'Fully Charged';

  @override
  String get organizationUnitEmpty => 'Organization unit is empty';

  @override
  String get confirmExit => 'Confirm Exit';

  @override
  String get confirmLogoutMessage => 'Are you sure you want to log out?';

  @override
  String get logoutSuccess => 'Logout successful';

  @override
  String get logoutFailed => 'Logout failed, please try again';

  @override
  String get versionUpdate => 'Version Update';

  @override
  String get aboutUs => 'About Us';

  @override
  String get versionUpdateTodo => 'Version update feature to be implemented';

  @override
  String get aboutUsTodo => 'About us feature to be implemented';

  @override
  String get userRoleEmpty => 'User role is empty';

  @override
  String get user => 'User';

  @override
  String get confirm => 'Confirm';

  @override
  String get usageDistribution => 'Usage Distribution';

  @override
  String get todayAlerts => 'Today\'s Alerts';

  @override
  String get operationLogs => 'Operation Logs';

  @override
  String get alarm => 'Alarm';

  @override
  String get severe => 'Severe';

  @override
  String get deviceReport => 'Device Report';

  @override
  String get platformDispatch => 'Platform Dispatch';

  @override
  String get top5Usage => 'Top 5 Usage Amount';
}
