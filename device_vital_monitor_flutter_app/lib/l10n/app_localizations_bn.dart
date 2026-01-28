// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appTitle => 'ডিভাইস ভাইটাল মনিটর';

  @override
  String get toggleThemeTooltip => 'লাইট / ডার্ক / সিস্টেম থিম টগল করুন';

  @override
  String get thermalState => 'তাপীয় অবস্থা';

  @override
  String get thermalStateNone => 'কোনও নেই';

  @override
  String get thermalStateLight => 'হালকা';

  @override
  String get thermalStateModerate => 'মাঝারি';

  @override
  String get thermalStateSevere => 'গুরুতর';

  @override
  String get thermalStateUnknown => 'অজানা';

  @override
  String get thermalDescriptionNone =>
      'সিস্টেম স্বাভাবিক তাপমাত্রার মধ্যে চলছে।';

  @override
  String get thermalDescriptionLight =>
      'হালকা উত্তাপ, পর্যবেক্ষণ সুপারিশ করা হয়।';

  @override
  String get thermalDescriptionModerate =>
      'মাঝারি তাপীয় চাপ সনাক্ত। ব্যবহার কমানোর বিবেচনা করুন।';

  @override
  String get thermalDescriptionSevere =>
      'গুরুতর তাপীয় অবস্থা। ডিভাইস পারফরম্যান্স সীমিত করতে পারে।';

  @override
  String get thermalDescriptionUnavailable => 'তাপীয় অবস্থা উপলব্ধ নয়।';

  @override
  String get loadingThermalState => 'তাপীয় অবস্থা লোড হচ্ছে...';

  @override
  String get batteryLevel => 'ব্যাটারি লেভেল';

  @override
  String get batteryStatusHealthy => 'স্বাস্থ্যকর';

  @override
  String get batteryStatusModerate => 'মাঝারি';

  @override
  String get batteryStatusLow => 'নিচু';

  @override
  String get batteryStatusCritical => 'সমালোচনামূলক';

  @override
  String get batteryStatusLoading => 'লোড হচ্ছে';

  @override
  String estimatedTimeRemaining(int hours) {
    return 'আনুমানিক $hoursঘণ্টা বাকি';
  }

  @override
  String deviceHealthLabel(String health) {
    return 'ডিভাইস স্বাস্থ্য: $health';
  }

  @override
  String chargerLabel(String connection) {
    return 'চার্জার: $connection';
  }

  @override
  String statusLabel(String status) {
    return 'স্থিতি: $status';
  }

  @override
  String get batteryHealthGood => 'ভালো';

  @override
  String get batteryHealthOverheat => 'অতিরিক্ত গরম';

  @override
  String get batteryHealthDead => 'মৃত';

  @override
  String get batteryHealthOverVoltage => 'ওভার ভোল্টেজ';

  @override
  String get batteryHealthUnspecifiedFailure => 'অনির্দিষ্ট ব্যর্থতা';

  @override
  String get batteryHealthCold => 'ঠান্ডা';

  @override
  String get chargerAc => 'এসি চার্জার';

  @override
  String get chargerUsb => 'ইউএসবি';

  @override
  String get chargerWireless => 'ওয়্যারলেস';

  @override
  String get chargerNone => 'সংযুক্ত নয়';

  @override
  String get batteryCharging => 'চার্জ হচ্ছে';

  @override
  String get batteryDischarging => 'ডিসচার্জ হচ্ছে';

  @override
  String get batteryFull => 'পূর্ণ';

  @override
  String get batteryNotCharging => 'চার্জ হচ্ছে না';

  @override
  String get batteryUnknown => 'অজানা';

  @override
  String get memoryUsage => 'মেমরি ব্যবহার';

  @override
  String get memoryCritical => 'সমালোচনামূলক';

  @override
  String get memoryHigh => 'উচ্চ';

  @override
  String get memoryModerate => 'মাঝারি';

  @override
  String get memoryNormal => 'স্বাভাবিক';

  @override
  String get memoryOptimized => 'অপ্টিমাইজড';

  @override
  String get used => 'ব্যবহৃত';

  @override
  String get loading => 'লোড হচ্ছে…';

  @override
  String get unavailable => 'অপলব্ধ';

  @override
  String get dash => '—';

  @override
  String get diskSpace => 'ডিস্ক স্পেস';

  @override
  String get total => 'মোট';

  @override
  String usedFormatted(String formatted) {
    return 'ব্যবহৃত: $formatted';
  }

  @override
  String availableFormatted(String formatted) {
    return 'উপলব্ধ: $formatted';
  }

  @override
  String get storageUnavailable => 'স্টোরেজ তথ্য উপলব্ধ নয়';

  @override
  String get logStatusSnapshot => 'লগ স্ট্যাটাস স্ন্যাপশট';

  @override
  String get unitB => 'B';

  @override
  String get unitKB => 'KB';

  @override
  String get unitMB => 'MB';

  @override
  String get unitGB => 'GB';

  @override
  String get unitTB => 'TB';

  @override
  String get zeroBytes => '০ B';

  @override
  String get historyTitle => 'ইতিহাস';

  @override
  String get historyEmpty =>
      'এখনও কোনো ভাইটাল লগ নেই। ড্যাশবোর্ডে \"লগ স্ট্যাটাস\" ব্যবহার করুন।';

  @override
  String get analyticsTitle => 'বিশ্লেষণ (রোলিং উইন্ডো)';

  @override
  String get averageThermalLabel => 'গড় তাপীয়';

  @override
  String get averageBatteryLabel => 'গড় ব্যাটারি';

  @override
  String get averageMemoryLabel => 'গড় মেমরি';

  @override
  String get totalLogsLabel => 'মোট লগ';

  @override
  String get rollingWindowLogsLabel => 'উইন্ডোতে লগ';

  @override
  String get dashboardTitle => 'ড্যাশবোর্ড';

  @override
  String get loggingEllipsis => 'লগ করা হচ্ছে…';

  @override
  String get appSettingsTitle => 'অ্যাপ সেটিংস';

  @override
  String get settingsSubtitle => 'আপনার পছন্দসমূহ পরিচালনা করুন';

  @override
  String get languageLabel => 'ভাষা';

  @override
  String get languageBangla => 'বাংলা';

  @override
  String get languageEnglish => 'ইংরেজি';

  @override
  String get themeLabel => 'থিম';

  @override
  String get themeLight => 'লাইট';

  @override
  String get themeDark => 'ডার্ক';

  @override
  String get themeSystemDefault => 'সিস্টেম ডিফল্ট';

  @override
  String get settingsTitle => 'সেটিংস';

  @override
  String versionBuild(String version, String build) {
    return 'সংস্করণ $version (বিল্ড $build)';
  }
}
