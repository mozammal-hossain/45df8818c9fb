import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../models/analytics_result.dart';
import '../../models/vital_log.dart';
import '../../repositories/vitals_repository.dart';

part 'history_event.dart';
part 'history_state.dart';

@injectable
class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  HistoryBloc(this._vitalsRepository) : super(const HistoryState()) {
    on<HistoryRequested>(_onHistoryRequested);
  }

  final VitalsRepository _vitalsRepository;

  Future<void> _onHistoryRequested(
    HistoryRequested event,
    Emitter<HistoryState> emit,
  ) async {
    emit(state.copyWith(status: HistoryStatus.loading));

    try {
      final results = await Future.wait([
        _vitalsRepository.getHistory(),
        _vitalsRepository.getAnalytics(),
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
