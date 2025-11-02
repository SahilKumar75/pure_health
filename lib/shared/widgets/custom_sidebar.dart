import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import '../../../app/config/app_router.dart';
import '../../../core/constants/color_constants.dart';
import '../../../core/theme/text_styles.dart';

class CustomSidebar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const CustomSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  State<CustomSidebar> createState() => _CustomSidebarState();
}

class _CustomSidebarState extends State<CustomSidebar> {
  bool isExpanded = false;

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
                    color: AppColors.accentPink.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(isExpanded ? 16 : 32),
                    border: Border.all(
                      color: AppColors.accentPink.withOpacity(0.3),
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
                            ? AppColors.accentPink
                            : AppColors.mediumText,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        fit: FlexFit.loose,
                        child: Text(
                          label,
                          style: AppTextStyles.button.copyWith(
                            color: isSelected
                                ? AppColors.accentPink
                                : AppColors.mediumText,
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
                          ? AppColors.accentPink
                          : AppColors.mediumText,
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
                                CupertinoIcons.sidebar_left,
                                color: AppColors.accentPink,
                                size: 18,
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
                              CupertinoIcons.bars,
                              color: AppColors.accentPink,
                              size: 18,
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
                itemCount: AppRouter.navigationItems.length,
                itemBuilder: (context, index) {
                  final item = AppRouter.navigationItems[index];
                  final iconMap = {
                    'home': CupertinoIcons.home,
                    'dashboard': CupertinoIcons.chart_bar_fill,
                    'history': CupertinoIcons.time,
                    'settings': CupertinoIcons.settings,
                    'chat': CupertinoIcons.chat_bubble_2,
                    'reports': CupertinoIcons.doc_fill,
                    'profile': CupertinoIcons.person_circle,
                  };

                  return _buildNavItem(
                    icon: iconMap[item['icon']] ?? CupertinoIcons.home,
                    label: item['label'] as String,
                    index: item['index'] as int,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
