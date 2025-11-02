import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:pure_health/core/constants/color_constants.dart';
import 'package:pure_health/core/theme/text_styles.dart';
import 'package:pure_health/shared/widgets/custom_sidebar.dart';
import '../viewmodel/chat_viewmodel.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  int _selectedIndex = 4;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatViewModel(),
      child: Scaffold(
        backgroundColor: AppColors.darkBg,
        body: Row(
          children: [
            CustomSidebar(
              selectedIndex: _selectedIndex,
              onItemSelected: (index) {
                setState(() => _selectedIndex = index);
              },
            ),
            Expanded(
              child: Consumer<ChatViewModel>(
                builder: (context, viewModel, _) {
                  return Column(
                    children: [
                      // Messages Area
                      Expanded(
                        child: viewModel.messages.isEmpty
                            ? _buildWelcomeScreen(context, viewModel)
                            : _buildMessagesScreen(context, viewModel),
                      ),

                      // Input Area
                      _buildInputArea(context, viewModel),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Welcome screen with greeting
  Widget _buildWelcomeScreen(BuildContext context, ChatViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Good evening',
            style: AppTextStyles.heading1.copyWith(
              color: AppColors.lightText,
              fontSize: 48,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bruce Wayne',
            style: AppTextStyles.body.copyWith(
              color: AppColors.mediumText,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 48),
          // Chat input box in center
          Container(
            constraints: const BoxConstraints(maxWidth: 1000),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Text(
                  'Upload water quality data and start asking questions',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.mediumText,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                // Centered input box
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.borderLight,
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      // Plus icon
                      CupertinoButton(
                        padding: const EdgeInsets.all(6),
                        minSize: 28,
                        onPressed: viewModel.isLoading
                            ? null
                            : () => _uploadFile(context, viewModel),
                        child: Icon(
                          CupertinoIcons.plus,
                          color: viewModel.isLoading
                              ? AppColors.dimText
                              : AppColors.mediumText,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Text input
                      Expanded(
                        child: TextField(
                          controller: viewModel.messageController,
                          enabled: !viewModel.isLoading,
                          maxLines: null,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            hintText: 'Ask about water quality...',
                            hintStyle: AppTextStyles.body.copyWith(
                              color: AppColors.dimText,
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.lightText,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Send button
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        minSize: 32,
                        onPressed: viewModel.isLoading
                            ? null
                            : () => _sendMessage(viewModel),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: viewModel.isLoading
                                ? AppColors.dimText
                                : AppColors.accentPink,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: viewModel.isLoading
                                ? SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                        AppColors.darkBg2,
                                      ),
                                    ),
                                  )
                                : Icon(
                                    CupertinoIcons.arrow_up,
                                    color: AppColors.darkBg2,
                                    size: 14,
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
        ],
      ),
    );
  }

  // Messages screen
  Widget _buildMessagesScreen(
      BuildContext context, ChatViewModel viewModel) {
    return ListView.builder(
      controller: viewModel.scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      itemCount: viewModel.messages.length,
      itemBuilder: (context, index) {
        final message = viewModel.messages[index];
        final isUser = message.role == 'user';

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isUser)
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.darkBg3,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text('🤖', style: TextStyle(fontSize: 18)),
                  ),
                ),
              if (!isUser) const SizedBox(width: 12),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isUser ? AppColors.accentPink : AppColors.darkBg3,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectableText(
                        message.message,
                        style: AppTextStyles.body.copyWith(
                          color: isUser ? AppColors.darkBg2 : AppColors.lightText,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      if (message.metadata != null &&
                          message.metadata!['prediction'] != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isUser
                                    ? AppColors.darkBg2.withOpacity(0.2)
                                    : AppColors.darkBg2,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '📊 Prediction',
                                    style:
                                        AppTextStyles.buttonSmall.copyWith(
                                      color: isUser
                                          ? AppColors.darkBg2
                                          : AppColors.accentPink,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Status: ${message.metadata!['prediction']['status']}',
                                    style: AppTextStyles.bodySmall
                                        .copyWith(
                                      color: isUser
                                          ? AppColors.darkBg2
                                          : AppColors.lightText,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    'Score: ${(message.metadata!['prediction']['score'] as num).toStringAsFixed(1)}/100',
                                    style: AppTextStyles.bodySmall
                                        .copyWith(
                                      color: isUser
                                          ? AppColors.darkBg2
                                          : AppColors.lightText,
                                      fontSize: 12,
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
              ),
              if (isUser) const SizedBox(width: 12),
              if (isUser)
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.accentPink,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text('👤', style: TextStyle(fontSize: 18)),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // Input area (moves to bottom when messages exist)
  Widget _buildInputArea(BuildContext context, ChatViewModel viewModel) {
    if (viewModel.messages.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.darkBg,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.borderLight,
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Plus icon
              CupertinoButton(
                padding: const EdgeInsets.all(6),
                minSize: 28,
                onPressed: viewModel.isLoading
                    ? null
                    : () => _uploadFile(context, viewModel),
                child: Icon(
                  CupertinoIcons.plus,
                  color: viewModel.isLoading
                      ? AppColors.dimText
                      : AppColors.mediumText,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              
              // Filter icon
              CupertinoButton(
                padding: const EdgeInsets.all(6),
                minSize: 28,
                onPressed: viewModel.isLoading ? null : () {},
                child: Icon(
                  CupertinoIcons.slider_horizontal_3,
                  color: viewModel.isLoading
                      ? AppColors.dimText
                      : AppColors.mediumText,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              
              // Timer icon
              CupertinoButton(
                padding: const EdgeInsets.all(6),
                minSize: 28,
                onPressed: viewModel.isLoading ? null : () {},
                child: Icon(
                  CupertinoIcons.timer,
                  color: viewModel.isLoading
                      ? AppColors.dimText
                      : AppColors.mediumText,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),

              // Text input
              Expanded(
                child: TextField(
                  controller: viewModel.messageController,
                  enabled: !viewModel.isLoading,
                  maxLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'How can I help you today?',
                    hintStyle: AppTextStyles.body.copyWith(
                      color: AppColors.dimText,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.lightText,
                    fontSize: 14,
                  ),
                  onSubmitted: (_) => _sendMessage(viewModel),
                ),
              ),
              const SizedBox(width: 12),

              // Model selector
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.darkBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'Sonnet 4.5',
                      child: Text('Sonnet 4.5'),
                    ),
                    const PopupMenuItem(
                      value: 'Claude 3',
                      child: Text('Claude 3'),
                    ),
                  ],
                  offset: const Offset(0, -100),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Sonnet 4.5',
                        style: AppTextStyles.buttonSmall.copyWith(
                          color: AppColors.lightText,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        CupertinoIcons.chevron_down,
                        color: AppColors.mediumText,
                        size: 10,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Send button
              CupertinoButton(
                padding: EdgeInsets.zero,
                minSize: 32,
                onPressed:
                    viewModel.isLoading ? null : () => _sendMessage(viewModel),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: viewModel.isLoading
                        ? AppColors.dimText
                        : AppColors.accentPink,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: viewModel.isLoading
                        ? SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.darkBg2,
                              ),
                            ),
                          )
                        : Icon(
                            CupertinoIcons.arrow_up,
                            color: AppColors.darkBg2,
                            size: 14,
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _uploadFile(
      BuildContext context, ChatViewModel viewModel) async {
    try {
      await viewModel.uploadFile();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ File uploaded: ${viewModel.fileInfo}'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _sendMessage(ChatViewModel viewModel) async {
    final message = viewModel.messageController.text.trim();
    if (message.isEmpty) return;

    viewModel.messageController.clear();

    try {
      await viewModel.sendMessage(message);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
