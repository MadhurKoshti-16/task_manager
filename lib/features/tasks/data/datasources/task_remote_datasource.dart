import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_manager_bloc/features/tasks/domain/entities/task_page.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/task_page_cursor.dart';
import '../models/task_model.dart';

abstract interface class TaskRemoteDataSource {
  Future<TaskPage> getTaskPage({
    required String userId,
    required int pageSize,
    TaskPageCursor? cursor,
  });

  Future<void> setTask(TaskModel task);

  Future<void> deleteTask({required String userId, required String taskId});
}

final class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  const TaskRemoteDataSourceImpl(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _taskCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('tasks');
  }

  @override
  Future<TaskPage> getTaskPage({
    required String userId,
    required int pageSize,
    TaskPageCursor? cursor,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _taskCollection(
        userId,
      ).orderBy('dueDate').orderBy(FieldPath.documentId);
      if (cursor != null) {
        query = query.startAfter([
          Timestamp.fromDate(cursor.dueDate),
          cursor.taskId,
        ]);
      }
      // Request one extra document to determine whether // another page exists.
      final snapshot = await query.limit(pageSize + 1).get();
      final hasMore = snapshot.docs.length > pageSize;
      final pageDocuments = hasMore
          ? snapshot.docs.take(pageSize)
          : snapshot.docs;
      final tasks = pageDocuments
          .map(TaskModel.fromFirestore)
          .toList(growable: false);
      final lastTask = tasks.isEmpty ? null : tasks.last;
      return TaskPage(
        tasks: tasks,
        hasMore: hasMore,
        nextCursor: lastTask == null
            ? null
            : TaskPageCursor(dueDate: lastTask.dueDate, taskId: lastTask.id),
      );
    } on FirebaseException catch (exception) {
      throw ServerException(
        code: exception.code,
        message: exception.message ?? 'Unable to load the next task page.',
      );
    } catch (error) {
      throw ServerException(
        message: 'Unable to load the next task page: $error',
      );
    }
  }

  @override
  Future<void> setTask(TaskModel task) async {
    try {
      await _taskCollection(
        task.userId,
      ).doc(task.id).set(task.toFirestoreMap(), SetOptions(merge: true));
    } on FirebaseException catch (exception) {
      throw ServerException(
        code: exception.code,
        message: exception.message ?? 'Unable to upload task.',
      );
    } catch (error) {
      throw ServerException(message: 'Unable to upload task: $error');
    }
  }

  @override
  Future<void> deleteTask({
    required String userId,
    required String taskId,
  }) async {
    try {
      await _taskCollection(userId).doc(taskId).delete();
    } on FirebaseException catch (exception) {
      throw ServerException(
        code: exception.code,
        message: exception.message ?? 'Unable to delete task.',
      );
    } catch (error) {
      throw ServerException(message: 'Unable to delete task: $error');
    }
  }
}
