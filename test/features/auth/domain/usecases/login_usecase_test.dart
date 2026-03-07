// LoginUseCase tests — Leandro Perez — SonhoLab
// Uses mocktail to mock the AuthRepository.

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_clean_starter/core/error/failures.dart';
import 'package:flutter_clean_starter/core/utils/either.dart';
import 'package:flutter_clean_starter/features/auth/domain/entities/user.dart';
import 'package:flutter_clean_starter/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_clean_starter/features/auth/domain/usecases/login_usecase.dart';

// ---------------------------------------------------------------------------
// Mock
// ---------------------------------------------------------------------------

class MockAuthRepository extends Mock implements AuthRepository {}

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

const _validEmail = 'leandro@sonholab.com';
const _validPassword = 'secret123';

const _tUser = User(
  id: 1,
  name: 'Leandro Perez',
  email: _validEmail,
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockAuthRepository mockRepository;
  late LoginUseCase useCase;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LoginUseCase(repository: mockRepository);
  });

  // Helper to stub a successful login.
  void stubLoginSuccess() {
    when(
      () => mockRepository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => right(_tUser));
  }

  // Helper to stub a failed login.
  void stubLoginFailure(Failure failure) {
    when(
      () => mockRepository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => left(failure));
  }

  group('LoginUseCase — input validation', () {
    test('returns AuthFailure when email is empty', () async {
      final result = await useCase(
        const LoginParams(email: '', password: _validPassword),
      );
      expect(result.isLeft, isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<AuthFailure>());
          expect(failure.message, contains('required'));
        },
        (_) => fail('Expected a Left'),
      );
      verifyNever(
        () => mockRepository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
    });

    test('returns AuthFailure when password is empty', () async {
      final result = await useCase(
        const LoginParams(email: _validEmail, password: ''),
      );
      expect(result.isLeft, isTrue);
      verifyNever(
        () => mockRepository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
    });

    test('returns AuthFailure when email format is invalid', () async {
      final result = await useCase(
        const LoginParams(email: 'not-an-email', password: _validPassword),
      );
      expect(result.isLeft, isTrue);
      result.fold(
        (f) => expect(f.message, contains('valid email')),
        (_) => fail('Expected a Left'),
      );
    });

    test('returns AuthFailure when password is shorter than 6 chars', () async {
      final result = await useCase(
        const LoginParams(email: _validEmail, password: '12345'),
      );
      expect(result.isLeft, isTrue);
      result.fold(
        (f) => expect(f.message, contains('6 characters')),
        (_) => fail('Expected a Left'),
      );
    });

    test('trims whitespace from email before calling repository', () async {
      stubLoginSuccess();
      await useCase(
        const LoginParams(email: '  $_validEmail  ', password: _validPassword),
      );
      verify(
        () => mockRepository.login(
          email: _validEmail,
          password: _validPassword,
        ),
      ).called(1);
    });
  });

  group('LoginUseCase — repository delegation', () {
    test('returns User on successful login', () async {
      stubLoginSuccess();
      final result = await useCase(
        const LoginParams(email: _validEmail, password: _validPassword),
      );
      expect(result.isRight, isTrue);
      result.fold(
        (_) => fail('Expected a Right'),
        (user) {
          expect(user.id, _tUser.id);
          expect(user.email, _tUser.email);
          expect(user.name, _tUser.name);
        },
      );
    });

    test('propagates ServerFailure from repository', () async {
      stubLoginFailure(
        const ServerFailure(message: 'Internal server error', statusCode: 500),
      );
      final result = await useCase(
        const LoginParams(email: _validEmail, password: _validPassword),
      );
      expect(result.isLeft, isTrue);
      result.fold(
        (f) {
          expect(f, isA<ServerFailure>());
          expect(f.message, 'Internal server error');
        },
        (_) => fail('Expected a Left'),
      );
    });

    test('propagates NetworkFailure from repository', () async {
      stubLoginFailure(const NetworkFailure());
      final result = await useCase(
        const LoginParams(email: _validEmail, password: _validPassword),
      );
      expect(result.isLeft, isTrue);
      result.fold(
        (f) => expect(f, isA<NetworkFailure>()),
        (_) => fail('Expected a Left'),
      );
    });

    test('propagates AuthFailure (401) from repository', () async {
      stubLoginFailure(
        const AuthFailure(message: 'Invalid credentials', statusCode: 401),
      );
      final result = await useCase(
        const LoginParams(email: _validEmail, password: _validPassword),
      );
      expect(result.isLeft, isTrue);
      result.fold(
        (f) {
          expect(f, isA<AuthFailure>());
          expect((f as AuthFailure).statusCode, 401);
        },
        (_) => fail('Expected a Left'),
      );
    });

    test('calls repository exactly once per invocation', () async {
      stubLoginSuccess();
      await useCase(
        const LoginParams(email: _validEmail, password: _validPassword),
      );
      verify(
        () => mockRepository.login(
          email: _validEmail,
          password: _validPassword,
        ),
      ).called(1);
    });
  });
}
