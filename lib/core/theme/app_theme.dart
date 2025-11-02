import 'package:flutter/material.dart';
import '../constants/color_constants.dart';
import 'text_styles.dart';

class AppTheme {
  static ThemeData getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primaryCream,
      scaffoldBackgroundColor: AppColors.lightCream,

      // Color Scheme
      colorScheme: ColorScheme.light(
        primary: AppColors.primaryCream,
        secondary: AppColors.darkVanilla,
        surface: AppColors.white,
        background: AppColors.lightGray,
        error: AppColors.error,
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.heading2.copyWith(
          color: AppColors.charcoal,
        ),
        iconTheme: IconThemeData(color: AppColors.charcoal),
      ),

      // Card Theme - FIXED: Use CardThemeData instead of CardTheme
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: AppColors.darkCream.withOpacity(0.3),
            width: 1,
          ),
        ),
        margin: EdgeInsets.zero,
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkVanilla,
          foregroundColor: AppColors.charcoal,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.charcoal,
          side: BorderSide(color: AppColors.darkVanilla, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.darkVanilla,
          textStyle: AppTextStyles.button,
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkCream.withOpacity(0.2),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: AppColors.darkCream.withOpacity(0.3),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: AppColors.darkVanilla,
            width: 2,
          ),
        ),
        labelStyle: AppTextStyles.body.copyWith(
          color: AppColors.mediumGray,
        ),
        hintStyle: AppTextStyles.body.copyWith(
          color: AppColors.mediumGray.withOpacity(0.6),
        ),
      ),

      // Text Theme
      textTheme: TextTheme(
        displayLarge: AppTextStyles.heading1.copyWith(
          color: AppColors.charcoal,
        ),
        displayMedium: AppTextStyles.heading2.copyWith(
          color: AppColors.charcoal,
        ),
        headlineSmall: AppTextStyles.heading3.copyWith(
          color: AppColors.charcoal,
        ),
        bodyLarge: AppTextStyles.body.copyWith(
          color: AppColors.charcoal,
        ),
        bodyMedium: AppTextStyles.body.copyWith(
          color: AppColors.mediumGray,
        ),
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: AppColors.darkCream.withOpacity(0.2),
        space: 1,
        thickness: 1,
      ),
    );
  }
}
