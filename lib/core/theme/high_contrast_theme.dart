import 'package:flutter/material.dart';
import 'package:pure_health/core/constants/color_constants.dart';
import 'package:pure_health/core/theme/text_styles.dart';

/// High contrast theme for accessibility
class HighContrastTheme {
  // High contrast colors
  static const Color highContrastBackground = Color(0xFF000000); // Pure black
  static const Color highContrastSurface = Color(0xFF1A1A1A); // Dark gray
  static const Color highContrastText = Color(0xFFFFFFFF); // Pure white
  static const Color highContrastTextSecondary = Color(0xFFE0E0E0); // Light gray
  static const Color highContrastPrimary = Color(0xFF00FF00); // Bright green
  static const Color highContrastSecondary = Color(0xFF00FFFF); // Cyan
  static const Color highContrastError = Color(0xFFFF0000); // Bright red
  static const Color highContrastWarning = Color(0xFFFFFF00); // Bright yellow
  static const Color highContrastSuccess = Color(0xFF00FF00); // Bright green
  static const Color highContrastBorder = Color(0xFFFFFFFF); // White borders

  /// Get high contrast theme data
  static ThemeData getHighContrastTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: highContrastBackground,
      primaryColor: highContrastPrimary,
      colorScheme: const ColorScheme.dark(
        primary: highContrastPrimary,
        secondary: highContrastSecondary,
        error: highContrastError,
        background: highContrastBackground,
        surface: highContrastSurface,
        onPrimary: highContrastBackground,
        onSecondary: highContrastBackground,
        onError: highContrastBackground,
        onBackground: highContrastText,
        onSurface: highContrastText,
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.heading1.copyWith(
          color: highContrastText,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: AppTextStyles.heading2.copyWith(
          color: highContrastText,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: AppTextStyles.heading3.copyWith(
          color: highContrastText,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: AppTextStyles.body.copyWith(
          color: highContrastText,
        ),
        bodyMedium: AppTextStyles.bodySmall.copyWith(
          color: highContrastTextSecondary,
        ),
      ),
      cardTheme: CardThemeData(
        color: highContrastSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: highContrastBorder,
            width: 2,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: highContrastPrimary,
          foregroundColor: highContrastBackground,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(
              color: highContrastBorder,
              width: 2,
            ),
          ),
          textStyle: AppTextStyles.button.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: highContrastText,
          side: const BorderSide(
            color: highContrastBorder,
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: highContrastSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: highContrastBorder,
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: highContrastBorder,
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: highContrastPrimary,
            width: 3,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: highContrastError,
            width: 2,
          ),
        ),
        labelStyle: const TextStyle(
          color: highContrastText,
          fontWeight: FontWeight.bold,
        ),
        hintStyle: const TextStyle(
          color: highContrastTextSecondary,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: highContrastBorder,
        thickness: 2,
      ),
      iconTheme: const IconThemeData(
        color: highContrastText,
        size: 24,
      ),
    );
  }

  /// Check if widget should use high contrast
  static bool shouldUseHighContrast(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.highContrast;
  }

  /// Get color with high contrast consideration
  static Color adaptiveColor(BuildContext context, {
    required Color normalColor,
    required Color highContrastColor,
  }) {
    return shouldUseHighContrast(context) ? highContrastColor : normalColor;
  }

  /// Get text color for high contrast
  static Color getTextColor(BuildContext context, {bool isSecondary = false}) {
    if (shouldUseHighContrast(context)) {
      return isSecondary ? highContrastTextSecondary : highContrastText;
    }
    return isSecondary ? AppColors.mediumGray : AppColors.charcoal;
  }

  /// Get background color for high contrast
  static Color getBackgroundColor(BuildContext context, {bool isSurface = false}) {
    if (shouldUseHighContrast(context)) {
      return isSurface ? highContrastSurface : highContrastBackground;
    }
    return isSurface ? AppColors.white : AppColors.lightCream;
  }

  /// Get border color for high contrast
  static Color getBorderColor(BuildContext context) {
    if (shouldUseHighContrast(context)) {
      return highContrastBorder;
    }
    return AppColors.darkCream.withOpacity(0.2);
  }

  /// Get status color for high contrast
  static Color getStatusColor(BuildContext context, String status) {
    if (shouldUseHighContrast(context)) {
      switch (status.toLowerCase()) {
        case 'safe':
        case 'success':
          return highContrastSuccess;
        case 'warning':
          return highContrastWarning;
        case 'critical':
        case 'error':
          return highContrastError;
        default:
          return highContrastPrimary;
      }
    }

    // Normal colors
    switch (status.toLowerCase()) {
      case 'safe':
      case 'success':
        return AppColors.success;
      case 'warning':
        return AppColors.warning;
      case 'critical':
      case 'error':
        return AppColors.error;
      default:
        return AppColors.accentPink;
    }
  }
}

/// Widget that adapts to high contrast mode
class AdaptiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? normalBackgroundColor;
  final Color? highContrastBackgroundColor;
  final BorderRadius? borderRadius;
  final bool showBorder;

  const AdaptiveContainer({
    Key? key,
    required this.child,
    this.padding,
    this.normalBackgroundColor,
    this.highContrastBackgroundColor,
    this.borderRadius,
    this.showBorder = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isHighContrast = HighContrastTheme.shouldUseHighContrast(context);
    
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: isHighContrast
            ? (highContrastBackgroundColor ?? HighContrastTheme.highContrastSurface)
            : (normalBackgroundColor ?? AppColors.white),
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        border: showBorder
            ? Border.all(
                color: isHighContrast
                    ? HighContrastTheme.highContrastBorder
                    : AppColors.darkCream.withOpacity(0.2),
                width: isHighContrast ? 2 : 1,
              )
            : null,
      ),
      child: child,
    );
  }
}

/// Text widget that adapts to high contrast
class AdaptiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final bool isSecondary;
  final int? maxLines;
  final TextOverflow? overflow;

  const AdaptiveText(
    this.text, {
    Key? key,
    this.style,
    this.isSecondary = false,
    this.maxLines,
    this.overflow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = HighContrastTheme.getTextColor(context, isSecondary: isSecondary);
    final adaptedStyle = (style ?? const TextStyle()).copyWith(
      color: color,
      fontWeight: HighContrastTheme.shouldUseHighContrast(context) 
          ? FontWeight.bold 
          : style?.fontWeight,
    );

    return Text(
      text,
      style: adaptedStyle,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
