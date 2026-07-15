import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

final class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required this._remoteDataSource,
    required this._localDataSource,
    required this._networkInfo,
  });

  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  @override
  Future<Result<UserEntity>> login({
    required String email,
    required String password,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const ErrorResult(
        NetworkFailure(
          message:
              'Login requires an internet connection. Your cached tasks remain available offline.',
        ),
      );
    }

    try {
      final user = await _remoteDataSource.login(
        email: email,
        password: password,
      );

      await _localDataSource.cacheUser(user);

      return Success(user);
    } on AuthenticationException catch (exception) {
      return ErrorResult(
        AuthenticationFailure(message: exception.message, code: exception.code),
      );
    } on CacheException catch (exception) {
      // Authentication succeeded, but local caching failed.
      // The user can still enter the application.
      final remoteUser = _remoteDataSource.getCurrentUser();

      if (remoteUser != null) {
        return Success(remoteUser);
      }

      return ErrorResult(CacheFailure(message: exception.message));
    } on ServerException catch (exception) {
      return ErrorResult(
        ServerFailure(message: exception.message, code: exception.code),
      );
    } catch (_) {
      return const ErrorResult(UnknownFailure());
    }
  }

  @override
  Future<Result<UserEntity>> register({
    required String email,
    required String password,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const ErrorResult(
        NetworkFailure(
          message: 'Registration requires an internet connection.',
        ),
      );
    }

    try {
      final user = await _remoteDataSource.register(
        email: email,
        password: password,
      );

      await _localDataSource.cacheUser(user);

      return Success(user);
    } on AuthenticationException catch (exception) {
      return ErrorResult(
        AuthenticationFailure(message: exception.message, code: exception.code),
      );
    } on CacheException {
      final remoteUser = _remoteDataSource.getCurrentUser();

      if (remoteUser != null) {
        return Success(remoteUser);
      }

      return const ErrorResult(CacheFailure());
    } on ServerException catch (exception) {
      return ErrorResult(
        ServerFailure(message: exception.message, code: exception.code),
      );
    } catch (_) {
      return const ErrorResult(UnknownFailure());
    }
  }

  @override
  Future<Result<UserEntity?>> getCurrentUser() async {
    try {
      final firebaseUser = _remoteDataSource.getCurrentUser();

      if (firebaseUser != null) {
        try {
          await _localDataSource.cacheUser(firebaseUser);
        } on CacheException {
          // Firebase session remains usable even if cache writing fails.
        }

        return Success(firebaseUser);
      }

      final cachedUser = _localDataSource.getCachedUser();

      if (cachedUser != null) {
        return Success(cachedUser);
      }

      return const Success(null);
    } on CacheException catch (exception) {
      return ErrorResult(CacheFailure(message: exception.message));
    } catch (_) {
      return const ErrorResult(UnknownFailure());
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      if (await _networkInfo.isConnected) {
        await _remoteDataSource.logout();
      }

      await _localDataSource.clearCachedUser();

      return const Success(null);
    } on AuthenticationException catch (exception) {
      return ErrorResult(
        AuthenticationFailure(message: exception.message, code: exception.code),
      );
    } on CacheException catch (exception) {
      return ErrorResult(CacheFailure(message: exception.message));
    } on ServerException catch (exception) {
      return ErrorResult(ServerFailure(message: exception.message));
    } catch (_) {
      return const ErrorResult(UnknownFailure());
    }
  }
}
