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
  String get networkError =>
      'Network error, please check connection and try again';

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
  String get usageRate => 'Usage';

  @override
  String get alerts => 'Alerts';

  @override
  String get operationLog => 'Operation';

  @override
  String get remoteSettings => 'Remote';

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
  String get alarm => 'Notice';

  @override
  String get severe => 'Severe';

  @override
  String get deviceReport => 'Report';

  @override
  String get platformDispatch => 'Dispatch';

  @override
  String get todayUsageTop5 => 'Today\'s Usage TOP5';

  @override
  String get loadDeviceDataFailed => 'Failed to load device data!';

  @override
  String remoteOpenCabinetDoor(String slotId) {
    return 'Do you want to remotely open cabinet door $slotId?';
  }

  @override
  String get pleaseEnterAdminPassword => 'Please enter administrator password';

  @override
  String cabinetDoorOpening(String slotId) {
    return 'Opening cabinet door $slotId...';
  }

  @override
  String cabinetDoorOpenedSuccessfully(String slotId) {
    return 'Cabinet door $slotId opened successfully';
  }

  @override
  String cabinetDoorOpenFailed(String slotId) {
    return 'Failed to open cabinet door $slotId, please try again';
  }

  @override
  String get deviceCannotRemoteClose => 'Device cannot be remotely closed';

  @override
  String get error => 'Error';

  @override
  String get loginError => 'Login Error';

  @override
  String get todayUsage => 'Today\'s Usage';

  @override
  String get noUsageRecords => 'No usage records';

  @override
  String get noUsageDataAvailable => 'No usage data available';

  @override
  String get operationInfo => 'Operation Info';

  @override
  String get operationTime => 'Operation Time';

  @override
  String get usageInfo => 'Usage Info';

  @override
  String get usageTime => 'Usage Time';

  @override
  String inUse(Object port) {
    return '$port In Use';
  }

  @override
  String get noAlertData => 'No alert data';

  @override
  String get noAlertInfo => 'No alert information';

  @override
  String get alertInfo => 'Alert Info';

  @override
  String get alertTime => 'Alert Time';

  @override
  String get propertyReport => 'Report';

  @override
  String get noLogData => 'No log data';

  @override
  String get noLogInfo => 'No log information';

  @override
  String get deviceManagement => 'Device Management';

  @override
  String get feedbackSuggestions => 'Feedback';

  @override
  String get settings => 'Settings';

  @override
  String get deviceUnbind => 'Device Unbind';

  @override
  String get confirmDeviceUnbind =>
      'Are you sure you want to unbind the current device?';

  @override
  String get unbind => 'Unbind';

  @override
  String get addDevice => 'Add Device';

  @override
  String get scanQROrEnterID => 'Scan QR code or enter device ID manually';

  @override
  String get unbindDevices => 'Unbind Devices';

  @override
  String get batchUnbindDevices => 'Batch unbind devices';

  @override
  String get deviceAddedSuccessfully => 'Device added successfully';

  @override
  String get enterDeviceIDManually => 'Enter Device ID Manually';

  @override
  String get pleaseEnterDeviceID => 'Please enter device ID';

  @override
  String get bindDevice => 'Bind Device';

  @override
  String get scanQRCode => 'Scan QR Code';

  @override
  String get scanDeviceQRCode => 'Scan Device QR Code';

  @override
  String get bindFailed =>
      'Binding failed, please check if device ID is correct';

  @override
  String get bindOperationFailed =>
      'Binding operation failed, please try again';

  @override
  String get loadDeviceListFailed => 'Failed to load device list';

  @override
  String get pleaseSelectAtLeastOneDevice =>
      'Please select at least one device';

  @override
  String get confirmUnbindDevices => 'Confirm Unbind Devices';

  @override
  String confirmUnbindMessage(int count) {
    return 'Are you sure you want to unbind the selected $count devices? This action cannot be undone.';
  }

  @override
  String get unbindingDevices => 'Unbinding devices...';

  @override
  String pleaseWaitProcessingDevices(int count) {
    return 'Please wait, processing $count devices';
  }

  @override
  String get noDevicesToUnbind => 'No devices to unbind';

  @override
  String get unbindWarning =>
      'After unbinding, you will no longer be able to control the device';

  @override
  String selectedDevicesCount(int count) {
    return 'Selected $count devices';
  }

  @override
  String get selectAll => 'Select All';

  @override
  String get clear => 'Clear';

  @override
  String allDevicesLoadedCount(int count) {
    return 'Loaded all $count devices';
  }

  @override
  String unbindCount(int count) {
    return 'Unbind ($count)';
  }

  @override
  String successfullyUnbound(int count) {
    return 'Successfully unbound $count devices';
  }

  @override
  String get unbindFailedRetry => 'Unbind failed, please try again';

  @override
  String unbindMixed(int success, int failed) {
    return 'Successfully unbound $success devices, $failed failed';
  }

  @override
  String get unbindOperationError => 'Unbind operation error, please try again';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get languageSettings => 'Language Settings';

  @override
  String currentLanguage(String language) {
    return 'Current Language: $language';
  }

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get notificationSettingsSubtitle =>
      'Manage push notification settings';

  @override
  String get notificationFeatureTodo =>
      'Notification settings feature to be developed';

  @override
  String get privacySecurity => 'Privacy & Security';

  @override
  String get privacySecuritySubtitle => 'Changing login password';

  @override
  String get securityFeatureTodo => 'Security settings feature to be developed';

  @override
  String get storageManagement => 'Storage Management';

  @override
  String get storageManagementSubtitle => 'Clear cache and local data';

  @override
  String get clearCache => 'Clear Cache';

  @override
  String get clearCacheConfirm =>
      'Are you sure you want to clear the application cache? This will delete temporary files but will not affect your personal data.';

  @override
  String get cacheCleared => 'Cache cleared successfully';

  @override
  String get saveLanguageSettingsFailed =>
      'Failed to save language settings, please try again';

  @override
  String get feedbackType => 'Feedback Type';

  @override
  String get feedbackContent => 'Feedback Content';

  @override
  String get contactInfo => 'Contact Info (Optional)';

  @override
  String get feedbackHint =>
      'Please describe your issue or suggestion in detail...';

  @override
  String get contactHint => 'Please enter your email or phone number';

  @override
  String get contactHelpText =>
      'Providing contact information helps us respond to you better';

  @override
  String get submitFeedback => 'Submit Feedback';

  @override
  String get pleaseFillFeedback => 'Please enter feedback content';

  @override
  String get feedbackSubmitFailed => 'Submission failed, please try again';

  @override
  String get featureSuggestion => 'Feature Suggestion';

  @override
  String get bugReport => 'Bug Report';

  @override
  String get usageQuestion => 'Usage Question';

  @override
  String get other => 'Other';

  @override
  String get permissionInsufficient => 'Permission Insufficient';

  @override
  String get cameraPermissionRequired =>
      'Camera permission is required to scan QR codes. Please enable camera permission in settings.';

  @override
  String get processing => 'Processing...';

  @override
  String get bindingDevice => 'Binding device...';

  @override
  String get bindSuccess => 'Binding success';

  @override
  String get scanInstructions =>
      'Place the device QR code within the scan frame';

  @override
  String get scanHint =>
      'Device will be automatically bound after successful scan';
}
