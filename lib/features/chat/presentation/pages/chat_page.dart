import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:pure_health/core/constants/color_constants.dart';
import 'package:pure_health/core/theme/text_styles.dart';
import 'package:pure_health/core/theme/government_theme.dart';
import 'package:pure_health/shared/widgets/custom_sidebar.dart';
import 'package:pure_health/shared/widgets/toast_notification.dart';
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
    final timeOfDay = _getTimeOfDay();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              // Icon
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutBack,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: child,
                  );
                },
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: GovernmentTheme.governmentBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text('💧', style: TextStyle(fontSize: 40)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Good $timeOfDay',
                style: AppTextStyles.heading1.copyWith(
                  color: AppColors.lightText,
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Water Quality Analysis Assistant',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.mediumText,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 48),
              
              // Quick action cards
              Text(
                'What can I help you with today?',
                style: AppTextStyles.heading4.copyWith(
                  color: AppColors.lightText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              _buildSuggestionCards(viewModel),
              const SizedBox(height: 48),
              // Input prompt
              Text(
                'Or type your question below',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.mediumText,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
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
                          onSubmitted: (_) => _sendMessage(viewModel),
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
      ),
    );
  }

  Widget _buildSuggestionCards(ChatViewModel viewModel) {
    final suggestions = [
      {
        'icon': '📊',
        'title': 'Analyze Trends',
        'description': 'Get insights on water quality patterns over time',
        'prompt': 'Analyze the water quality trends from my data and identify any concerning patterns.',
      },
      {
        'icon': '📈',
        'title': 'Generate Report',
        'description': 'Create comprehensive compliance reports',
        'prompt': 'Generate a detailed compliance report for all water quality parameters.',
      },
      {
        'icon': '⚠️',
        'title': 'Risk Assessment',
        'description': 'Identify potential contamination risks',
        'prompt': 'Assess the risk levels across all monitoring zones and provide recommendations.',
      },
      {
        'icon': '🎯',
        'title': 'Recommendations',
        'description': 'Get actionable improvement suggestions',
        'prompt': 'What actions should I take to improve water quality in critical zones?',
      },
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: suggestions.map((suggestion) {
        return Flexible(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: _buildSuggestionCard(
              icon: suggestion['icon']!,
              title: suggestion['title']!,
              description: suggestion['description']!,
              onTap: () {
                viewModel.messageController.text = suggestion['prompt']!;
                _sendMessage(viewModel);
              },
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSuggestionCard({
    required String icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.darkBg3,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTextStyles.heading4.copyWith(
                color: AppColors.lightText,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.mediumText,
                fontSize: 12,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'morning';
    } else if (hour < 17) {
      return 'afternoon';
    } else {
      return 'evening';
    }
  }

  // Messages screen
  Widget _buildMessagesScreen(
      BuildContext context, ChatViewModel viewModel) {
    return Column(
      children: [
        // Data upload banner
        if (viewModel.fileUploaded && viewModel.fileInfo != null)
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: GovernmentTheme.governmentBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: GovernmentTheme.governmentBlue.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: GovernmentTheme.governmentBlue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    CupertinoIcons.checkmark_circle_fill,
                    color: GovernmentTheme.governmentBlue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Data Connected',
                        style: AppTextStyles.buttonSmall.copyWith(
                          color: GovernmentTheme.governmentBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        viewModel.fileInfo!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.mediumText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            controller: viewModel.scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            itemCount: viewModel.messages.length,
            itemBuilder: (context, index) {
        final message = viewModel.messages[index];
        final isUser = message.role == 'user';

        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isUser 
                      ? GovernmentTheme.governmentBlue.withOpacity(0.1)
                      : GovernmentTheme.governmentBlue.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isUser
                        ? GovernmentTheme.governmentBlue.withOpacity(0.3)
                        : GovernmentTheme.governmentBlue.withOpacity(0.4),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: isUser
                      ? Icon(
                          CupertinoIcons.person_fill,
                          size: 18,
                          color: GovernmentTheme.governmentBlue,
                        )
                      : const Text('💧', style: TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Role label
                    Text(
                      isUser ? 'You' : 'Water Quality Assistant',
                      style: AppTextStyles.buttonSmall.copyWith(
                        color: AppColors.mediumText,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Message content
                    SelectableText(
                      message.message,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.lightText,
                        fontSize: 15,
                        height: 1.6,
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
            ],
          ),
        );
      },
          ),
        ),
      ],
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
                onPressed: viewModel.isLoading 
                    ? null 
                    : () => ToastNotification.info(context, 'Filters coming soon...'),
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
                onPressed: viewModel.isLoading 
                    ? null 
                    : () => ToastNotification.info(context, 'History coming soon...'),
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
        ToastNotification.success(
          context,
          'File uploaded: ${viewModel.fileInfo}',
        );
      }
    } catch (e) {
      if (mounted) {
        ToastNotification.error(context, 'Upload failed: ${e.toString()}');
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
        ToastNotification.error(context, 'Message failed: ${e.toString()}');
      }
    }
  }
}
