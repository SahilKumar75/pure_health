import 'package:flutter/material.dart';
import 'package:pure_health/core/utils/responsive_extensions.dart';

class ResponsiveScaffold extends StatelessWidget {
  final String? title;
  final List<Widget> actions;
  final Widget body;
  final Widget? drawer;
  final Widget? sidebar;
  final bool showSidebar;
  final double sidebarWidth;

  const ResponsiveScaffold({
    Key? key,
    this.title,
    this.actions = const [],
    required this.body,
    this.drawer,
    this.sidebar,
    this.showSidebar = true,
    this.sidebarWidth = 280,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;

    if (isMobile) {
      return Scaffold(
        appBar: AppBar(
          title: title != null ? Text(title!) : null,
          actions: actions,
        ),
        drawer: drawer,
        body: body,
      );
    }

    // Desktop/Tablet Layout - Two Pane
    if (showSidebar && sidebar != null) {
      return Scaffold(
        appBar: AppBar(
          title: title != null ? Text(title!) : null,
          actions: actions,
        ),
        body: Row(
          children: [
            // Sidebar
            Container(
              width: sidebarWidth,
              child: sidebar,
            ),
            // Divider
            VerticalDivider(width: 1),
            // Main Content
            Expanded(
              child: body,
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: title != null ? Text(title!) : null,
        actions: actions,
      ),
      body: body,
    );
  }
}
