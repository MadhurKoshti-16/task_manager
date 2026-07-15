import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:task_manager_bloc/core/error/exceptions.dart';
import 'package:task_manager_bloc/core/error/failures.dart';
import 'package:task_manager_bloc/core/result/result.dart';
import 'package:task_manager_bloc/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:task_manager_bloc/features/authentication/domain/entities/user_entity.dart';
import '../../../../helpers/test_data.dart';
import '../../../../helpers/test_mocks.dart';

void main() {
  late MockAuthRemoteDataSource remoteDataSource;
  late MockAuthLocalDataSource localDataSource;
  late MockNetworkInfo networkInfo;
  late AuthRepositoryImpl repository;
  setUp(() {
    remoteDataSource = MockAuthRemoteDataSource();
    localDataSource = MockAuthLocalDataSource();
    networkInfo = MockNetworkInfo();
    repository = AuthRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
      networkInfo: networkInfo,
    );
  });
  group('login', () {
    test('returns NetworkFailure when internet is unavailable', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);
      final result = await repository.login(
        email: TestData.email,
        password: TestData.password,
      );
      expect(result, isA<ErrorResult<UserEntity>>());
      final error = result as ErrorResult<UserEntity>;
      expect(error.failure, isA<NetworkFailure>());
      verify(() => networkInfo.isConnected).called(1);
      verifyNever(
        () => remoteDataSource.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
    });
    test('logs in remotely, caches user, and returns success', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => remoteDataSource.login(
          email: TestData.email,
          password: TestData.password,
        ),
      ).thenAnswer((_) async => TestData.userModel);
      when(
        () => localDataSource.cacheUser(TestData.userModel),
      ).thenAnswer((_) async {});
      final result = await repository.login(
        email: TestData.email,
        password: TestData.password,
      );
      expect(result, isA<Success<UserEntity>>());
      final success = result as Success<UserEntity>;
      expect(success.data, TestData.userModel);
      verify(() => networkInfo.isConnected).called(1);
      verify(
        () => remoteDataSource.login(
          email: TestData.email,
          password: TestData.password,
        ),
      ).called(1);
      verify(() => localDataSource.cacheUser(TestData.userModel)).called(1);
    });
    test(
      'returns AuthenticationFailure when remote datasource throws',
      () async {
        when(() => networkInfo.isConnected).thenAnswer((_) async => true);
        when(
          () => remoteDataSource.login(
            email: TestData.email,
            password: TestData.password,
          ),
        ).thenThrow(
          const AuthenticationException(
            code: 'invalid-credential',
            message: 'The email address or password is incorrect.',
          ),
        );
        final result = await repository.login(
          email: TestData.email,
          password: TestData.password,
        );
        expect(result, isA<ErrorResult<UserEntity>>());
        final error = result as ErrorResult<UserEntity>;
        expect(error.failure, isA<AuthenticationFailure>());
        expect(
          error.failure.message,
          'The email address or password is incorrect.',
        );
        expect(error.failure.code, 'invalid-credential');
      },
    );
    test('returns remote user when login succeeds but cache fails', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => remoteDataSource.login(
          email: TestData.email,
          password: TestData.password,
        ),
      ).thenAnswer((_) async => TestData.userModel);
      when(
        () => localDataSource.cacheUser(TestData.userModel),
      ).thenThrow(const CacheException('Cache write failed.'));
      when(remoteDataSource.getCurrentUser).thenReturn(TestData.userModel);
      final result = await repository.login(
        email: TestData.email,
        password: TestData.password,
      );
      expect(result, isA<Success<UserEntity>>());
      final success = result as Success<UserEntity>;
      expect(success.data, TestData.userModel);
    });
  });
  group('register', () {
    test(
      'returns NetworkFailure when registration is attempted offline',
      () async {
        when(() => networkInfo.isConnected).thenAnswer((_) async => false);
        final result = await repository.register(
          email: TestData.email,
          password: TestData.password,
        );
        expect(result, isA<ErrorResult<UserEntity>>());
        final error = result as ErrorResult<UserEntity>;
        expect(error.failure, isA<NetworkFailure>());
        verifyNever(
          () => remoteDataSource.register(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        );
      },
    );
    test('registers remotely, caches user, and returns success', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => remoteDataSource.register(
          email: TestData.email,
          password: TestData.password,
        ),
      ).thenAnswer((_) async => TestData.userModel);
      when(
        () => localDataSource.cacheUser(TestData.userModel),
      ).thenAnswer((_) async {});
      final result = await repository.register(
        email: TestData.email,
        password: TestData.password,
      );
      expect(result, isA<Success<UserEntity>>());
      verify(
        () => remoteDataSource.register(
          email: TestData.email,
          password: TestData.password,
        ),
      ).called(1);
      verify(() => localDataSource.cacheUser(TestData.userModel)).called(1);
    });
    test('returns AuthenticationFailure for existing email', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => remoteDataSource.register(
          email: TestData.email,
          password: TestData.password,
        ),
      ).thenThrow(
        const AuthenticationException(
          code: 'email-already-in-use',
          message: 'An account already exists for this email address.',
        ),
      );
      final result = await repository.register(
        email: TestData.email,
        password: TestData.password,
      );
      expect(result, isA<ErrorResult<UserEntity>>());
      final error = result as ErrorResult<UserEntity>;
      expect(error.failure, isA<AuthenticationFailure>());
      expect(error.failure.code, 'email-already-in-use');
    });
  });
  group('getCurrentUser', () {
    test('returns Firebase user when current remote user exists', () async {
      when(remoteDataSource.getCurrentUser).thenReturn(TestData.userModel);
      when(
        () => localDataSource.cacheUser(TestData.userModel),
      ).thenAnswer((_) async {});
      final result = await repository.getCurrentUser();
      expect(result, isA<Success<UserEntity?>>());
      final success = result as Success<UserEntity?>;
      expect(success.data, TestData.userModel);
      verify(() => localDataSource.cacheUser(TestData.userModel)).called(1);
      verifyNever(localDataSource.getCachedUser);
    });
    test('returns cached user when Firebase user is unavailable', () async {
      when(remoteDataSource.getCurrentUser).thenReturn(null);
      when(localDataSource.getCachedUser).thenReturn(TestData.cachedUserModel);
      final result = await repository.getCurrentUser();
      expect(result, isA<Success<UserEntity?>>());
      final success = result as Success<UserEntity?>;
      expect(success.data, TestData.cachedUserModel);
      expect(success.data?.isFromCache, isTrue);
    });
    test(
      'returns success with null when no remote or cached user exists',
      () async {
        when(remoteDataSource.getCurrentUser).thenReturn(null);
        when(localDataSource.getCachedUser).thenReturn(null);
        final result = await repository.getCurrentUser();
        expect(result, isA<Success<UserEntity?>>());
        final success = result as Success<UserEntity?>;
        expect(success.data, isNull);
      },
    );
    test('returns CacheFailure when cached-user reading fails', () async {
      when(remoteDataSource.getCurrentUser).thenReturn(null);
      when(
        localDataSource.getCachedUser,
      ).thenThrow(const CacheException('Unable to read cached user.'));
      final result = await repository.getCurrentUser();
      expect(result, isA<ErrorResult<UserEntity?>>());
      final error = result as ErrorResult<UserEntity?>;
      expect(error.failure, isA<CacheFailure>());
    });
  });
  group('logout', () {
    test('signs out remotely and clears local cache when online', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(remoteDataSource.logout).thenAnswer((_) async {});
      when(localDataSource.clearCachedUser).thenAnswer((_) async {});
      final result = await repository.logout();
      expect(result, isA<Success<void>>());
      verify(remoteDataSource.logout).called(1);
      verify(localDataSource.clearCachedUser).called(1);
    });
    test('clears local cache without remote logout when offline', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);
      when(localDataSource.clearCachedUser).thenAnswer((_) async {});
      final result = await repository.logout();
      expect(result, isA<Success<void>>());
      verifyNever(remoteDataSource.logout);
      verify(localDataSource.clearCachedUser).called(1);
    });
  });
}
