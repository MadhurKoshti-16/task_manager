import '../../../../core/result/result.dart';
import '../entities/user_entity.dart';

abstract interface class AuthRepository {
  Future<Result<UserEntity>> login({
    required String email,
    required String password,
  });
  Future<Result<UserEntity>> register({
    required String email,
    required String password,
  });
  Future<Result<UserEntity?>> getCurrentUser();
  Future<Result<void>> logout();
}
