import 'package:equatable/equatable.dart';
import 'task_entity.dart';
import 'task_page_cursor.dart';

class TaskPage extends Equatable {
  const TaskPage({required this.tasks, required this.hasMore, this.nextCursor});
  final List<TaskEntity> tasks;
  final bool hasMore;
  final TaskPageCursor? nextCursor;
  @override
  List<Object?> get props => [tasks, hasMore, nextCursor];
}
