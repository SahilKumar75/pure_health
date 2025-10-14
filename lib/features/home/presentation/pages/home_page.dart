import 'package:flutter/material.dart';
import 'package:pure_health/widgets/custom_title_bar.dart';
import 'package:pure_health/widgets/custom_map_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomTitleBar(title: 'Home'),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Welcome to the Home Page!'),
          const SizedBox(height: 16),
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
