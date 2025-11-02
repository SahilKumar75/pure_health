import 'package:flutter/material.dart';
import '../constants/color_constants.dart';
import 'text_styles.dart';

class AppTheme {
  static ThemeData getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Colors
      scaffoldBackgroundColor: AppColors.darkBg,
      canvasColor: AppColors.darkBg,
      cardColor: AppColors.darkBg2,
      dialogBackgroundColor: AppColors.darkBg2,
      
      // Primary colors
      primaryColor: AppColors.accentPink,
      primarySwatch: MaterialColor(
        0xFFd97d66,
        const {
          50: Color(0xFFf5ede7),
          100: Color(0xFFedded2),
          200: Color(0xFFe5cdb7),
          300: Color(0xFFd99d7a),
          400: Color(0xFFd97d66),
          500: Color(0xFFd97d66),
          600: Color(0xFFc8685a),
          700: Color(0xFFb4534e),
          800: Color(0xFFa04544),
          900: Color(0xFF8a3a3a),
        },
      ),
      
      // AppBar theme
      appBarTheme: AppBarThemeData(
        backgroundColor: AppColors.darkBg2,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.heading2.copyWith(
          color: AppColors.lightText,
        ),
      ),
      
      // Text theme
      textTheme: TextTheme(
        displayLarge: AppTextStyles.heading1.copyWith(
          color: AppColors.lightText,
        ),
        displayMedium: AppTextStyles.heading2.copyWith(
          color: AppColors.lightText,
        ),
        displaySmall: AppTextStyles.heading3.copyWith(
          color: AppColors.lightText,
        ),
        headlineMedium: AppTextStyles.body.copyWith(
          color: AppColors.lightText2,
        ),
        bodyLarge: AppTextStyles.body.copyWith(
          color: AppColors.lightText2,
        ),
        bodyMedium: AppTextStyles.body.copyWith(
          color: AppColors.mediumText,
        ),
        bodySmall: AppTextStyles.bodySmall.copyWith(
          color: AppColors.dimText,
        ),
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkBg2,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: AppColors.accentPink,
            width: 2,
          ),
        ),
        hintStyle: AppTextStyles.body.copyWith(
          color: AppColors.dimText,
        ),
      ),
      
      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentPink,
          foregroundColor: AppColors.darkBg2,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
      ),
      
      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accentPink,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
        ),
      ),
    );
  }
}
