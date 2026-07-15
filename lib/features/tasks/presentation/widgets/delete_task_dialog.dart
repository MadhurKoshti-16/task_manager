import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';

Future<bool> showDeleteTaskDialog({
  required BuildContext context,
  required String taskTitle,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      final colorScheme = Theme.of(dialogContext).colorScheme;
      return AlertDialog(
        icon: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: colorScheme.errorContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.delete_outline_rounded,
            color: colorScheme.onErrorContainer,
          ),
        ),
        title: const Text(AppStrings.deleteTaskDialogTitle),
        content: Text(
          AppStrings.deleteTaskDialogMessage(taskTitle),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: const Text(AppStrings.deleteTaskDialogCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
            child: const Text(AppStrings.deleteTaskDialogDelete),
          ),
        ],
      );
    },
  );
  return result ?? false;
}
