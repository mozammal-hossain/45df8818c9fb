part of 'dashboard_bloc.dart';

/// {@template dashboard_event}
/// Base class for all dashboard events.
/// {@endtemplate}
sealed class DashboardEvent extends Equatable {
  /// {@macro dashboard_event}
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

/// {@template dashboard_sensor_data_requested}
/// Event to fetch all sensor data.
/// {@endtemplate}
final class DashboardSensorDataRequested extends DashboardEvent {
  /// {@macro dashboard_sensor_data_requested}
  const DashboardSensorDataRequested();
}

/// {@template dashboard_log_status_requested}
/// Event to send current sensor data to the backend.
/// {@endtemplate}
final class DashboardLogStatusRequested extends DashboardEvent {
  /// {@macro dashboard_log_status_requested}
  const DashboardLogStatusRequested();
}

/// {@template dashboard_thermal_status_changed}
/// Event when native thermal status changes (Android thermal status listener).
/// {@endtemplate}
final class DashboardThermalStatusChanged extends DashboardEvent {
  /// {@macro dashboard_thermal_status_changed}
  const DashboardThermalStatusChanged(this.thermalState);

  final int? thermalState;

  @override
  List<Object?> get props => [thermalState];
}
