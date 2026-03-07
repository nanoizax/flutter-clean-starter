// User domain entity — Leandro Perez — SonhoLab
// Pure domain class — no JSON serialization, no framework dependencies.

class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    this.username,
    this.avatarUrl,
    this.role = UserRole.user,
  });

  final int id;
  final String name;
  final String email;
  final String? username;
  final String? avatarUrl;
  final UserRole role;

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? username,
    String? avatarUrl,
    UserRole? role,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == id &&
          other.email == email);

  @override
  int get hashCode => Object.hash(id, email);

  @override
  String toString() => 'User(id: $id, name: $name, email: $email)';
}

enum UserRole { admin, user, guest }
