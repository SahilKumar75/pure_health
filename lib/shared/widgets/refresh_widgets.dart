import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pure_health/core/constants/color_constants.dart';

/// Custom pull-to-refresh wrapper with beautiful animations
class CustomRefreshWrapper extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? color;
  final Color? backgroundColor;
  final String? refreshText;

  const CustomRefreshWrapper({
    Key? key,
    required this.child,
    required this.onRefresh,
    this.color,
    this.backgroundColor,
    this.refreshText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: color ?? AppColors.accentPink,
      backgroundColor: backgroundColor ?? AppColors.white,
      displacement: 60,
      strokeWidth: 3,
      child: child,
    );
  }
}

/// iOS-style pull to refresh
class CupertinoRefreshWrapper extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final ScrollController? scrollController;

  const CupertinoRefreshWrapper({
    Key? key,
    required this.child,
    required this.onRefresh,
    this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        CupertinoSliverRefreshControl(
          onRefresh: onRefresh,
          builder: (
            BuildContext context,
            RefreshIndicatorMode refreshState,
            double pulledExtent,
            double refreshTriggerPullDistance,
            double refreshIndicatorExtent,
          ) {
            return Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: _buildRefreshIndicator(refreshState),
              ),
            );
          },
        ),
        SliverToBoxAdapter(
          child: child,
        ),
      ],
    );
  }

  Widget _buildRefreshIndicator(RefreshIndicatorMode state) {
    switch (state) {
      case RefreshIndicatorMode.drag:
        return const Icon(
          CupertinoIcons.arrow_down,
          color: AppColors.accentPink,
          size: 24,
        );
      case RefreshIndicatorMode.armed:
        return const Icon(
          CupertinoIcons.arrow_down_circle_fill,
          color: AppColors.accentPink,
          size: 24,
        );
      case RefreshIndicatorMode.refresh:
        return const CupertinoActivityIndicator(
          color: AppColors.accentPink,
          radius: 12,
        );
      case RefreshIndicatorMode.done:
        return const Icon(
          CupertinoIcons.check_mark_circled_solid,
          color: AppColors.success,
          size: 24,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

/// Swipe to refresh with custom indicator
class SwipeRefreshWrapper extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final double triggerOffset;

  const SwipeRefreshWrapper({
    Key? key,
    required this.child,
    required this.onRefresh,
    this.triggerOffset = 100,
  }) : super(key: key);

  @override
  State<SwipeRefreshWrapper> createState() => _SwipeRefreshWrapperState();
}

class _SwipeRefreshWrapperState extends State<SwipeRefreshWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isRefreshing = false;
  double _dragOffset = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    setState(() => _isRefreshing = true);
    _controller.repeat();

    try {
      await widget.onRefresh();
    } finally {
      if (mounted) {
        _controller.stop();
        _controller.reset();
        setState(() => _isRefreshing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification) {
          if (notification.metrics.pixels < -widget.triggerOffset) {
            _dragOffset = -notification.metrics.pixels;
            if (!_isRefreshing && _dragOffset >= widget.triggerOffset) {
              _handleRefresh();
            }
          }
        }
        return false;
      },
      child: Stack(
        children: [
          widget.child,
          if (_isRefreshing)
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.charcoal.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RotationTransition(
                        turns: _controller,
                        child: const Icon(
                          CupertinoIcons.refresh,
                          color: AppColors.accentPink,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Refreshing...',
                        style: TextStyle(
                          color: AppColors.charcoal,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Loading progress bar at top of screen
class LoadingProgressBar extends StatelessWidget {
  final bool isLoading;
  final Color? color;
  final double height;

  const LoadingProgressBar({
    Key? key,
    required this.isLoading,
    this.color,
    this.height = 3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: isLoading ? height : 0,
      child: isLoading
          ? LinearProgressIndicator(
              color: color ?? AppColors.accentPink,
              backgroundColor: AppColors.lightCream,
            )
          : const SizedBox.shrink(),
    );
  }
}

/// Circular progress overlay
class LoadingOverlayWithProgress extends StatelessWidget {
  final bool isLoading;
  final String? message;
  final double? progress; // 0.0 to 1.0
  final Color? backgroundColor;

  const LoadingOverlayWithProgress({
    Key? key,
    required this.isLoading,
    this.message,
    this.progress,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return const SizedBox.shrink();

    return Container(
      color: (backgroundColor ?? Colors.black).withOpacity(0.5),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.charcoal.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (progress != null)
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 6,
                    backgroundColor: AppColors.lightCream,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.accentPink,
                    ),
                  ),
                )
              else
                const SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    strokeWidth: 6,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.accentPink,
                    ),
                  ),
                ),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(
                  message!,
                  style: TextStyle(
                    color: AppColors.charcoal,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (progress != null) ...[
                const SizedBox(height: 8),
                Text(
                  '${(progress! * 100).toInt()}%',
                  style: TextStyle(
                    color: AppColors.mediumGray,
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
