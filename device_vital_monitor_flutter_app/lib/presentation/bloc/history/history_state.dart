part of 'history_bloc.dart';

enum HistoryStatus { initial, loading, loaded, failure }

final class HistoryState extends Equatable {
  const HistoryState({
    this.status = HistoryStatus.initial,
    this.logs = const [],
    this.analytics,
    this.errorMessage,
  });

  final HistoryStatus status;
  final List<VitalLog> logs;
  final AnalyticsResult? analytics;
  final String? errorMessage;

  HistoryState copyWith({
    HistoryStatus? status,
    List<VitalLog>? logs,
    AnalyticsResult? analytics,
    String? errorMessage,
    bool clearError = false,
  }) {
    return HistoryState(
      status: status ?? this.status,
      logs: logs ?? this.logs,
      analytics: analytics ?? this.analytics,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, logs, analytics, errorMessage];
}
