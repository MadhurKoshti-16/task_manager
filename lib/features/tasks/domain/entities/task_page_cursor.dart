import 'package:equatable/equatable.dart';

class TaskPageCursor extends Equatable {
  const TaskPageCursor({required this.dueDate, required this.taskId});
  final DateTime dueDate;
  final String taskId;
  @override
  List<Object?> get props => [dueDate, taskId];
}
