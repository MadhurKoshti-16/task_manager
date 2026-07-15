import '../../../../core/result/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUser implements UseCase<Result<UserEntity?>, NoParams> {
  const GetCurrentUser(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<UserEntity?>> call(NoParams params) {
    return _repository.getCurrentUser();
  }
}
