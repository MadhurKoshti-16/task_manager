import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/date_time_extensions.dart';
import '../../domain/entities/task_entity.dart';
import 'package:intl/intl.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    required this.task,
    required this.onEdit,
    required this.onDelete,
    required this.onStatusChanged,
    super.key,
  });
  final TaskEntity task;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onStatusChanged;
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isOverdue = task.dueDate.isOverdue && task.isPending;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.96, end: 1),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: task.isCompleted
                ? colorScheme.primary.withValues(alpha: 0.28)
                : colorScheme.outline.withValues(alpha: 0.7),
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.07),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: InkWell(
          onTap: onEdit,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: task.isCompleted,
                onChanged: (_) => onStatusChanged(),
              ),

              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 220),
                            style: textTheme.titleMedium!.copyWith(
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: task.isCompleted
                                  ? colorScheme.onSurfaceVariant
                                  : colorScheme.onSurface,
                            ),
                            child: Text(
                              task.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        if (!task.isSynced)
                          Tooltip(
                            message: AppStrings.taskCardSyncTooltip,
                            child: Icon(
                              Icons.cloud_off_outlined,
                              size: 18,
                              color: colorScheme.tertiary,
                            ),
                          ),
                      ],
                    ),
                    if (task.description.trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        task.description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium,
                      ),
                    ],
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(
                          side: BorderSide(
                            color: colorScheme.primary.withValues(alpha: 0.28),
                          ),
                          avatar: Icon(
                            task.isCompleted
                                ? Icons.check_circle_outline
                                : Icons.schedule,
                            size: 18,
                            color: task.isCompleted
                                ? colorScheme.primary
                                : isOverdue
                                ? colorScheme.error
                                : colorScheme.tertiary,
                          ),
                          label: Text(
                            task.isCompleted
                                ? AppStrings.taskFilterCompleted
                                : isOverdue
                                ? AppStrings.taskFilterOverdue
                                : AppStrings.taskFilterPending,
                            style: TextStyle(
                              color: task.isCompleted
                                  ? colorScheme.primary
                                  : isOverdue
                                  ? colorScheme.error
                                  : colorScheme.tertiary,
                            ),
                          ),
                        ),
                        Chip(
                          side: BorderSide(
                            color: colorScheme.primary.withValues(alpha: 0.28),
                          ),

                          avatar: Icon(
                            Icons.event_outlined,
                            size: 18,
                            color: task.isCompleted
                                ? colorScheme.primary
                                : isOverdue
                                ? colorScheme.error
                                : colorScheme.tertiary,
                          ),
                          label: Text(
                            DateFormat('dd MMM yyyy').format(task.dueDate),
                            style: TextStyle(
                              color: task.isCompleted
                                  ? colorScheme.primary
                                  : isOverdue
                                  ? colorScheme.error
                                  : colorScheme.tertiary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: AppStrings.taskCardActionsTooltip,
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      onEdit();
                    case 'delete':
                      onDelete();
                  }
                },
                itemBuilder: (_) {
                  return const [
                    PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.edit_outlined),
                        title: Text(AppStrings.taskCardEditAction),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.delete_outline),
                        title: Text(AppStrings.taskCardDeleteAction),
                      ),
                    ),
                  ];
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
