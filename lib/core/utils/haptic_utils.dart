import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Haptic feedback utility for providing tactile responses
class HapticUtils {
  /// Light impact haptic
  static Future<void> lightImpact() async {
    if (!kIsWeb) {
      try {
        await HapticFeedback.lightImpact();
      } catch (e) {
        // Haptic feedback not supported
      }
    }
  }

  /// Medium impact haptic
  static Future<void> mediumImpact() async {
    if (!kIsWeb) {
      try {
        await HapticFeedback.mediumImpact();
      } catch (e) {
        // Haptic feedback not supported
      }
    }
  }

  /// Heavy impact haptic
  static Future<void> heavyImpact() async {
    if (!kIsWeb) {
      try {
        await HapticFeedback.heavyImpact();
      } catch (e) {
        // Haptic feedback not supported
      }
    }
  }

  /// Selection click haptic (lighter than light impact)
  static Future<void> selectionClick() async {
    if (!kIsWeb) {
      try {
        await HapticFeedback.selectionClick();
      } catch (e) {
        // Haptic feedback not supported
      }
    }
  }

  /// Vibrate for success
  static Future<void> success() async {
    if (!kIsWeb) {
      try {
        await HapticFeedback.lightImpact();
        await Future.delayed(const Duration(milliseconds: 50));
        await HapticFeedback.lightImpact();
      } catch (e) {
        // Haptic feedback not supported
      }
    }
  }

  /// Vibrate for error
  static Future<void> error() async {
    if (!kIsWeb) {
      try {
        await HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 100));
        await HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 100));
        await HapticFeedback.heavyImpact();
      } catch (e) {
        // Haptic feedback not supported
      }
    }
  }

  /// Vibrate for warning
  static Future<void> warning() async {
    if (!kIsWeb) {
      try {
        await HapticFeedback.mediumImpact();
        await Future.delayed(const Duration(milliseconds: 100));
        await HapticFeedback.lightImpact();
      } catch (e) {
        // Haptic feedback not supported
      }
    }
  }

  /// Button press feedback
  static Future<void> buttonPress() async {
    await lightImpact();
  }

  /// Toggle switch feedback
  static Future<void> toggleSwitch() async {
    await selectionClick();
  }

  /// Scroll feedback
  static Future<void> scroll() async {
    await selectionClick();
  }

  /// Long press feedback
  static Future<void> longPress() async {
    await mediumImpact();
  }
}

/// Mixin to add haptic feedback to widgets
mixin HapticFeedbackMixin {
  Future<void> vibrate() async {
    await HapticUtils.lightImpact();
  }

  Future<void> vibrateOnTap() async {
    await HapticUtils.buttonPress();
  }

  Future<void> vibrateOnSuccess() async {
    await HapticUtils.success();
  }

  Future<void> vibrateOnError() async {
    await HapticUtils.error();
  }

  Future<void> vibrateOnWarning() async {
    await HapticUtils.warning();
  }
}
