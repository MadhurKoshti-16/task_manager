import 'dart:math' as math;
import 'package:flutter/material.dart';

class AuthAnimatedBackground extends StatelessWidget {
  const AuthAnimatedBackground({required this.animation, super.key});
  final Animation<double> animation;
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return CustomPaint(
          painter: _AuthBackgroundPainter(
            progress: animation.value,
            primary: colorScheme.primary,
            secondary: colorScheme.secondary,
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _AuthBackgroundPainter extends CustomPainter {
  const _AuthBackgroundPainter({
    required this.progress,
    required this.primary,
    required this.secondary,
  });
  final double progress;
  final Color primary;
  final Color secondary;
  @override
  void paint(Canvas canvas, Size size) {
    final firstCenter = Offset(
      size.width * 0.10 + math.sin(progress * math.pi * 2) * 16,
      size.height * 0.12,
    );
    final secondCenter = Offset(
      size.width * 0.92,
      size.height * 0.42 + math.cos(progress * math.pi * 2) * 20,
    );
    final firstPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              primary.withValues(alpha: 0.18),
              primary.withValues(alpha: 0),
            ],
          ).createShader(
            Rect.fromCircle(center: firstCenter, radius: size.width * 0.55),
          );
    final secondPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              secondary.withValues(alpha: 0.12),
              secondary.withValues(alpha: 0),
            ],
          ).createShader(
            Rect.fromCircle(center: secondCenter, radius: size.width * 0.52),
          );
    canvas.drawCircle(firstCenter, size.width * 0.55, firstPaint);
    canvas.drawCircle(secondCenter, size.width * 0.52, secondPaint);
  }

  @override
  bool shouldRepaint(covariant _AuthBackgroundPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.primary != primary ||
        oldDelegate.secondary != secondary;
  }
}
