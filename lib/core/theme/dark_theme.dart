import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.dark(
    primary: AppColors.darkPrimary,
    secondary: AppColors.darkSecondary,
    surface: AppColors.darkSurface,
    error: AppColors.error,
    onPrimary: Colors.black,
    onSecondary: Colors.black,
    onSurface: AppColors.darkOnSurface,
    onError: AppColors.onError,
  ),
  textTheme: TextTheme(
    headlineLarge: AppTextStyles.headlineLarge.copyWith(color: AppColors.darkOnSurface),
    headlineMedium: AppTextStyles.headlineMedium.copyWith(color: AppColors.darkOnSurface),
    bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.darkOnSurface),
    bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkOnSurface),
    labelLarge: AppTextStyles.labelLarge.copyWith(color: Colors.black),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.darkPrimary,
      foregroundColor: Colors.black,
      textStyle: AppTextStyles.labelLarge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  ),
);
