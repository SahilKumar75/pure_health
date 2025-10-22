import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:pure_health/widgets/custom_sidebar.dart';
import 'package:pure_health/widgets/vertical_floating_card.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  int _selectedIndex = 4; // Chat index in sidebar

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemBackground,
      child: Stack(
        children: [
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
          // Main chat floating card
          Align(
            alignment: Alignment.centerRight,
            child: VerticalFloatingCard(
              width: 320,
              initiallyCollapsed: false,
              alignment: Alignment.centerRight,
            ),
          ),
        ],
      ),
    );
  }
}
