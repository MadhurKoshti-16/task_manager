import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';

class TaskEmptyView extends StatelessWidget {
  const TaskEmptyView({required this.hasFilters, super.key});
  final bool hasFilters;
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 50),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasFilters ? Icons.search_off_rounded : Icons.task_alt_rounded,
                size: 44,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              hasFilters
                  ? AppStrings.taskEmptyNoMatching
                  : AppStrings.taskEmptyNoTasks,
              style: textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Text(
              hasFilters
                  ? AppStrings.taskEmptyNoMatchingHelp
                  : AppStrings.taskEmptyNoTasksHelp,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
