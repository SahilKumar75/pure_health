import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import '../../../app/config/app_router.dart';
import '../../../core/constants/color_constants.dart';
import '../../../core/theme/text_styles.dart';

class CustomSidebar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final ValueChanged<bool>? onExpansionChanged;

  const CustomSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    this.onExpansionChanged,
  });

  @override
  State<CustomSidebar> createState() => _CustomSidebarState();
}

class _CustomSidebarState extends State<CustomSidebar> {
  bool isExpanded = true; // Changed to true for expanded by default

  void _handleNavigation(int index) {
    try {
      final route = AppRouter.getRouteByIndex(index);
      if (context.mounted && GoRouter.maybeOf(context) != null) {
        context.go(route);
        widget.onItemSelected(index);
      }
    } catch (e) {
      debugPrint('❌ Navigation error: $e');
    }
  }

  void _toggleExpansion() {
    setState(() {
      isExpanded = !isExpanded;
    });
    widget.onExpansionChanged?.call(isExpanded);
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    String? shortcut,
  }) {
    final isSelected = widget.selectedIndex == index;

    final navItem = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isExpanded ? 8.0 : 4.0,
        vertical: 4.0,
      ),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              customBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isExpanded ? 16 : 32),
              ),
              onTap: () => _handleNavigation(index),
              hoverColor: AppColors.primaryBlue.withOpacity(0.08),
              splashColor: AppColors.primaryBlue.withOpacity(0.2),
              child: Container(
                padding: EdgeInsets.all(isExpanded ? 12.0 : 10.0),
                decoration: isSelected
                    ? BoxDecoration(
                        color: AppColors.primaryBlue.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(isExpanded ? 16 : 32),
                        border: Border.all(
                          color: AppColors.primaryBlue.withOpacity(0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryBlue.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      )
                    : null,
                child: isExpanded
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            icon,
                            color: isSelected
                                ? AppColors.primaryBlue
                                : AppColors.mediumText,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              label,
                              style: AppTextStyles.button.copyWith(
                                color: isSelected
                                    ? AppColors.primaryBlue
                                    : AppColors.mediumText,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (shortcut != null && isExpanded) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.darkBg3,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: AppColors.borderLight,
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                shortcut,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.dimText,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      )
                    : Center(
                        child: Icon(
                          icon,
                          color: isSelected
                              ? AppColors.primaryBlue
                              : AppColors.mediumText,
                          size: 22,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );

    // Add tooltip when sidebar is collapsed
    if (!isExpanded) {
      return Tooltip(
        message: shortcut != null ? '$label ($shortcut)' : label,
        preferBelow: false,
        verticalOffset: 8,
        waitDuration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          color: AppColors.charcoal,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: AppColors.charcoal.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        textStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w500,
        ),
        child: navItem,
      );
    }

    return navItem;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkBg2,
        border: Border(
          right: BorderSide(
            color: AppColors.borderLight,
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
            // Toggle button
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
                      color: AppColors.darkBg3,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: isExpanded
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.menu_open,
                                color: AppColors.primaryBlue,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Flexible(
                                child: Text(
                                  'Menu',
                                  style: AppTextStyles.button.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.lightText,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          )
                        : Center(
                            child: Icon(
                              Icons.menu,
                              color: AppColors.primaryBlue,
                              size: 20,
                            ),
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Main navigation items (top section)
            Expanded(
              child: Column(
                children: [
                  // Main navigation items
                  Expanded(
                    child: ListView.builder(
                      itemCount: AppRouter.navigationItems.length - 2, // Exclude Profile and Settings
                      itemBuilder: (context, index) {
                        final item = AppRouter.navigationItems[index];
                        final iconMap = {
                          'home': Icons.home_outlined,
                          'dashboard': Icons.dashboard_outlined,
                          'live_monitoring': Icons.sensors_outlined,
                          'history': Icons.description_outlined,
                          'settings': Icons.settings_outlined,
                          'ai': Icons.forum_outlined,
                          'profile': Icons.person_outline,
                        };

                        final shortcutMap = {
                          0: '⌘1',
                          1: '⌘2',
                          2: '⌘3',
                          3: '⌘4',
                          4: '⌘5',
                          5: '⌘6',
                          6: '⌘7',
                        };

                        return _buildNavItem(
                          icon: iconMap[item['icon']] ?? Icons.home_outlined,
                          label: item['label'] as String,
                          index: item['index'] as int,
                          shortcut: shortcutMap[item['index'] as int],
                        );
                      },
                    ),
                  ),
                  
                  // Spacer divider
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isExpanded ? 16.0 : 8.0,
                      vertical: 8.0,
                    ),
                    child: Container(
                      height: 1,
                      color: AppColors.borderLight,
                    ),
                  ),
                  
                  // Bottom items (Profile and Settings)
                  ...AppRouter.navigationItems
                      .skip(AppRouter.navigationItems.length - 2) // Last 2 items
                      .map((item) {
                    final iconMap = {
                      'home': Icons.home_outlined,
                      'dashboard': Icons.dashboard_outlined,
                      'live_monitoring': Icons.sensors_outlined,
                      'history': Icons.description_outlined,
                      'settings': Icons.settings_outlined,
                      'ai': Icons.forum_outlined,
                      'profile': Icons.person_outline,
                    };

                    final shortcutMap = {
                      0: '⌘1',
                      1: '⌘2',
                      2: '⌘3',
                      3: '⌘4',
                      4: '⌘5',
                      5: '⌘6',
                      6: '⌘7',
                    };

                    return _buildNavItem(
                      icon: iconMap[item['icon']] ?? Icons.home_outlined,
                      label: item['label'] as String,
                      index: item['index'] as int,
                      shortcut: shortcutMap[item['index'] as int],
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
