import 'package:flutter/material.dart';
import 'package:pure_health/widgets/custom_sidebar.dart';
import 'package:pure_health/widgets/custom_map_widget.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      context.go('/');
    } else if (index == 1) {
      context.go('/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          CustomSidebar(
            selectedIndex: _selectedIndex,
            onItemSelected: _onItemSelected,
          ),
          const Expanded(
            child: CustomMapWidget(
              zoom: 13.0,
            ),
          ),
        ],
      ),
    );
  }
}
