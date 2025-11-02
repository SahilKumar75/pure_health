import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:pure_health/core/utils/responsive_extensions.dart';

class WebLayout extends StatelessWidget {
  final Widget? sidebar;
  final Widget mainContent;
  final double maxWidth;
  final double sidebarWidth;

  const WebLayout({
    Key? key,
    this.sidebar,
    required this.mainContent,
    this.maxWidth = 1400,
    this.sidebarWidth = 300,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;

    if (isMobile) {
      return SingleChildScrollView(
        child: Column(
          children: [
            if (sidebar != null) sidebar!,
            mainContent,
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sidebar
                if (sidebar != null) ...[
                  Container(
                    width: sidebarWidth,
                    child: sidebar,
                  ),
                  SizedBox(width: 3.w),
                ],
                // Main Content
                Expanded(
                  child: mainContent,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
