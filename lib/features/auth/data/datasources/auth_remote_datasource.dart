// Auth remote data source — Leandro Perez — SonhoLab
// Communicates with the remote API for authentication operations.
// Throws typed exceptions (never Failures — that's the repository's job).

import 'package:flutter_clean_starter/core/error/exceptions.dart';
import 'package:flutter_clean_starter/core/network/api_endpoints.dart';
import 'package:flutter_clean_starter/core/network/dio_client.dart';
import 'package:flutter_clean_starter/features/auth/data/models/user_model.dart';

abstract interface class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl({required this.client});

  final DioClient client;

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.post<Map<String, dynamic>>(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );

      final data = response.data;
      if (data == null) {
        throw const ServerException(
          message: 'Empty response from server.',
          statusCode: 200,
        );
      }

      // The API may return the user under a "user" key alongside the tokens,
      // or return the entire payload flat.
      final userJson = (data['user'] as Map<String, dynamic>?) ?? data;
      return UserModel.fromJson({
        ...userJson,
        'access_token': data['access_token'],
        'refresh_token': data['refresh_token'],
      });
    } on ServerException {
      rethrow;
    } on NetworkException {
      rethrow;
    } on AuthException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> logout() async {
    try {
      await client.post<void>(ApiEndpoints.logout);
    } on AuthException {
      // If the server returns 401 on logout, the session is already invalid
      // on the server side — treat as success.
      return;
    } on ServerException {
      rethrow;
    } on NetworkException {
      rethrow;
    }
  }
}
