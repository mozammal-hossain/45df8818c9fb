/// Domain entity: device storage information.
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
}
