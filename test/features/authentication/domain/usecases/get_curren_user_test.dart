import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:task_manager_bloc/core/result/result.dart';
import 'package:task_manager_bloc/core/usecases/usecase.dart';
import 'package:task_manager_bloc/features/authentication/domain/entities/user_entity.dart';
import 'package:task_manager_bloc/features/authentication/domain/usecases/get_current_user.dart';
import '../../../../helpers/test_data.dart';
import '../../../../helpers/test_mocks.dart';

void main() {
  late MockAuthRepository repository;
  late GetCurrentUser useCase;
  setUp(() {
    repository = MockAuthRepository();
    useCase = GetCurrentUser(repository);
  });
  test('returns current user from repository', () async {
    when(
      repository.getCurrentUser,
    ).thenAnswer((_) async => const Success<UserEntity?>(TestData.userEntity));
    final result = await useCase(const NoParams());
    expect(result, isA<Success<UserEntity?>>());
    verify(repository.getCurrentUser).called(1);
    verifyNoMoreInteractions(repository);
  });
  test('returns success with null when user is not logged in', () async {
    when(
      repository.getCurrentUser,
    ).thenAnswer((_) async => const Success<UserEntity?>(null));
    final result = await useCase(const NoParams());
    expect(result, isA<Success<UserEntity?>>());
    final success = result as Success<UserEntity?>;
    expect(success.data, isNull);
  });
}
