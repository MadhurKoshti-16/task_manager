import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/task_page.dart';
import '../../domain/entities/task_page_params.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_local_datasource.dart';
import '../datasources/task_remote_datasource.dart';
import '../models/task_model.dart';

final class TaskRepositoryImpl implements TaskRepository {
  const TaskRepositoryImpl({
    required this._firebaseAuth,
    required this._localDataSource,
    required this._remoteDataSource,
    required this._networkInfo,
  });

  final FirebaseAuth _firebaseAuth;
  final TaskLocalDataSource _localDataSource;
  final TaskRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  String? get _currentUserId => _firebaseAuth.currentUser?.uid;

  @override
  Future<Result<TaskPage>> getTaskPage(TaskPageParams params) async {
    final userId = _currentUserId;
    if (userId == null) {
      return const ErrorResult(
        AuthenticationFailure(message: 'You must be signed in to view tasks.'),
      );
    }
    try {
      final isConnected = await _networkInfo.isConnected;
      if (isConnected && params.forceRemote) {
        try {
          final remotePage = await _remoteDataSource.getTaskPage(
            userId: userId,
            pageSize: params.pageSize,
            cursor: params.cursor,
          );
          final remoteModels = remotePage.tasks
              .map(TaskModel.fromEntity)
              .map((task) => task.copyModel(isSynced: true, isDeleted: false))
              .toList(growable: false);
          await _localDataSource.upsertTasks(remoteModels);
          return Success<TaskPage>(
            TaskPage(
              tasks: remoteModels,
              hasMore: remotePage.hasMore,
              nextCursor: remotePage.nextCursor,
            ),
          );
        } on ServerException {
          // If Firestore fails, fall back to Hive.
        }
      }
      final localPage = _localDataSource.getTaskPage(
        userId: userId,
        pageSize: params.pageSize,
        cursor: params.cursor,
      );
      return Success<TaskPage>(localPage);
    } on CacheException catch (exception) {
      return ErrorResult(CacheFailure(message: exception.message));
    } on ServerException catch (exception) {
      return ErrorResult(
        ServerFailure(message: exception.message, code: exception.code),
      );
    } catch (_) {
      return const ErrorResult(UnknownFailure());
    }
  }

  @override
  Future<Result<TaskEntity>> addTask(TaskEntity task) async {
    try {
      final localTask = TaskModel.fromEntity(
        task.copyWith(
          isSynced: false,
          isDeleted: false,
          updatedAt: DateTime.now(),
        ),
      );

      await _localDataSource.upsertTask(localTask);

      if (await _networkInfo.isConnected) {
        return _uploadAndMarkSynced(localTask);
      }

      return Success<TaskEntity>(localTask);
    } on CacheException catch (exception) {
      return ErrorResult(CacheFailure(message: exception.message));
    } catch (_) {
      return const ErrorResult(UnknownFailure());
    }
  }

  @override
  Future<Result<TaskEntity>> updateTask(TaskEntity task) async {
    try {
      final localTask = TaskModel.fromEntity(
        task.copyWith(isSynced: false, updatedAt: DateTime.now()),
      );

      await _localDataSource.upsertTask(localTask);

      if (await _networkInfo.isConnected) {
        return _uploadAndMarkSynced(localTask);
      }

      return Success<TaskEntity>(localTask);
    } on CacheException catch (exception) {
      return ErrorResult(CacheFailure(message: exception.message));
    } catch (_) {
      return const ErrorResult(UnknownFailure());
    }
  }

  @override
  Future<Result<TaskEntity>> toggleTaskStatus(TaskEntity task) {
    final newStatus = task.status == TaskStatus.pending
        ? TaskStatus.completed
        : TaskStatus.pending;

    return updateTask(task.copyWith(status: newStatus));
  }

  @override
  Future<Result<void>> deleteTask(TaskEntity task) async {
    try {
      final deletedTask = TaskModel.fromEntity(
        task.copyWith(
          isDeleted: true,
          isSynced: false,
          updatedAt: DateTime.now(),
        ),
      );

      // Hide immediately from UI while retaining a local tombstone.
      await _localDataSource.upsertTask(deletedTask);

      if (!await _networkInfo.isConnected) {
        return const Success<void>(null);
      }

      try {
        await _remoteDataSource.deleteTask(
          userId: deletedTask.userId,
          taskId: deletedTask.id,
        );

        await _localDataSource.hardDeleteTask(
          userId: deletedTask.userId,
          taskId: deletedTask.id,
        );

        return const Success<void>(null);
      } on ServerException {
        // Keep tombstone for the next synchronization attempt.
        return const Success<void>(null);
      }
    } on CacheException catch (exception) {
      return ErrorResult(CacheFailure(message: exception.message));
    } catch (_) {
      return const ErrorResult(UnknownFailure());
    }
  }

  @override
  Future<Result<void>> synchronizeTasks() async {
    final userId = _currentUserId;

    if (userId == null) {
      return const ErrorResult(
        AuthenticationFailure(
          message: 'You must be signed in to synchronize tasks.',
        ),
      );
    }

    if (!await _networkInfo.isConnected) {
      return const ErrorResult(
        NetworkFailure(
          message: 'Offline mode: cached tasks are still available.',
        ),
      );
    }

    try {
      final pendingTasks = _localDataSource.getPendingSyncTasks(userId);

      for (final task in pendingTasks) {
        if (task.isDeleted) {
          await _remoteDataSource.deleteTask(
            userId: task.userId,
            taskId: task.id,
          );

          await _localDataSource.hardDeleteTask(
            userId: task.userId,
            taskId: task.id,
          );

          continue;
        }

        await _remoteDataSource.setTask(task);

        await _localDataSource.upsertTask(task.copyModel(isSynced: true));
      }

      return const Success<void>(null);
    } on CacheException catch (exception) {
      return ErrorResult(CacheFailure(message: exception.message));
    } on ServerException catch (exception) {
      return ErrorResult(
        ServerFailure(message: exception.message, code: exception.code),
      );
    } catch (_) {
      return const ErrorResult(UnknownFailure());
    }
  }

  Future<Result<TaskEntity>> _uploadAndMarkSynced(TaskModel task) async {
    try {
      await _remoteDataSource.setTask(task);

      final syncedTask = task.copyModel(isSynced: true);

      await _localDataSource.upsertTask(syncedTask);

      return Success<TaskEntity>(syncedTask);
    } on ServerException {
      // Local save already succeeded, so keep the task pending.
      return Success<TaskEntity>(task);
    }
  }
}
