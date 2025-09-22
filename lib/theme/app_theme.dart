import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static TextStyle appBarText = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
  );

  static TextStyle subTitle = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  static TextStyle bodyText = const TextStyle(
    fontSize: 16,
    color: Colors.black87,
  );

  static TextStyle caption = const TextStyle(
    fontSize: 14,
    color: Colors.black54,
  );
}
