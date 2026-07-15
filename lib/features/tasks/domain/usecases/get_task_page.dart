import 'package:task_manager_bloc/features/tasks/domain/entities/task_page.dart';
import 'package:task_manager_bloc/features/tasks/domain/entities/task_page_params.dart';

import '../../../../core/result/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/task_repository.dart';

final class GetTaskPage implements UseCase<Result<TaskPage>, TaskPageParams> {
  const GetTaskPage(this._repository);

  final TaskRepository _repository;

  @override
  Future<Result<TaskPage>> call(TaskPageParams params) {
    return _repository.getTaskPage(params);
  }
}
