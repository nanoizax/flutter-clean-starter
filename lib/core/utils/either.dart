// Functional Either type — Leandro Perez — SonhoLab
// A lightweight Either<L, R> implementation with no external dependencies.
// Used throughout the data and domain layers to make error-handling explicit.

/// Represents a value of one of two possible types.
/// - [Left] conventionally holds an error/failure value.
/// - [Right] conventionally holds a success value.
sealed class Either<L, R> {
  const Either();

  /// Returns `true` when this is a [Right] (success).
  bool get isRight => this is Right<L, R>;

  /// Returns `true` when this is a [Left] (failure).
  bool get isLeft => this is Left<L, R>;

  /// Applies [onLeft] if this is [Left], or [onRight] if this is [Right].
  T fold<T>(T Function(L left) onLeft, T Function(R right) onRight) {
    return switch (this) {
      Left<L, R>(value: final l) => onLeft(l),
      Right<L, R>(value: final r) => onRight(r),
    };
  }

  /// Maps the right value, leaving a [Left] unchanged.
  Either<L, T> map<T>(T Function(R right) f) {
    return switch (this) {
      Left<L, R>(value: final l) => Left<L, T>(l),
      Right<L, R>(value: final r) => Right<L, T>(f(r)),
    };
  }

  /// FlatMaps (chain) the right value, leaving a [Left] unchanged.
  Either<L, T> flatMap<T>(Either<L, T> Function(R right) f) {
    return switch (this) {
      Left<L, R>(value: final l) => Left<L, T>(l),
      Right<L, R>(value: final r) => f(r),
    };
  }

  /// Returns the right value or throws a [StateError].
  R getOrElse(R Function() orElse) {
    return switch (this) {
      Left<L, R>() => orElse(),
      Right<L, R>(value: final r) => r,
    };
  }
}

/// The left (failure) side of [Either].
final class Left<L, R> extends Either<L, R> {
  const Left(this.value);

  final L value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Left<L, R> && other.value == value);

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Left($value)';
}

/// The right (success) side of [Either].
final class Right<L, R> extends Either<L, R> {
  const Right(this.value);

  final R value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Right<L, R> && other.value == value);

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Right($value)';
}

// ---------------------------------------------------------------------------
// Convenience constructors
// ---------------------------------------------------------------------------

/// Shorthand to create a [Left].
Either<L, R> left<L, R>(L value) => Left<L, R>(value);

/// Shorthand to create a [Right].
Either<L, R> right<L, R>(R value) => Right<L, R>(value);
