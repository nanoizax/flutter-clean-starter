// Auth repository implementation — Leandro Perez — SonhoLab
// Orchestrates remote + local data sources and converts exceptions → Failures.

import 'package:flutter_clean_starter/core/error/exceptions.dart';
import 'package:flutter_clean_starter/core/error/failures.dart';
import 'package:flutter_clean_starter/core/utils/either.dart';
import 'package:flutter_clean_starter/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:flutter_clean_starter/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:flutter_clean_starter/features/auth/domain/entities/user.dart';
import 'package:flutter_clean_starter/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await remoteDataSource.login(
        email: email,
        password: password,
      );

      // Persist tokens and cached user.
      await Future.wait([
        localDataSource.saveUser(userModel),
        if (userModel.accessToken != null)
          localDataSource.saveTokens(
            accessToken: userModel.accessToken!,
            refreshToken: userModel.refreshToken,
          ),
      ]);

      return right(userModel);
    } on AuthException catch (e) {
      return left(AuthFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on CacheException catch (e) {
      return left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // Best-effort server-side logout (fire-and-forget on network errors).
      try {
        await remoteDataSource.logout();
      } on NetworkException {
        // Proceed to clear local session even if offline.
      }
      await localDataSource.clearSession();
      return right(null);
    } on CacheException catch (e) {
      return left(CacheFailure(message: e.message));
    } on ServerException catch (e) {
      return left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, User?>> getCachedUser() async {
    try {
      final user = await localDataSource.getCachedUser();
      return right(user);
    } on CacheException catch (e) {
      return left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<bool> isAuthenticated() => localDataSource.hasAccessToken();
}
