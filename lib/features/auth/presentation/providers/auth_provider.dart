// Auth provider — Leandro Perez — SonhoLab
// StateNotifier-based provider for auth state management with Riverpod.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_clean_starter/core/network/api_endpoints.dart';
import 'package:flutter_clean_starter/core/network/dio_client.dart';
import 'package:flutter_clean_starter/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:flutter_clean_starter/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:flutter_clean_starter/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_clean_starter/features/auth/domain/entities/user.dart';
import 'package:flutter_clean_starter/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_clean_starter/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_clean_starter/features/auth/domain/usecases/logout_usecase.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

sealed class AuthState {
  const AuthState();
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({required this.user});
  final User user;
}

final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

final class AuthError extends AuthState {
  const AuthError({required this.message});
  final String message;
}

// ---------------------------------------------------------------------------
// Infrastructure providers
// ---------------------------------------------------------------------------

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'SharedPreferences must be overridden before the app starts. '
    'Call ProviderScope(overrides: [sharedPreferencesProvider.overrideWithValue(prefs)]).',
  );
});

final dioClientProvider = Provider<DioClient>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return DioClient(dio: buildDioClient(prefs));
});

// ---------------------------------------------------------------------------
// Repository providers
// ---------------------------------------------------------------------------

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSourceImpl(prefs: ref.watch(sharedPreferencesProvider));
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(client: ref.watch(dioClientProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    localDataSource: ref.watch(authLocalDataSourceProvider),
  );
});

// ---------------------------------------------------------------------------
// Use-case providers
// ---------------------------------------------------------------------------

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(repository: ref.watch(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(repository: ref.watch(authRepositoryProvider));
});

// ---------------------------------------------------------------------------
// Auth StateNotifier
// ---------------------------------------------------------------------------

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier({
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.repository,
  }) : super(const AuthInitial());

  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final AuthRepository repository;

  /// Check if a cached session already exists (called at startup).
  Future<void> checkSession() async {
    state = const AuthLoading();
    final isAuth = await repository.isAuthenticated();
    if (!isAuth) {
      state = const AuthUnauthenticated();
      return;
    }

    final result = await repository.getCachedUser();
    state = result.fold(
      (failure) => const AuthUnauthenticated(),
      (user) =>
          user != null ? AuthAuthenticated(user: user) : const AuthUnauthenticated(),
    );
  }

  Future<void> login({required String email, required String password}) async {
    state = const AuthLoading();
    final result = await loginUseCase(
      LoginParams(email: email, password: password),
    );
    state = result.fold(
      (failure) => AuthError(message: failure.message),
      (user) => AuthAuthenticated(user: user),
    );
  }

  Future<void> logout() async {
    state = const AuthLoading();
    final result = await logoutUseCase();
    state = result.fold(
      (failure) => AuthError(message: failure.message),
      (_) => const AuthUnauthenticated(),
    );
  }

  void clearError() {
    if (state is AuthError) {
      state = const AuthUnauthenticated();
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    loginUseCase: ref.watch(loginUseCaseProvider),
    logoutUseCase: ref.watch(logoutUseCaseProvider),
    repository: ref.watch(authRepositoryProvider),
  );
});

// ---------------------------------------------------------------------------
// Convenience derived providers
// ---------------------------------------------------------------------------

/// Returns the authenticated user or null.
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authProvider);
  return authState is AuthAuthenticated ? authState.user : null;
});

/// Returns true when the user is authenticated.
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider) is AuthAuthenticated;
});
