import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/task_filter.dart';

class TaskFilterBar extends StatelessWidget {
  const TaskFilterBar({
    required this.statusFilter,
    required this.dueDateFilter,
    required this.onStatusChanged,
    required this.onDueDateChanged,
    required this.selectedDueDate,
    required this.onDateSelected,
    required this.onDateCleared,
    super.key,
  });
  final TaskStatusFilter statusFilter;
  final TaskDueDateFilter dueDateFilter;
  final ValueChanged<TaskStatusFilter> onStatusChanged;
  final ValueChanged<TaskDueDateFilter> onDueDateChanged;
  final DateTime? selectedDueDate;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback onDateCleared;

  Future<void> _openDatePicker(BuildContext context) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: selectedDueDate ?? today,
      firstDate: today,
      lastDate: DateTime(now.year + 10, now.month, now.day),
    );
    if (selectedDate != null) {
      onDateSelected(selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ...TaskStatusFilter.values.map((filter) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    selected: statusFilter == filter,
                    label: Text(_statusLabel(filter)),
                    onSelected: (_) => onStatusChanged(filter),
                  ),
                );
              }),
              FilterChip(
                onSelected: (value) => _openDatePicker(context),
                onDeleted: onDateCleared,

                label: Text(
                  selectedDueDate == null
                      ? AppStrings.taskDueDateLabel
                      : MaterialLocalizations.of(
                          context,
                        ).formatShortDate(selectedDueDate!),
                ),
                avatar: const Icon(Icons.calendar_month_outlined),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  String _statusLabel(TaskStatusFilter filter) {
    return switch (filter) {
      TaskStatusFilter.all => AppStrings.taskFilterAll,
      TaskStatusFilter.pending => AppStrings.taskFilterPending,
      TaskStatusFilter.completed => AppStrings.taskFilterCompleted,
    };
  }
}
