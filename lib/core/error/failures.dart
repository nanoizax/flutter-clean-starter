// Domain-level failures — Leandro Perez — SonhoLab
// Failures are the domain representation of errors.  They are returned by
// repositories via Either<Failure, T> so that use-cases never deal with
// raw exceptions.

/// Base sealed class for all domain failures.
sealed class Failure {
  const Failure({required this.message});

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// The remote API returned an error (4xx / 5xx).
final class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    this.statusCode,
  });

  final int? statusCode;
}

/// The device has no internet connection or the request timed out.
final class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection. Please check your network.',
  });
}

/// A local-storage operation (Isar / SharedPreferences) failed.
final class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Could not read or write to local cache.',
  });
}

/// Authentication failed (bad credentials, expired/missing token, etc.).
final class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    this.statusCode,
  });

  final int? statusCode;
}
