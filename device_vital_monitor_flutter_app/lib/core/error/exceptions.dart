/// Base type for application-level exceptions.
abstract base class AppException implements Exception {
  const AppException(this.message, [this.cause]);
  final String message;
  final dynamic cause;
  @override
  String toString() => '$runtimeType: $message';
}

/// Thrown when the vitals backend returns non-2xx or the request fails.
final class VitalsRepositoryException extends AppException {
  const VitalsRepositoryException(super.message, [this.statusCode, super.cause]);
  final int? statusCode;
  @override
  String toString() =>
      'VitalsRepositoryException: $message${statusCode != null ? ' (status: $statusCode)' : ''}';
}
