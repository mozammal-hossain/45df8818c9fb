part of 'dashboard_bloc.dart';

/// Log action substate when [DashboardLoaded].
enum LogStatusState { idle, submitting, success, failure }

sealed class DashboardState extends Equatable {
  const DashboardState();
}

final class DashboardInitial extends DashboardState {
  const DashboardInitial();
  @override
  List<Object?> get props => [];
}

final class DashboardLoading extends DashboardState {
  const DashboardLoading();
  @override
  List<Object?> get props => [];
}

final class DashboardLoaded extends DashboardState {
  const DashboardLoaded({
    required this.sensorData,
    this.logStatus = LogStatusState.idle,
    this.logStatusMessage,
  });

  final SensorData sensorData;
  final LogStatusState logStatus;
  final String? logStatusMessage;

  @override
  List<Object?> get props => [sensorData, logStatus, logStatusMessage];

  DashboardLoaded copyWith({
    SensorData? sensorData,
    LogStatusState? logStatus,
    String? logStatusMessage,
    bool clearLogStatusMessage = false,
  }) =>
      DashboardLoaded(
        sensorData: sensorData ?? this.sensorData,
        logStatus: logStatus ?? this.logStatus,
        logStatusMessage: clearLogStatusMessage
            ? null
            : (logStatusMessage ?? this.logStatusMessage),
      );
}

final class DashboardError extends DashboardState {
  const DashboardError(this.message, {this.lastKnownData});

  final String message;
  final SensorData? lastKnownData;

  @override
  List<Object?> get props => [message, lastKnownData];
}
