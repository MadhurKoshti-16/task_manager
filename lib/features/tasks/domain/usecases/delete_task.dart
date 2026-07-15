import '../../../../core/result/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

final class DeleteTask implements UseCase<Result<void>, TaskEntity> {
  const DeleteTask(this._repository);

  final TaskRepository _repository;

  @override
  Future<Result<void>> call(TaskEntity task) {
    return _repository.deleteTask(task);
  }
}
