import 'package:flutter/material.dart';
import 'package:pure_health/widgets/custom_title_bar.dart';
import 'package:pure_health/widgets/custom_map_widget.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomTitleBar(
        title: 'Home',
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.account_circle, size: 28),
              onPressed: () {
                context.go('/profile');
              },
            ),
          ),
        ],
      ),
      body: const CustomMapWidget(
        zoom: 13.0,
      ),
    );
  }
}
