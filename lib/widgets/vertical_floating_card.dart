import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


/// A reusable vertical floating card with iOS-style glass effect.
/// - anchored to left or right
/// - extends from top to bottom with SafeArea
/// - collapses to a small visible tab and expands when tapped
/// - includes default Quick Tools content with iOS theming
class VerticalFloatingCard extends StatefulWidget {
  final double width;
  final double collapsedVisibleWidth;
  final Widget? child;
  final bool initiallyCollapsed;
  final Alignment alignment;
  final Duration duration;

  const VerticalFloatingCard({
    Key? key,
    this.width = 320,
    this.collapsedVisibleWidth = 32,
    this.child,
    this.initiallyCollapsed = false,
    this.alignment = Alignment.centerRight,
    this.duration = const Duration(milliseconds: 300),
  }) : super(key: key);

  @override
  State<VerticalFloatingCard> createState() => _VerticalFloatingCardState();
}

class _VerticalFloatingCardState extends State<VerticalFloatingCard> {
  late bool _collapsed;

  @override
  void initState() {
    super.initState();
    _collapsed = widget.initiallyCollapsed;
  }

  @override
  void didUpdateWidget(covariant VerticalFloatingCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initiallyCollapsed != widget.initiallyCollapsed) {
      _collapsed = widget.initiallyCollapsed;
    }
  }

  void _toggle() => setState(() => _collapsed = !_collapsed);

  // Default content widget with iOS theming
  Widget _buildDefaultContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with iOS style
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Quick Tools',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: CupertinoColors.label,
                  letterSpacing: -0.5,
                ),
              ),
              // Collapse button
              CupertinoButton(
                padding: EdgeInsets.zero,
                minSize: 32,
                onPressed: _toggle,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey5.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _collapsed ? CupertinoIcons.chevron_left : CupertinoIcons.chevron_right,
                    size: 18,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Divider
        Container(
          height: 0.5,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: const BoxDecoration(
            color: CupertinoColors.separator,
          ),
        ),
        // iOS-style list section
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: CupertinoListSection.insetGrouped(
              margin: EdgeInsets.zero,
              backgroundColor: Colors.transparent,
              decoration: BoxDecoration(
                color: CupertinoColors.secondarySystemGroupedBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              children: [
                CupertinoListTile(
                  backgroundColor: CupertinoColors.systemGroupedBackground,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          CupertinoColors.systemBlue,
                          CupertinoColors.systemBlue,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      CupertinoIcons.slider_horizontal_3,
                      color: CupertinoColors.white,
                      size: 20,
                    ),
                  ),
                  title: const Text(
                    'Filters',
                    style: TextStyle(
                      color: CupertinoColors.label,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: const Icon(
                    CupertinoIcons.chevron_right,
                    color: CupertinoColors.systemGrey3,
                    size: 16,
                  ),
                  onTap: () {},
                ),
                CupertinoListTile(
                  backgroundColor: CupertinoColors.systemGroupedBackground,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          CupertinoColors.systemGreen,
                          CupertinoColors.systemGreen,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      CupertinoIcons.share,
                      color: CupertinoColors.white,
                      size: 20,
                    ),
                  ),
                  title: const Text(
                    'Share',
                    style: TextStyle(
                      color: CupertinoColors.label,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: const Icon(
                    CupertinoIcons.chevron_right,
                    color: CupertinoColors.systemGrey3,
                    size: 16,
                  ),
                  onTap: () {},
                ),
                CupertinoListTile(
                  backgroundColor: CupertinoColors.systemGroupedBackground,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          CupertinoColors.systemPurple,
                          CupertinoColors.systemPurple,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      CupertinoIcons.chart_bar,
                      color: CupertinoColors.white,
                      size: 20,
                    ),
                  ),
                  title: const Text(
                    'Analytics',
                    style: TextStyle(
                      color: CupertinoColors.label,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: const Icon(
                    CupertinoIcons.chevron_right,
                    color: CupertinoColors.systemGrey3,
                    size: 16,
                  ),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final anchoredRight = widget.alignment == Alignment.centerRight;
    
    return SafeArea(
      child: Align(
        alignment: anchoredRight ? Alignment.centerRight : Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: 16,
            horizontal: anchoredRight ? 0 : 16,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final availableHeight = constraints.maxHeight.isInfinite
                  ? MediaQuery.of(context).size.height - 32
                  : constraints.maxHeight;

              return SizedBox(
                width: _collapsed ? widget.collapsedVisibleWidth : widget.width,
                height: availableHeight,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Main card with slide animation
                    AnimatedPositioned(
                      duration: widget.duration,
                      curve: Curves.easeInOut,
                      right: anchoredRight
                          ? (_collapsed ? -(widget.width - widget.collapsedVisibleWidth) : 0)
                          : null,
                      left: anchoredRight
                          ? null
                          : (_collapsed ? -(widget.width - widget.collapsedVisibleWidth) : 0),
                      top: 0,
                      bottom: 0,
                      width: widget.width,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: anchoredRight
                              ? const BorderRadius.only(
                                  topLeft: Radius.circular(24),
                                  bottomLeft: Radius.circular(24),
                                )
                              : const BorderRadius.only(
                                  topRight: Radius.circular(24),
                                  bottomRight: Radius.circular(24),
                                ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 20,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: widget.child ?? _buildDefaultContent(),
                      ),
                    ),
                    // Tap target when collapsed - visible tab area
                    if (_collapsed)
                      Positioned(
                        right: anchoredRight ? 0 : null,
                        left: anchoredRight ? null : 0,
                        top: 0,
                        bottom: 0,
                        width: widget.collapsedVisibleWidth,
                        child: GestureDetector(
                          onTap: _toggle,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                            ),
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: CupertinoColors.systemGrey5.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  anchoredRight
                                      ? CupertinoIcons.chevron_left
                                      : CupertinoIcons.chevron_right,
                                  size: 18,
                                  color: CupertinoColors.systemGrey,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}