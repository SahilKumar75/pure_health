import 'package:flutter/material.dart';

/// Responsive breakpoints and utilities for adaptive layouts
class ResponsiveUtils {
  // Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
  
  // Minimum touch target size (accessibility)
  static const double minTouchTarget = 44.0;
  
  // Get device type
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) {
      return DeviceType.mobile;
    } else if (width < tabletBreakpoint) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }
  
  // Check device type
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }
  
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }
  
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }
  
  // Responsive padding
  static double getHorizontalPadding(BuildContext context) {
    if (isMobile(context)) return 16.0;
    if (isTablet(context)) return 24.0;
    return 32.0;
  }
  
  static double getVerticalPadding(BuildContext context) {
    if (isMobile(context)) return 12.0;
    if (isTablet(context)) return 16.0;
    return 20.0;
  }
  
  // Responsive font scaling
  static double getScaledFontSize(BuildContext context, double baseSize) {
    if (isMobile(context)) return baseSize * 0.9;
    if (isTablet(context)) return baseSize * 0.95;
    return baseSize;
  }
  
  // Grid columns based on screen size
  static int getGridColumns(BuildContext context) {
    if (isMobile(context)) return 1;
    if (isTablet(context)) return 2;
    return 3;
  }
  
  // Responsive spacing
  static double getSpacing(BuildContext context, {double mobile = 8, double tablet = 12, double desktop = 16}) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }
  
  // Safe area for content
  static double getMaxContentWidth(BuildContext context) {
    if (isMobile(context)) return double.infinity;
    if (isTablet(context)) return 800;
    return 1400;
  }
  
  // Card sizing
  static double getCardWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (isMobile(context)) return screenWidth - 32;
    if (isTablet(context)) return (screenWidth - 64) / 2;
    return (screenWidth - 96) / 3;
  }
  
  // Sidebar width
  static double getSidebarWidth(BuildContext context, bool isExpanded) {
    if (isMobile(context)) return 0; // Hidden on mobile
    return isExpanded ? 200 : 72;
  }
  
  // Should show sidebar
  static bool shouldShowSidebar(BuildContext context) {
    return !isMobile(context);
  }
}

enum DeviceType {
  mobile,
  tablet,
  desktop,
}

/// Extension for easier access to responsive utils
extension ResponsiveExtension on BuildContext {
  bool get isMobile => ResponsiveUtils.isMobile(this);
  bool get isTablet => ResponsiveUtils.isTablet(this);
  bool get isDesktop => ResponsiveUtils.isDesktop(this);
  DeviceType get deviceType => ResponsiveUtils.getDeviceType(this);
  
  double get horizontalPadding => ResponsiveUtils.getHorizontalPadding(this);
  double get verticalPadding => ResponsiveUtils.getVerticalPadding(this);
  
  int get gridColumns => ResponsiveUtils.getGridColumns(this);
  double get maxContentWidth => ResponsiveUtils.getMaxContentWidth(this);
  
  bool get shouldShowSidebar => ResponsiveUtils.shouldShowSidebar(this);
}
