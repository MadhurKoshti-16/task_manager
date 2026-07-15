import 'package:flutter/material.dart';
import 'package:task_manager_bloc/core/constants/app_strings.dart';

Future<bool> showLogoutConfirmationDialog({
  required BuildContext context,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      final colorScheme = Theme.of(dialogContext).colorScheme;
      return AlertDialog(
        icon: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: colorScheme.errorContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.logout_rounded,
            color: colorScheme.onErrorContainer,
            size: 30,
          ),
        ),
        title: const Text(AppStrings.logout, textAlign: TextAlign.center),
        content: const Text(
          AppStrings.logoutContent,
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: const Text(AppStrings.cancel),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: Text(AppStrings.logout),
          ),
        ],
      );
    },
  );
  return result ?? false;
}
