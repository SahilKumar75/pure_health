import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pure_health/widgets/custom_sidebar.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  int _selectedIndex = 4; // Chat index in sidebar
  bool _isSidebarExpanded = false;
  final List<_ChatMessage> _messages = [
    _ChatMessage(text: "Hi! How can I help you today?", isUser: false),
  ];
  final TextEditingController _controller = TextEditingController();

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _messages.add(_ChatMessage(text: "(This is a demo reply.)", isUser: false));
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemBackground,
      child: NotificationListener<SidebarExpandNotification>(
        onNotification: (notification) {
          setState(() {
            _isSidebarExpanded = notification.isExpanded;
          });
          return true;
        },
        child: Row(
          children: [
            // Sidebar with dynamic width based on expand state
            CustomSidebar(
              selectedIndex: _selectedIndex,
              onItemSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
            // Main chat area (ChatGPT web style)
            Expanded(
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      boxShadow: [
                        BoxShadow(
                          color: CupertinoColors.systemGrey4.withOpacity(0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: const [
                        Text(
                          'Chat',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: CupertinoColors.label,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Chat messages area
                  Expanded(
                    child: Container(
                      color: CupertinoColors.extraLightBackgroundGray,
                      child: ListView.builder(
                        reverse: true,
                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 0),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[_messages.length - 1 - index];
                          return Row(
                            mainAxisAlignment: msg.isUser
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                constraints: const BoxConstraints(maxWidth: 420),
                                decoration: BoxDecoration(
                                  color: msg.isUser
                                      ? CupertinoColors.activeBlue
                                      : CupertinoColors.systemGrey5,
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(18),
                                    topRight: const Radius.circular(18),
                                    bottomLeft: Radius.circular(msg.isUser ? 18 : 4),
                                    bottomRight: Radius.circular(msg.isUser ? 4 : 18),
                                  ),
                                ),
                                child: Text(
                                  msg.text,
                                  style: TextStyle(
                                    color: msg.isUser ? CupertinoColors.white : CupertinoColors.label,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  // Input area fixed at bottom
                  Container(
                    color: CupertinoColors.white,
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                    child: Row(
                      children: [
                        Expanded(
                          child: CupertinoTextField(
                            controller: _controller,
                            placeholder: "Type a message...",
                            onSubmitted: (_) => _sendMessage(),
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                          ),
                        ),
                        const SizedBox(width: 12),
                        CupertinoButton(
                          padding: const EdgeInsets.all(0),
                          minSize: 36,
                          onPressed: _sendMessage,
                          child: const Icon(CupertinoIcons.arrow_up_circle_fill, color: CupertinoColors.activeBlue, size: 32),
                        ),
                      ],
                    ),
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

class _ChatMessage {
  final String text;
  final bool isUser;
  const _ChatMessage({required this.text, required this.isUser});
}