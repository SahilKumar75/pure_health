import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A vertical floating card that acts as a chat interface, with collapse/expand and minimize features.
class VerticalFloatingCard extends StatefulWidget {
  final double width;
  final double collapsedVisibleWidth;
  final bool initiallyCollapsed;
  final Alignment alignment;
  final Duration duration;

  const VerticalFloatingCard({
    Key? key,
    this.width = 400,
    this.collapsedVisibleWidth = 48,
    this.initiallyCollapsed = false,
    this.alignment = Alignment.centerRight,
    this.duration = const Duration(milliseconds: 300),
  }) : super(key: key);

  @override
  State<VerticalFloatingCard> createState() => _VerticalFloatingCardState();
}

class _VerticalFloatingCardState extends State<VerticalFloatingCard> {
  late bool _collapsed;
  bool _isMinimized = false;
  final List<_ChatMessage> _messages = [
    _ChatMessage(text: "Hi! How can I help you today?", isUser: false),
  ];
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

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
  
  void _toggleMinimize() {
    setState(() {
      _isMinimized = !_isMinimized;
      if (_isMinimized) {
        _collapsed = false; // Expand if minimizing
      }
    });
  }

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

  Widget _buildChatContent() {
    const userBubble = Color(0xFF2A2A2A);
    const assistantBubble = Color(0xFF1A1A1A);
    const borderColor = Color(0xFF525252);

    return Column(
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'Chat',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withOpacity(0.95),
                    letterSpacing: -0.3,
                    fontFamily: 'SF Pro',
                  ),
                ),
                const SizedBox(width: 8),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minSize: 28,
                  onPressed: () {
                    GoRouter.of(context).go('/chat');
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF667EEA).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF667EEA).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      CupertinoIcons.arrow_up_right_square,
                      color: Color(0xFF667EEA),
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                // Minimize button
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minSize: 32,
                  onPressed: _toggleMinimize,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: borderColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      CupertinoIcons.minus_rectangle,
                      size: 16,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Collapse/Expand button
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minSize: 32,
                  onPressed: _toggle,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: borderColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      _collapsed ? CupertinoIcons.chevron_left : CupertinoIcons.chevron_right,
                      size: 16,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        Container(
          height: 1,
          margin: const EdgeInsets.symmetric(vertical: 12),
          color: borderColor.withOpacity(0.3),
        ),
        // Chat messages
        Expanded(
          child: ListView.builder(
            reverse: true,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final msg = _messages[_messages.length - 1 - index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
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
              );
            },
          ),
        ),
        // Input field
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF3E3E3E),
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
      ],
    );
  }

  Widget _buildMinimizedBox() {
    const bgColor = Color(0xFF343434);
    const borderColor = Color(0xFF525252);
    
    return GestureDetector(
      onTap: _toggleMinimize,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: borderColor.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 24,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF667EEA).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                CupertinoIcons.chat_bubble_2_fill,
                color: Color(0xFF667EEA),
                size: 22,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFEF5350),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${_messages.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'SF Pro',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF343434);
    final anchoredRight = widget.alignment == Alignment.centerRight;
    
    return SafeArea(
      child: Align(
        alignment: anchoredRight ? Alignment.bottomRight : Alignment.bottomLeft,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: 24,
            right: anchoredRight ? 16 : 0,
            left: anchoredRight ? 0 : 16,
          ),
          child: AnimatedSwitcher(
            duration: widget.duration,
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: animation,
                alignment: anchoredRight ? Alignment.bottomRight : Alignment.bottomLeft,
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: _isMinimized
                ? _buildMinimizedBox()
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final availableHeight = MediaQuery.of(context).size.height * 0.8;
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
                                  color: bgColor,
                                  borderRadius: anchoredRight
                                      ? const BorderRadius.only(
                                          topLeft: Radius.circular(24),
                                          bottomLeft: Radius.circular(24),
                                        )
                                      : const BorderRadius.only(
                                          topRight: Radius.circular(24),
                                          bottomRight: Radius.circular(24),
                                        ),
                                  border: Border.all(
                                    color: const Color(0xFF525252).withOpacity(0.3),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 24,
                                      offset: const Offset(0, 4),
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
                                    decoration: BoxDecoration(
                                      color: bgColor,
                                      borderRadius: anchoredRight
                                          ? const BorderRadius.only(
                                              topLeft: Radius.circular(24),
                                              bottomLeft: Radius.circular(24),
                                            )
                                          : const BorderRadius.only(
                                              topRight: Radius.circular(24),
                                              bottomRight: Radius.circular(24),
                                            ),
                                      border: Border.all(
                                        color: const Color(0xFF525252).withOpacity(0.3),
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          blurRadius: 24,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.08),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: const Color(0xFF525252).withOpacity(0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: Icon(
                                          anchoredRight
                                              ? CupertinoIcons.chevron_left
                                              : CupertinoIcons.chevron_right,
                                          size: 20,
                                          color: Colors.white.withOpacity(0.7),
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
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  const _ChatMessage({required this.text, required this.isUser});
}
