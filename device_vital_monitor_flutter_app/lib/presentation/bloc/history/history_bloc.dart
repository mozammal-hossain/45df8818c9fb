import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import 'package:device_vital_monitor_flutter_app/core/error/exceptions.dart';
import 'package:device_vital_monitor_flutter_app/domain/entities/analytics_result.dart';
import 'package:device_vital_monitor_flutter_app/domain/entities/vital_log.dart';
import 'package:device_vital_monitor_flutter_app/domain/usecases/get_analytics_usecase.dart';
import 'package:device_vital_monitor_flutter_app/domain/usecases/get_history_usecase.dart';

part 'history_event.dart';
part 'history_state.dart';

@injectable
class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  HistoryBloc(this._getHistory, this._getAnalytics)
      : super(const HistoryState()) {
    on<HistoryRequested>(_onHistoryRequested);
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
        _getHistory(),
        _getAnalytics(),
      ]);
      final logs = results[0] as List<VitalLog>;
      final analytics = results[1] as AnalyticsResult;
      emit(
        state.copyWith(
          status: HistoryStatus.loaded,
          logs: logs,
          analytics: analytics,
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
}
