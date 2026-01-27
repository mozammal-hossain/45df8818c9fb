// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:device_vital_monitor_flutter_app/bloc/dashboard/dashboard_bloc.dart'
    as _i617;
import 'package:device_vital_monitor_flutter_app/bloc/history/history_bloc.dart'
    as _i473;
import 'package:device_vital_monitor_flutter_app/repositories/vitals_repository.dart'
    as _i347;
import 'package:device_vital_monitor_flutter_app/services/device_id_service.dart'
    as _i110;
import 'package:device_vital_monitor_flutter_app/services/device_sensor_service.dart'
    as _i810;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.lazySingleton<_i347.VitalsRepository>(() => _i347.VitalsRepository());
    gh.lazySingleton<_i810.DeviceSensorService>(
      () => _i810.DeviceSensorService(),
    );
    gh.factory<_i473.HistoryBloc>(
      () => _i473.HistoryBloc(gh<_i347.VitalsRepository>()),
    );
    gh.lazySingleton<_i110.DeviceIdService>(
      () => _i110.DeviceIdService(gh<_i460.SharedPreferences>()),
    );
    gh.factory<_i617.DashboardBloc>(
      () => _i617.DashboardBloc(
        gh<_i810.DeviceSensorService>(),
        gh<_i347.VitalsRepository>(),
        gh<_i110.DeviceIdService>(),
      ),
    );
    return this;
  }
}
