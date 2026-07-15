import 'package:equatable/equatable.dart';
import 'package:task_manager_bloc/features/authentication/domain/entities/user_entity.dart';

sealed class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object?> get props => [];
}

final class SplashInitial extends SplashState {
  const SplashInitial();
}

final class SplashLoading extends SplashState {
  const SplashLoading();
}

final class SplashAuthenticated extends SplashState {
  const SplashAuthenticated({required this.user});
  final UserEntity user;

  @override
  List<Object?> get props => [user];
}

final class SplashUnauthenticated extends SplashState {
  const SplashUnauthenticated();
}

final class SplashFailure extends SplashState {
  const SplashFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
