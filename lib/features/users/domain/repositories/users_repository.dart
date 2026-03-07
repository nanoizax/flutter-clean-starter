// Users repository contract — Leandro Perez — SonhoLab

import 'package:flutter_clean_starter/core/error/failures.dart';
import 'package:flutter_clean_starter/core/utils/either.dart';
import 'package:flutter_clean_starter/features/users/domain/entities/user_list_item.dart';

abstract interface class UsersRepository {
  /// Fetches a paginated list of users.
  Future<Either<Failure, List<UserListItem>>> getUsers({
    int page = 1,
    int limit = 20,
  });

  /// Fetches a single user by ID.
  Future<Either<Failure, UserListItem>> getUserById(int id);
}
