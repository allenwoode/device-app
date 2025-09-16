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
  /// **'Network error, please try again later'**
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
  /// **'Usage Rate'**
  String get usageRate;

  /// No description provided for @alerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alerts;

  /// No description provided for @operationLog.
  ///
  /// In en, this message translates to:
  /// **'Operation Log'**
  String get operationLog;

  /// No description provided for @remoteSettings.
  ///
  /// In en, this message translates to:
  /// **'Remote Settings'**
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
  /// **'Alarm'**
  String get alarm;

  /// No description provided for @severe.
  ///
  /// In en, this message translates to:
  /// **'Severe'**
  String get severe;

  /// No description provided for @deviceReport.
  ///
  /// In en, this message translates to:
  /// **'Device Report'**
  String get deviceReport;

  /// No description provided for @platformDispatch.
  ///
  /// In en, this message translates to:
  /// **'Platform Dispatch'**
  String get platformDispatch;

  /// No description provided for @top5Usage.
  ///
  /// In en, this message translates to:
  /// **'Top 5 Usage Amount'**
  String get top5Usage;
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
