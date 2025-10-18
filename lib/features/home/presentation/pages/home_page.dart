import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pure_health/widgets/custom_sidebar.dart';
import 'package:pure_health/widgets/custom_map_widget.dart';
import 'package:pure_health/widgets/vertical_floating_card.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemBackground,
      child: Stack(
        children: [
          // Map widget as the base layer - provides content for glass blur effect
          const CustomMapWidget(
            zoom: 13.0,
            sidebarWidth: 72.0, // Pass collapsed width; for dynamic, lift state up
          ),
          // Sidebar with glass effect positioned on the left
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: CustomSidebar(
              selectedIndex: _selectedIndex,
              onItemSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ),
          // iOS-style vertical floating card on the right
          const VerticalFloatingCard(
            width: 320,
            initiallyCollapsed: false,
            alignment: Alignment.centerRight,
          ),
        ],
      ),
    );
  }
}
