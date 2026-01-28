import 'package:equatable/equatable.dart';

/// Base type for representable failures (e.g. for Bloc/UseCase results).
abstract base class Failure extends Equatable {
  const Failure(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

/// Failure when backend or network is unreachable or request times out.
final class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Failure when the server returns a validation or HTTP error.
final class ServerFailure extends Failure {
  const ServerFailure(super.message, [this.statusCode]);
  final int? statusCode;
  @override
  List<Object?> get props => [message, statusCode];
}

/// Failure from platform / native code (e.g. MethodChannel).
final class PlatformFailure extends Failure {
  const PlatformFailure(super.message);
}

/// Unexpected or unknown failure.
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message);
}
