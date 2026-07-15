import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/result/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/bloc_event_transformers.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/task_filter.dart';
import '../../domain/entities/task_page.dart';
import '../../domain/entities/task_page_params.dart';
import '../../domain/usecases/add_task.dart';
import '../../domain/usecases/delete_task.dart';
import '../../domain/usecases/get_task_page.dart';
import '../../domain/usecases/sync_tasks.dart';
import '../../domain/usecases/toggle_task_status.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import '../../domain/usecases/update_task.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  TaskBloc({
    required this._getTaskPage,
    required this._syncTasks,
    required this._addTask,
    required this._updateTask,
    required this._toggleTaskStatus,
    required this._deleteTask,
  }) : super(const TaskState()) {
    on<TaskStarted>(_onStarted, transformer: droppable());
    on<TaskRefreshRequested>(_onRefreshRequested, transformer: droppable());
    on<TaskLoadMoreRequested>(_onLoadMoreRequested, transformer: droppable());
    on<TaskSearchChanged>(_onSearchChanged, transformer: debounceRestartable());
    on<TaskStatusFilterChanged>(_onStatusFilterChanged);
    on<TaskDueDateFilterChanged>(_onDueDateFilterChanged);
    on<TaskAddRequested>(_onAddRequested);
    on<TaskUpdateRequested>(_onUpdateRequested);
    on<TaskStatusToggleRequested>(_onStatusToggleRequested);
    on<TaskDeleteRequested>(_onDeleteRequested);
    on<TaskMessageCleared>(_onMessageCleared);
    on<TaskDueDateSelected>(_onDueDateSelected);
    on<TaskDueDateCleared>(_onDueDateCleared);
  }
  static const int _pageSize = 10;
  final GetTaskPage _getTaskPage;
  final SyncTasks _syncTasks;
  final AddTask _addTask;
  final UpdateTask _updateTask;
  final ToggleTaskStatus _toggleTaskStatus;
  final DeleteTask _deleteTask;

  Future<void> _onStarted(TaskStarted event, Emitter<TaskState> emit) async {
    emit(
      state.copyWith(
        status: TaskViewStatus.loading,
        allTasks: const [],
        visibleTasks: const [],
        hasMore: true,
        clearCursor: true,
        clearMessage: true,
        isOffline: false,
        isSynchronizing: false,
      ),
    );
    // First upload any pending offline changes.
    final syncResult = await _syncTasks(const NoParams());
    switch (syncResult) {
      case Success<void>():
        // Internet is available. // Load the first page directly from Firebase.
        await _loadRemoteFirstPage(emit);
      case ErrorResult<void>(:final failure):
        // Network or synchronization failed. // Fall back to Hive cache.
        await _loadCachedFirstPage(emit, fallbackMessage: failure.message);
    }
  }

  Future<void> _loadRemoteFirstPage(Emitter<TaskState> emit) async {
    final result = await _getTaskPage(
      const TaskPageParams(pageSize: _pageSize, forceRemote: true),
    );

    switch (result) {
      case Success<TaskPage>(:final data):
        emit(
          _applyFilters(
            state.copyWith(
              status: TaskViewStatus.success,
              allTasks: _deduplicateTasks(data.tasks),
              hasMore: data.hasMore,
              nextCursor: data.nextCursor,
              clearCursor: data.nextCursor == null,
              isOffline: false,
              isSynchronizing: false,
              clearMessage: true,
            ),
          ),
        );

      case ErrorResult<TaskPage>(:final failure):
        // Firebase failed even after sync succeeded.
        // Try Hive as a fallback.
        await _loadCachedFirstPage(emit, fallbackMessage: failure.message);
    }
  }

  Future<void> _loadCachedFirstPage(
    Emitter<TaskState> emit, {
    required String fallbackMessage,
  }) async {
    final result = await _getTaskPage(
      const TaskPageParams(pageSize: _pageSize, forceRemote: false),
    );

    switch (result) {
      case Success<TaskPage>(:final data):
        final hasCachedTasks = data.tasks.isNotEmpty;

        emit(
          _applyFilters(
            state.copyWith(
              status: hasCachedTasks
                  ? TaskViewStatus.success
                  : TaskViewStatus.failure,
              allTasks: _deduplicateTasks(data.tasks),
              hasMore: data.hasMore,
              nextCursor: data.nextCursor,
              clearCursor: data.nextCursor == null,
              isOffline: true,
              isSynchronizing: false,
              message: hasCachedTasks
                  ? 'Unable to connect. Showing cached tasks.'
                  : fallbackMessage,
            ),
          ),
        );

      case ErrorResult<TaskPage>(:final failure):
        emit(
          state.copyWith(
            status: TaskViewStatus.failure,
            isOffline: true,
            isSynchronizing: false,
            message: failure.message,
          ),
        );
    }
  }

  Future<void> _onRefreshRequested(
    TaskRefreshRequested event,
    Emitter<TaskState> emit,
  ) async {
    emit(state.copyWith(isSynchronizing: true, clearMessage: true));
    final syncResult = await _syncTasks(const NoParams());
    switch (syncResult) {
      case Success<void>():
        await _loadRemoteFirstPage(emit);
        emit(state.copyWith(isSynchronizing: false, isOffline: false));
      case ErrorResult<void>(:final failure):
        await _loadRemoteFirstPage(emit);
        emit(
          state.copyWith(
            isSynchronizing: false,
            isOffline: true,
            message: failure.message,
          ),
        );
    }
  }

  Future<void> _onLoadMoreRequested(
    TaskLoadMoreRequested event,
    Emitter<TaskState> emit,
  ) async {
    if (state.isLoadingMore ||
        !state.hasMore ||
        state.nextCursor == null ||
        state.status == TaskViewStatus.loading) {
      return;
    }
    emit(state.copyWith(isLoadingMore: true, clearMessage: true));
    final result = await _getTaskPage(
      TaskPageParams(
        cursor: state.nextCursor,
        pageSize: _pageSize,
        forceRemote: !state.isOffline,
      ),
    );
    switch (result) {
      case Success<TaskPage>(:final data):
        final combinedTasks = _deduplicateTasks([
          ...state.allTasks,
          ...data.tasks,
        ]);
        emit(
          _applyFilters(
            state.copyWith(
              allTasks: combinedTasks,
              isLoadingMore: false,
              hasMore: data.hasMore,
              nextCursor: data.nextCursor,
              clearCursor: data.nextCursor == null,
            ),
          ),
        );
      case ErrorResult<TaskPage>(:final failure):
        emit(state.copyWith(isLoadingMore: false, message: failure.message));
    }
  }

  List<TaskEntity> _deduplicateTasks(Iterable<TaskEntity> tasks) {
    final tasksById = <String, TaskEntity>{};
    for (final task in tasks) {
      final existingTask = tasksById[task.id];
      if (existingTask == null ||
          task.updatedAt.isAfter(existingTask.updatedAt)) {
        tasksById[task.id] = task;
      }
    }
    return _sortTasks(tasksById.values);
  }

  void _onSearchChanged(TaskSearchChanged event, Emitter<TaskState> emit) {
    emit(
      _applyFilters(
        state.copyWith(
          searchQuery: event.query.trim().toLowerCase(),
          clearMessage: true,
        ),
      ),
    );
  }

  void _onStatusFilterChanged(
    TaskStatusFilterChanged event,
    Emitter<TaskState> emit,
  ) {
    emit(
      _applyFilters(
        state.copyWith(statusFilter: event.filter, clearMessage: true),
      ),
    );
  }

  void _onDueDateFilterChanged(
    TaskDueDateFilterChanged event,
    Emitter<TaskState> emit,
  ) {
    emit(
      _applyFilters(
        state.copyWith(dueDateFilter: event.filter, clearMessage: true),
      ),
    );
  }

  Future<void> _onAddRequested(
    TaskAddRequested event,
    Emitter<TaskState> emit,
  ) async {
    final result = await _addTask(event.task);
    switch (result) {
      case Success<TaskEntity>(:final data):
        final tasks = [
          ...state.allTasks.where((task) => task.id != data.id),
          data,
        ];
        emit(
          _applyFilters(
            state.copyWith(
              status: TaskViewStatus.success,
              allTasks: _sortTasks(tasks),
              message: data.isSynced
                  ? 'Task added successfully.'
                  : 'Task saved offline and will sync later.',
            ),
          ),
        );
      case ErrorResult<TaskEntity>(:final failure):
        emit(state.copyWith(message: failure.message));
    }
  }

  Future<void> _onUpdateRequested(
    TaskUpdateRequested event,
    Emitter<TaskState> emit,
  ) async {
    final result = await _updateTask(event.task);
    switch (result) {
      case Success<TaskEntity>(:final data):
        final tasks = state.allTasks
            .map((task) {
              return task.id == data.id ? data : task;
            })
            .toList(growable: false);
        emit(
          _applyFilters(
            state.copyWith(
              allTasks: _sortTasks(tasks),
              message: data.isSynced
                  ? 'Task updated successfully.'
                  : 'Task updated offline and will sync later.',
            ),
          ),
        );
      case ErrorResult<TaskEntity>(:final failure):
        emit(state.copyWith(message: failure.message));
    }
  }

  Future<void> _onStatusToggleRequested(
    TaskStatusToggleRequested event,
    Emitter<TaskState> emit,
  ) async {
    final result = await _toggleTaskStatus(event.task);
    switch (result) {
      case Success<TaskEntity>(:final data):
        final tasks = state.allTasks
            .map((task) {
              return task.id == data.id ? data : task;
            })
            .toList(growable: false);
        emit(
          _applyFilters(
            state.copyWith(
              allTasks: _sortTasks(tasks),
              message: data.isCompleted
                  ? 'Task marked as completed.'
                  : 'Task moved back to pending.',
            ),
          ),
        );
      case ErrorResult<TaskEntity>(:final failure):
        emit(state.copyWith(message: failure.message));
    }
  }

  Future<void> _onDeleteRequested(
    TaskDeleteRequested event,
    Emitter<TaskState> emit,
  ) async {
    final result = await _deleteTask(event.task);
    switch (result) {
      case Success<void>():
        final tasks = state.allTasks
            .where((task) => task.id != event.task.id)
            .toList(growable: false);
        emit(
          _applyFilters(
            state.copyWith(
              allTasks: tasks,
              message: 'Task deleted successfully.',
            ),
          ),
        );
      case ErrorResult<void>(:final failure):
        emit(state.copyWith(message: failure.message));
    }
  }

  void _onMessageCleared(TaskMessageCleared event, Emitter<TaskState> emit) {
    emit(state.copyWith(clearMessage: true));
  }

  TaskState _applyFilters(TaskState currentState) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final filteredTasks = currentState.allTasks
        .where((task) {
          final normalizedDueDate = DateTime(
            task.dueDate.year,
            task.dueDate.month,
            task.dueDate.day,
          );
          final matchesSearch =
              currentState.searchQuery.isEmpty ||
              task.title.toLowerCase().contains(currentState.searchQuery);
          final matchesStatus = switch (currentState.statusFilter) {
            TaskStatusFilter.all => true,
            TaskStatusFilter.pending => task.isPending,
            TaskStatusFilter.completed => task.isCompleted,
          };
          final matchesDueDate = switch (currentState.dueDateFilter) {
            TaskDueDateFilter.all => true,
            TaskDueDateFilter.today => normalizedDueDate.isAtSameMomentAs(
              today,
            ),
            TaskDueDateFilter.upcoming => normalizedDueDate.isAfter(today),
            TaskDueDateFilter.overdue =>
              normalizedDueDate.isBefore(today) && task.isPending,
          };
          final selectedDueDate = currentState.selectedDueDate;
          final matchesSelectedDate =
              selectedDueDate == null ||
              normalizedDueDate.isAtSameMomentAs(
                DateTime(
                  selectedDueDate.year,
                  selectedDueDate.month,
                  selectedDueDate.day,
                ),
              );
          return matchesSearch &&
              matchesStatus &&
              matchesDueDate &&
              matchesSelectedDate;
        })
        .toList(growable: false);
    return currentState.copyWith(visibleTasks: _sortTasks(filteredTasks));
  }

  List<TaskEntity> _sortTasks(Iterable<TaskEntity> tasks) {
    final sorted = tasks.toList();
    sorted.sort((first, second) {
      final dateComparison = first.dueDate.compareTo(second.dueDate);
      if (dateComparison != 0) {
        return dateComparison;
      }
      return first.id.compareTo(second.id);
    });
    return sorted;
  }

  void _onDueDateSelected(TaskDueDateSelected event, Emitter<TaskState> emit) {
    final normalizedDate = DateTime(
      event.date.year,
      event.date.month,
      event.date.day,
    );
    emit(
      _applyFilters(
        state.copyWith(
          selectedDueDate: normalizedDate,
          dueDateFilter: TaskDueDateFilter.all,
          clearMessage: true,
        ),
      ),
    );
  }

  void _onDueDateCleared(TaskDueDateCleared event, Emitter<TaskState> emit) {
    emit(
      _applyFilters(
        state.copyWith(clearSelectedDueDate: true, clearMessage: true),
      ),
    );
  }
}
