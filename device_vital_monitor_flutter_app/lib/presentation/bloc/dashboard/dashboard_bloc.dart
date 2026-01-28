import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import 'package:device_vital_monitor_flutter_app/core/error/exceptions.dart';
import 'package:device_vital_monitor_flutter_app/core/error/result.dart';
import 'package:device_vital_monitor_flutter_app/domain/entities/sensor_data.dart';
import 'package:device_vital_monitor_flutter_app/domain/repositories/device_repository.dart';
import 'package:device_vital_monitor_flutter_app/domain/usecases/get_sensor_data_usecase.dart';
import 'package:device_vital_monitor_flutter_app/domain/usecases/log_vital_snapshot_usecase.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

@injectable
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc(
    this._getSensorData,
    this._logVitalSnapshot,
    this._deviceRepository,
  ) : super(const DashboardInitial()) {
    on<DashboardSensorDataRequested>(_onSensorDataRequested);
    on<DashboardLogStatusRequested>(_onLogStatusRequested);
    on<DashboardThermalStatusChanged>(_onThermalStatusChanged);
    _thermalSubscription =
        _deviceRepository.thermalStatusChangeStream.listen(
      (state) => add(DashboardThermalStatusChanged(state)),
      onError: (e, st) =>
          debugPrint('DashboardBloc thermal stream error: $e'),
    );
  }

  final GetSensorDataUsecase _getSensorData;
  final LogVitalSnapshotUsecase _logVitalSnapshot;
  final DeviceRepository _deviceRepository;
  StreamSubscription<int?>? _thermalSubscription;

  @override
  Future<void> close() {
    _thermalSubscription?.cancel();
    return super.close();
  }

  void _onThermalStatusChanged(
    DashboardThermalStatusChanged event,
    Emitter<DashboardState> emit,
  ) {
    final s = state;
    switch (s) {
      case DashboardLoaded(:final sensorData):
        emit(s.copyWith(
          sensorData: sensorData.copyWith(thermalState: event.thermalState),
        ));
      case DashboardError(:final message, :final lastKnownData):
        if (lastKnownData != null) {
          emit(DashboardError(
            message,
            lastKnownData:
                lastKnownData.copyWith(thermalState: event.thermalState),
          ));
        }
      default:
        break;
    }
  }

  Future<void> _onLogStatusRequested(
    DashboardLogStatusRequested event,
    Emitter<DashboardState> emit,
  ) async {
    final s = state;
    if (s is! DashboardLoaded) return;

    final d = s.sensorData;
    final thermal = d.thermalState;
    final battery = d.batteryLevel;
    final memory = d.memoryUsage;

    if (thermal == null || battery == null || memory == null) {
      emit(s.copyWith(
        logStatus: LogStatusState.failure,
        logStatusMessage: 'Sensor data not ready. Pull to refresh.',
        clearLogStatusMessage: false,
      ));
      return;
    }

    emit(s.copyWith(
      logStatus: LogStatusState.submitting,
      clearLogStatusMessage: true,
    ));

    try {
      await _logVitalSnapshot(
        thermalValue: thermal,
        batteryLevel: battery.toDouble(),
        memoryUsage: memory.toDouble(),
      );
      final current = state;
      if (current is DashboardLoaded) {
        emit(current.copyWith(
          logStatus: LogStatusState.success,
          logStatusMessage: 'Vital logged successfully.',
        ));
      }
    } on VitalsRepositoryException catch (e) {
      final current = state;
      if (current is DashboardLoaded) {
        emit(current.copyWith(
          logStatus: LogStatusState.failure,
          logStatusMessage: e.message,
        ));
      }
    } catch (e, st) {
      addError(e, st);
      final current = state;
      if (current is DashboardLoaded) {
        emit(current.copyWith(
          logStatus: LogStatusState.failure,
          logStatusMessage: e.toString(),
        ));
      }
    }
  }

  Future<void> _onSensorDataRequested(
    DashboardSensorDataRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());

    final result = await _getSensorData();

    switch (result) {
      case Success(:final data):
        emit(DashboardLoaded(sensorData: data));
      case Error(:final failure):
        emit(DashboardError(failure.message));
        debugPrint('DashboardBloc Error: ${failure.message}');
    }
  }
}
