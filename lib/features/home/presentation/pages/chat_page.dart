import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pure_health/widgets/custom_sidebar.dart';
import 'package:pure_health/widgets/custom_map_widget.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  int _selectedIndex = 4;
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
    const userBubble = Color(0xFF2A2A2A);
    const assistantBubble = Color(0xFF1A1A1A);
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
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.35,
                  child: CustomMapWidget(
                    sidebarWidth: 72.0,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                color: bgColor.withOpacity(0.85),
              ),
            ),
            Row(
              children: [
                CustomSidebar(
                  selectedIndex: _selectedIndex,
                  onItemSelected: (int index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                ),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          color: Colors.transparent,
                          child: ListView.builder(
                            reverse: true,
                            padding: const EdgeInsets.all(16),
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              final msg = _messages[_messages.length - 1 - index];
                              return Center(
                                child: Container(
                                  constraints: const BoxConstraints(maxWidth: 800),
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Row(
                                    mainAxisAlignment: msg.isUser
                                        ? MainAxisAlignment.end
                                        : MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (!msg.isUser) ...[
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFB8956A),
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: const Icon(
                                            CupertinoIcons.sparkles,
                                            size: 18,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                      ],
                                      Flexible(
                                        child: Container(
                                          constraints: const BoxConstraints(maxWidth: 500),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: msg.isUser ? userBubble : assistantBubble,
                                            borderRadius: msg.isUser
                                                ? const BorderRadius.only(
                                                    topLeft: Radius.circular(18),
                                                    topRight: Radius.circular(4),
                                                    bottomLeft: Radius.circular(18),
                                                    bottomRight: Radius.circular(18),
                                                  )
                                                : const BorderRadius.only(
                                                    topLeft: Radius.circular(4),
                                                    topRight: Radius.circular(18),
                                                    bottomLeft: Radius.circular(18),
                                                    bottomRight: Radius.circular(18),
                                                  ),
                                            border: Border.all(
                                              color: borderColor.withOpacity(0.2),
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            msg.text,
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(0.95),
                                              fontSize: 15,
                                              height: 1.5,
                                              fontFamily: 'SF Pro',
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (msg.isUser) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF667EEA),
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: const Icon(
                                            CupertinoIcons.person_fill,
                                            size: 18,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border(
                            top: BorderSide(
                              color: borderColor.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                        ),
                        child: SafeArea(
                          top: false,
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 800),
                            decoration: BoxDecoration(
                              color: inputBg,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: borderColor.withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                CupertinoButton(
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
                                Expanded(
                                  child: CupertinoTextField(
                                    controller: _controller,
                                    focusNode: _focusNode,
                                    placeholder: "Message Assistant...",
                                    onSubmitted: (_) => _sendMessage(),
                                    onChanged: (_) => setState(() {}),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 4,
                                    ),
                                    decoration: const BoxDecoration(
                                      color: Colors.transparent,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.white,
                                      height: 1.4,
                                      fontFamily: 'SF Pro',
                                    ),
                                    placeholderStyle: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white.withOpacity(0.4),
                                      fontFamily: 'SF Pro',
                                    ),
                                    maxLines: 6,
                                    minLines: 1,
                                    textInputAction: TextInputAction.newline,
                                    cursorColor: Colors.white,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    minSize: 0,
                                    onPressed: _controller.text.trim().isEmpty
                                        ? null
                                        : _sendMessage,
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: _controller.text.trim().isEmpty
                                            ? Colors.white.withOpacity(0.1)
                                            : const Color(0xFF667EEA),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Icon(
                                        CupertinoIcons.arrow_up,
                                        color: _controller.text.trim().isEmpty
                                            ? Colors.white.withOpacity(0.3)
                                            : Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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