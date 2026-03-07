// Either tests — Leandro Perez — SonhoLab

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_clean_starter/core/utils/either.dart';

void main() {
  group('Either', () {
    // ── Left ────────────────────────────────────────────────────────────────
    group('Left', () {
      test('isLeft returns true', () {
        final result = left<String, int>('error');
        expect(result.isLeft, isTrue);
      });

      test('isRight returns false', () {
        final result = left<String, int>('error');
        expect(result.isRight, isFalse);
      });

      test('fold calls onLeft with the left value', () {
        final result = left<String, int>('error message');
        final output = result.fold((l) => 'got: $l', (r) => 'right: $r');
        expect(output, 'got: error message');
      });

      test('map does not transform the value', () {
        final result = left<String, int>('error');
        final mapped = result.map((r) => r * 2);
        expect(mapped.isLeft, isTrue);
        expect((mapped as Left<String, int>).value, 'error');
      });

      test('flatMap does not transform the value', () {
        final result = left<String, int>('error');
        final chained = result.flatMap((r) => right<String, String>('ok'));
        expect(chained.isLeft, isTrue);
      });

      test('getOrElse returns the orElse value', () {
        final result = left<String, int>('error');
        expect(result.getOrElse(() => 42), 42);
      });

      test('equality holds for the same value', () {
        expect(left<String, int>('a'), equals(left<String, int>('a')));
      });

      test('inequality when values differ', () {
        expect(left<String, int>('a'), isNot(equals(left<String, int>('b'))));
      });
    });

    // ── Right ───────────────────────────────────────────────────────────────
    group('Right', () {
      test('isRight returns true', () {
        final result = right<String, int>(42);
        expect(result.isRight, isTrue);
      });

      test('isLeft returns false', () {
        final result = right<String, int>(42);
        expect(result.isLeft, isFalse);
      });

      test('fold calls onRight with the right value', () {
        final result = right<String, int>(10);
        final output = result.fold((l) => 'left', (r) => 'right: $r');
        expect(output, 'right: 10');
      });

      test('map transforms the value', () {
        final result = right<String, int>(10);
        final mapped = result.map((r) => r * 2);
        expect(mapped.isRight, isTrue);
        expect((mapped as Right<String, int>).value, 20);
      });

      test('flatMap chains correctly', () {
        final result = right<String, int>(5);
        final chained = result.flatMap(
          (r) => r > 0
              ? right<String, String>('positive')
              : left<String, String>('non-positive'),
        );
        expect(chained.isRight, isTrue);
        expect((chained as Right<String, String>).value, 'positive');
      });

      test('flatMap can produce a Left', () {
        final result = right<String, int>(-1);
        final chained = result.flatMap(
          (r) => r > 0
              ? right<String, String>('positive')
              : left<String, String>('non-positive'),
        );
        expect(chained.isLeft, isTrue);
      });

      test('getOrElse returns the right value', () {
        final result = right<String, int>(99);
        expect(result.getOrElse(() => 0), 99);
      });

      test('equality holds for the same value', () {
        expect(right<String, int>(1), equals(right<String, int>(1)));
      });

      test('inequality when values differ', () {
        expect(right<String, int>(1), isNot(equals(right<String, int>(2))));
      });
    });

    // ── Cross-type checks ───────────────────────────────────────────────────
    group('Left vs Right', () {
      test('Left and Right with same inner value are not equal', () {
        expect(left<int, int>(1), isNot(equals(right<int, int>(1))));
      });
    });
  });
}
