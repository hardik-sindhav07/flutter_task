import 'package:flutter/material.dart';
import 'app_colors.dart';


class AppTextStyles {

  static const TextStyle heading = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  static const TextStyle subheading = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );
  static const TextStyle body = TextStyle(
    fontSize: 15,
    color: AppColors.textPrimary,
  );
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );
  static const TextStyle progress = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.secondary,
  );

  static const textTheme = TextTheme(
    titleLarge: heading,
    titleMedium: subheading,
    bodyMedium: body,
    labelLarge: button,
    labelSmall: progress,
  );
} 