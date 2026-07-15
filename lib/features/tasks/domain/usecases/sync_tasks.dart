import '../../../../core/result/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/task_repository.dart';

final class SyncTasks implements UseCase<Result<void>, NoParams> {
  const SyncTasks(this._repository);
  final TaskRepository _repository;
  @override
  Future<Result<void>> call(NoParams params) {
    return _repository.synchronizeTasks();
  }
}
