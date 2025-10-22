import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

/// A vertical floating card that acts as a chat interface, with collapse/expand and const constructor support.
class VerticalFloatingCard extends StatefulWidget {
  final double width;
  final double collapsedVisibleWidth;
  final bool initiallyCollapsed;
  final Alignment alignment;
  final Duration duration;

  const VerticalFloatingCard({
    Key? key,
    this.width = 320,
    this.collapsedVisibleWidth = 32,
    this.initiallyCollapsed = false,
    this.alignment = Alignment.centerRight,
    this.duration = const Duration(milliseconds: 300),
  }) : super(key: key);

  @override
  State<VerticalFloatingCard> createState() => _VerticalFloatingCardState();
}

class _VerticalFloatingCardState extends State<VerticalFloatingCard> {
  late bool _collapsed;
  final List<_ChatMessage> _messages = [
    _ChatMessage(text: "Hi! How can I help you today?", isUser: false),
  ];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _collapsed = widget.initiallyCollapsed;
  }

  @override
  void didUpdateWidget(covariant VerticalFloatingCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initiallyCollapsed != widget.initiallyCollapsed) {
      _collapsed = widget.initiallyCollapsed;
    }
  }

  void _toggle() => setState(() => _collapsed = !_collapsed);

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _messages.add(_ChatMessage(text: "(This is a demo reply.)", isUser: false));
      _controller.clear();
    });
  }

  Widget _buildChatContent() {
    return Column(
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  'Chat',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: CupertinoColors.label,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 8),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minSize: 28,
                  onPressed: () {
                    GoRouter.of(context).go('/chat');
                  },
                  child: const Icon(
                    CupertinoIcons.arrow_up_right_square,
                    color: CupertinoColors.activeBlue,
                    size: 22,
                  ),
                ),
              ],
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              minSize: 32,
              onPressed: _toggle,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey5.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _collapsed ? CupertinoIcons.chevron_left : CupertinoIcons.chevron_right,
                  size: 18,
                  color: CupertinoColors.systemGrey,
                ),
              ),
            ),
          ],
        ),
        Container(
          height: 1,
          margin: const EdgeInsets.symmetric(vertical: 8),
          color: CupertinoColors.separator,
        ),
        // Chat messages
        Expanded(
          child: ListView.builder(
            reverse: true,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final msg = _messages[_messages.length - 1 - index];
              return Align(
                alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  decoration: BoxDecoration(
                    color: msg.isUser
                        ? CupertinoColors.activeBlue
                        : CupertinoColors.systemGrey5,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    msg.text,
                    style: TextStyle(
                      color: msg.isUser ? CupertinoColors.white : CupertinoColors.label,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // Input field
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              Expanded(
                child: CupertinoTextField(
                  controller: _controller,
                  placeholder: "Type a message...",
                  onSubmitted: (_) => _sendMessage(),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                ),
              ),
              const SizedBox(width: 8),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final anchoredRight = widget.alignment == Alignment.centerRight;
    return SafeArea(
      child: Align(
        alignment: anchoredRight ? Alignment.centerRight : Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: 16,
            horizontal: anchoredRight ? 0 : 16,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final availableHeight = constraints.maxHeight.isInfinite
                  ? MediaQuery.of(context).size.height - 32
                  : constraints.maxHeight;
              return SizedBox(
                width: _collapsed ? widget.collapsedVisibleWidth : widget.width,
                height: availableHeight,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Main card with slide animation
                    AnimatedPositioned(
                      duration: widget.duration,
                      curve: Curves.easeInOut,
                      right: anchoredRight
                          ? (_collapsed ? -(widget.width - widget.collapsedVisibleWidth) : 0)
                          : null,
                      left: anchoredRight
                          ? null
                          : (_collapsed ? -(widget.width - widget.collapsedVisibleWidth) : 0),
                      top: 0,
                      bottom: 0,
                      width: widget.width,
                      child: Container(
                        decoration: BoxDecoration(
                          color: CupertinoColors.white,
                          borderRadius: anchoredRight
                              ? const BorderRadius.only(
                                  topLeft: Radius.circular(24),
                                  bottomLeft: Radius.circular(24),
                                )
                              : const BorderRadius.only(
                                  topRight: Radius.circular(24),
                                  bottomRight: Radius.circular(24),
                                ),
                          boxShadow: [
                            BoxShadow(
                              color: CupertinoColors.systemGrey4,
                              blurRadius: 20,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: _buildChatContent(),
                      ),
                    ),
                    // Tap target when collapsed - visible tab area
                    if (_collapsed)
                      Positioned(
                        right: anchoredRight ? 0 : null,
                        left: anchoredRight ? null : 0,
                        top: 0,
                        bottom: 0,
                        width: widget.collapsedVisibleWidth,
                        child: GestureDetector(
                          onTap: _toggle,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: CupertinoColors.transparent,
                            ),
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: CupertinoColors.systemGrey5.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  anchoredRight
                                      ? CupertinoIcons.chevron_left
                                      : CupertinoIcons.chevron_right,
                                  size: 18,
                                  color: CupertinoColors.systemGrey,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
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