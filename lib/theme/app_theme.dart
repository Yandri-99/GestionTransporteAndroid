import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      colorSchemeSeed: AppColors.primary,
      useMaterial3: true,
    );
  }
}
