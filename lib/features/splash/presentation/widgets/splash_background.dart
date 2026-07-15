import 'package:flutter/material.dart';
import '../../../../config/theme/app_colors.dart';

class SplashBackground extends StatelessWidget {
  const SplashBackground({required this.animation, super.key});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final progress = animation.value;

        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1.0 + (progress * 2.0), -1.0),
              end: Alignment(1.0 + (progress * 2.0), 1.0),
              colors: const [
                AppColors.splashGradientStart,
                AppColors.splashGradientMiddle,
                AppColors.splashGradientEnd,
                AppColors.splashGradientStart,
              ],
              stops: const [0.0, 0.35, 0.70, 1.0],
            ),
          ),
          child: child,
        );
      },
      child: const SizedBox.expand(),
    );
  }
}
