import 'package:hive_ce/hive.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/task_page.dart';
import '../../domain/entities/task_page_cursor.dart';
import '../models/task_model.dart';

abstract interface class TaskLocalDataSource {
  TaskPage getTaskPage({
    required String userId,
    required int pageSize,
    TaskPageCursor? cursor,
  });
  List<TaskModel> getTasks(String userId);

  List<TaskModel> getPendingSyncTasks(String userId);

  Future<void> upsertTask(TaskModel task);

  Future<void> upsertTasks(List<TaskModel> tasks);

  Future<void> hardDeleteTask({required String userId, required String taskId});

  Future<void> clearUserTasks(String userId);
}

final class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  const TaskLocalDataSourceImpl(this._taskBox);

  final Box<dynamic> _taskBox;

  String _key({required String userId, required String taskId}) {
    return '$userId::$taskId';
  }

  @override
  List<TaskModel> getTasks(String userId) {
    try {
      final tasks = <TaskModel>[];

      for (final value in _taskBox.values) {
        if (value is! Map) {
          continue;
        }

        final task = TaskModel.fromHiveMap(value);

        if (task.userId == userId && !task.isDeleted) {
          tasks.add(task);
        }
      }

      tasks.sort((first, second) {
        final dateComparison = first.dueDate.compareTo(second.dueDate);
        if (dateComparison != 0) {
          return dateComparison;
        }
        return first.id.compareTo(second.id);
      });

      return tasks;
    } catch (error) {
      throw CacheException('Unable to read cached tasks: $error');
    }
  }

  @override
  List<TaskModel> getPendingSyncTasks(String userId) {
    try {
      final tasks = <TaskModel>[];

      for (final value in _taskBox.values) {
        if (value is! Map) {
          continue;
        }

        final task = TaskModel.fromHiveMap(value);

        if (task.userId == userId && !task.isSynced) {
          tasks.add(task);
        }
      }

      tasks.sort(
        (first, second) => first.updatedAt.compareTo(second.updatedAt),
      );

      return tasks;
    } catch (error) {
      throw CacheException('Unable to read pending task changes: $error');
    }
  }

  @override
  Future<void> upsertTask(TaskModel task) async {
    try {
      await _taskBox.put(
        _key(userId: task.userId, taskId: task.id),
        task.toHiveMap(),
      );
    } catch (error) {
      throw CacheException('Unable to save task locally: $error');
    }
  }

  @override
  Future<void> upsertTasks(List<TaskModel> tasks) async {
    try {
      final values = <String, Map<String, dynamic>>{};

      for (final task in tasks) {
        values[_key(userId: task.userId, taskId: task.id)] = task.toHiveMap();
      }

      await _taskBox.putAll(values);
    } catch (error) {
      throw CacheException('Unable to cache remote tasks: $error');
    }
  }

  @override
  Future<void> hardDeleteTask({
    required String userId,
    required String taskId,
  }) async {
    try {
      await _taskBox.delete(_key(userId: userId, taskId: taskId));
    } catch (error) {
      throw CacheException('Unable to remove cached task: $error');
    }
  }

  @override
  Future<void> clearUserTasks(String userId) async {
    try {
      final keys = <dynamic>[];

      for (final key in _taskBox.keys) {
        if (key is String && key.startsWith('$userId::')) {
          keys.add(key);
        }
      }

      await _taskBox.deleteAll(keys);
    } catch (error) {
      throw CacheException('Unable to clear cached tasks: $error');
    }
  }

  @override
  TaskPage getTaskPage({
    required String userId,
    required int pageSize,
    TaskPageCursor? cursor,
  }) {
    try {
      final tasks = getTasks(userId);
      var startIndex = 0;
      if (cursor != null) {
        final cursorIndex = tasks.indexWhere((task) {
          return task.id == cursor.taskId &&
              task.dueDate.isAtSameMomentAs(cursor.dueDate);
        });
        if (cursorIndex >= 0) {
          startIndex = cursorIndex + 1;
        }
      }
      if (startIndex >= tasks.length) {
        return const TaskPage(tasks: [], hasMore: false);
      }
      final endIndex = (startIndex + pageSize).clamp(0, tasks.length);
      final pageTasks = tasks.sublist(startIndex, endIndex);
      final hasMore = endIndex < tasks.length;
      final lastTask = pageTasks.isEmpty ? null : pageTasks.last;
      return TaskPage(
        tasks: pageTasks,
        hasMore: hasMore,
        nextCursor: lastTask == null
            ? null
            : TaskPageCursor(dueDate: lastTask.dueDate, taskId: lastTask.id),
      );
    } catch (error) {
      throw CacheException('Unable to load cached task page: $error');
    }
  }
}
