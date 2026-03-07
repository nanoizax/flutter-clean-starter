// Auth local data source — Leandro Perez — SonhoLab
// Persists tokens and the cached user via SharedPreferences.
// Throws [CacheException] on failure.

import 'dart:convert';

import 'package:flutter_clean_starter/core/error/exceptions.dart';
import 'package:flutter_clean_starter/core/network/dio_client.dart';
import 'package:flutter_clean_starter/features/auth/data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kCachedUserKey = 'cached_user';

abstract interface class AuthLocalDataSource {
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> saveTokens({
    required String accessToken,
    required String? refreshToken,
  });
  Future<void> clearSession();
  Future<bool> hasAccessToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  const AuthLocalDataSourceImpl({required this.prefs});

  final SharedPreferences prefs;

  @override
  Future<void> saveUser(UserModel user) async {
    try {
      final json = jsonEncode(user.toJson());
      await prefs.setString(_kCachedUserKey, json);
    } catch (e) {
      throw CacheException(message: 'Could not save user: $e');
    }
  }

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final json = prefs.getString(_kCachedUserKey);
      if (json == null) return null;
      final map = jsonDecode(json) as Map<String, dynamic>;
      return UserModel.fromJson(map);
    } catch (e) {
      throw CacheException(message: 'Could not read cached user: $e');
    }
  }

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String? refreshToken,
  }) async {
    try {
      await prefs.setString(kAccessTokenKey, accessToken);
      if (refreshToken != null) {
        await prefs.setString(kRefreshTokenKey, refreshToken);
      }
    } catch (e) {
      throw CacheException(message: 'Could not save tokens: $e');
    }
  }

  @override
  Future<void> clearSession() async {
    try {
      await Future.wait([
        prefs.remove(kAccessTokenKey),
        prefs.remove(kRefreshTokenKey),
        prefs.remove(_kCachedUserKey),
      ]);
    } catch (e) {
      throw CacheException(message: 'Could not clear session: $e');
    }
  }

  @override
  Future<bool> hasAccessToken() async {
    final token = prefs.getString(kAccessTokenKey);
    return token != null && token.isNotEmpty;
  }
}
