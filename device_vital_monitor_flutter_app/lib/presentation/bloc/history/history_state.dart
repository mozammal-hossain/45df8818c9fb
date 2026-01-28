part of 'history_bloc.dart';

enum HistoryStatus { initial, loading, loaded, failure }

final class HistoryState extends Equatable {
  const HistoryState({
    this.status = HistoryStatus.initial,
    this.logs = const [],
    this.analytics,
    this.errorMessage,
    this.hasNextPage = false,
    this.isLoadingMore = false,
    this.nextPage = 1,
  });

  final HistoryStatus status;
  final List<VitalLog> logs;
  final AnalyticsResult? analytics;
  final String? errorMessage;
  final bool hasNextPage;
  final bool isLoadingMore;
  final int nextPage;

  HistoryState copyWith({
    HistoryStatus? status,
    List<VitalLog>? logs,
    AnalyticsResult? analytics,
    String? errorMessage,
    bool? hasNextPage,
    bool? isLoadingMore,
    int? nextPage,
    bool clearError = false,
  }) {
    return HistoryState(
      status: status ?? this.status,
      logs: logs ?? this.logs,
      analytics: analytics ?? this.analytics,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      hasNextPage: hasNextPage ?? this.hasNextPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      nextPage: nextPage ?? this.nextPage,
    );
  }

  @override
  List<Object?> get props =>
      [status, logs, analytics, errorMessage, hasNextPage, isLoadingMore, nextPage];
}
