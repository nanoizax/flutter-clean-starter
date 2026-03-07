// API endpoints — Leandro Perez — SonhoLab
// Centralised place for all API paths.
// Change [baseUrl] via the --dart-define=BASE_URL=... flag at build time.

abstract final class ApiEndpoints {
  ApiEndpoints._();

  // ---------------------------------------------------------------------------
  // Base URL — override at build time:
  //   flutter run --dart-define=BASE_URL=https://api.example.com
  // ---------------------------------------------------------------------------
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://jsonplaceholder.typicode.com',
  );

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // ---------------------------------------------------------------------------
  // Auth
  // ---------------------------------------------------------------------------
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String me = '/auth/me';

  // ---------------------------------------------------------------------------
  // Users
  // ---------------------------------------------------------------------------
  static const String users = '/users';
  static String userById(int id) => '/users/$id';
}
