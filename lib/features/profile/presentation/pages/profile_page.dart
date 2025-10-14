import 'package:flutter/material.dart';
import 'package:pure_health/widgets/custom_title_bar.dart';
import 'package:pure_health/widgets/glass_container.dart';
import 'package:pure_health/widgets/cupertino_button.dart';
import 'package:pure_health/widgets/cupertino_loader.dart';
import 'package:pure_health/widgets/cupertino_switch.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomTitleBar(
        title: 'Profile',
        height: kToolbarHeight + 16,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () {
            context.go('/');
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Icon(CupertinoIcons.person_crop_circle, size: 28),
          ),
        ],
      ),
      body: Padding(
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
    );
  }
}
