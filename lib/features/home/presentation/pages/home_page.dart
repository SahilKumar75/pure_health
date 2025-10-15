import 'package:flutter/material.dart';
import 'package:pure_health/widgets/custom_sidebar.dart';
import 'package:pure_health/widgets/custom_map_widget.dart';
import 'package:pure_health/widgets/glass_container.dart';
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
    return Scaffold(
      body: GlassContainer(
        borderRadius: BorderRadius.zero,
        blur: 18,
        opacity: 0.14,
        padding: EdgeInsets.zero,
        child: Row(
          children: [
            CustomSidebar(
              selectedIndex: _selectedIndex,
              onItemSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
            const Expanded(
              child: CustomMapWidget(
                zoom: 13.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
