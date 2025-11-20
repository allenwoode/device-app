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
  String get ok => 'OK';

  @override
  String get success => 'Success';

  @override
  String get failed => 'Failed';

  @override
  String get finish => 'Finish';

  @override
  String get continueConfig => 'Continue';

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
  String get versionUpdateTodo => 'Already the latest version';

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
  String get notice => 'Notice';

  @override
  String get alarm => 'Warning';

  @override
  String get severe => 'Severe';

  @override
  String get report => 'Report';

  @override
  String get dispatch => 'Dispatch';

  @override
  String get event => 'Event Report';

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
  String inIdel(Object port) {
    return '$port In Idel';
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
  String get noLogData => 'No log data';

  @override
  String get noLogInfo => 'No log information';

  @override
  String get deviceConnector => 'Device Configure';

  @override
  String get deviceManagement => 'Device Management';

  @override
  String get feedback => 'Feedback';

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
  String get feedbackSubmitSuccess => 'Feedback submitted successfully';

  @override
  String get feedbackSubmitFailed => 'Submission failed, please try again';

  @override
  String get featureSuggestion => 'Feature Suggestion';

  @override
  String get bugReport => 'Bug Report';

  @override
  String get usageQuestion => 'Usage Question';

  @override
  String get deposit => 'Place';

  @override
  String get withdraw => 'Fetch';

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

  @override
  String get ready => 'Device ready';

  @override
  String get readyForNextDevice => 'Ready for next device configuration';

  @override
  String autoConnectingToDevice(String name) {
    return 'Auto-connecting to $name...';
  }

  @override
  String get scanningAzDevices => 'ScanningBLEdevices...';

  @override
  String foundAzDevices(int count) {
    return 'Found ${count}BLEdevices';
  }

  @override
  String connectedTo(String name) {
    return 'Connected to $name';
  }

  @override
  String get connectionFailed => 'Connection failed';

  @override
  String get disconnected => 'Disconnected';

  @override
  String get sendingConfig => 'Sending configuration...';

  @override
  String get configSentSuccess => 'Configuration sent successfully';

  @override
  String get configSentFailed => 'Configuration failed';

  @override
  String get connecting => 'Connecting...';

  @override
  String get scanning => 'Scanning...';

  @override
  String get scanAzDevices => 'ScanBLEDevices';

  @override
  String get disconnect => 'Disconnect';

  @override
  String get sendConfig => 'Send Config';

  @override
  String get startScanning => 'Starting scan for BLE devices';

  @override
  String scanComplete(int count) {
    return 'Scan complete, found $count devices';
  }

  @override
  String get noAzDevices =>
      'No BLE devices found, please ensure device is powered on';

  @override
  String get scanError => 'Scan error';

  @override
  String attemptingConnection(String name) {
    return 'Attempting to connect to: $name';
  }

  @override
  String get connectionSuccess => 'Connection successful';

  @override
  String get errorConnectFirst => 'Please connect to device first';

  @override
  String get errorEnterSsid => 'Please enter WiFi SSID';

  @override
  String get errorEnterPassword => 'Please enter WiFi password';

  @override
  String get startSendingWifiConfig => 'Starting WiFi configuration';

  @override
  String get ssid => 'SSID';

  @override
  String get passwordLength => 'Password length';

  @override
  String get sendException => 'Send exception';

  @override
  String get deviceAcceptedConfig => '✓ Device accepted configuration';

  @override
  String get deviceRejectedConfig => '✗ Device rejected configuration';

  @override
  String get receivingFrame => 'Receiving frame';

  @override
  String get deviceResponse => 'Device response';

  @override
  String get frameProcessingError => 'Frame processing error';

  @override
  String get unknownDataFormat => 'Unknown data format';

  @override
  String get waitingForDeviceResponse => 'Waiting for device response...';

  @override
  String get deviceResponseTimeout =>
      'Device response timeout, please check WiFi password';

  @override
  String get foundAzDevicesLabel => 'FoundBLEDevices:';

  @override
  String get wifiConfig => 'WiFi Configuration';

  @override
  String get wifiSsid => 'WiFi SSID';

  @override
  String get wifiPassword => 'WiFi Password';

  @override
  String get enterWifiPassword => 'Enter WiFi password';

  @override
  String get logs => 'Message';

  @override
  String get receivedNotification => 'Received notification';

  @override
  String get usageStatus => 'Usage Status:';

  @override
  String get lockStatus => 'Lock Status:';

  @override
  String get chargingStatus => 'Charging Status:';

  @override
  String get pleaseEnableBluetooth => 'Please enable Bluetooth';

  @override
  String get bluetoothNotEnabled => 'Bluetooth not enabled';

  @override
  String get bluetoothEnabled => 'Bluetooth enabled';

  @override
  String get bluetoothRequired => 'Bluetooth Required';

  @override
  String get bluetoothRequiredMessage =>
      'Bluetooth is required to scan for devices. Would you like to turn it on now?';

  @override
  String get turnOn => 'Turn On';

  @override
  String get changePassword => 'Change Password';

  @override
  String get oldPassword => 'Current Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get pleaseEnterOldPassword => 'Please enter current password';

  @override
  String get pleaseEnterNewPassword => 'Please enter new password';

  @override
  String get pleaseEnterConfirmPassword => 'Please confirm new password';

  @override
  String get passwordsDoNotMatch =>
      'New password and confirmation do not match';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get updatePassword => 'Update Password';

  @override
  String get passwordUpdateSuccess => 'Password updated successfully';

  @override
  String get passwordUpdateFailed =>
      'Password update failed, please check your current password';

  @override
  String get oldPasswordIncorrect => 'Current password is incorrect';

  @override
  String get passwordResetSuccess => 'Password reset successfully';

  @override
  String get passwordResetFailed => 'Password reset failed';

  @override
  String get operateCabinetDoor => 'Operate Door';

  @override
  String get deviceCharging => 'Charging';

  @override
  String get operatePanel => 'Operate Panel';

  @override
  String get deviceOnline => 'Online';

  @override
  String get deviceOffline => 'Offline';

  @override
  String get remoteOperationSuccess => 'Remote Invoke Success';

  @override
  String get remoteOperationFailed => 'Remote Invoke Failed';

  @override
  String get remoteOpenDoor => 'Remote Open Door';

  @override
  String get remoteOpenAlarm => 'Remote Open Alarm';

  @override
  String get appVersion => 'Version';

  @override
  String get searchDevice => 'Search Device';

  @override
  String get searchDeviceHint => 'Enter device ID or name';

  @override
  String get search => 'Search';

  @override
  String get registrationNumber => 'Registration No';

  @override
  String get officialWebsite => 'Official Website';

  @override
  String get noMoreData => 'No more data';
}
