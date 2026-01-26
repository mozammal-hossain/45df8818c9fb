/// Model representing device storage information.
class StorageInfo {
  const StorageInfo({
    required this.total,
    required this.used,
    required this.available,
    required this.usagePercent,
  });

  /// Total storage in bytes
  final int total;

  /// Used storage in bytes
  final int used;

  /// Available storage in bytes
  final int available;

  /// Usage percentage (0-100)
  final int usagePercent;

  /// Creates a [StorageInfo] instance from a JSON map.
  factory StorageInfo.fromJson(Map<String, dynamic> json) {
    // Helper to convert dynamic to int
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

  /// Converts this [StorageInfo] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'used': used,
      'available': available,
      'usagePercent': usagePercent,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StorageInfo &&
        other.total == total &&
        other.used == used &&
        other.available == available &&
        other.usagePercent == usagePercent;
  }

  @override
  int get hashCode {
    return Object.hash(total, used, available, usagePercent);
  }

  @override
  String toString() {
    return 'StorageInfo(total: $total, used: $used, available: $available, usagePercent: $usagePercent)';
  }
}
