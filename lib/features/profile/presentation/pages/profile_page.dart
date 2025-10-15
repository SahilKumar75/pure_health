import 'package:flutter/material.dart';
import 'package:pure_health/widgets/custom_sidebar.dart';
import 'package:pure_health/widgets/glass_container.dart';
import 'package:pure_health/widgets/cupertino_button.dart';
import 'package:pure_health/widgets/cupertino_loader.dart';
import 'package:pure_health/widgets/cupertino_switch.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 1;

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      context.go('/');
    } else if (index == 1) {
      context.go('/profile');
    } else if (index == 2) {
      context.go('/history');
    }
  }

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
              onItemSelected: _onItemSelected,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GlassContainer(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        child: Icon(CupertinoIcons.person_crop_circle, size: 48),
                        backgroundColor: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Your Name',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'your.email@example.com',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      CupertinoButtonWidget(
                        text: 'Edit Profile',
                        onPressed: () {},
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Dark Mode'),
                          CupertinoSwitchWidget(
                            value: false,
                            onChanged: (val) {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const CupertinoLoader(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
