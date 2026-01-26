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
