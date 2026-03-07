// Auth repository contract — Leandro Perez — SonhoLab
// The domain layer only knows about this interface.
// Implementations live in the data layer.

import 'package:flutter_clean_starter/core/error/failures.dart';
import 'package:flutter_clean_starter/core/utils/either.dart';
import 'package:flutter_clean_starter/features/auth/domain/entities/user.dart';

abstract interface class AuthRepository {
  /// Returns the authenticated [User] or a [Failure].
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  /// Clears the session (tokens + cached user).
  Future<Either<Failure, void>> logout();

  /// Returns the currently cached user, if any.
  Future<Either<Failure, User?>> getCachedUser();

  /// Returns `true` when a valid access token is present in storage.
  Future<bool> isAuthenticated();
}
