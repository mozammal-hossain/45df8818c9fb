import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../models/storage_info.dart';
import '../../services/device_sensor_service.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

/// {@template dashboard_bloc}
/// Bloc for managing dashboard sensor data state.
/// {@endtemplate}
@injectable
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  /// {@macro dashboard_bloc}
  DashboardBloc(this._deviceSensorService)
      : super(const DashboardState()) {
    on<DashboardSensorDataRequested>(_onSensorDataRequested);
  }

  final DeviceSensorService _deviceSensorService;

  Future<void> _onSensorDataRequested(
    DashboardSensorDataRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(
      status: DashboardStatus.loading,
    ));

    try {
      final results = await Future.wait([
        _deviceSensorService.getThermalState(),
        _deviceSensorService.getBatteryLevel(),
        _deviceSensorService.getBatteryHealth(),
        _deviceSensorService.getChargerConnection(),
        _deviceSensorService.getBatteryStatus(),
        _deviceSensorService.getMemoryUsage(),
        _deviceSensorService.getStorageInfo(),
      ]);

      emit(state.copyWith(
        status: DashboardStatus.loaded,
        thermalState: results[0] as int?,
        batteryLevel: results[1] as int?,
        batteryHealth: results[2] as String?,
        chargerConnection: results[3] as String?,
        batteryStatus: results[4] as String?,
        memoryUsage: results[5] as int?,
        storageInfo: results[6] as StorageInfo?,
        isLoadingThermal: false,
        isLoadingBattery: false,
        isLoadingMemory: false,
        isLoadingStorage: false,
      ));
    } catch (error, stackTrace) {
      emit(state.copyWith(
        status: DashboardStatus.failure,
        error: error,
        stackTrace: stackTrace,
      ));
      addError(error, stackTrace);
    }
  }
}
