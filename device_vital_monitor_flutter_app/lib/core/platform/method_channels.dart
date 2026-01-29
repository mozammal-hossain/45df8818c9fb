/// Method channel and event channel names for native platform communication.
abstract final class MethodChannels {
  MethodChannels._();

  /// Main sensor channel: thermal, battery, memory.
  static const String sensors = 'device_vital_monitor/sensors';

  /// Thermal status change stream (Android).
  static const String thermalEvents = 'device_vital_monitor/thermal_events';
}

/// Method names used on [MethodChannels.sensors].
abstract final class SensorMethods {
  SensorMethods._();

  static const String getThermalState = 'getThermalState';
  static const String getThermalHeadroom = 'getThermalHeadroom';
  static const String getBatteryLevel = 'getBatteryLevel';
  static const String getBatteryHealth = 'getBatteryHealth';
  static const String getChargerConnection = 'getChargerConnection';
  static const String getBatteryStatus = 'getBatteryStatus';
  static const String getMemoryUsage = 'getMemoryUsage';
}

/// Channel for scheduling/cancelling background auto-logging (WorkManager / BGAppRefresh).
abstract final class AutoLoggingChannel {
  AutoLoggingChannel._();

  static const String name = 'device_vital_monitor/auto_logging';

  /// Schedule background work. Arguments: [baseUrl], [deviceId].
  static const String scheduleBackground = 'scheduleBackgroundAutoLog';

  /// Cancel background work.
  static const String cancelBackground = 'cancelBackgroundAutoLog';
}
