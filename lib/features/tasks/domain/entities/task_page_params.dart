import 'package:equatable/equatable.dart';
import 'task_page_cursor.dart';

class TaskPageParams extends Equatable {
  const TaskPageParams({
    this.cursor,
    this.pageSize = 15,
    this.forceRemote = false,
  });
  final TaskPageCursor? cursor;
  final int pageSize;

  /// When true, the repository tries Firestore first.
  final bool forceRemote;
  @override
  List<Object?> get props => [cursor, pageSize, forceRemote];
}
