import 'package:flutter/material.dart';
import 'glass_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

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

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = widget.selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isExpanded ? 16 : 32),
          ),
          onTap: () => _handleNavigation(index),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isExpanded ? 16.0 : 12.0,
              vertical: 12.0,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? CupertinoColors.activeBlue.withOpacity(0.15)
                  : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(isExpanded ? 16 : 32),
              border: Border.all(
                color: isSelected
                    ? CupertinoColors.activeBlue.withOpacity(0.3)
                    : Colors.white.withOpacity(0.1),
                width: 1.5,
              ),
            ),
            child: isExpanded
                ? Row(
                    children: [
                      Icon(
                        icon,
                        color: isSelected
                            ? CupertinoColors.activeBlue
                            : CupertinoColors.systemGrey,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          label,
                          style: TextStyle(
                            color: isSelected
                                ? CupertinoColors.activeBlue
                                : CupertinoColors.label,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  )
                : Icon(
                    icon,
                    color: isSelected
                        ? CupertinoColors.activeBlue
                        : CupertinoColors.systemGrey,
                    size: 22,
                  ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: BorderRadius.circular(24),
      blur: 16,
      opacity: 0.18,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: isExpanded ? 200 : 72,
        child: Column(
          children: [
            // Menu button
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  customBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  onTap: () {
                    setState(() {
                      isExpanded = !isExpanded;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: isExpanded
                        ? Row(
                            children: [
                              Icon(
                                CupertinoIcons.sidebar_left,
                                color: CupertinoColors.systemGrey,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Menu',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: CupertinoColors.label,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Icon(
                            CupertinoIcons.bars,
                            color: CupertinoColors.systemGrey,
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
