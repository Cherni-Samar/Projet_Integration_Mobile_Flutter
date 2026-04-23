/// Base class for all domain failures.
abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

/// Network / HTTP layer failures.
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Authentication failures (401, expired token, etc.).
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// Server-side validation failures (400, 422…).
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Generic server error (5xx).
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Local storage failures.
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}
