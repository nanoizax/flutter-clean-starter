// App router — Leandro Perez — SonhoLab
// GoRouter with auth-guard redirect and named routes.
//
// Route tree:
//   /splash                    → SplashScreen
//   /login                     → LoginScreen
//   /home/users                → UsersScreen
//   /home/users/:id            → UserDetailScreen

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_clean_starter/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_clean_starter/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter_clean_starter/features/auth/presentation/screens/splash_screen.dart';
import 'package:flutter_clean_starter/features/users/presentation/screens/user_detail_screen.dart';
import 'package:flutter_clean_starter/features/users/presentation/screens/users_screen.dart';

// ---------------------------------------------------------------------------
// Route names (use these instead of raw strings)
// ---------------------------------------------------------------------------

abstract final class AppRoutes {
  static const splash = 'splash';
  static const login = 'login';
  static const users = 'users';
  static const userDetail = 'user-detail';
}

// ---------------------------------------------------------------------------
// Route paths
// ---------------------------------------------------------------------------

abstract final class AppPaths {
  static const splash = '/splash';
  static const login = '/login';
  static const users = '/home/users';
  static const userDetail = '/home/users/:id';
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final routerProvider = Provider<GoRouter>((ref) {
  // Listen to auth state changes so GoRouter can reactively redirect.
  final authNotifier = ref.watch(authProvider.notifier);
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: AppPaths.splash,
    debugLogDiagnostics: true,
    refreshListenable: _AuthStateListenable(ref),
    redirect: (BuildContext context, GoRouterState state) {
      final isLoggingIn = state.matchedLocation == AppPaths.login;
      final isSplash = state.matchedLocation == AppPaths.splash;

      final authStatus = authState;

      // While checking session, stay on splash.
      if (authStatus is AuthInitial || authStatus is AuthLoading) {
        return isSplash ? null : AppPaths.splash;
      }

      final authenticated = authStatus is AuthAuthenticated;

      // Unauthenticated users may only access /login and /splash.
      if (!authenticated && !isLoggingIn && !isSplash) {
        return AppPaths.login;
      }

      // Authenticated users should not see /login or /splash.
      if (authenticated && (isLoggingIn || isSplash)) {
        return AppPaths.users;
      }

      return null; // no redirect
    },
    routes: [
      GoRoute(
        path: AppPaths.splash,
        name: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppPaths.login,
        name: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppPaths.users,
        name: AppRoutes.users,
        builder: (context, state) => const UsersScreen(),
        routes: [
          GoRoute(
            path: ':id',
            name: AppRoutes.userDetail,
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
              return UserDetailScreen(userId: id);
            },
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.error}'),
      ),
    ),
  );
});

// ---------------------------------------------------------------------------
// Listenable bridge between Riverpod and GoRouter
// ---------------------------------------------------------------------------

class _AuthStateListenable extends ChangeNotifier {
  _AuthStateListenable(Ref ref) {
    ref.listen(authProvider, (_, __) => notifyListeners());
  }
}
