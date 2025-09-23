import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Device Manager'**
  String get appTitle;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @loginProblem.
  ///
  /// In en, this message translates to:
  /// **'Having trouble logging in?'**
  String get loginProblem;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @accountAppeal.
  ///
  /// In en, this message translates to:
  /// **'Account Appeal'**
  String get accountAppeal;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}!'**
  String welcome(String name);

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed, please check username and password'**
  String get loginFailed;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error, please check connection and try again'**
  String get networkError;

  /// No description provided for @checkingLoginState.
  ///
  /// In en, this message translates to:
  /// **'Checking login status...'**
  String get checkingLoginState;

  /// No description provided for @startingApp.
  ///
  /// In en, this message translates to:
  /// **'Starting app...'**
  String get startingApp;

  /// No description provided for @loginExpired.
  ///
  /// In en, this message translates to:
  /// **'Login expired, please login again'**
  String get loginExpired;

  /// No description provided for @pleaseEnterUsername.
  ///
  /// In en, this message translates to:
  /// **'Please enter username'**
  String get pleaseEnterUsername;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter password'**
  String get pleaseEnterPassword;

  /// No description provided for @passwordLogin.
  ///
  /// In en, this message translates to:
  /// **'Password Login'**
  String get passwordLogin;

  /// No description provided for @devices.
  ///
  /// In en, this message translates to:
  /// **'Devices'**
  String get devices;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @mine.
  ///
  /// In en, this message translates to:
  /// **'Mine'**
  String get mine;

  /// No description provided for @iot.
  ///
  /// In en, this message translates to:
  /// **'IoT'**
  String get iot;

  /// No description provided for @searchDeviceIdName.
  ///
  /// In en, this message translates to:
  /// **'Search device ID/name'**
  String get searchDeviceIdName;

  /// No description provided for @loadingDevicesFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load device data'**
  String get loadingDevicesFailed;

  /// No description provided for @networkConnectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Network connection failed'**
  String get networkConnectionFailed;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Server error'**
  String get serverError;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noDeviceData.
  ///
  /// In en, this message translates to:
  /// **'No device data'**
  String get noDeviceData;

  /// No description provided for @loadingMoreDevices.
  ///
  /// In en, this message translates to:
  /// **'Loading more devices...'**
  String get loadingMoreDevices;

  /// No description provided for @allDevicesLoaded.
  ///
  /// In en, this message translates to:
  /// **'All devices loaded ({count} total)'**
  String allDevicesLoaded(int count);

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @usageRate.
  ///
  /// In en, this message translates to:
  /// **'Usage'**
  String get usageRate;

  /// No description provided for @alerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alerts;

  /// No description provided for @operationLog.
  ///
  /// In en, this message translates to:
  /// **'Operation'**
  String get operationLog;

  /// No description provided for @remoteSettings.
  ///
  /// In en, this message translates to:
  /// **'Remote'**
  String get remoteSettings;

  /// No description provided for @deviceOfflineCannotRemoteSet.
  ///
  /// In en, this message translates to:
  /// **'Device offline, cannot perform remote settings'**
  String get deviceOfflineCannotRemoteSet;

  /// No description provided for @deviceLock.
  ///
  /// In en, this message translates to:
  /// **'Device Lock'**
  String get deviceLock;

  /// No description provided for @deviceUnlock.
  ///
  /// In en, this message translates to:
  /// **'Device Unlock'**
  String get deviceUnlock;

  /// No description provided for @notPowered.
  ///
  /// In en, this message translates to:
  /// **'Not Powered'**
  String get notPowered;

  /// No description provided for @charging.
  ///
  /// In en, this message translates to:
  /// **'Charging'**
  String get charging;

  /// No description provided for @fullyCharged.
  ///
  /// In en, this message translates to:
  /// **'Fully Charged'**
  String get fullyCharged;

  /// No description provided for @organizationUnitEmpty.
  ///
  /// In en, this message translates to:
  /// **'Organization unit is empty'**
  String get organizationUnitEmpty;

  /// No description provided for @confirmExit.
  ///
  /// In en, this message translates to:
  /// **'Confirm Exit'**
  String get confirmExit;

  /// No description provided for @confirmLogoutMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get confirmLogoutMessage;

  /// No description provided for @logoutSuccess.
  ///
  /// In en, this message translates to:
  /// **'Logout successful'**
  String get logoutSuccess;

  /// No description provided for @logoutFailed.
  ///
  /// In en, this message translates to:
  /// **'Logout failed, please try again'**
  String get logoutFailed;

  /// No description provided for @versionUpdate.
  ///
  /// In en, this message translates to:
  /// **'Version Update'**
  String get versionUpdate;

  /// No description provided for @aboutUs.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get aboutUs;

  /// No description provided for @versionUpdateTodo.
  ///
  /// In en, this message translates to:
  /// **'Version update feature to be implemented'**
  String get versionUpdateTodo;

  /// No description provided for @aboutUsTodo.
  ///
  /// In en, this message translates to:
  /// **'About us feature to be implemented'**
  String get aboutUsTodo;

  /// No description provided for @userRoleEmpty.
  ///
  /// In en, this message translates to:
  /// **'User role is empty'**
  String get userRoleEmpty;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @usageDistribution.
  ///
  /// In en, this message translates to:
  /// **'Usage Distribution'**
  String get usageDistribution;

  /// No description provided for @todayAlerts.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Alerts'**
  String get todayAlerts;

  /// No description provided for @operationLogs.
  ///
  /// In en, this message translates to:
  /// **'Operation Logs'**
  String get operationLogs;

  /// No description provided for @alarm.
  ///
  /// In en, this message translates to:
  /// **'Notice'**
  String get alarm;

  /// No description provided for @severe.
  ///
  /// In en, this message translates to:
  /// **'Severe'**
  String get severe;

  /// No description provided for @deviceReport.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get deviceReport;

  /// No description provided for @platformDispatch.
  ///
  /// In en, this message translates to:
  /// **'Dispatch'**
  String get platformDispatch;

  /// No description provided for @todayUsageTop5.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Usage TOP5'**
  String get todayUsageTop5;

  /// No description provided for @loadDeviceDataFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load device data!'**
  String get loadDeviceDataFailed;

  /// No description provided for @remoteOpenCabinetDoor.
  ///
  /// In en, this message translates to:
  /// **'Do you want to remotely open cabinet door {slotId}?'**
  String remoteOpenCabinetDoor(String slotId);

  /// No description provided for @pleaseEnterAdminPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter administrator password'**
  String get pleaseEnterAdminPassword;

  /// No description provided for @cabinetDoorOpening.
  ///
  /// In en, this message translates to:
  /// **'Opening cabinet door {slotId}...'**
  String cabinetDoorOpening(String slotId);

  /// No description provided for @cabinetDoorOpenedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Cabinet door {slotId} opened successfully'**
  String cabinetDoorOpenedSuccessfully(String slotId);

  /// No description provided for @cabinetDoorOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to open cabinet door {slotId}, please try again'**
  String cabinetDoorOpenFailed(String slotId);

  /// No description provided for @deviceCannotRemoteClose.
  ///
  /// In en, this message translates to:
  /// **'Device cannot be remotely closed'**
  String get deviceCannotRemoteClose;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @loginError.
  ///
  /// In en, this message translates to:
  /// **'Login Error'**
  String get loginError;

  /// No description provided for @todayUsage.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Usage'**
  String get todayUsage;

  /// No description provided for @noUsageRecords.
  ///
  /// In en, this message translates to:
  /// **'No usage records'**
  String get noUsageRecords;

  /// No description provided for @noUsageDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No usage data available'**
  String get noUsageDataAvailable;

  /// No description provided for @operationInfo.
  ///
  /// In en, this message translates to:
  /// **'Operation Info'**
  String get operationInfo;

  /// No description provided for @operationTime.
  ///
  /// In en, this message translates to:
  /// **'Operation Time'**
  String get operationTime;

  /// No description provided for @usageInfo.
  ///
  /// In en, this message translates to:
  /// **'Usage Info'**
  String get usageInfo;

  /// No description provided for @usageTime.
  ///
  /// In en, this message translates to:
  /// **'Usage Time'**
  String get usageTime;

  /// No description provided for @inUse.
  ///
  /// In en, this message translates to:
  /// **'{port} In Use'**
  String inUse(Object port);

  /// No description provided for @noAlertData.
  ///
  /// In en, this message translates to:
  /// **'No alert data'**
  String get noAlertData;

  /// No description provided for @noAlertInfo.
  ///
  /// In en, this message translates to:
  /// **'No alert information'**
  String get noAlertInfo;

  /// No description provided for @alertInfo.
  ///
  /// In en, this message translates to:
  /// **'Alert Info'**
  String get alertInfo;

  /// No description provided for @alertTime.
  ///
  /// In en, this message translates to:
  /// **'Alert Time'**
  String get alertTime;

  /// No description provided for @propertyReport.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get propertyReport;

  /// No description provided for @noLogData.
  ///
  /// In en, this message translates to:
  /// **'No log data'**
  String get noLogData;

  /// No description provided for @noLogInfo.
  ///
  /// In en, this message translates to:
  /// **'No log information'**
  String get noLogInfo;

  /// No description provided for @deviceManagement.
  ///
  /// In en, this message translates to:
  /// **'Device Management'**
  String get deviceManagement;

  /// No description provided for @feedbackSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedbackSuggestions;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @deviceUnbind.
  ///
  /// In en, this message translates to:
  /// **'Device Unbind'**
  String get deviceUnbind;

  /// No description provided for @confirmDeviceUnbind.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to unbind the current device?'**
  String get confirmDeviceUnbind;

  /// No description provided for @unbind.
  ///
  /// In en, this message translates to:
  /// **'Unbind'**
  String get unbind;

  /// No description provided for @addDevice.
  ///
  /// In en, this message translates to:
  /// **'Add Device'**
  String get addDevice;

  /// No description provided for @scanQROrEnterID.
  ///
  /// In en, this message translates to:
  /// **'Scan QR code or enter device ID manually'**
  String get scanQROrEnterID;

  /// No description provided for @unbindDevices.
  ///
  /// In en, this message translates to:
  /// **'Unbind Devices'**
  String get unbindDevices;

  /// No description provided for @batchUnbindDevices.
  ///
  /// In en, this message translates to:
  /// **'Batch unbind devices'**
  String get batchUnbindDevices;

  /// No description provided for @deviceAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Device added successfully'**
  String get deviceAddedSuccessfully;

  /// No description provided for @enterDeviceIDManually.
  ///
  /// In en, this message translates to:
  /// **'Enter Device ID Manually'**
  String get enterDeviceIDManually;

  /// No description provided for @pleaseEnterDeviceID.
  ///
  /// In en, this message translates to:
  /// **'Please enter device ID'**
  String get pleaseEnterDeviceID;

  /// No description provided for @bindDevice.
  ///
  /// In en, this message translates to:
  /// **'Bind Device'**
  String get bindDevice;

  /// No description provided for @scanQRCode.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get scanQRCode;

  /// No description provided for @scanDeviceQRCode.
  ///
  /// In en, this message translates to:
  /// **'Scan Device QR Code'**
  String get scanDeviceQRCode;

  /// No description provided for @bindFailed.
  ///
  /// In en, this message translates to:
  /// **'Binding failed, please check if device ID is correct'**
  String get bindFailed;

  /// No description provided for @bindOperationFailed.
  ///
  /// In en, this message translates to:
  /// **'Binding operation failed, please try again'**
  String get bindOperationFailed;

  /// No description provided for @loadDeviceListFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load device list'**
  String get loadDeviceListFailed;

  /// No description provided for @pleaseSelectAtLeastOneDevice.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one device'**
  String get pleaseSelectAtLeastOneDevice;

  /// No description provided for @confirmUnbindDevices.
  ///
  /// In en, this message translates to:
  /// **'Confirm Unbind Devices'**
  String get confirmUnbindDevices;

  /// No description provided for @confirmUnbindMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to unbind the selected {count} devices? This action cannot be undone.'**
  String confirmUnbindMessage(int count);

  /// No description provided for @unbindingDevices.
  ///
  /// In en, this message translates to:
  /// **'Unbinding devices...'**
  String get unbindingDevices;

  /// No description provided for @pleaseWaitProcessingDevices.
  ///
  /// In en, this message translates to:
  /// **'Please wait, processing {count} devices'**
  String pleaseWaitProcessingDevices(int count);

  /// No description provided for @noDevicesToUnbind.
  ///
  /// In en, this message translates to:
  /// **'No devices to unbind'**
  String get noDevicesToUnbind;

  /// No description provided for @unbindWarning.
  ///
  /// In en, this message translates to:
  /// **'After unbinding, you will no longer be able to control the device'**
  String get unbindWarning;

  /// No description provided for @selectedDevicesCount.
  ///
  /// In en, this message translates to:
  /// **'Selected {count} devices'**
  String selectedDevicesCount(int count);

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get selectAll;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @allDevicesLoadedCount.
  ///
  /// In en, this message translates to:
  /// **'Loaded all {count} devices'**
  String allDevicesLoadedCount(int count);

  /// No description provided for @unbindCount.
  ///
  /// In en, this message translates to:
  /// **'Unbind ({count})'**
  String unbindCount(int count);

  /// No description provided for @successfullyUnbound.
  ///
  /// In en, this message translates to:
  /// **'Successfully unbound {count} devices'**
  String successfullyUnbound(int count);

  /// No description provided for @unbindFailedRetry.
  ///
  /// In en, this message translates to:
  /// **'Unbind failed, please try again'**
  String get unbindFailedRetry;

  /// No description provided for @unbindMixed.
  ///
  /// In en, this message translates to:
  /// **'Successfully unbound {success} devices, {failed} failed'**
  String unbindMixed(int success, int failed);

  /// No description provided for @unbindOperationError.
  ///
  /// In en, this message translates to:
  /// **'Unbind operation error, please try again'**
  String get unbindOperationError;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @languageSettings.
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get languageSettings;

  /// No description provided for @currentLanguage.
  ///
  /// In en, this message translates to:
  /// **'Current Language: {language}'**
  String currentLanguage(String language);

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// No description provided for @notificationSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage push notification settings'**
  String get notificationSettingsSubtitle;

  /// No description provided for @notificationFeatureTodo.
  ///
  /// In en, this message translates to:
  /// **'Notification settings feature to be developed'**
  String get notificationFeatureTodo;

  /// No description provided for @privacySecurity.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get privacySecurity;

  /// No description provided for @privacySecuritySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Changing login password'**
  String get privacySecuritySubtitle;

  /// No description provided for @securityFeatureTodo.
  ///
  /// In en, this message translates to:
  /// **'Security settings feature to be developed'**
  String get securityFeatureTodo;

  /// No description provided for @storageManagement.
  ///
  /// In en, this message translates to:
  /// **'Storage Management'**
  String get storageManagement;

  /// No description provided for @storageManagementSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Clear cache and local data'**
  String get storageManagementSubtitle;

  /// No description provided for @clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get clearCache;

  /// No description provided for @clearCacheConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear the application cache? This will delete temporary files but will not affect your personal data.'**
  String get clearCacheConfirm;

  /// No description provided for @cacheCleared.
  ///
  /// In en, this message translates to:
  /// **'Cache cleared successfully'**
  String get cacheCleared;

  /// No description provided for @saveLanguageSettingsFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save language settings, please try again'**
  String get saveLanguageSettingsFailed;

  /// No description provided for @feedbackType.
  ///
  /// In en, this message translates to:
  /// **'Feedback Type'**
  String get feedbackType;

  /// No description provided for @feedbackContent.
  ///
  /// In en, this message translates to:
  /// **'Feedback Content'**
  String get feedbackContent;

  /// No description provided for @contactInfo.
  ///
  /// In en, this message translates to:
  /// **'Contact Info (Optional)'**
  String get contactInfo;

  /// No description provided for @feedbackHint.
  ///
  /// In en, this message translates to:
  /// **'Please describe your issue or suggestion in detail...'**
  String get feedbackHint;

  /// No description provided for @contactHint.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email or phone number'**
  String get contactHint;

  /// No description provided for @contactHelpText.
  ///
  /// In en, this message translates to:
  /// **'Providing contact information helps us respond to you better'**
  String get contactHelpText;

  /// No description provided for @submitFeedback.
  ///
  /// In en, this message translates to:
  /// **'Submit Feedback'**
  String get submitFeedback;

  /// No description provided for @pleaseFillFeedback.
  ///
  /// In en, this message translates to:
  /// **'Please enter feedback content'**
  String get pleaseFillFeedback;

  /// No description provided for @feedbackSubmitFailed.
  ///
  /// In en, this message translates to:
  /// **'Submission failed, please try again'**
  String get feedbackSubmitFailed;

  /// No description provided for @featureSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Feature Suggestion'**
  String get featureSuggestion;

  /// No description provided for @bugReport.
  ///
  /// In en, this message translates to:
  /// **'Bug Report'**
  String get bugReport;

  /// No description provided for @usageQuestion.
  ///
  /// In en, this message translates to:
  /// **'Usage Question'**
  String get usageQuestion;

  /// No description provided for @primary.
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get primary;

  /// No description provided for @secondary.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get secondary;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @permissionInsufficient.
  ///
  /// In en, this message translates to:
  /// **'Permission Insufficient'**
  String get permissionInsufficient;

  /// No description provided for @cameraPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is required to scan QR codes. Please enable camera permission in settings.'**
  String get cameraPermissionRequired;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// No description provided for @bindingDevice.
  ///
  /// In en, this message translates to:
  /// **'Binding device...'**
  String get bindingDevice;

  /// No description provided for @bindSuccess.
  ///
  /// In en, this message translates to:
  /// **'Binding success'**
  String get bindSuccess;

  /// No description provided for @scanInstructions.
  ///
  /// In en, this message translates to:
  /// **'Place the device QR code within the scan frame'**
  String get scanInstructions;

  /// No description provided for @scanHint.
  ///
  /// In en, this message translates to:
  /// **'Device will be automatically bound after successful scan'**
  String get scanHint;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
