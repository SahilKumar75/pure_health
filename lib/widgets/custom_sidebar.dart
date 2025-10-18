import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';


// Notification class to communicate sidebar expansion state
class SidebarExpandNotification extends Notification {
  final bool isExpanded;
  
  SidebarExpandNotification(this.isExpanded);
}


class CustomSidebar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;


  const CustomSidebar({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
  }) : super(key: key);


  @override
  State<CustomSidebar> createState() => _CustomSidebarState();
}


class _CustomSidebarState extends State<CustomSidebar> {
  bool isExpanded = false;


  void _handleNavigation(int index) {
    if (index == 0) {
      GoRouter.of(context).go('/');
    } else if (index == 1) {
      GoRouter.of(context).go('/profile');
    } else if (index == 2) {
      GoRouter.of(context).go('/history');
    } else if (index == 3) {
      GoRouter.of(context).go('/settings');
    }
    widget.onItemSelected(index);
  }


  void _toggleExpansion() {
    setState(() {
      isExpanded = !isExpanded;
    });
    // Send notification to parent widgets
    SidebarExpandNotification(isExpanded).dispatch(context);
  }


  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = widget.selectedIndex == index;
    final theme = Theme.of(context);
    final cupertinoTheme = CupertinoTheme.of(context);
    final primaryColor = theme.primaryColor;
  final labelColor = Colors.white;
  final inactiveColor = CupertinoColors.white.withOpacity(0.5);
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isExpanded ? 8.0 : 4.0,
        vertical: 4.0,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isExpanded ? 16 : 32),
          ),
          onTap: () => _handleNavigation(index),
          child: Container(
            padding: EdgeInsets.all(isExpanded ? 12.0 : 10.0),
            decoration: isSelected
                ? BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(isExpanded ? 16 : 32),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.25),
                      width: 1.5,
                    ),
                  )
                : null,
                    child: isExpanded
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                icon,
                color: CupertinoColors.white,
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Flexible(
                                fit: FlexFit.loose,
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : labelColor,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          )
                        : Center(
                            child: Icon(
                              icon,
                color: CupertinoColors.white,
                              size: 22,
                            ),
                          ),
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
  final theme = Theme.of(context);
  final cupertinoTheme = CupertinoTheme.of(context);
  final labelColor = cupertinoTheme.textTheme.textStyle.color ?? theme.textTheme.bodyMedium?.color ?? Colors.black;
  final inactiveColor = cupertinoTheme.primaryColor.withOpacity(0.4);
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF343434),
        borderRadius: BorderRadius.zero,
        border: const Border(
          right: BorderSide(
            color: Color(0xFFDDDDDD),
            width: 0.7,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: isExpanded ? 200 : 72,
        child: Column(
          children: [
            // Menu button
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isExpanded ? 8.0 : 4.0,
                vertical: 4.0,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  customBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  onTap: _toggleExpansion,
                  child: Container(
                    padding: EdgeInsets.all(isExpanded ? 12.0 : 10.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: isExpanded
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                CupertinoIcons.sidebar_left,
                                color: CupertinoColors.white,
                              ),
                              const SizedBox(width: 12),
                              Flexible(
                                fit: FlexFit.loose,
                                child: Text(
                                  'Menu',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: labelColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          )
                        : Center(
                            child: Icon(
                              CupertinoIcons.bars,
                              color: CupertinoColors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Home button
            _buildNavItem(
              icon: CupertinoIcons.home,
              label: 'Home',
              index: 0,
            ),
            // History button
            _buildNavItem(
              icon: CupertinoIcons.time,
              label: 'History',
              index: 2,
            ),
            const Spacer(),
            // Bottom buttons
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Profile button
                _buildNavItem(
                  icon: CupertinoIcons.person_circle,
                  label: 'Profile',
                  index: 1,
                ),
                // Settings button
                _buildNavItem(
                  icon: CupertinoIcons.settings,
                  label: 'Settings',
                  index: 3,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
