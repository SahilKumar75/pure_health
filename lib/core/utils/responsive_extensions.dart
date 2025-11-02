import 'package:flutter/material.dart';

extension ResponsiveExtension on BuildContext {
  /// Returns the screen size
  Size get screenSize => MediaQuery.of(this).size;

  /// Returns the screen width
  double get screenWidth => screenSize.width;

  /// Returns the screen height
  double get screenHeight => screenSize.height;

  /// Returns true if the device is in portrait mode
  bool get isPortrait => MediaQuery.of(this).orientation == Orientation.portrait;

  /// Returns true if the device is in landscape mode
  bool get isLandscape => MediaQuery.of(this).orientation == Orientation.landscape;

  /// Returns true if the screen width is less than 600
  bool get isMobile => screenWidth < 600;

  /// Returns true if the screen width is between 600 and 1200
  bool get isTablet => screenWidth >= 600 && screenWidth < 1200;

  /// Returns true if the screen width is greater than or equal to 1200
  bool get isDesktop => screenWidth >= 1200;

  /// Returns the device type
  DeviceType get deviceType {
    if (isMobile) return DeviceType.mobile;
    if (isTablet) return DeviceType.tablet;
    return DeviceType.desktop;
  }
}

enum DeviceType { mobile, tablet, desktop }
