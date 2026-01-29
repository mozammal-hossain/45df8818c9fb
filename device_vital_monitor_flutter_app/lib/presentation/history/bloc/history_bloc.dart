import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import 'package:device_vital_monitor_flutter_app/core/error/exceptions.dart';
import 'package:device_vital_monitor_flutter_app/domain/entities/analytics_result.dart';
import 'package:device_vital_monitor_flutter_app/domain/entities/paged_result.dart';
import 'package:device_vital_monitor_flutter_app/domain/entities/vital_log.dart';
import 'package:device_vital_monitor_flutter_app/domain/usecases/get_analytics_usecase.dart';
import 'package:device_vital_monitor_flutter_app/domain/usecases/get_history_usecase.dart';

part 'history_event.dart';
part 'history_state.dart';

const int _historyPageSize = 20;

@injectable
class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  HistoryBloc(this._getHistory, this._getAnalytics)
      : super(const HistoryState()) {
    on<HistoryRequested>(_onHistoryRequested);
    on<HistoryLoadMoreRequested>(_onHistoryLoadMoreRequested);
  }

  final GetHistoryUsecase _getHistory;
  final GetAnalyticsUsecase _getAnalytics;

  Future<void> _onHistoryRequested(
    HistoryRequested event,
    Emitter<HistoryState> emit,
  ) async {
    emit(state.copyWith(status: HistoryStatus.loading));

    try {
      final results = await Future.wait([
        _getHistory(page: 1, pageSize: _historyPageSize),
        _getAnalytics(),
      ]);
      final paged = results[0] as PagedResult<VitalLog>;
      final analytics = results[1] as AnalyticsResult;
      final items = paged.items;
      final hasNext = paged.hasNextPage;
      emit(
        state.copyWith(
          status: HistoryStatus.loaded,
          logs: items,
          analytics: analytics,
          hasNextPage: hasNext,
          nextPage: 2,
          clearError: true,
        ),
      );
    } on VitalsRepositoryException catch (e) {
      emit(
        state.copyWith(
          status: HistoryStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (e, st) {
      addError(e, st);
      emit(
        state.copyWith(
          status: HistoryStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onHistoryLoadMoreRequested(
    HistoryLoadMoreRequested event,
    Emitter<HistoryState> emit,
  ) async {
    if (state.isLoadingMore || !state.hasNextPage) return;

    emit(state.copyWith(isLoadingMore: true));

    try {
      final paged = await _getHistory(
        page: state.nextPage,
        pageSize: _historyPageSize,
      );
      final appended = [...state.logs, ...paged.items];
      emit(
        state.copyWith(
          logs: appended,
          hasNextPage: paged.hasNextPage,
          nextPage: state.nextPage + 1,
          isLoadingMore: false,
        ),
      );
    } on VitalsRepositoryException catch (e) {
      emit(
        state.copyWith(
          isLoadingMore: false,
          errorMessage: e.message,
        ),
      );
      // Optionally show snackbar via listener for load-more errors
    } catch (e, st) {
      addError(e, st);
      emit(
        state.copyWith(
          isLoadingMore: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
