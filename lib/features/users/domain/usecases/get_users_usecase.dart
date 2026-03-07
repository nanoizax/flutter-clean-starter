// GetUsers use-case — Leandro Perez — SonhoLab

import 'package:flutter_clean_starter/core/error/failures.dart';
import 'package:flutter_clean_starter/core/utils/either.dart';
import 'package:flutter_clean_starter/features/users/domain/entities/user_list_item.dart';
import 'package:flutter_clean_starter/features/users/domain/repositories/users_repository.dart';

class GetUsersUseCase {
  const GetUsersUseCase({required this.repository});

  final UsersRepository repository;

  Future<Either<Failure, List<UserListItem>>> call(GetUsersParams params) {
    return repository.getUsers(page: params.page, limit: params.limit);
  }
}

class GetUsersParams {
  const GetUsersParams({this.page = 1, this.limit = 20});

  final int page;
  final int limit;
}
