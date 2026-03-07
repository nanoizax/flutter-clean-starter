// Login use-case — Leandro Perez — SonhoLab
// Orchestrates the login flow: validates input, calls the repository,
// and returns either a [User] or a [Failure].

import 'package:flutter_clean_starter/core/error/failures.dart';
import 'package:flutter_clean_starter/core/utils/either.dart';
import 'package:flutter_clean_starter/features/auth/domain/entities/user.dart';
import 'package:flutter_clean_starter/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  const LoginUseCase({required this.repository});

  final AuthRepository repository;

  Future<Either<Failure, User>> call(LoginParams params) async {
    // Basic input validation at the domain level.
    if (params.email.trim().isEmpty || params.password.isEmpty) {
      return left(const AuthFailure(message: 'Email and password are required.'));
    }

    if (!_isValidEmail(params.email)) {
      return left(const AuthFailure(message: 'Please enter a valid email address.'));
    }

    if (params.password.length < 6) {
      return left(const AuthFailure(message: 'Password must be at least 6 characters.'));
    }

    return repository.login(
      email: params.email.trim(),
      password: params.password,
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }
}

class LoginParams {
  const LoginParams({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;
}
