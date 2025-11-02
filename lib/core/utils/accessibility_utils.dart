import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Utility class for accessibility features
class AccessibilityUtils {
  /// Announces a message to screen readers
  static void announce(BuildContext context, String message, {TextDirection? textDirection}) {
    SemanticsService.announce(
      message,
      textDirection ?? Directionality.of(context),
    );
  }

  /// Creates semantic label for numeric values with units
  static String numericLabel(num value, String unit) {
    return '$value $unit';
  }

  /// Creates semantic label for percentage values
  static String percentageLabel(num value) {
    return '$value percent';
  }

  /// Creates semantic label for status indicators
  static String statusLabel(String status, {String? prefix}) {
    final prefixText = prefix != null ? '$prefix: ' : '';
    return '$prefixText$status';
  }

  /// Creates semantic label for date/time
  static String dateTimeLabel(DateTime dateTime, {bool includeTime = false}) {
    if (includeTime) {
      return '${dateTime.month}/${dateTime.day}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
    return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
  }

  /// Creates semantic label for navigation items
  static String navigationLabel(String label, {bool isSelected = false}) {
    return isSelected ? '$label, selected' : label;
  }

  /// Creates semantic label for buttons with state
  static String buttonLabel(String label, {bool isEnabled = true, bool isLoading = false}) {
    if (isLoading) return '$label, loading';
    if (!isEnabled) return '$label, disabled';
    return label;
  }

  /// Creates semantic label for form fields
  static String formFieldLabel(String label, {bool isRequired = false, String? errorMessage}) {
    String result = label;
    if (isRequired) result += ', required';
    if (errorMessage != null && errorMessage.isNotEmpty) {
      result += ', error: $errorMessage';
    }
    return result;
  }

  /// Creates semantic label for lists
  static String listItemLabel(int index, int total, String itemDescription) {
    return 'Item ${index + 1} of $total, $itemDescription';
  }

  /// Creates semantic label for tabs
  static String tabLabel(String label, int index, int total, {bool isSelected = false}) {
    String result = '$label, tab ${index + 1} of $total';
    if (isSelected) result += ', selected';
    return result;
  }

  /// Checks if screen reader is enabled
  static bool isScreenReaderEnabled(BuildContext context) {
    final data = MediaQuery.of(context);
    return data.accessibleNavigation;
  }

  /// Checks if high contrast mode is enabled
  static bool isHighContrastEnabled(BuildContext context) {
    final data = MediaQuery.of(context);
    return data.highContrast;
  }

  /// Checks if bold text is enabled
  static bool isBoldTextEnabled(BuildContext context) {
    final data = MediaQuery.of(context);
    return data.boldText;
  }

  /// Gets text scale factor for accessibility
  static double getTextScaleFactor(BuildContext context) {
    final data = MediaQuery.of(context);
    return data.textScaleFactor;
  }

  /// Wraps widget with semantic label
  static Widget semanticLabel(
    Widget child, {
    required String label,
    String? hint,
    bool? isButton,
    bool? isHeader,
    bool? isLink,
    bool excludeSemantics = false,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      button: isButton,
      header: isHeader,
      link: isLink,
      excludeSemantics: excludeSemantics,
      child: child,
    );
  }

  /// Creates semantic container for groups
  static Widget semanticContainer({
    required Widget child,
    String? label,
    String? hint,
    bool isEnabled = true,
  }) {
    return Semantics(
      container: true,
      label: label,
      hint: hint,
      enabled: isEnabled,
      child: child,
    );
  }

  /// Creates focusable widget with semantic label
  static Widget focusableWidget({
    required Widget child,
    required String label,
    String? hint,
    VoidCallback? onTap,
    FocusNode? focusNode,
  }) {
    return MergeSemantics(
      child: Semantics(
        label: label,
        hint: hint,
        button: onTap != null,
        focusable: true,
        child: Focus(
          focusNode: focusNode,
          child: GestureDetector(
            onTap: onTap,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Mixin for accessibility features in widgets
mixin AccessibilityMixin<T extends StatefulWidget> on State<T> {
  /// Announce message to screen readers
  void announce(String message) {
    AccessibilityUtils.announce(context, message);
  }

  /// Check if screen reader is enabled
  bool get isScreenReaderEnabled => AccessibilityUtils.isScreenReaderEnabled(context);

  /// Check if high contrast mode is enabled
  bool get isHighContrastEnabled => AccessibilityUtils.isHighContrastEnabled(context);

  /// Check if bold text is enabled
  bool get isBoldTextEnabled => AccessibilityUtils.isBoldTextEnabled(context);

  /// Get text scale factor
  double get textScaleFactor => AccessibilityUtils.getTextScaleFactor(context);
}

/// Focus manager for keyboard navigation
class FocusManager {
  static final FocusNode _primaryFocus = FocusNode();
  static final Map<String, FocusNode> _focusNodes = {};

  /// Get or create focus node with key
  static FocusNode getFocusNode(String key) {
    if (!_focusNodes.containsKey(key)) {
      _focusNodes[key] = FocusNode();
    }
    return _focusNodes[key]!;
  }

  /// Request focus for a specific key
  static void requestFocus(String key) {
    final node = getFocusNode(key);
    node.requestFocus();
  }

  /// Clear all focus nodes
  static void clearAllFocus() {
    for (var node in _focusNodes.values) {
      node.unfocus();
    }
  }

  /// Dispose focus node
  static void disposeFocusNode(String key) {
    if (_focusNodes.containsKey(key)) {
      _focusNodes[key]!.dispose();
      _focusNodes.remove(key);
    }
  }

  /// Dispose all focus nodes
  static void disposeAll() {
    for (var node in _focusNodes.values) {
      node.dispose();
    }
    _focusNodes.clear();
  }

  /// Get primary focus node
  static FocusNode get primaryFocus => _primaryFocus;
}

/// Widget for skip to content functionality
class SkipToContent extends StatelessWidget {
  final Widget child;
  final String skipLabel;
  final GlobalKey contentKey;

  const SkipToContent({
    Key? key,
    required this.child,
    required this.contentKey,
    this.skipLabel = 'Skip to main content',
  }) : super(key: key);

  void _skipToContent() {
    final context = contentKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Skip link (visible only on focus)
        Focus(
          onFocusChange: (hasFocus) {
            if (hasFocus) {
              AccessibilityUtils.announce(context, skipLabel);
            }
          },
          child: Offstage(
            offstage: true,
            child: ElevatedButton(
              onPressed: _skipToContent,
              child: Text(skipLabel),
            ),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}
