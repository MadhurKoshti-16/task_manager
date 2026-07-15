import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:task_manager_bloc/core/error/failures.dart';
import 'package:task_manager_bloc/core/result/result.dart';
import 'package:task_manager_bloc/core/usecases/usecase.dart';
import 'package:task_manager_bloc/features/authentication/domain/entities/user_entity.dart';
import 'package:task_manager_bloc/features/authentication/domain/usecases/login_user.dart';
import 'package:task_manager_bloc/features/authentication/domain/usecases/register_user.dart';
import 'package:task_manager_bloc/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:task_manager_bloc/features/authentication/presentation/bloc/auth_event.dart';
import 'package:task_manager_bloc/features/authentication/presentation/bloc/auth_state.dart';
import '../../../../helpers/test_data.dart';
import '../../../../helpers/test_mocks.dart';

void main() {
  late MockLoginUser loginUser;
  late MockRegisterUser registerUser;
  late MockGetCurrentUser getCurrentUser;
  late MockLogoutUser logoutUser;
  late AuthBloc bloc;
  setUpAll(() {
    registerFallbackValue(const LoginParams(email: '', password: ''));
    registerFallbackValue(const RegisterParams(email: '', password: ''));
    registerFallbackValue(const NoParams());
  });
  setUp(() {
    loginUser = MockLoginUser();
    registerUser = MockRegisterUser();
    getCurrentUser = MockGetCurrentUser();
    logoutUser = MockLogoutUser();
    bloc = AuthBloc(
      loginUser: loginUser,
      registerUser: registerUser,
      getCurrentUser: getCurrentUser,
      logoutUser: logoutUser,
    );
  });
  tearDown(() async {
    await bloc.close();
  });
  test('initial state is AuthInitial', () {
    expect(bloc.state, const AuthInitial());
  });
  group('AuthLoginSubmitted', () {
    blocTest<AuthBloc, AuthState>(
      'emits AuthLoading and AuthAuthenticated on success',
      build: () {
        when(() => loginUser(any())).thenAnswer(
          (_) async => const Success<UserEntity>(TestData.userEntity),
        );
        return bloc;
      },
      act: (bloc) {
        bloc.add(
          const AuthLoginSubmitted(
            email: TestData.email,
            password: TestData.password,
          ),
        );
      },
      expect: () => [
        const AuthLoading(),
        const AuthAuthenticated(TestData.userEntity),
      ],
      verify: (_) {
        verify(
          () => loginUser(
            const LoginParams(
              email: TestData.email,
              password: TestData.password,
            ),
          ),
        ).called(1);
      },
    );
    blocTest<AuthBloc, AuthState>(
      'trims email before passing it to login use case',
      build: () {
        when(() => loginUser(any())).thenAnswer(
          (_) async => const Success<UserEntity>(TestData.userEntity),
        );
        return bloc;
      },
      act: (bloc) {
        bloc.add(
          const AuthLoginSubmitted(
            email: ' madhur@example.com ',
            password: TestData.password,
          ),
        );
      },
      expect: () => [
        const AuthLoading(),
        const AuthAuthenticated(TestData.userEntity),
      ],
      verify: (_) {
        verify(
          () => loginUser(
            const LoginParams(
              email: TestData.email,
              password: TestData.password,
            ),
          ),
        ).called(1);
      },
    );
    blocTest<AuthBloc, AuthState>(
      'emits AuthLoading and AuthFailure on failure',
      build: () {
        when(() => loginUser(any())).thenAnswer(
          (_) async => const ErrorResult<UserEntity>(
            AuthenticationFailure(
              code: 'invalid-credential',
              message: 'The email address or password is incorrect.',
            ),
          ),
        );
        return bloc;
      },
      act: (bloc) {
        bloc.add(
          const AuthLoginSubmitted(
            email: TestData.email,
            password: TestData.wrongPassword,
          ),
        );
      },
      expect: () => [
        const AuthLoading(),
        const AuthFailure(
          code: 'invalid-credential',
          message: 'The email address or password is incorrect.',
        ),
      ],
    );
  });
  group('AuthRegisterSubmitted', () {
    blocTest<AuthBloc, AuthState>(
      'emits AuthLoading and AuthAuthenticated on registration success',
      build: () {
        when(() => registerUser(any())).thenAnswer(
          (_) async => const Success<UserEntity>(TestData.userEntity),
        );
        return bloc;
      },
      act: (bloc) {
        bloc.add(
          const AuthRegisterSubmitted(
            email: TestData.email,
            password: TestData.password,
          ),
        );
      },
      expect: () => [
        const AuthLoading(),
        const AuthAuthenticated(TestData.userEntity),
      ],
      verify: (_) {
        verify(
          () => registerUser(
            const RegisterParams(
              email: TestData.email,
              password: TestData.password,
            ),
          ),
        ).called(1);
      },
    );
    blocTest<AuthBloc, AuthState>(
      'emits AuthFailure when email already exists',
      build: () {
        when(() => registerUser(any())).thenAnswer(
          (_) async => const ErrorResult<UserEntity>(
            AuthenticationFailure(
              code: 'email-already-in-use',
              message: 'An account already exists for this email address.',
            ),
          ),
        );
        return bloc;
      },
      act: (bloc) {
        bloc.add(
          const AuthRegisterSubmitted(
            email: TestData.email,
            password: TestData.password,
          ),
        );
      },
      expect: () => [
        const AuthLoading(),
        const AuthFailure(
          code: 'email-already-in-use',
          message: 'An account already exists for this email address.',
        ),
      ],
    );
  });
  group('AuthCurrentUserRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits AuthAuthenticated when current user exists',
      build: () {
        when(() => getCurrentUser(any())).thenAnswer(
          (_) async => const Success<UserEntity?>(TestData.userEntity),
        );
        return bloc;
      },
      act: (bloc) {
        bloc.add(const AuthCurrentUserRequested());
      },
      expect: () => [
        const AuthLoading(),
        const AuthAuthenticated(TestData.userEntity),
      ],
    );
    blocTest<AuthBloc, AuthState>(
      'emits AuthUnauthenticated when current user is null',
      build: () {
        when(
          () => getCurrentUser(any()),
        ).thenAnswer((_) async => const Success<UserEntity?>(null));
        return bloc;
      },
      act: (bloc) {
        bloc.add(const AuthCurrentUserRequested());
      },
      expect: () => [const AuthLoading(), const AuthUnauthenticated()],
    );
  });
  group('AuthLogoutRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits AuthLoading and AuthLoggedOut on success',
      build: () {
        when(
          () => logoutUser(any()),
        ).thenAnswer((_) async => const Success<void>(null));
        return bloc;
      },
      act: (bloc) {
        bloc.add(const AuthLogoutRequested());
      },
      expect: () => [const AuthLoading(), const AuthLoggedOut()],
    );
    blocTest<AuthBloc, AuthState>(
      'emits AuthFailure when logout fails',
      build: () {
        when(() => logoutUser(any())).thenAnswer(
          (_) async => const ErrorResult<void>(
            CacheFailure(message: 'Unable to clear cached user.'),
          ),
        );
        return bloc;
      },
      act: (bloc) {
        bloc.add(const AuthLogoutRequested());
      },
      expect: () => [
        const AuthLoading(),
        const AuthFailure(message: 'Unable to clear cached user.'),
      ],
    );
  });
  blocTest<AuthBloc, AuthState>(
    'AuthMessageCleared emits AuthInitial',
    build: () => bloc,
    seed: () => const AuthFailure(message: 'Previous error'),
    act: (bloc) {
      bloc.add(const AuthMessageCleared());
    },
    expect: () => [const AuthInitial()],
  );
}
