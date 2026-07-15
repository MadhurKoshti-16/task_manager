import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager_bloc/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:task_manager_bloc/features/settings/presentation/cubit/theme_cubit.dart';

import 'config/routes/app_routes.dart';
import 'config/routes/route_generator.dart';
import 'config/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'core/di/injection_container.dart';
import 'features/tasks/presentation/bloc/task_bloc.dart';

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider<TaskBloc>(create: (_) => sl<TaskBloc>()),
        BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,

            // Theme configuration
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,

            // Navigation configuration
            initialRoute: AppRoutes.splash,
            onGenerateRoute: RouteGenerator.generateRoute,
          );
        },
      ),
    );
  }
}
