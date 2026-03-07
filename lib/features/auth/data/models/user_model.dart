// UserModel — Leandro Perez — SonhoLab
// Data-layer extension of the domain [User] entity.
// Handles JSON serialization / deserialization.

import 'package:flutter_clean_starter/features/auth/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.username,
    super.avatarUrl,
    super.role,
    this.accessToken,
    this.refreshToken,
  });

  final String? accessToken;
  final String? refreshToken;

  // ---------------------------------------------------------------------------
  // Factory constructors
  // ---------------------------------------------------------------------------

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: _parseInt(json['id']),
      name: (json['name'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      username: json['username'] as String?,
      avatarUrl: json['avatar_url'] as String? ?? json['picture'] as String?,
      role: _parseRole(json['role'] as String?),
      accessToken: json['access_token'] as String?,
      refreshToken: json['refresh_token'] as String?,
    );
  }

  /// Construct from JSONPlaceholder-style response (used with the demo API).
  factory UserModel.fromJsonPlaceholder(Map<String, dynamic> json) {
    return UserModel(
      id: _parseInt(json['id']),
      name: (json['name'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      username: json['username'] as String?,
    );
  }

  // ---------------------------------------------------------------------------
  // Serialization
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      if (username != null) 'username': username,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      'role': role.name,
      if (accessToken != null) 'access_token': accessToken,
      if (refreshToken != null) 'refresh_token': refreshToken,
    };
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static UserRole _parseRole(String? value) {
    return UserRole.values.firstWhere(
      (r) => r.name == value,
      orElse: () => UserRole.user,
    );
  }

  UserModel copyWithTokens({
    String? accessToken,
    String? refreshToken,
  }) {
    return UserModel(
      id: id,
      name: name,
      email: email,
      username: username,
      avatarUrl: avatarUrl,
      role: role,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }
}
