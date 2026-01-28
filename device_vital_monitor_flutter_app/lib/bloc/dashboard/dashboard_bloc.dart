import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../models/storage_info.dart';
import '../../models/vital_log_request.dart';
import '../../repositories/vitals_repository.dart';
import '../../services/device_id_service.dart';
import '../../services/device_sensor_service.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

/// {@template dashboard_bloc}
/// Bloc for managing dashboard sensor data state.
/// {@endtemplate}
@injectable
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  /// {@macro dashboard_bloc}
  DashboardBloc(
    this._deviceSensorService,
    this._vitalsRepository,
    this._deviceIdService,
  ) : super(const DashboardState()) {
    on<DashboardSensorDataRequested>(_onSensorDataRequested);
    on<DashboardLogStatusRequested>(_onLogStatusRequested);
    on<DashboardThermalStatusChanged>(_onThermalStatusChanged);
    _thermalSubscription =
        _deviceSensorService.thermalStatusChangeStream.listen(
      (state) => add(DashboardThermalStatusChanged(state)),
      onError: (e, st) => debugPrint('DashboardBloc thermal stream error: $e'),
    );
  }

  final DeviceSensorService _deviceSensorService;
  final VitalsRepository _vitalsRepository;
  final DeviceIdService _deviceIdService;
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
    emit(state.copyWith(thermalState: event.thermalState));
  }

  Future<void> _onLogStatusRequested(
    DashboardLogStatusRequested event,
    Emitter<DashboardState> emit,
  ) async {
    final thermal = state.thermalState;
    final battery = state.batteryLevel;
    final memory = state.memoryUsage;

    if (thermal == null || battery == null || memory == null) {
      emit(
        state.copyWith(
          logStatusState: LogStatusState.failure,
          logStatusMessage: 'Sensor data not ready. Pull to refresh.',
          clearLogStatusMessage: false,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        logStatusState: LogStatusState.submitting,
        clearLogStatusMessage: true,
      ),
    );

    try {
      final deviceId = await _deviceIdService.getOrCreateDeviceId();
      final request = VitalLogRequest(
        deviceId: deviceId,
        timestamp: DateTime.now().toUtc(),
        thermalValue: thermal.clamp(0, 3),
        batteryLevel: battery.toDouble().clamp(0, 100),
        memoryUsage: memory.toDouble().clamp(0, 100),
      );
      await _vitalsRepository.logVital(request);
      emit(
        state.copyWith(
          logStatusState: LogStatusState.success,
          logStatusMessage: 'Vital logged successfully.',
        ),
      );
    } on VitalsRepositoryException catch (e) {
      emit(
        state.copyWith(
          logStatusState: LogStatusState.failure,
          logStatusMessage: e.message,
        ),
      );
    } catch (e, st) {
      addError(e, st);
      emit(
        state.copyWith(
          logStatusState: LogStatusState.failure,
          logStatusMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onSensorDataRequested(
    DashboardSensorDataRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(status: DashboardStatus.loading));

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

      emit(
        state.copyWith(
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
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('DashboardBloc Error: $error');
      emit(
        state.copyWith(
          status: DashboardStatus.failure,
          error: error,
          stackTrace: stackTrace,
        ),
      );
      addError(error, stackTrace);
    }
  }
}
