// UserListModel — Leandro Perez — SonhoLab
// Data-layer extension of [UserListItem].
// Parses JSONPlaceholder-style user objects.

import 'package:flutter_clean_starter/features/users/domain/entities/user_list_item.dart';

class UserListModel extends UserListItem {
  const UserListModel({
    required super.id,
    required super.name,
    required super.email,
    super.username,
    super.phone,
    super.website,
    super.companyName,
    super.city,
  });

  factory UserListModel.fromJson(Map<String, dynamic> json) {
    // Support JSONPlaceholder nested structure:
    // { "address": { "city": "..." }, "company": { "name": "..." } }
    final address = json['address'] as Map<String, dynamic>?;
    final company = json['company'] as Map<String, dynamic>?;

    return UserListModel(
      id: _parseInt(json['id']),
      name: (json['name'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      username: json['username'] as String?,
      phone: json['phone'] as String?,
      website: json['website'] as String?,
      companyName: company?['name'] as String?,
      city: address?['city'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      if (username != null) 'username': username,
      if (phone != null) 'phone': phone,
      if (website != null) 'website': website,
      if (companyName != null) 'company': {'name': companyName},
      if (city != null) 'address': {'city': city},
    };
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
