import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import 'animated_task_logo.dart';

class SplashContent extends StatelessWidget {
  const SplashContent({
    required this.logoAnimation,
    required this.welcomeAnimation,
    required this.titleAnimation,
    required this.descriptionAnimation,
    required this.loadingAnimation,
    super.key,
  });

  final Animation<double> logoAnimation;
  final Animation<double> welcomeAnimation;
  final Animation<double> titleAnimation;
  final Animation<double> descriptionAnimation;
  final Animation<double> loadingAnimation;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const Spacer(flex: 3),

            AnimatedTaskLogo(animation: logoAnimation),

            const SizedBox(height: 42),

            _AnimatedSlideFade(
              animation: welcomeAnimation,
              beginOffset: const Offset(0, 0.35),
              child: Text(
                AppStrings.splashWelcome,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.white.withValues(alpha: 0.82),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 8),

            _AnimatedSlideFade(
              animation: titleAnimation,
              beginOffset: const Offset(0, 0.45),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  AppStrings.splashTitle,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 42,
                    height: 1.1,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.2,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            _AnimatedSlideFade(
              animation: descriptionAnimation,
              beginOffset: const Offset(0, 0.35),
              child: Text(
                AppStrings.splashDescription,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.white.withValues(alpha: 0.74),
                  fontSize: 15,
                  height: 1.6,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

            const Spacer(flex: 3),

            _AnimatedSlideFade(
              animation: loadingAnimation,
              beginOffset: const Offset(0, 0.3),
              child: const _SplashLoadingIndicator(),
            ),

            const SizedBox(height: 42),
          ],
        ),
      ),
    );
  }
}

class _AnimatedSlideFade extends StatelessWidget {
  const _AnimatedSlideFade({
    required this.animation,
    required this.beginOffset,
    required this.child,
  });

  final Animation<double> animation;
  final Offset beginOffset;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: beginOffset,
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }
}

class _SplashLoadingIndicator extends StatelessWidget {
  const _SplashLoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2.4,
            color: AppColors.white,
            backgroundColor: AppColors.white.withValues(alpha: 0.18),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          AppStrings.loading,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.white.withValues(alpha: 0.66),
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}
