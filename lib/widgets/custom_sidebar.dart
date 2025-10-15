import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

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

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: isExpanded ? 200 : 72,
      child: NavigationRail(
        backgroundColor: Colors.white,
        selectedIndex: widget.selectedIndex == 1 ? null : widget.selectedIndex,
        onDestinationSelected: widget.onItemSelected,
        labelType: isExpanded
            ? NavigationRailLabelType.none
            : NavigationRailLabelType.selected,
        extended: isExpanded,
        minWidth: 72,
        minExtendedWidth: 200,
        destinations: const [
          NavigationRailDestination(
            icon: Icon(CupertinoIcons.home),
            selectedIcon:
                Icon(CupertinoIcons.home, color: CupertinoColors.activeBlue),
            label: Text('Home'),
          ),
        ],
        leading: Container(
          width: 72,
          alignment: Alignment.center,
          padding: const EdgeInsets.only(top: 8.0),
          child: IconButton(
            icon: Icon(isExpanded ? Icons.menu_open : Icons.menu),
            tooltip: 'Menu',
            onPressed: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
          ),
        ),
        trailing: Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Profile button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    customBorder: isExpanded ? null : const CircleBorder(),
                    onTap: () => widget.onItemSelected(1),
                    child: Container(
                      width: isExpanded ? double.infinity : null,
                      padding: EdgeInsets.symmetric(
                        horizontal: isExpanded ? 16.0 : 12.0,
                        vertical: 8.0,
                      ),
                      child: isExpanded
                          ? Row(
                              children: [
                                Icon(
                                  CupertinoIcons.profile_circled,
                                  color: widget.selectedIndex == 1
                                      ? CupertinoColors.activeBlue
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Profile',
                                    style: TextStyle(
                                      color: widget.selectedIndex == 1
                                          ? CupertinoColors.activeBlue
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Icon(
                              CupertinoIcons.profile_circled,
                              color: widget.selectedIndex == 1
                                  ? CupertinoColors.activeBlue
                                  : null,
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Settings button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    customBorder: isExpanded ? null : const CircleBorder(),
                    onTap: () {
                      showModalBottomSheet<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return SizedBox(
                            height: 200,
                            child: Center(
                              child: Text(
                                'Settings placeholder',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: Container(
                      width: isExpanded ? double.infinity : null,
                      padding: EdgeInsets.symmetric(
                        horizontal: isExpanded ? 16.0 : 12.0,
                        vertical: 8.0,
                      ),
                      child: isExpanded
                          ? Row(
                              children: const [
                                Icon(CupertinoIcons.settings),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text('Settings'),
                                ),
                              ],
                            )
                          : const Icon(CupertinoIcons.settings),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}