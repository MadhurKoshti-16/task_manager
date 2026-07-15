import 'package:equatable/equatable.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/task_filter.dart';

sealed class TaskEvent extends Equatable {
  const TaskEvent();
  @override
  List<Object?> get props => [];
}

final class TaskStarted extends TaskEvent {
  const TaskStarted();
}

final class TaskRefreshRequested extends TaskEvent {
  const TaskRefreshRequested();
}

final class TaskSearchChanged extends TaskEvent {
  const TaskSearchChanged(this.query);
  final String query;
  @override
  List<Object?> get props => [query];
}

final class TaskStatusFilterChanged extends TaskEvent {
  const TaskStatusFilterChanged(this.filter);
  final TaskStatusFilter filter;
  @override
  List<Object?> get props => [filter];
}

final class TaskDueDateFilterChanged extends TaskEvent {
  const TaskDueDateFilterChanged(this.filter);
  final TaskDueDateFilter filter;
  @override
  List<Object?> get props => [filter];
}

final class TaskAddRequested extends TaskEvent {
  const TaskAddRequested(this.task);
  final TaskEntity task;
  @override
  List<Object?> get props => [task];
}

final class TaskUpdateRequested extends TaskEvent {
  const TaskUpdateRequested(this.task);
  final TaskEntity task;
  @override
  List<Object?> get props => [task];
}

final class TaskStatusToggleRequested extends TaskEvent {
  const TaskStatusToggleRequested(this.task);
  final TaskEntity task;
  @override
  List<Object?> get props => [task];
}

final class TaskDeleteRequested extends TaskEvent {
  const TaskDeleteRequested(this.task);
  final TaskEntity task;
  @override
  List<Object?> get props => [task];
}

final class TaskMessageCleared extends TaskEvent {
  const TaskMessageCleared();
}

final class TaskLoadMoreRequested extends TaskEvent {
  const TaskLoadMoreRequested();
}

final class TaskDueDateSelected extends TaskEvent {
  const TaskDueDateSelected(this.date);
  final DateTime date;
  @override
  List<Object?> get props => [date];
}

final class TaskDueDateCleared extends TaskEvent {
  const TaskDueDateCleared();
}
