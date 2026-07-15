import 'package:equatable/equatable.dart';

abstract final class TaskStatus {
  TaskStatus._();

  static const int pending = 0;
  static const int completed = 1;
}

class TaskEntity extends Equatable {
  const TaskEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = true,
    this.isDeleted = false,
  });

  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime dueDate;

  /// 0 = pending, 1 = completed.
  final int status;

  final DateTime createdAt;
  final DateTime updatedAt;

  /// False means that the local change still needs to be uploaded.
  final bool isSynced;

  /// Offline deletion tombstone.
  ///
  /// Deleted tasks are hidden from the UI but retained locally until
  /// Firestore deletion succeeds.
  final bool isDeleted;

  bool get isCompleted => status == TaskStatus.completed;

  bool get isPending => status == TaskStatus.pending;

  TaskEntity copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? dueDate,
    int? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    bool? isDeleted,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    title,
    description,
    dueDate,
    status,
    createdAt,
    updatedAt,
    isSynced,
    isDeleted,
  ];
}
