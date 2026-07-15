import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../config/theme/app_colors.dart';

class AnimatedTaskLogo extends StatelessWidget {
  const AnimatedTaskLogo({required this.animation, super.key});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final curvedProgress = Curves.elasticOut.transform(
          animation.value.clamp(0, 1),
        );

        return Transform.rotate(
          angle: math.sin(animation.value * math.pi) * 0.05,
          child: Transform.scale(
            scale: curvedProgress,
            child: Opacity(opacity: animation.value.clamp(0, 1), child: child),
          ),
        );
      },
      child: Container(
        width: 100,
        height: 100,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.16),
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.white.withValues(alpha: 0.38),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 32,
              offset: const Offset(0, 18),
            ),
            BoxShadow(
              color: AppColors.white.withValues(alpha: 0.12),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.task_alt_rounded,
            color: AppColors.primary,
            size: 52,
          ),
        ),
      ),
    );
  }
}
