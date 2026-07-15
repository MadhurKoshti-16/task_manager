import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';

class TaskSearchField extends StatelessWidget {
  const TaskSearchField({
    required this.controller,
    required this.onChanged,
    super.key,
  });
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: AppStrings.taskSearchHint,
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) {
            if (value.text.isEmpty) {
              return const SizedBox.shrink();
            }
            return IconButton(
              tooltip: AppStrings.taskSearchClearTooltip,
              onPressed: () {
                controller.clear();
                onChanged('');
              },
              icon: const Icon(Icons.close_rounded),
            );
          },
        ),
        filled: true,
        fillColor: colorScheme.surface,
      ),
    );
  }
}
