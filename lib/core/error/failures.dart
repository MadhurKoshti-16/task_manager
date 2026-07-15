import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  const Failure({required this.message, this.code});

  final String message;
  final String? code;

  @override
  List<Object?> get props => [message, code];
}

final class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection. Please check your network.',
    super.code,
  });
}

final class AuthenticationFailure extends Failure {
  const AuthenticationFailure({required super.message, super.code});
}

final class ServerFailure extends Failure {
  const ServerFailure({
    super.message = 'Something went wrong. Please try again.',
    super.code,
  });
}

final class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Unable to access offline data.',
    super.code,
  });
}

final class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'An unexpected error occurred.',
    super.code,
  });
}
