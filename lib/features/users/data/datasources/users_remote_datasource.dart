// Users remote data source — Leandro Perez — SonhoLab

import 'package:flutter_clean_starter/core/error/exceptions.dart';
import 'package:flutter_clean_starter/core/network/api_endpoints.dart';
import 'package:flutter_clean_starter/core/network/dio_client.dart';
import 'package:flutter_clean_starter/features/users/data/models/user_list_model.dart';

abstract interface class UsersRemoteDataSource {
  Future<List<UserListModel>> getUsers({int page = 1, int limit = 20});
  Future<UserListModel> getUserById(int id);
}

class UsersRemoteDataSourceImpl implements UsersRemoteDataSource {
  const UsersRemoteDataSourceImpl({required this.client});

  final DioClient client;

  @override
  Future<List<UserListModel>> getUsers({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await client.get<List<dynamic>>(
        ApiEndpoints.users,
        queryParameters: {
          '_page': page,
          '_limit': limit,
        },
      );

      final data = response.data;
      if (data == null) return [];

      return data
          .whereType<Map<String, dynamic>>()
          .map(UserListModel.fromJson)
          .toList();
    } on ServerException {
      rethrow;
    } on NetworkException {
      rethrow;
    } on AuthException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to parse users: $e');
    }
  }

  @override
  Future<UserListModel> getUserById(int id) async {
    try {
      final response = await client.get<Map<String, dynamic>>(
        ApiEndpoints.userById(id),
      );

      final data = response.data;
      if (data == null) {
        throw ServerException(
          message: 'User $id not found.',
          statusCode: 404,
        );
      }
      return UserListModel.fromJson(data);
    } on ServerException {
      rethrow;
    } on NetworkException {
      rethrow;
    } on AuthException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to parse user $id: $e');
    }
  }
}
