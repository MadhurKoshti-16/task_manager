import 'package:flutter/material.dart';

abstract final class AppColors {
  AppColors._();

  // // Brand colors
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF4D46D8);
  static const Color secondary = Color(0xFF00C2A8);
  static const Color accent = Color(0xFFFFB84D);

  // // Light theme colors
  static const Color lightBackground = Color(0xFFF7F7FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF0F0F8);
  static const Color lightTextPrimary = Color(0xFF1A1A2E);
  static const Color lightTextSecondary = Color(0xFF6B6B80);
  static const Color lightBorder = Color(0xFFE7E7F0);

  // // Dark theme colors
  static const Color darkBackground = Color(0xFF11111B);
  static const Color darkSurface = Color(0xFF1B1B29);
  static const Color darkSurfaceVariant = Color(0xFF252538);
  static const Color darkTextPrimary = Color(0xFFF8F8FC);
  static const Color darkTextSecondary = Color(0xFFB4B4C7);
  static const Color darkBorder = Color(0xFF343449);

  // // State colors
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // // Splash gradient
  static const Color splashGradientStart = Color(0xFF7165FF);
  static const Color splashGradientMiddle = Color(0xFF5147E5);
  static const Color splashGradientEnd = Color(0xFF27215C);

  static const Color white = Color(0xFFFFFFFF);
  static const Color transparent = Colors.transparent;
}
