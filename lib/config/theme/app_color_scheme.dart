import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppColorScheme {
  AppColorScheme._();

  static const ColorScheme light = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.white,
    primaryContainer: Color(0xFFE6E3FF),
    onPrimaryContainer: Color(0xFF211A72),
    secondary: AppColors.secondary,
    onSecondary: AppColors.white,
    secondaryContainer: Color(0xFFC4F5EC),
    onSecondaryContainer: Color(0xFF00382F),
    tertiary: AppColors.accent,
    onTertiary: Color(0xFF402D00),
    error: AppColors.error,
    onError: AppColors.white,
    surface: AppColors.lightSurface,
    onSurface: AppColors.lightTextPrimary,
    surfaceContainerHighest: AppColors.lightSurfaceVariant,
    outline: AppColors.lightBorder,
    shadow: Color(0x1A000000),
    inverseSurface: AppColors.darkSurface,
    onInverseSurface: AppColors.darkTextPrimary,
    inversePrimary: Color(0xFFC5C0FF),
  );

  static const ColorScheme dark = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFB8B2FF),
    onPrimary: Color(0xFF211A72),
    primaryContainer: AppColors.primaryDark,
    onPrimaryContainer: Color(0xFFE5E1FF),
    secondary: Color(0xFF66DDCA),
    onSecondary: Color(0xFF00382F),
    secondaryContainer: Color(0xFF005047),
    onSecondaryContainer: Color(0xFF86F9E5),
    tertiary: Color(0xFFFFCA72),
    onTertiary: Color(0xFF432F00),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    surface: AppColors.darkSurface,
    onSurface: AppColors.darkTextPrimary,
    surfaceContainerHighest: AppColors.darkSurfaceVariant,
    outline: AppColors.darkBorder,
    shadow: Color(0x99000000),
    inverseSurface: AppColors.lightSurface,
    onInverseSurface: AppColors.lightTextPrimary,
    inversePrimary: AppColors.primaryDark,
  );
}
