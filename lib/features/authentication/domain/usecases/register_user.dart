import 'package:equatable/equatable.dart';
import '../../../../core/result/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUser implements UseCase<Result<UserEntity>, RegisterParams> {
  const RegisterUser(this._repository);
  final AuthRepository _repository;
  @override
  Future<Result<UserEntity>> call(RegisterParams params) {
    return _repository.register(email: params.email, password: params.password);
  }
}

final class RegisterParams extends Equatable {
  const RegisterParams({required this.email, required this.password});
  final String email;
  final String password;
  @override
  List<Object?> get props => [email, password];
}
