import '../../../../core/result/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

final class ToggleTaskStatus
    implements UseCase<Result<TaskEntity>, TaskEntity> {
  const ToggleTaskStatus(this._repository);

  final TaskRepository _repository;

  @override
  Future<Result<TaskEntity>> call(TaskEntity task) {
    return _repository.toggleTaskStatus(task);
  }
}
