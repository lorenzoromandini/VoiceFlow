import '../errors/app_exception.dart';

sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get value => switch (this) {
    Success<T>(value: final v) => v,
    _ => null,
  };

  AppException? get error => switch (this) {
    Failure<T>(error: final e) => e,
    _ => null,
  };

  Result<R> map<R>(R Function(T) transform) {
    return switch (this) {
      Success<T>(value: final v) => Success(transform(v)),
      Failure<T>(error: final e) => Failure<R>(e),
    };
  }

  Result<R> flatMap<R>(Result<R> Function(T) transform) {
    return switch (this) {
      Success<T>(value: final v) => transform(v),
      Failure<T>(error: final e) => Failure<R>(e),
    };
  }
}

class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
}

class Failure<T> extends Result<T> {
  @override
  final AppException error;
  const Failure(this.error);
}
