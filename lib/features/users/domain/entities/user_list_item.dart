// UserListItem domain entity — Leandro Perez — SonhoLab
// Lightweight entity used in list views.

class UserListItem {
  const UserListItem({
    required this.id,
    required this.name,
    required this.email,
    this.username,
    this.phone,
    this.website,
    this.companyName,
    this.city,
  });

  final int id;
  final String name;
  final String email;
  final String? username;
  final String? phone;
  final String? website;
  final String? companyName;
  final String? city;

  /// Returns initials suitable for an avatar placeholder.
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is UserListItem && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'UserListItem(id: $id, name: $name)';
}
