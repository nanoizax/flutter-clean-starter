// Core exceptions — Leandro Perez — SonhoLab
// These are thrown by data sources and caught at the repository layer,
// where they are converted into domain-level Failure objects.

/// Thrown when the remote API returns an error or an unexpected response.
class ServerException implements Exception {
  const ServerException({
    required this.message,
    this.statusCode,
  });

  final String message;
  final int? statusCode;

  @override
  String toString() => 'ServerException($statusCode): $message';
}

/// Thrown when there is no network connectivity or a connection timeout.
class NetworkException implements Exception {
  const NetworkException({
    this.message = 'No internet connection or request timed out.',
  });

  final String message;

  @override
  String toString() => 'NetworkException: $message';
}

/// Thrown when reading from or writing to local storage (Isar / SharedPreferences) fails.
class CacheException implements Exception {
  const CacheException({
    this.message = 'Local cache operation failed.',
  });

  final String message;

  @override
  String toString() => 'CacheException: $message';
}

/// Thrown when an authentication operation fails (invalid credentials, expired token, etc.).
class AuthException implements Exception {
  const AuthException({
    required this.message,
    this.statusCode,
  });

  final String message;
  final int? statusCode;

  @override
  String toString() => 'AuthException($statusCode): $message';
}
