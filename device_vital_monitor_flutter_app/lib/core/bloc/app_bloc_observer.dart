import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

/// {@template app_bloc_observer}
/// Custom [BlocObserver] that logs all bloc state changes, errors, and events.
/// {@endtemplate}
class AppBlocObserver extends BlocObserver {
  /// {@macro app_bloc_observer}
  const AppBlocObserver();

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    if (kDebugMode) {
      debugPrint('${bloc.runtimeType} $change');
    }
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      debugPrint('${bloc.runtimeType} $error $stackTrace');
    }
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    if (kDebugMode) {
      debugPrint('${bloc.runtimeType} $event');
    }
  }
}
