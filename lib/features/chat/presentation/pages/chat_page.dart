import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pure_health/core/constants/color_constants.dart';
import 'package:pure_health/core/theme/text_styles.dart';
import 'package:pure_health/shared/widgets/custom_sidebar.dart';
import 'package:pure_health/shared/widgets/custom_map_widget.dart';
import 'package:pure_health/shared/widgets/vertical_floating_card.dart';
import 'package:pure_health/shared/widgets/custom_alert.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';

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
    return Scaffold(
      backgroundColor: AppColors.lightCream,
      body: NotificationListener<SidebarExpandNotification>(
        onNotification: (notification) {
          setState(() {
            _isSidebarExpanded = notification.isExpanded;
          });
          return true;
        },
        child: Stack(
          children: [
            // Background map with overlay
            Positioned.fill(
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.2,
                  child: CustomMapWidget(
                    sidebarWidth: 72.0,
                  ),
                ),
              ),
            ),
            // Cream color overlay
            Positioned.fill(
              child: Container(
                color: AppColors.lightCream.withOpacity(0.90),
              ),
            ),
            // Main layout
            Row(
              children: [
                // Sidebar
                CustomSidebar(
                  selectedIndex: _selectedIndex,
                  onItemSelected: (int index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                ),
                // Chat content
                Expanded(
                  child: Column(
                    children: [
                      // Messages area
                      Expanded(
                        child: Container(
                          color: Colors.transparent,
                          child: ListView.builder(
                            reverse: true,
                            padding: const EdgeInsets.all(16),
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              final msg =
                                  _messages[_messages.length - 1 - index];
                              return Center(
                                child: Container(
                                  constraints:
                                      const BoxConstraints(maxWidth: 800),
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Row(
                                    mainAxisAlignment: msg.isUser
                                        ? MainAxisAlignment.end
                                        : MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (!msg.isUser) ...[
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: AppColors.darkVanilla
                                                .withOpacity(0.3),
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: Icon(
                                            CupertinoIcons.sparkles,
                                            size: 18,
                                            color: AppColors.darkVanilla,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                      ],
                                      Flexible(
                                        child: Container(
                                          constraints: const BoxConstraints(
                                              maxWidth: 500),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: msg.isUser
                                                ? AppColors.darkCream
                                                    .withOpacity(0.2)
                                                : AppColors.white,
                                            borderRadius: msg.isUser
                                                ? const BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(18),
                                                    topRight:
                                                        Radius.circular(4),
                                                    bottomLeft:
                                                        Radius.circular(18),
                                                    bottomRight:
                                                        Radius.circular(18),
                                                  )
                                                : const BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(4),
                                                    topRight:
                                                        Radius.circular(18),
                                                    bottomLeft:
                                                        Radius.circular(18),
                                                    bottomRight:
                                                        Radius.circular(18),
                                                  ),
                                            border: Border.all(
                                              color: AppColors.darkCream
                                                  .withOpacity(0.2),
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            msg.text,
                                            style: AppTextStyles.body
                                                .copyWith(
                                              color: AppColors.charcoal,
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
                                            color: AppColors.darkVanilla
                                                .withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: Icon(
                                            CupertinoIcons.person_fill,
                                            size: 18,
                                            color: AppColors.darkVanilla,
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
                      // Input area
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border(
                            top: BorderSide(
                              color: AppColors.darkCream.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                        ),
                        child: SafeArea(
                          top: false,
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 800),
                            decoration: BoxDecoration(
                              color: AppColors.darkCream.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: AppColors.darkCream.withOpacity(0.2),
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
                                    color: AppColors.mediumGray,
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
                                    style: AppTextStyles.body.copyWith(
                                      color: AppColors.charcoal,
                                    ),
                                    placeholderStyle:
                                        AppTextStyles.body.copyWith(
                                      color: AppColors.mediumGray
                                          .withOpacity(0.5),
                                    ),
                                    maxLines: 6,
                                    minLines: 1,
                                    textInputAction: TextInputAction.newline,
                                    cursorColor: AppColors.darkVanilla,
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
                                            ? AppColors.darkCream
                                                .withOpacity(0.1)
                                            : AppColors.darkVanilla,
                                        borderRadius:
                                            BorderRadius.circular(16),
                                      ),
                                      child: Icon(
                                        CupertinoIcons.arrow_up,
                                        color: _controller.text
                                                .trim()
                                                .isEmpty
                                            ? AppColors.mediumGray
                                                .withOpacity(0.3)
                                            : AppColors.white,
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
