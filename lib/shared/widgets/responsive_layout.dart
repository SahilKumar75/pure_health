import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pure_health/core/utils/responsive_utils.dart';
import 'package:pure_health/core/constants/color_constants.dart';
import 'package:pure_health/shared/widgets/custom_sidebar.dart';

/// Responsive scaffold that adapts layout based on screen size
class ResponsiveScaffold extends StatefulWidget {
  final Widget body;
  final int selectedIndex;
  final ValueChanged<int> onNavigationChanged;
  final String? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Color? backgroundColor;

  const ResponsiveScaffold({
    Key? key,
    required this.body,
    required this.selectedIndex,
    required this.onNavigationChanged,
    this.title,
    this.actions,
    this.floatingActionButton,
    this.backgroundColor,
  }) : super(key: key);

  @override
  State<ResponsiveScaffold> createState() => _ResponsiveScaffoldState();
}

class _ResponsiveScaffoldState extends State<ResponsiveScaffold> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final isTablet = context.isTablet;

    if (isMobile) {
      return _buildMobileLayout();
    } else if (isTablet) {
      return _buildTabletLayout();
    } else {
      return _buildDesktopLayout();
    }
  }

  // Mobile layout with bottom navigation
  Widget _buildMobileLayout() {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: widget.backgroundColor ?? AppColors.lightCream,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(CupertinoIcons.bars, color: AppColors.charcoal),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: widget.title != null
            ? Text(
                widget.title!,
                style: TextStyle(
                  color: AppColors.charcoal,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              )
            : null,
        actions: widget.actions,
      ),
      drawer: _buildMobileDrawer(),
      body: SafeArea(
        child: widget.body,
      ),
      floatingActionButton: widget.floatingActionButton,
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  // Tablet layout with rail navigation
  Widget _buildTabletLayout() {
    return Scaffold(
      backgroundColor: widget.backgroundColor ?? AppColors.lightCream,
      body: Row(
        children: [
          CustomSidebar(
            selectedIndex: widget.selectedIndex,
            onItemSelected: widget.onNavigationChanged,
          ),
          Expanded(
            child: Column(
              children: [
                if (widget.title != null || widget.actions != null)
                  _buildAppBar(),
                Expanded(child: widget.body),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: widget.floatingActionButton,
    );
  }

  // Desktop layout with permanent sidebar
  Widget _buildDesktopLayout() {
    return Scaffold(
      backgroundColor: widget.backgroundColor ?? AppColors.lightCream,
      body: Row(
        children: [
          CustomSidebar(
            selectedIndex: widget.selectedIndex,
            onItemSelected: widget.onNavigationChanged,
          ),
          Expanded(
            child: Column(
              children: [
                if (widget.title != null || widget.actions != null)
                  _buildAppBar(),
                Expanded(child: widget.body),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: widget.floatingActionButton,
    );
  }

  Widget _buildAppBar() {
    return Container(
      height: 64,
      padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(
            color: AppColors.darkCream.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          if (widget.title != null)
            Text(
              widget.title!,
              style: TextStyle(
                color: AppColors.charcoal,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
          const Spacer(),
          if (widget.actions != null) ...widget.actions!,
        ],
      ),
    );
  }

  Widget _buildMobileDrawer() {
    return Drawer(
      backgroundColor: AppColors.darkBg2,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Text(
                    '💧',
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'PureHealth',
                    style: TextStyle(
                      color: AppColors.lightText,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: AppColors.borderLight),
            Expanded(
              child: _buildDrawerItems(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItems() {
    final items = [
      {'icon': CupertinoIcons.home, 'label': 'Home', 'index': 0},
      {'icon': CupertinoIcons.chart_bar_fill, 'label': 'Dashboard', 'index': 1},
      {'icon': CupertinoIcons.time, 'label': 'History', 'index': 2},
      {'icon': CupertinoIcons.settings, 'label': 'Settings', 'index': 3},
      {'icon': CupertinoIcons.chat_bubble_2, 'label': 'Chat', 'index': 4},
      {'icon': CupertinoIcons.person_circle, 'label': 'Profile', 'index': 5},
      {'icon': CupertinoIcons.doc_fill, 'label': 'Reports', 'index': 6},
    ];

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: items.map((item) {
        final isSelected = widget.selectedIndex == item['index'];
        return ListTile(
          leading: Icon(
            item['icon'] as IconData,
            color: isSelected ? AppColors.accentPink : AppColors.mediumText,
            size: 24,
          ),
          title: Text(
            item['label'] as String,
            style: TextStyle(
              color: isSelected ? AppColors.accentPink : AppColors.lightText,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          selected: isSelected,
          selectedTileColor: AppColors.accentPink.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          onTap: () {
            widget.onNavigationChanged(item['index'] as int);
            Navigator.of(context).pop();
          },
        );
      }).toList(),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomNavItem(CupertinoIcons.home, 'Home', 0),
              _buildBottomNavItem(CupertinoIcons.chart_bar_fill, 'Dashboard', 1),
              _buildBottomNavItem(CupertinoIcons.time, 'History', 2),
              _buildBottomNavItem(CupertinoIcons.chat_bubble_2, 'Chat', 4),
              _buildBottomNavItem(CupertinoIcons.person_circle, 'Profile', 5),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, int index) {
    final isSelected = widget.selectedIndex == index;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => widget.onNavigationChanged(index),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isSelected ? AppColors.accentPink : AppColors.mediumGray,
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? AppColors.accentPink : AppColors.mediumGray,
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
