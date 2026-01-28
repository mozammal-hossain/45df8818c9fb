import 'storage_info.dart';

/// Domain entity: snapshot of device sensor readings (thermal, battery, memory, storage).
class SensorData {
  const SensorData({
    this.thermalState,
    this.thermalHeadroom,
    this.batteryLevel,
    this.batteryHealth,
    this.chargerConnection,
    this.batteryStatus,
    this.memoryUsage,
    this.storageInfo,
  });

  final int? thermalState;
  final double? thermalHeadroom;
  final int? batteryLevel;
  final String? batteryHealth;
  final String? chargerConnection;
  final String? batteryStatus;
  final int? memoryUsage;
  final StorageInfo? storageInfo;

  SensorData copyWith({
    int? thermalState,
    double? thermalHeadroom,
    int? batteryLevel,
    String? batteryHealth,
    String? chargerConnection,
    String? batteryStatus,
    int? memoryUsage,
    StorageInfo? storageInfo,
  }) =>
      SensorData(
        thermalState: thermalState ?? this.thermalState,
        thermalHeadroom: thermalHeadroom ?? this.thermalHeadroom,
        batteryLevel: batteryLevel ?? this.batteryLevel,
        batteryHealth: batteryHealth ?? this.batteryHealth,
        chargerConnection: chargerConnection ?? this.chargerConnection,
        batteryStatus: batteryStatus ?? this.batteryStatus,
        memoryUsage: memoryUsage ?? this.memoryUsage,
        storageInfo: storageInfo ?? this.storageInfo,
      );
}
