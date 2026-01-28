import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:device_vital_monitor_flutter_app/core/utils/constants.dart';

@lazySingleton
class DeviceIdLocalDatasource {
  DeviceIdLocalDatasource(this._prefs);

  final SharedPreferences _prefs;
  static const _uuid = Uuid();

  Future<String> getOrCreateDeviceId() async {
    final existing = _prefs.getString(Constants.deviceIdKey);
    if (existing != null && existing.isNotEmpty) return existing;
    final id = _uuid.v4();
    await _prefs.setString(Constants.deviceIdKey, id);
    return id;
  }
}
