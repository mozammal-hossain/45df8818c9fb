import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

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
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Device Vital Monitor'**
  String get appTitle;

  /// No description provided for @toggleThemeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Toggle light / dark / system theme'**
  String get toggleThemeTooltip;

  /// No description provided for @thermalState.
  ///
  /// In en, this message translates to:
  /// **'Thermal State'**
  String get thermalState;

  /// No description provided for @thermalStateNone.
  ///
  /// In en, this message translates to:
  /// **'NONE'**
  String get thermalStateNone;

  /// No description provided for @thermalStateLight.
  ///
  /// In en, this message translates to:
  /// **'LIGHT'**
  String get thermalStateLight;

  /// No description provided for @thermalStateModerate.
  ///
  /// In en, this message translates to:
  /// **'MODERATE'**
  String get thermalStateModerate;

  /// No description provided for @thermalStateSevere.
  ///
  /// In en, this message translates to:
  /// **'SEVERE'**
  String get thermalStateSevere;

  /// No description provided for @thermalStateUnknown.
  ///
  /// In en, this message translates to:
  /// **'UNKNOWN'**
  String get thermalStateUnknown;

  /// No description provided for @thermalDescriptionNone.
  ///
  /// In en, this message translates to:
  /// **'System operating within normal temperature ranges.'**
  String get thermalDescriptionNone;

  /// No description provided for @thermalDescriptionLight.
  ///
  /// In en, this message translates to:
  /// **'Slightly elevated temperature, monitoring recommended.'**
  String get thermalDescriptionLight;

  /// No description provided for @thermalDescriptionModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate thermal stress detected. Consider reducing usage.'**
  String get thermalDescriptionModerate;

  /// No description provided for @thermalDescriptionSevere.
  ///
  /// In en, this message translates to:
  /// **'Severe thermal condition. Device may throttle performance.'**
  String get thermalDescriptionSevere;

  /// No description provided for @thermalDescriptionUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Thermal state unavailable.'**
  String get thermalDescriptionUnavailable;

  /// No description provided for @loadingThermalState.
  ///
  /// In en, this message translates to:
  /// **'Loading thermal state...'**
  String get loadingThermalState;

  /// No description provided for @batteryLevel.
  ///
  /// In en, this message translates to:
  /// **'Battery Level'**
  String get batteryLevel;

  /// No description provided for @batteryStatusHealthy.
  ///
  /// In en, this message translates to:
  /// **'HEALTHY'**
  String get batteryStatusHealthy;

  /// No description provided for @batteryStatusModerate.
  ///
  /// In en, this message translates to:
  /// **'MODERATE'**
  String get batteryStatusModerate;

  /// No description provided for @batteryStatusLow.
  ///
  /// In en, this message translates to:
  /// **'LOW'**
  String get batteryStatusLow;

  /// No description provided for @batteryStatusCritical.
  ///
  /// In en, this message translates to:
  /// **'CRITICAL'**
  String get batteryStatusCritical;

  /// No description provided for @batteryStatusLoading.
  ///
  /// In en, this message translates to:
  /// **'LOADING'**
  String get batteryStatusLoading;

  /// No description provided for @estimatedTimeRemaining.
  ///
  /// In en, this message translates to:
  /// **'Estimated {hours}h remaining'**
  String estimatedTimeRemaining(int hours);

  /// No description provided for @deviceHealthLabel.
  ///
  /// In en, this message translates to:
  /// **'Device health: {health}'**
  String deviceHealthLabel(String health);

  /// No description provided for @chargerLabel.
  ///
  /// In en, this message translates to:
  /// **'Charger: {connection}'**
  String chargerLabel(String connection);

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status: {status}'**
  String statusLabel(String status);

  /// No description provided for @batteryHealthGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get batteryHealthGood;

  /// No description provided for @batteryHealthOverheat.
  ///
  /// In en, this message translates to:
  /// **'Overheat'**
  String get batteryHealthOverheat;

  /// No description provided for @batteryHealthDead.
  ///
  /// In en, this message translates to:
  /// **'Dead'**
  String get batteryHealthDead;

  /// No description provided for @batteryHealthOverVoltage.
  ///
  /// In en, this message translates to:
  /// **'Over voltage'**
  String get batteryHealthOverVoltage;

  /// No description provided for @batteryHealthUnspecifiedFailure.
  ///
  /// In en, this message translates to:
  /// **'Unspecified failure'**
  String get batteryHealthUnspecifiedFailure;

  /// No description provided for @batteryHealthCold.
  ///
  /// In en, this message translates to:
  /// **'Cold'**
  String get batteryHealthCold;

  /// No description provided for @chargerAc.
  ///
  /// In en, this message translates to:
  /// **'AC Charger'**
  String get chargerAc;

  /// No description provided for @chargerUsb.
  ///
  /// In en, this message translates to:
  /// **'USB'**
  String get chargerUsb;

  /// No description provided for @chargerWireless.
  ///
  /// In en, this message translates to:
  /// **'Wireless'**
  String get chargerWireless;

  /// No description provided for @chargerNone.
  ///
  /// In en, this message translates to:
  /// **'Not connected'**
  String get chargerNone;

  /// No description provided for @batteryCharging.
  ///
  /// In en, this message translates to:
  /// **'Charging'**
  String get batteryCharging;

  /// No description provided for @batteryDischarging.
  ///
  /// In en, this message translates to:
  /// **'Discharging'**
  String get batteryDischarging;

  /// No description provided for @batteryFull.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get batteryFull;

  /// No description provided for @batteryNotCharging.
  ///
  /// In en, this message translates to:
  /// **'Not charging'**
  String get batteryNotCharging;

  /// No description provided for @batteryUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get batteryUnknown;

  /// No description provided for @memoryUsage.
  ///
  /// In en, this message translates to:
  /// **'Memory Usage'**
  String get memoryUsage;

  /// No description provided for @memoryCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get memoryCritical;

  /// No description provided for @memoryHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get memoryHigh;

  /// No description provided for @memoryModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get memoryModerate;

  /// No description provided for @memoryNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get memoryNormal;

  /// No description provided for @memoryOptimized.
  ///
  /// In en, this message translates to:
  /// **'Optimized'**
  String get memoryOptimized;

  /// No description provided for @used.
  ///
  /// In en, this message translates to:
  /// **'used'**
  String get used;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'loading…'**
  String get loading;

  /// No description provided for @unavailable.
  ///
  /// In en, this message translates to:
  /// **'unavailable'**
  String get unavailable;

  /// No description provided for @dash.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get dash;

  /// No description provided for @diskSpace.
  ///
  /// In en, this message translates to:
  /// **'Disk Space'**
  String get diskSpace;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'total'**
  String get total;

  /// No description provided for @usedFormatted.
  ///
  /// In en, this message translates to:
  /// **'Used: {formatted}'**
  String usedFormatted(String formatted);

  /// No description provided for @availableFormatted.
  ///
  /// In en, this message translates to:
  /// **'Available: {formatted}'**
  String availableFormatted(String formatted);

  /// No description provided for @storageUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Storage information unavailable'**
  String get storageUnavailable;

  /// No description provided for @logStatusSnapshot.
  ///
  /// In en, this message translates to:
  /// **'Log Status Snapshot'**
  String get logStatusSnapshot;

  /// No description provided for @unitB.
  ///
  /// In en, this message translates to:
  /// **'B'**
  String get unitB;

  /// No description provided for @unitKB.
  ///
  /// In en, this message translates to:
  /// **'KB'**
  String get unitKB;

  /// No description provided for @unitMB.
  ///
  /// In en, this message translates to:
  /// **'MB'**
  String get unitMB;

  /// No description provided for @unitGB.
  ///
  /// In en, this message translates to:
  /// **'GB'**
  String get unitGB;

  /// No description provided for @unitTB.
  ///
  /// In en, this message translates to:
  /// **'TB'**
  String get unitTB;

  /// No description provided for @zeroBytes.
  ///
  /// In en, this message translates to:
  /// **'0 B'**
  String get zeroBytes;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// No description provided for @historyEmpty.
  ///
  /// In en, this message translates to:
  /// **'No vitals logged yet. Use “Log Status” on the dashboard.'**
  String get historyEmpty;

  /// No description provided for @analyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Analytics (rolling window)'**
  String get analyticsTitle;

  /// No description provided for @averageThermalLabel.
  ///
  /// In en, this message translates to:
  /// **'Avg thermal'**
  String get averageThermalLabel;

  /// No description provided for @averageBatteryLabel.
  ///
  /// In en, this message translates to:
  /// **'Avg battery'**
  String get averageBatteryLabel;

  /// No description provided for @averageMemoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Avg memory'**
  String get averageMemoryLabel;

  /// No description provided for @totalLogsLabel.
  ///
  /// In en, this message translates to:
  /// **'Total logs'**
  String get totalLogsLabel;

  /// No description provided for @rollingWindowLogsLabel.
  ///
  /// In en, this message translates to:
  /// **'Logs in window'**
  String get rollingWindowLogsLabel;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// No description provided for @loggingEllipsis.
  ///
  /// In en, this message translates to:
  /// **'Logging…'**
  String get loggingEllipsis;
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
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
