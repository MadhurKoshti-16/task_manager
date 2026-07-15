import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager_bloc/core/constants/app_duration.dart';
import 'package:task_manager_bloc/core/result/result.dart';
import 'package:task_manager_bloc/features/authentication/domain/entities/user_entity.dart';
import 'package:task_manager_bloc/features/splash/presentation/bloc/splash_event.dart';
import 'package:task_manager_bloc/features/splash/presentation/bloc/splash_state.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../authentication/domain/usecases/get_current_user.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc({required this._getCurrentUser}) : super(const SplashInitial()) {
    on<SplashStarted>(_onSplashStarted);
  }

  final GetCurrentUser _getCurrentUser;

  Future<void> _onSplashStarted(
    SplashStarted event,
    Emitter<SplashState> emit,
  ) async {
    emit(SplashLoading());
    try {
      final results = await Future.wait<Object?>([
        Future<void>.delayed(AppDurations.splashDuration),
        _getCurrentUser(const NoParams()),
      ]);

      final result = results[1] as Result<UserEntity?>;

      switch (result) {
        case Success<UserEntity?>(:final data):
          if (data == null) {
            emit(const SplashUnauthenticated());
          } else {
            emit(SplashAuthenticated(user: data));
          }

        case ErrorResult<UserEntity?>(:final failure):
          emit(SplashFailure(failure.message));
      }
    } catch (error) {
      emit(
        SplashFailure("'Unable to start the application. Please try again.'"),
      );
    }
  }
}
