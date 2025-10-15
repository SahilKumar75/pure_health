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
    if (widget.onItemSelected != null) {
      widget.onItemSelected(index);
    }
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = widget.selectedIndex == index;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: isExpanded ? null : const CircleBorder(),
        onTap: () => _handleNavigation(index),
        child: GlassContainer(
          borderRadius: BorderRadius.circular(isExpanded ? 16 : 32),
          blur: 10,
          opacity: 0.22,
          padding: EdgeInsets.symmetric(
            horizontal: isExpanded ? 16.0 : 12.0,
            vertical: 8.0,
          ),
          child: isExpanded
              ? Row(
                  children: [
                    Icon(
                      icon,
                      color: isSelected ? CupertinoColors.activeBlue : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          color: isSelected
                              ? CupertinoColors.activeBlue
                              : Colors.black,
                        ),
                      ),
                    ),
                  ],
                )
              : Icon(
                  icon,
                  color: isSelected ? CupertinoColors.activeBlue : null,
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
      padding: EdgeInsets.zero,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: isExpanded ? 200 : 72,
        child: Column(
          children: [
            // Menu button with label when expanded
            GlassContainer(
              borderRadius: BorderRadius.circular(16),
              blur: 12,
              opacity: 0.22,
              padding: const EdgeInsets.only(top: 8.0),
              child: isExpanded
                  ? Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.menu_open),
                          tooltip: 'Menu',
                          onPressed: () {
                            setState(() {
                              isExpanded = !isExpanded;
                            });
                          },
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Sidebar',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ],
                    )
                  : IconButton(
                      icon: Icon(Icons.menu),
                      tooltip: 'Menu',
                      onPressed: () {
                        setState(() {
                          isExpanded = !isExpanded;
                        });
                      },
                    ),
            ),
            const SizedBox(height: 16),
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
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Profile button
                  _buildNavItem(
                    icon: CupertinoIcons.profile_circled,
                    label: 'Profile',
                    index: 1,
                  ),
                  const SizedBox(height: 8),
                  // Settings button
                  _buildNavItem(
                    icon: CupertinoIcons.settings,
                    label: 'Settings',
                    index: 3,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}