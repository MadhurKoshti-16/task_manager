import 'package:task_manager_bloc/features/tasks/domain/entities/task_page.dart';
import 'package:task_manager_bloc/features/tasks/domain/entities/task_page_params.dart';

import '../../../../core/result/result.dart';
import '../entities/task_entity.dart';

abstract interface class TaskRepository {
  Future<Result<TaskPage>> getTaskPage(TaskPageParams params);
  Future<Result<void>> synchronizeTasks();
  Future<Result<TaskEntity>> addTask(TaskEntity task);
  Future<Result<TaskEntity>> updateTask(TaskEntity task);
  Future<Result<TaskEntity>> toggleTaskStatus(TaskEntity task);
  Future<Result<void>> deleteTask(TaskEntity task);
}
