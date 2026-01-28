import 'package:device_vital_monitor_flutter_app/domain/entities/storage_info.dart'
    as domain;

/// Local/platform model for device storage with JSON (de)serialization.
class StorageInfo {
  const StorageInfo({
    required this.total,
    required this.used,
    required this.available,
    required this.usagePercent,
  });

  final int total;
  final int used;
  final int available;
  final int usagePercent;

  factory StorageInfo.fromJson(Map<String, dynamic> json) {
    int? toInt(Object? value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      return null;
    }
    return StorageInfo(
      total: toInt(json['total']) ?? 0,
      used: toInt(json['used']) ?? 0,
      available: toInt(json['available']) ?? 0,
      usagePercent: toInt(json['usagePercent']) ?? 0,
    );
  }

  domain.StorageInfo toEntity() => domain.StorageInfo(
        total: total,
        used: used,
        available: available,
        usagePercent: usagePercent,
      );
}
