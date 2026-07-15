import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager_bloc/features/tasks/presentation/pages/add_edit_task_page.dart';

void main() {
  testWidgets('renders add task page without Material assertion', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AddEditTaskPage()));

    expect(find.text('Add Task'), findsOneWidget);
  });
}
