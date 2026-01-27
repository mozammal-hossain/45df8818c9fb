import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

const _keyDeviceId = 'device_vital_monitor_device_id';

/// Provides a stable device identifier for logging vitals.
@lazySingleton
class DeviceIdService {
  DeviceIdService(this._prefs);

  final SharedPreferences _prefs;

  static const _uuid = Uuid();

  /// Returns a persisted device id, or creates and stores one.
  Future<String> getOrCreateDeviceId() async {
    final existing = _prefs.getString(_keyDeviceId);
    if (existing != null && existing.isNotEmpty) return existing;
    final id = _uuid.v4();
    await _prefs.setString(_keyDeviceId, id);
    return id;
  }
}
