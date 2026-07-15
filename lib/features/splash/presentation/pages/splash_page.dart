import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager_bloc/core/constants/app_strings.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../config/theme/app_colors.dart';
import '../bloc/splash_bloc.dart';
import '../bloc/splash_event.dart';
import '../bloc/splash_state.dart';
import '../widgets/splash_background.dart';
import '../widgets/splash_content.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  late final Animation<double> _backgroundAnimation;
  late final Animation<double> _logoAnimation;
  late final Animation<double> _welcomeAnimation;
  late final Animation<double> _titleAnimation;
  late final Animation<double> _descriptionAnimation;
  late final Animation<double> _loadingAnimation;

  @override
  void initState() {
    super.initState();

    _initializeAnimations();

    _animationController.forward();

    context.read<SplashBloc>().add(const SplashStarted());
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    _backgroundAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _logoAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.05, 0.35, curve: Curves.easeOutBack),
    );

    _welcomeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.25, 0.48, curve: Curves.easeOutCubic),
    );

    _titleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.34, 0.60, curve: Curves.easeOutCubic),
    );

    _descriptionAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.48, 0.72, curve: Curves.easeOutCubic),
    );

    _loadingAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.66, 0.90, curve: Curves.easeOutCubic),
    );
  }

  void _handleState(BuildContext context, SplashState state) {
    switch (state) {
      case SplashAuthenticated():
        Navigator.pushReplacementNamed(context, AppRoutes.dashboard);

      case SplashUnauthenticated():
        Navigator.pushReplacementNamed(context, AppRoutes.login);

      case SplashFailure(:final message):
        _showError(context, message);

      case SplashInitial():
      case SplashLoading():
        break;
    }
  }

  void _showError(BuildContext context, String message) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.error_outline_rounded,
            color: AppColors.error,
            size: 42,
          ),
          title: const Text(AppStrings.startUpFailed),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                context.read<SplashBloc>().add(const SplashStarted());
              },
              child: const Text(AppStrings.tryAgain),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashBloc, SplashState>(
      listener: _handleState,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            SplashBackground(animation: _backgroundAnimation),
            SplashContent(
              logoAnimation: _logoAnimation,
              welcomeAnimation: _welcomeAnimation,
              titleAnimation: _titleAnimation,
              descriptionAnimation: _descriptionAnimation,
              loadingAnimation: _loadingAnimation,
            ),
          ],
        ),
      ),
    );
  }
}
