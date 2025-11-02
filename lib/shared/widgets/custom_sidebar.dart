import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/color_constants.dart';
import '../../../core/theme/text_styles.dart';

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

  // Navigation items list
  final List<Map<String, dynamic>> navigationItems = [
    {
      'icon': CupertinoIcons.home,
      'label': 'Home',
      'index': 0,
      'route': '/',
    },
    {
      'icon': CupertinoIcons.chart_bar_fill,
      'label': 'Dashboard',
      'index': 1,
      'route': '/dashboard',
    },
    {
      'icon': CupertinoIcons.time,
      'label': 'History',
      'index': 2,
      'route': '/history',
    },
    {
      'icon': CupertinoIcons.settings,
      'label': 'Settings',
      'index': 3,
      'route': '/settings',
    },
    {
      'icon': CupertinoIcons.chat_bubble_2,
      'label': 'Chat',
      'index': 4,
      'route': '/chat',
    },
  ];

  void _handleNavigation(int index) {
    try {
      // Find the route for this index
      final item = navigationItems.firstWhere(
        (item) => item['index'] == index,
        orElse: () => {'route': '/'},
      );

      // Only navigate if GoRouter is available in context
      if (context.mounted && GoRouter.maybeOf(context) != null) {
        context.go(item['route']);
      }
    } catch (e) {
      debugPrint('Navigation error: $e');
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
                    color: AppColors.darkVanilla.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(isExpanded ? 16 : 32),
                    border: Border.all(
                      color: AppColors.darkVanilla.withOpacity(0.4),
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
                        color: isSelected
                            ? AppColors.darkVanilla
                            : AppColors.charcoal,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        fit: FlexFit.loose,
                        child: Text(
                          label,
                          style: AppTextStyles.button.copyWith(
                            color: isSelected
                                ? AppColors.darkVanilla
                                : AppColors.charcoal,
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
                      color: isSelected
                          ? AppColors.darkVanilla
                          : AppColors.charcoal,
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.zero,
        border: Border(
          right: BorderSide(
            color: AppColors.darkCream.withOpacity(0.2),
            width: 1,
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
                      color: AppColors.darkCream.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: isExpanded
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                CupertinoIcons.sidebar_left,
                                color: AppColors.charcoal,
                              ),
                              const SizedBox(width: 12),
                              Flexible(
                                fit: FlexFit.loose,
                                child: Text(
                                  'Menu',
                                  style: AppTextStyles.button.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.charcoal,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          )
                        : Center(
                            child: Icon(
                              CupertinoIcons.bars,
                              color: AppColors.charcoal,
                            ),
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Navigation items
            Expanded(
              child: ListView.builder(
                itemCount: navigationItems.length,
                itemBuilder: (context, index) {
                  final item = navigationItems[index];
                  return _buildNavItem(
                    icon: item['icon'] as IconData,
                    label: item['label'] as String,
                    index: item['index'] as int,
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Bottom buttons (Profile)
            _buildNavItem(
              icon: CupertinoIcons.person_circle,
              label: 'Profile',
              index: 5,
            ),
          ],
        ),
      ),
    );
  }
}
