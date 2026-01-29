// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:device_vital_monitor_flutter_app/core/config/api_config.dart'
    as _i321;
import 'package:device_vital_monitor_flutter_app/core/services/auto_logging_scheduler.dart'
    as _i403;
import 'package:device_vital_monitor_flutter_app/data/datasources/local/device_id_local_datasource.dart'
    as _i900;
import 'package:device_vital_monitor_flutter_app/data/datasources/local/preferences_datasource.dart'
    as _i969;
import 'package:device_vital_monitor_flutter_app/data/datasources/platform/auto_logging_platform_datasource.dart'
    as _i656;
import 'package:device_vital_monitor_flutter_app/data/datasources/platform/sensor_platform_datasource.dart'
    as _i139;
import 'package:device_vital_monitor_flutter_app/data/datasources/remote/vitals_remote_datasource.dart'
    as _i305;
import 'package:device_vital_monitor_flutter_app/data/repositories/device_repository_impl.dart'
    as _i1046;
import 'package:device_vital_monitor_flutter_app/data/repositories/preferences_repository_impl.dart'
    as _i422;
import 'package:device_vital_monitor_flutter_app/data/repositories/vitals_repository_impl.dart'
    as _i28;
import 'package:device_vital_monitor_flutter_app/domain/repositories/device_repository.dart'
    as _i480;
import 'package:device_vital_monitor_flutter_app/domain/repositories/preferences_repository.dart'
    as _i608;
import 'package:device_vital_monitor_flutter_app/domain/repositories/vitals_repository.dart'
    as _i734;
import 'package:device_vital_monitor_flutter_app/domain/usecases/get_analytics_usecase.dart'
    as _i783;
import 'package:device_vital_monitor_flutter_app/domain/usecases/get_history_usecase.dart'
    as _i732;
import 'package:device_vital_monitor_flutter_app/domain/usecases/get_sensor_data_usecase.dart'
    as _i531;
import 'package:device_vital_monitor_flutter_app/domain/usecases/log_vital_snapshot_usecase.dart'
    as _i366;
import 'package:device_vital_monitor_flutter_app/presentation/dashboard/bloc/dashboard_bloc.dart'
    as _i686;
import 'package:device_vital_monitor_flutter_app/presentation/history/bloc/history_bloc.dart'
    as _i801;
import 'package:dio/dio.dart' as _i361;
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
    gh.lazySingleton<_i656.AutoLoggingPlatformDatasource>(
      () => _i656.AutoLoggingPlatformDatasource(),
    );
    gh.lazySingleton<_i139.SensorPlatformDatasource>(
      () => _i139.SensorPlatformDatasource(),
    );
    gh.lazySingleton<_i900.DeviceIdLocalDatasource>(
      () => _i900.DeviceIdLocalDatasource(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i969.PreferencesDatasource>(
      () => _i969.PreferencesDatasource(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i305.VitalsRemoteDatasource>(
      () => _i305.VitalsRemoteDatasource(
        dio: gh<_i361.Dio>(),
        apiConfig: gh<_i321.ApiConfig>(),
      ),
    );
    gh.lazySingleton<_i480.DeviceRepository>(
      () => _i1046.DeviceRepositoryImpl(
        gh<_i900.DeviceIdLocalDatasource>(),
        gh<_i139.SensorPlatformDatasource>(),
      ),
    );
    gh.lazySingleton<_i734.VitalsRepository>(
      () => _i28.VitalsRepositoryImpl(gh<_i305.VitalsRemoteDatasource>()),
    );
    gh.factory<_i366.LogVitalSnapshotUsecase>(
      () => _i366.LogVitalSnapshotUsecase(
        gh<_i734.VitalsRepository>(),
        gh<_i480.DeviceRepository>(),
      ),
    );
    gh.factory<_i531.GetSensorDataUsecase>(
      () => _i531.GetSensorDataUsecase(gh<_i480.DeviceRepository>()),
    );
    gh.lazySingleton<_i608.PreferencesRepository>(
      () => _i422.PreferencesRepositoryImpl(gh<_i969.PreferencesDatasource>()),
    );
    gh.factory<_i783.GetAnalyticsUsecase>(
      () => _i783.GetAnalyticsUsecase(gh<_i734.VitalsRepository>()),
    );
    gh.factory<_i732.GetHistoryUsecase>(
      () => _i732.GetHistoryUsecase(gh<_i734.VitalsRepository>()),
    );
    gh.factory<_i801.HistoryBloc>(
      () => _i801.HistoryBloc(
        gh<_i732.GetHistoryUsecase>(),
        gh<_i783.GetAnalyticsUsecase>(),
      ),
    );
    gh.lazySingleton<_i403.AutoLoggingScheduler>(
      () => _i403.AutoLoggingScheduler(
        gh<_i366.LogVitalSnapshotUsecase>(),
        gh<_i531.GetSensorDataUsecase>(),
        gh<_i480.DeviceRepository>(),
        gh<_i656.AutoLoggingPlatformDatasource>(),
      ),
    );
    gh.factory<_i686.DashboardBloc>(
      () => _i686.DashboardBloc(
        gh<_i531.GetSensorDataUsecase>(),
        gh<_i366.LogVitalSnapshotUsecase>(),
        gh<_i480.DeviceRepository>(),
      ),
    );
    return this;
  }
}
