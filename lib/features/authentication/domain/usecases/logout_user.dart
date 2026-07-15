import '../../../../core/result/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class LogoutUser implements UseCase<Result<void>, NoParams> {
  const LogoutUser(this._repository);
  final AuthRepository _repository;
  @override
  Future<Result<void>> call(NoParams params) {
    return _repository.logout();
  }
}
