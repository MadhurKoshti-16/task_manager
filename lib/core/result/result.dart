import '../error/failures.dart';

sealed class Result<T> {
  const Result();
}

final class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;
}

final class ErrorResult<T> extends Result<T> {
  const ErrorResult(this.failure);
  final Failure failure;
}
