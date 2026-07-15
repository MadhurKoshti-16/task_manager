import 'package:equatable/equatable.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/task_filter.dart';
import '../../domain/entities/task_page_cursor.dart';

enum TaskViewStatus { initial, loading, success, failure }

class TaskState extends Equatable {
  const TaskState({
    this.status = TaskViewStatus.initial,
    this.allTasks = const [],
    this.visibleTasks = const [],
    this.statusFilter = TaskStatusFilter.all,
    this.dueDateFilter = TaskDueDateFilter.all,
    this.searchQuery = '',
    this.message,
    this.isSynchronizing = false,
    this.isOffline = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.nextCursor,
    this.selectedDueDate,
  });
  final TaskViewStatus status;
  final List<TaskEntity> allTasks;
  final List<TaskEntity> visibleTasks;
  final TaskStatusFilter statusFilter;
  final TaskDueDateFilter dueDateFilter;
  final String searchQuery;
  final String? message;
  final bool isSynchronizing;
  final bool isOffline;
  final bool isLoadingMore;
  final bool hasMore;
  final TaskPageCursor? nextCursor;
  final DateTime? selectedDueDate;
  int get totalCount => allTasks.length;
  int get pendingCount => allTasks.where((task) => task.isPending).length;
  int get completedCount => allTasks.where((task) => task.isCompleted).length;
  TaskState copyWith({
    TaskViewStatus? status,
    List<TaskEntity>? allTasks,
    List<TaskEntity>? visibleTasks,
    TaskStatusFilter? statusFilter,
    TaskDueDateFilter? dueDateFilter,
    String? searchQuery,
    String? message,
    bool clearMessage = false,
    bool? isSynchronizing,
    bool? isOffline,
    bool? isLoadingMore,
    bool? hasMore,
    TaskPageCursor? nextCursor,
    bool clearCursor = false,
    DateTime? selectedDueDate,
    bool clearSelectedDueDate = false,
  }) {
    return TaskState(
      status: status ?? this.status,
      allTasks: allTasks ?? this.allTasks,
      visibleTasks: visibleTasks ?? this.visibleTasks,
      statusFilter: statusFilter ?? this.statusFilter,
      dueDateFilter: dueDateFilter ?? this.dueDateFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      message: clearMessage ? null : message ?? this.message,
      isSynchronizing: isSynchronizing ?? this.isSynchronizing,
      isOffline: isOffline ?? this.isOffline,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      nextCursor: clearCursor ? null : nextCursor ?? this.nextCursor,
      selectedDueDate: clearSelectedDueDate
          ? null
          : selectedDueDate ?? this.selectedDueDate,
    );
  }

  @override
  List<Object?> get props => [
    status,
    allTasks,
    visibleTasks,
    statusFilter,
    dueDateFilter,
    searchQuery,
    message,
    isSynchronizing,
    isOffline,
    isLoadingMore,
    hasMore,
    nextCursor,
    selectedDueDate,
  ];
}
