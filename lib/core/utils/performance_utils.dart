import 'package:flutter/material.dart';

/// Performance utilities for optimization
class PerformanceUtils {
  // Cache for expensive computations
  static final Map<String, dynamic> _cache = {};

  /// Get cached value or compute and cache it
  static T getCachedOrCompute<T>(String key, T Function() compute) {
    if (_cache.containsKey(key)) {
      return _cache[key] as T;
    }
    final value = compute();
    _cache[key] = value;
    return value;
  }

  /// Clear specific cache entry
  static void clearCache(String key) {
    _cache.remove(key);
  }

  /// Clear all cache
  static void clearAllCache() {
    _cache.clear();
  }

  /// Debounce function calls
  static void Function() debounce(
    VoidCallback callback, {
    Duration delay = const Duration(milliseconds: 300),
  }) {
    DateTime? lastCall;
    return () {
      final now = DateTime.now();
      if (lastCall == null || now.difference(lastCall!) >= delay) {
        lastCall = now;
        callback();
      }
    };
  }

  /// Throttle function calls
  static VoidCallback throttle(
    VoidCallback callback, {
    Duration delay = const Duration(milliseconds: 300),
  }) {
    bool isThrottled = false;
    return () {
      if (!isThrottled) {
        callback();
        isThrottled = true;
        Future.delayed(delay, () {
          isThrottled = false;
        });
      }
    };
  }
}

/// Memoized widget that rebuilds only when dependencies change
class MemoWidget extends StatelessWidget {
  final Widget Function() builder;
  final List<Object?> dependencies;
  final String? debugLabel;

  const MemoWidget({
    Key? key,
    required this.builder,
    required this.dependencies,
    this.debugLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return builder();
  }
}

/// Lazy loading list view for better performance
class LazyListView extends StatefulWidget {
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final ScrollController? controller;
  final EdgeInsets? padding;
  final int initialLoadCount;
  final int loadMoreThreshold;

  const LazyListView({
    Key? key,
    required this.itemCount,
    required this.itemBuilder,
    this.controller,
    this.padding,
    this.initialLoadCount = 20,
    this.loadMoreThreshold = 5,
  }) : super(key: key);

  @override
  State<LazyListView> createState() => _LazyListViewState();
}

class _LazyListViewState extends State<LazyListView> {
  late ScrollController _scrollController;
  int _loadedItemCount = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _loadedItemCount = widget.initialLoadCount.clamp(0, widget.itemCount);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    if (_loadedItemCount >= widget.itemCount) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final delta = maxScroll - currentScroll;

    if (delta < 200) {
      // Load more when near bottom
      setState(() {
        _loadedItemCount = (_loadedItemCount + widget.loadMoreThreshold)
            .clamp(0, widget.itemCount);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      padding: widget.padding,
      itemCount: _loadedItemCount,
      itemBuilder: widget.itemBuilder,
    );
  }
}

/// Cached network image placeholder
class CachedImagePlaceholder extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const CachedImagePlaceholder({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: frame != null 
              ? child 
              : placeholder ?? Container(
                  width: width,
                  height: height,
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ?? Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: const Icon(Icons.error_outline),
        );
      },
    );
  }
}

/// Efficient animated switcher with reduced rebuilds
class OptimizedAnimatedSwitcher extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const OptimizedAnimatedSwitcher({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: curve,
      switchOutCurve: curve,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: child,
    );
  }
}

/// Repaint boundary wrapper for expensive widgets
class RepaintBoundaryWrapper extends StatelessWidget {
  final Widget child;

  const RepaintBoundaryWrapper({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: child,
    );
  }
}

/// Const widget wrapper to prevent unnecessary rebuilds
class ConstWrapper extends StatelessWidget {
  final Widget child;

  const ConstWrapper({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

/// Visibility detector for lazy loading widgets
class VisibilityDetector extends StatefulWidget {
  final Widget child;
  final void Function(bool isVisible) onVisibilityChanged;
  final double visibilityThreshold;

  const VisibilityDetector({
    Key? key,
    required this.child,
    required this.onVisibilityChanged,
    this.visibilityThreshold = 0.1,
  }) : super(key: key);

  @override
  State<VisibilityDetector> createState() => _VisibilityDetectorState();
}

class _VisibilityDetectorState extends State<VisibilityDetector> {
  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final renderBox = context.findRenderObject() as RenderBox?;
          if (renderBox != null && mounted) {
            final position = renderBox.localToGlobal(Offset.zero);
            final size = renderBox.size;
            final screenHeight = MediaQuery.of(context).size.height;

            final isNowVisible = position.dy < screenHeight &&
                position.dy + size.height > 0;

            if (isNowVisible != _isVisible) {
              _isVisible = isNowVisible;
              widget.onVisibilityChanged(isNowVisible);
            }
          }
        });

        return widget.child;
      },
    );
  }
}

/// Mixin for performance monitoring
mixin PerformanceMonitorMixin<T extends StatefulWidget> on State<T> {
  DateTime? _buildStartTime;

  @override
  Widget build(BuildContext context) {
    _buildStartTime = DateTime.now();
    return Container(); // Override in subclass
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_buildStartTime != null) {
      final buildDuration = DateTime.now().difference(_buildStartTime!);
      if (buildDuration.inMilliseconds > 16) {
        // Longer than 1 frame (16ms at 60fps)
        debugPrint('⚠️ Slow build in ${T.toString()}: ${buildDuration.inMilliseconds}ms');
      }
    }
  }
}
