import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/result/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/logout_user.dart';
import '../../domain/usecases/register_user.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required this._loginUser,
    required this._registerUser,
    required this._getCurrentUser,
    required this._logoutUser,
  }) : super(const AuthInitial()) {
    on<AuthLoginSubmitted>(_onLoginSubmitted);
    on<AuthRegisterSubmitted>(_onRegisterSubmitted);
    on<AuthCurrentUserRequested>(_onCurrentUserRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthMessageCleared>(_onMessageCleared);
  }

  final LoginUser _loginUser;
  final RegisterUser _registerUser;
  final GetCurrentUser _getCurrentUser;
  final LogoutUser _logoutUser;

  Future<void> _onLoginSubmitted(
    AuthLoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _loginUser(
      LoginParams(email: event.email.trim(), password: event.password),
    );

    _emitUserResult(result, emit);
  }

  Future<void> _onRegisterSubmitted(
    AuthRegisterSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _registerUser(
      RegisterParams(email: event.email.trim(), password: event.password),
    );

    _emitUserResult(result, emit);
  }

  Future<void> _onCurrentUserRequested(
    AuthCurrentUserRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _getCurrentUser(const NoParams());

    switch (result) {
      case Success<UserEntity?>(:final data):
        if (data == null) {
          emit(const AuthUnauthenticated());
        } else {
          emit(AuthAuthenticated(data));
        }

      case ErrorResult<UserEntity?>(:final failure):
        emit(AuthFailure(message: failure.message, code: failure.code));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _logoutUser(const NoParams());

    switch (result) {
      case Success<void>():
        emit(const AuthLoggedOut());

      case ErrorResult<void>(:final failure):
        emit(AuthFailure(message: failure.message, code: failure.code));
    }
  }

  void _onMessageCleared(AuthMessageCleared event, Emitter<AuthState> emit) {
    emit(const AuthInitial());
  }

  void _emitUserResult(Result<UserEntity> result, Emitter<AuthState> emit) {
    switch (result) {
      case Success<UserEntity>(:final data):
        emit(AuthAuthenticated(data));

      case ErrorResult<UserEntity>(:final failure):
        emit(AuthFailure(message: failure.message, code: failure.code));
    }
  }
}
