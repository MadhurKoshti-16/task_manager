import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:task_manager_bloc/features/settings/presentation/cubit/theme_cubit.dart';
import 'package:task_manager_bloc/features/tasks/presentation/bloc/task_bloc.dart';
import 'package:task_manager_bloc/features/tasks/presentation/bloc/task_event.dart';
import 'package:task_manager_bloc/features/tasks/presentation/bloc/task_state.dart';
import 'package:task_manager_bloc/features/tasks/presentation/pages/task_dashboard_page.dart';

class MockTaskBloc extends MockBloc<TaskEvent, TaskState> implements TaskBloc {}

void main() {
  late MockTaskBloc bloc;

  setUpAll(() {
    registerFallbackValue(const TaskStarted());
  });

  setUp(() {
    bloc = MockTaskBloc();
    const initialState = TaskState(
      status: TaskViewStatus.success,
      allTasks: [],
      visibleTasks: [],
      isLoadingMore: true,
    );

    when(() => bloc.state).thenReturn(initialState);
    whenListen(
      bloc,
      Stream<TaskState>.fromIterable([initialState]),
      initialState: initialState,
    );
    when(() => bloc.add(any())).thenAnswer((_) {});
  });

  testWidgets('does not show a pagination loader for an empty task list', (
    tester,
  ) async {
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<TaskBloc>.value(value: bloc),
          BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
        ],
        child: const MaterialApp(home: TaskDashboardPage()),
      ),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
