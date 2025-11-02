import 'package:flutter/material.dart';
import 'package:pure_health/core/theme/text_styles.dart';

/// Professional government theme with formal design
class GovernmentTheme {
  // Professional government colors
  static const Color governmentBlue = Color(0xFF003B5C); // Official dark blue
  static const Color governmentGray = Color(0xFF6B7280); // Professional gray
  static const Color governmentWhite = Color(0xFFFAFAFA); // Clean white
  static const Color governmentBorder = Color(0xFFE5E7EB); // Subtle border
  static const Color statusGreen = Color(0xFF10B981); // Safe status
  static const Color statusYellow = Color(0xFFF59E0B); // Warning status
  static const Color statusRed = Color(0xFFEF4444); // Critical status
  static const Color accentBlue = Color(0xFF3B82F6); // Action blue

  /// Get professional government theme
  static ThemeData getGovernmentTheme() {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: governmentWhite,
      primaryColor: governmentBlue,
      colorScheme: ColorScheme.light(
        primary: governmentBlue,
        secondary: accentBlue,
        error: statusRed,
        background: governmentWhite,
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onError: Colors.white,
        onBackground: governmentBlue,
        onSurface: governmentBlue,
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.heading1.copyWith(
          color: governmentBlue,
          fontWeight: FontWeight.w700,
        ),
        displayMedium: AppTextStyles.heading2.copyWith(
          color: governmentBlue,
          fontWeight: FontWeight.w600,
        ),
        displaySmall: AppTextStyles.heading3.copyWith(
          color: governmentBlue,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: AppTextStyles.body.copyWith(
          color: governmentGray,
        ),
        bodyMedium: AppTextStyles.bodySmall.copyWith(
          color: governmentGray,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: governmentBorder,
            width: 1,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: governmentBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          textStyle: AppTextStyles.button.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: governmentBlue,
          side: BorderSide(
            color: governmentBorder,
            width: 1.5,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: governmentWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(
            color: governmentBorder,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(
            color: governmentBorder,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(
            color: governmentBlue,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(
            color: statusRed,
            width: 1,
          ),
        ),
        labelStyle: TextStyle(
          color: governmentGray,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(
          color: governmentGray.withOpacity(0.6),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: governmentBorder,
        thickness: 1,
      ),
      iconTheme: IconThemeData(
        color: governmentGray,
        size: 20,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: governmentBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.heading3.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Get status color for government theme
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'safe':
        return statusGreen;
      case 'warning':
        return statusYellow;
      case 'critical':
      case 'danger':
        return statusRed;
      default:
        return governmentGray;
    }
  }

  /// Get priority color
  static Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return statusRed;
      case 'medium':
        return statusYellow;
      case 'low':
        return statusGreen;
      default:
        return governmentGray;
    }
  }
}

/// Professional container widget for government UI
class GovernmentCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final String? title;
  final Widget? trailing;
  final VoidCallback? onTap;

  const GovernmentCard({
    Key? key,
    required this.child,
    this.padding,
    this.title,
    this.trailing,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: GovernmentTheme.governmentBorder,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: GovernmentTheme.governmentBorder,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title!,
                        style: AppTextStyles.heading4.copyWith(
                          color: GovernmentTheme.governmentBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (trailing != null) trailing!,
                  ],
                ),
              ),
            Padding(
              padding: padding ?? const EdgeInsets.all(16),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

/// Status badge widget
class StatusBadge extends StatelessWidget {
  final String status;
  final bool isCompact;

  const StatusBadge({
    Key? key,
    required this.status,
    this.isCompact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = GovernmentTheme.getStatusColor(status);
    
    return Container(
      padding: isCompact
          ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
          : const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: color,
          width: 1,
        ),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: isCompact ? 11 : 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
