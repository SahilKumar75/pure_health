import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pure_health/core/utils/responsive_utils.dart';
import 'package:pure_health/core/constants/color_constants.dart';
import 'package:pure_health/core/theme/text_styles.dart';

/// Responsive button that adapts size and touch targets for different devices
class ResponsiveButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;
  final Color? textColor;
  final bool isLoading;
  final bool isFullWidth;
  final ButtonSize size;

  const ResponsiveButton({
    Key? key,
    required this.label,
    this.onPressed,
    this.icon,
    this.color,
    this.textColor,
    this.isLoading = false,
    this.isFullWidth = false,
    this.size = ButtonSize.medium,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? AppColors.accentPink;
    final buttonTextColor = textColor ?? Colors.white;
    final padding = _getPadding(context);
    final fontSize = _getFontSize(context);
    final minHeight = _getMinHeight(context);

    Widget button = CupertinoButton(
      padding: padding,
      color: buttonColor,
      disabledColor: buttonColor.withOpacity(0.5),
      borderRadius: BorderRadius.circular(12),
      onPressed: isLoading ? null : onPressed,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: minHeight - padding.vertical,
        ),
        child: Row(
          mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(buttonTextColor),
                ),
              )
            else if (icon != null) ...[
              Icon(icon, color: buttonTextColor, size: fontSize + 2),
              const SizedBox(width: 8),
            ],
            if (!isLoading)
              Text(
                label,
                style: AppTextStyles.button.copyWith(
                  color: buttonTextColor,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );

    if (isFullWidth) {
      button = SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }

  EdgeInsets _getPadding(BuildContext context) {
    final isMobile = context.isMobile;
    
    switch (size) {
      case ButtonSize.small:
        return EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16,
          vertical: isMobile ? 8 : 10,
        );
      case ButtonSize.medium:
        return EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 20,
          vertical: isMobile ? 12 : 14,
        );
      case ButtonSize.large:
        return EdgeInsets.symmetric(
          horizontal: isMobile ? 20 : 24,
          vertical: isMobile ? 16 : 18,
        );
    }
  }

  double _getFontSize(BuildContext context) {
    final baseSizes = {
      ButtonSize.small: 13.0,
      ButtonSize.medium: 15.0,
      ButtonSize.large: 17.0,
    };
    
    return ResponsiveUtils.getScaledFontSize(context, baseSizes[size]!);
  }

  double _getMinHeight(BuildContext context) {
    // Ensure minimum touch target on mobile
    if (context.isMobile) {
      return ResponsiveUtils.minTouchTarget;
    }
    
    switch (size) {
      case ButtonSize.small:
        return 36;
      case ButtonSize.medium:
        return 44;
      case ButtonSize.large:
        return 52;
    }
  }
}

enum ButtonSize {
  small,
  medium,
  large,
}

/// Responsive icon button with proper touch targets
class ResponsiveIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? backgroundColor;
  final double? size;
  final String? tooltip;

  const ResponsiveIconButton({
    Key? key,
    required this.icon,
    this.onPressed,
    this.color,
    this.backgroundColor,
    this.size,
    this.tooltip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final iconSize = size ?? (context.isMobile ? 22 : 24);
    final buttonSize = context.isMobile 
        ? ResponsiveUtils.minTouchTarget 
        : 40.0;

    Widget button = Container(
      width: buttonSize,
      height: buttonSize,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon),
        iconSize: iconSize,
        color: color ?? AppColors.charcoal,
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        constraints: BoxConstraints(
          minWidth: buttonSize,
          minHeight: buttonSize,
        ),
      ),
    );

    if (tooltip != null) {
      button = Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}

/// Responsive floating action button
class ResponsiveFAB extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final String? tooltip;

  const ResponsiveFAB({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.tooltip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fabSize = context.isMobile ? 56.0 : 64.0;
    final iconSize = context.isMobile ? 24.0 : 28.0;

    return SizedBox(
      width: fabSize,
      height: fabSize,
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: backgroundColor ?? AppColors.accentPink,
        foregroundColor: foregroundColor ?? Colors.white,
        tooltip: tooltip,
        child: Icon(icon, size: iconSize),
      ),
    );
  }
}
