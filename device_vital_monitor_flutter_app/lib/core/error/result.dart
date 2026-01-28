import 'package:device_vital_monitor_flutter_app/core/error/failures.dart';

/// Result of an operation that can succeed with [T] or fail with [Failure].
sealed class Result<T> {
  const Result();
}

/// Successful result carrying [data].
final class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;
}

/// Failed result carrying [failure].
final class Error<T> extends Result<T> {
  const Error(this.failure);
  final Failure failure;
}
