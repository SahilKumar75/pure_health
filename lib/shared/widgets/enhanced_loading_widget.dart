import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/constants/color_constants.dart';
import '../../core/theme/text_styles.dart';

/// Enhanced loading widget with multiple styles
class EnhancedLoadingWidget extends StatelessWidget {
  final String? message;
  final LoadingStyle style;
  final Color? color;
  final double size;

  const EnhancedLoadingWidget({
    Key? key,
    this.message,
    this.style = LoadingStyle.circular,
    this.color,
    this.size = 48,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLoader(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: AppTextStyles.body.copyWith(
                color: AppColors.mediumText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoader() {
    switch (style) {
      case LoadingStyle.circular:
        return SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? AppColors.accentPink,
            ),
          ),
        );
      case LoadingStyle.cupertino:
        return CupertinoActivityIndicator(
          radius: size / 3,
          color: color ?? AppColors.accentPink,
        );
      case LoadingStyle.dots:
        return _DotsLoader(color: color ?? AppColors.accentPink, size: size);
      case LoadingStyle.pulse:
        return _PulseLoader(color: color ?? AppColors.accentPink, size: size);
    }
  }
}

enum LoadingStyle { circular, cupertino, dots, pulse }

/// Animated dots loader
class _DotsLoader extends StatefulWidget {
  final Color color;
  final double size;

  const _DotsLoader({
    required this.color,
    required this.size,
  });

  @override
  State<_DotsLoader> createState() => _DotsLoaderState();
}

class _DotsLoaderState extends State<_DotsLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dotSize = widget.size / 6;
    return SizedBox(
      width: widget.size,
      height: dotSize,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final value = ((_controller.value - (index * 0.2)) % 1.0);
              final scale = 0.5 + (0.5 * (1 - (value - 0.5).abs() * 2));
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: dotSize,
                  height: dotSize,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

/// Pulse loader animation
class _PulseLoader extends StatefulWidget {
  final Color color;
  final double size;

  const _PulseLoader({
    required this.color,
    required this.size,
  });

  @override
  State<_PulseLoader> createState() => _PulseLoaderState();
}

class _PulseLoaderState extends State<_PulseLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer pulse
            Container(
              width: widget.size * _animation.value,
              height: widget.size * _animation.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withOpacity(0.3 * (1 - _animation.value)),
              ),
            ),
            // Inner circle
            Container(
              width: widget.size * 0.5,
              height: widget.size * 0.5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Full-screen loading overlay
class LoadingOverlay extends StatelessWidget {
  final String? message;
  final bool isLoading;
  final Widget child;

  const LoadingOverlay({
    Key? key,
    this.message,
    required this.isLoading,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: EnhancedLoadingWidget(
              message: message,
              style: LoadingStyle.pulse,
            ),
          ),
      ],
    );
  }
}
