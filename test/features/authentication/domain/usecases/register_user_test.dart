import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:task_manager_bloc/core/result/result.dart';
import 'package:task_manager_bloc/features/authentication/domain/entities/user_entity.dart';
import 'package:task_manager_bloc/features/authentication/domain/usecases/register_user.dart';
import '../../../../helpers/test_data.dart';
import '../../../../helpers/test_mocks.dart';

void main() {
  late MockAuthRepository repository;
  late RegisterUser useCase;
  setUp(() {
    repository = MockAuthRepository();
    useCase = RegisterUser(repository);
  });
  test('passes registration credentials to repository', () async {
    when(
      () => repository.register(
        email: TestData.email,
        password: TestData.password,
      ),
    ).thenAnswer((_) async => const Success<UserEntity>(TestData.userEntity));
    final result = await useCase(
      const RegisterParams(email: TestData.email, password: TestData.password),
    );
    expect(result, isA<Success<UserEntity>>());
    verify(
      () => repository.register(
        email: TestData.email,
        password: TestData.password,
      ),
    ).called(1);
    verifyNoMoreInteractions(repository);
  });
}
