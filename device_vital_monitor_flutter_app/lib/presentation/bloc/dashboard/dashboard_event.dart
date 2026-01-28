part of 'dashboard_bloc.dart';

sealed class DashboardEvent extends Equatable {
  const DashboardEvent();
  @override
  List<Object?> get props => [];
}

final class DashboardSensorDataRequested extends DashboardEvent {
  const DashboardSensorDataRequested();
}

final class DashboardLogStatusRequested extends DashboardEvent {
  const DashboardLogStatusRequested();
}

final class DashboardThermalStatusChanged extends DashboardEvent {
  const DashboardThermalStatusChanged(this.thermalState);
  final int? thermalState;
  @override
  List<Object?> get props => [thermalState];
}
