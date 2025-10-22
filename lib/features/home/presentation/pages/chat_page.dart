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
  final FocusNode _focusNode = FocusNode();

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
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF343434);
    const messageBg = Color(0xFF2A2A2A);
    const inputBg = Color(0xFF3E3E3E);
    const borderColor = Color(0xFF525252);

    return CupertinoPageScaffold(
      backgroundColor: bgColor,
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
            // Main chat area (Claude web-style interface)
            Expanded(
              child: Column(
                children: [
                  // Chat messages area
                  Expanded(
                    child: Container(
                      color: bgColor,
                      child: ListView.builder(
                        reverse: true,
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[_messages.length - 1 - index];
                          return Center(
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 768),
                              padding: const EdgeInsets.symmetric(horizontal: 32),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 24),
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: msg.isUser ? messageBg : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  border: msg.isUser
                                      ? Border.all(
                                          color: borderColor.withOpacity(0.3),
                                          width: 1,
                                        )
                                      : null,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Message header with icon/avatar
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              gradient: msg.isUser
                                                  ? const LinearGradient(
                                                      colors: [
                                                        Color(0xFF667EEA),
                                                        Color(0xFF764BA2),
                                                      ],
                                                    )
                                                  : const LinearGradient(
                                                      colors: [
                                                        Color(0xFFD4A574),
                                                        Color(0xFFB8956A),
                                                      ],
                                                    ),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              msg.isUser
                                                  ? CupertinoIcons.person_fill
                                                  : CupertinoIcons.sparkles,
                                              size: 18,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            msg.isUser ? 'You' : 'Assistant',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                              letterSpacing: 0.2,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Message content
                                    Padding(
                                      padding: const EdgeInsets.only(left: 44),
                                      child: Text(
                                        msg.text,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.92),
                                          fontSize: 15,
                                          height: 1.6,
                                          letterSpacing: 0.1,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Input area fixed at bottom - Web style
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    decoration: BoxDecoration(
                      color: bgColor,
                      border: Border(
                        top: BorderSide(
                          color: borderColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 768),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: inputBg,
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: borderColor,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Attachment button
                              Padding(
                                padding: const EdgeInsets.only(left: 4, bottom: 4),
                                child: CupertinoButton(
                                  padding: const EdgeInsets.all(12),
                                  minSize: 0,
                                  onPressed: () {
                                    // TODO: Implement attachment
                                  },
                                  child: Icon(
                                    CupertinoIcons.paperclip,
                                    color: Colors.white.withOpacity(0.6),
                                    size: 22,
                                  ),
                                ),
                              ),
                              // Text input
                              Expanded(
                                child: CupertinoTextField(
                                  controller: _controller,
                                  focusNode: _focusNode,
                                  placeholder: "Message Assistant...",
                                  onSubmitted: (_) => _sendMessage(),
                                  onChanged: (_) => setState(() {}),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                    horizontal: 8,
                                  ),
                                  decoration: const BoxDecoration(
                                    color: Colors.transparent,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                    height: 1.5,
                                  ),
                                  placeholderStyle: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white.withOpacity(0.4),
                                  ),
                                  maxLines: 5,
                                  minLines: 1,
                                  textInputAction: TextInputAction.newline,
                                  cursorColor: Colors.white,
                                ),
                              ),
                              // Send button
                              Padding(
                                padding: const EdgeInsets.only(right: 4, bottom: 4),
                                child: CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  minSize: 0,
                                  onPressed: _controller.text.trim().isEmpty
                                      ? null
                                      : _sendMessage,
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      gradient: _controller.text.trim().isEmpty
                                          ? null
                                          : const LinearGradient(
                                              colors: [
                                                Color(0xFF667EEA),
                                                Color(0xFF764BA2),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                      color: _controller.text.trim().isEmpty
                                          ? Colors.white.withOpacity(0.1)
                                          : null,
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: Icon(
                                      CupertinoIcons.arrow_up,
                                      color: _controller.text.trim().isEmpty
                                          ? Colors.white.withOpacity(0.3)
                                          : Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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