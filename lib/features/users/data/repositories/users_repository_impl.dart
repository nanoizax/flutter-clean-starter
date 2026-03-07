// Users repository implementation — Leandro Perez — SonhoLab

import 'package:flutter_clean_starter/core/error/exceptions.dart';
import 'package:flutter_clean_starter/core/error/failures.dart';
import 'package:flutter_clean_starter/core/utils/either.dart';
import 'package:flutter_clean_starter/features/users/data/datasources/users_remote_datasource.dart';
import 'package:flutter_clean_starter/features/users/domain/entities/user_list_item.dart';
import 'package:flutter_clean_starter/features/users/domain/repositories/users_repository.dart';

class UsersRepositoryImpl implements UsersRepository {
  const UsersRepositoryImpl({required this.remoteDataSource});

  final UsersRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, List<UserListItem>>> getUsers({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final models = await remoteDataSource.getUsers(page: page, limit: limit);
      return right(models);
    } on AuthException catch (e) {
      return left(AuthFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, UserListItem>> getUserById(int id) async {
    try {
      final model = await remoteDataSource.getUserById(id);
      return right(model);
    } on AuthException catch (e) {
      return left(AuthFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
