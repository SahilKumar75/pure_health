import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/constants/color_constants.dart';
import '../../core/theme/text_styles.dart';

/// Enhanced empty state widget with better UX
class EmptyStateWidget extends StatelessWidget {
  final String emoji;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? actionIcon;
  final bool showAnimation;

  const EmptyStateWidget({
    Key? key,
    required this.emoji,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.actionIcon,
    this.showAnimation = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated emoji
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 600),
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Text(
                    emoji,
                    style: TextStyle(fontSize: 80 * value),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Title
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 400),
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: Text(
                      title,
                      style: AppTextStyles.heading2.copyWith(
                        color: AppColors.lightText,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            // Message
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 600),
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: Text(
                      message,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.mediumText,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                    ),
                  ),
                );
              },
            ),

            // Action button
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 32),
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 800),
                tween: Tween(begin: 0.0, end: 1.0),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: CupertinoButton(
                      onPressed: onAction,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      color: AppColors.accentPink,
                      borderRadius: BorderRadius.circular(12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (actionIcon != null) ...[
                            Icon(
                              actionIcon,
                              size: 20,
                              color: AppColors.white,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            actionLabel!,
                            style: AppTextStyles.button.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Specialized empty states for common scenarios
class EmptyStates {
  static Widget noData({
    String title = 'No Data Available',
    String message = 'There is no data to display at the moment.',
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return EmptyStateWidget(
      emoji: '📊',
      title: title,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
      actionIcon: CupertinoIcons.refresh,
    );
  }

  static Widget noConnection({
    String title = 'No Connection',
    String message = 'Please check your internet connection and try again.',
    VoidCallback? onRetry,
  }) {
    return EmptyStateWidget(
      emoji: '📡',
      title: title,
      message: message,
      actionLabel: 'Retry',
      onAction: onRetry,
      actionIcon: CupertinoIcons.refresh_circled,
    );
  }

  static Widget noResults({
    String title = 'No Results Found',
    String message = 'Try adjusting your search or filters.',
    VoidCallback? onClear,
  }) {
    return EmptyStateWidget(
      emoji: '🔍',
      title: title,
      message: message,
      actionLabel: onClear != null ? 'Clear Filters' : null,
      onAction: onClear,
      actionIcon: CupertinoIcons.clear_circled,
    );
  }

  static Widget error({
    String title = 'Something Went Wrong',
    String message = 'An unexpected error occurred. Please try again.',
    VoidCallback? onRetry,
  }) {
    return EmptyStateWidget(
      emoji: '⚠️',
      title: title,
      message: message,
      actionLabel: 'Try Again',
      onAction: onRetry,
      actionIcon: CupertinoIcons.arrow_clockwise,
    );
  }

  static Widget comingSoon({
    String title = 'Coming Soon',
    String message = 'This feature is under development and will be available soon.',
  }) {
    return EmptyStateWidget(
      emoji: '🚀',
      title: title,
      message: message,
    );
  }
}
