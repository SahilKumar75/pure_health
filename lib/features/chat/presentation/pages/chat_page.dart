import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pure_health/core/constants/color_constants.dart';
import 'package:pure_health/core/theme/text_styles.dart';
import 'package:pure_health/shared/widgets/custom_sidebar.dart';
import '../providers/chat_provider.dart';
import '../../data/repositories/chat_repository.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  int _selectedIndex = 4;
  final _messageController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _messageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    
    final message = _messageController.text.trim();
    _messageController.clear();
    
    Provider.of<ChatProvider>(context, listen: false).sendMessage(message);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatProvider(ChatRepository()),
      child: Scaffold(
        backgroundColor: AppColors.lightCream,
        body: Row(
          children: [
            CustomSidebar(
              selectedIndex: _selectedIndex,
              onItemSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
            Expanded(
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.darkCream.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Text(
                      'PureHealth AI Assistant',
                      style: AppTextStyles.heading3.copyWith(
                        color: AppColors.charcoal,
                      ),
                    ),
                  ),
                  // Messages
                  Expanded(
                    child: Consumer<ChatProvider>(
                      builder: (context, chatProvider, _) {
                        return ListView.builder(
                          reverse: true,
                          padding: const EdgeInsets.all(16),
                          itemCount: chatProvider.messages.length,
                          itemBuilder: (context, index) {
                            final message =
                                chatProvider.messages[chatProvider.messages.length - 1 - index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                mainAxisAlignment: message.isUser
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                                children: [
                                  if (!message.isUser)
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: AppColors.darkVanilla
                                            .withOpacity(0.2),
                                        borderRadius:
                                            BorderRadius.circular(18),
                                      ),
                                      child: Icon(
                                        Icons.smart_toy,
                                        color: AppColors.darkVanilla,
                                        size: 20,
                                      ),
                                    ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Container(
                                      constraints: const BoxConstraints(
                                        maxWidth: 500,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: message.isUser
                                            ? AppColors.darkCream
                                                .withOpacity(0.2)
                                            : AppColors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppColors.darkCream
                                              .withOpacity(0.2),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        message.text,
                                        style: AppTextStyles.body.copyWith(
                                          color: AppColors.charcoal,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (message.isUser) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: AppColors.darkVanilla
                                            .withOpacity(0.2),
                                        borderRadius:
                                            BorderRadius.circular(18),
                                      ),
                                      child: Icon(
                                        Icons.person,
                                        color: AppColors.darkVanilla,
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  // Input
                  Consumer<ChatProvider>(
                    builder: (context, chatProvider, _) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          border: Border(
                            top: BorderSide(
                              color: AppColors.darkCream.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _messageController,
                                focusNode: _focusNode,
                                decoration: InputDecoration(
                                  hintText: 'Ask about water quality...',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: BorderSide(
                                      color: AppColors.darkCream
                                          .withOpacity(0.2),
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            FloatingActionButton(
                              onPressed: chatProvider.isLoading
                                  ? null
                                  : _sendMessage,
                              backgroundColor: chatProvider.isLoading
                                  ? AppColors.mediumGray
                                  : AppColors.darkVanilla,
                              child: const Icon(Icons.send),
                            ),
                          ],
                        ),
                      );
                    },
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
