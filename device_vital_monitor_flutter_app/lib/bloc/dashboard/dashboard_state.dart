part of 'dashboard_bloc.dart';

/// {@template dashboard_status}
/// Status enum for dashboard state.
/// {@endtemplate}
enum DashboardStatus {
  /// Initial state
  initial,

  /// Loading state
  loading,

  /// Loaded state
  loaded,

  /// Failure state
  failure,
}

/// Status of the "Log Status" action.
enum LogStatusState {
  idle,
  submitting,
  success,
  failure,
}

/// {@template dashboard_state}
/// State for dashboard sensor data management.
/// {@endtemplate}
final class DashboardState extends Equatable {
  /// {@macro dashboard_state}
  const DashboardState({
    this.status = DashboardStatus.initial,
    this.thermalState,
    this.isLoadingThermal = false,
    this.batteryLevel,
    this.batteryHealth,
    this.chargerConnection,
    this.batteryStatus,
    this.isLoadingBattery = false,
    this.memoryUsage,
    this.isLoadingMemory = false,
    this.storageInfo,
    this.isLoadingStorage = false,
    this.logStatusState = LogStatusState.idle,
    this.logStatusMessage,
    this.error,
    this.stackTrace,
  });

  final DashboardStatus status;
  final int? thermalState;
  final bool isLoadingThermal;
  final int? batteryLevel;
  final String? batteryHealth;
  final String? chargerConnection;
  final String? batteryStatus;
  final bool isLoadingBattery;
  final int? memoryUsage;
  final bool isLoadingMemory;
  final StorageInfo? storageInfo;
  final bool isLoadingStorage;
  final LogStatusState logStatusState;
  final String? logStatusMessage;
  final Object? error;
  final StackTrace? stackTrace;

  DashboardState copyWith({
    DashboardStatus? status,
    int? thermalState,
    bool? isLoadingThermal,
    int? batteryLevel,
    String? batteryHealth,
    String? chargerConnection,
    String? batteryStatus,
    bool? isLoadingBattery,
    int? memoryUsage,
    bool? isLoadingMemory,
    StorageInfo? storageInfo,
    bool? isLoadingStorage,
    LogStatusState? logStatusState,
    String? logStatusMessage,
    bool clearLogStatusMessage = false,
    Object? error,
    StackTrace? stackTrace,
  }) {
    return DashboardState(
      status: status ?? this.status,
      thermalState: thermalState ?? this.thermalState,
      isLoadingThermal: isLoadingThermal ?? this.isLoadingThermal,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      batteryHealth: batteryHealth ?? this.batteryHealth,
      chargerConnection: chargerConnection ?? this.chargerConnection,
      batteryStatus: batteryStatus ?? this.batteryStatus,
      isLoadingBattery: isLoadingBattery ?? this.isLoadingBattery,
      memoryUsage: memoryUsage ?? this.memoryUsage,
      isLoadingMemory: isLoadingMemory ?? this.isLoadingMemory,
      storageInfo: storageInfo ?? this.storageInfo,
      isLoadingStorage: isLoadingStorage ?? this.isLoadingStorage,
      logStatusState: logStatusState ?? this.logStatusState,
      logStatusMessage:
          clearLogStatusMessage ? null : (logStatusMessage ?? this.logStatusMessage),
      error: error ?? this.error,
      stackTrace: stackTrace ?? this.stackTrace,
    );
  }

  @override
  List<Object?> get props => [
        status,
        thermalState,
        isLoadingThermal,
        batteryLevel,
        batteryHealth,
        chargerConnection,
        batteryStatus,
        isLoadingBattery,
        memoryUsage,
        isLoadingMemory,
        storageInfo,
        isLoadingStorage,
        logStatusState,
        logStatusMessage,
        error,
        stackTrace,
      ];
}
