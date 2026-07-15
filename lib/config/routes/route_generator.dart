import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager_bloc/core/constants/app_strings.dart';
import 'package:task_manager_bloc/features/authentication/presentation/pages/login_page.dart';
import 'package:task_manager_bloc/features/authentication/presentation/pages/register_page.dart';

import '../../core/di/injection_container.dart';
import '../../core/constants/app_duration.dart';
import '../../features/splash/presentation/bloc/splash_bloc.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/tasks/presentation/pages/task_dashboard_page.dart';
import 'app_routes.dart';

abstract final class RouteGenerator {
  RouteGenerator._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _buildRoute(
          settings: settings,
          builder: (_) {
            return BlocProvider<SplashBloc>(
              create: (_) => sl<SplashBloc>(),
              child: const SplashPage(),
            );
          },
        );

      case AppRoutes.login:
        return _buildRoute(
          settings: settings,
          builder: (_) => const LoginPage(),
        );

      case AppRoutes.register:
        return _buildRoute(
          settings: settings,
          builder: (_) => const RegisterPage(),
        );

      case AppRoutes.dashboard:
        return _buildRoute(
          settings: settings,
          builder: (_) => const TaskDashboardPage(),
        );

      default:
        return _buildRoute(
          settings: settings,
          builder: (_) => const _RouteNotFoundPage(),
        );
    }
  }

  static PageRouteBuilder<dynamic> _buildRoute({
    required RouteSettings settings,
    required WidgetBuilder builder,
  }) {
    return PageRouteBuilder<dynamic>(
      settings: settings,
      transitionDuration: AppDurations.pageTransitionDuration,
      reverseTransitionDuration: AppDurations.reversePageTransitionDuration,
      pageBuilder: (context, animation, secondaryAnimation) {
        return builder(context);
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fadeAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        );

        final slideAnimation =
            Tween<Offset>(
              begin: const Offset(0.04, 0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            );

        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(position: slideAnimation, child: child),
        );
      },
    );
  }
}

class _RouteNotFoundPage extends StatelessWidget {
  const _RouteNotFoundPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.pageNotFound)),
      body: const Center(child: Text(AppStrings.pageNotExist)),
    );
  }
}
