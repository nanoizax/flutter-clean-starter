// Logout use-case — Leandro Perez — SonhoLab

import 'package:flutter_clean_starter/core/error/failures.dart';
import 'package:flutter_clean_starter/core/utils/either.dart';
import 'package:flutter_clean_starter/features/auth/domain/repositories/auth_repository.dart';

class LogoutUseCase {
  const LogoutUseCase({required this.repository});

  final AuthRepository repository;

  Future<Either<Failure, void>> call() => repository.logout();
}
