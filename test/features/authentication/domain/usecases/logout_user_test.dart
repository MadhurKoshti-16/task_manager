import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:task_manager_bloc/core/result/result.dart';
import 'package:task_manager_bloc/core/usecases/usecase.dart';
import 'package:task_manager_bloc/features/authentication/domain/usecases/logout_user.dart';
import '../../../../helpers/test_mocks.dart';

void main() {
  late MockAuthRepository repository;
  late LogoutUser useCase;
  setUp(() {
    repository = MockAuthRepository();
    useCase = LogoutUser(repository);
  });
  test('calls logout on repository', () async {
    when(repository.logout).thenAnswer((_) async => const Success<void>(null));
    final result = await useCase(const NoParams());
    expect(result, isA<Success<void>>());
    verify(repository.logout).called(1);
    verifyNoMoreInteractions(repository);
  });
}
