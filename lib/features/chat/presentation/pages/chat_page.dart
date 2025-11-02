import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:pure_health/core/constants/color_constants.dart';
import 'package:pure_health/core/theme/text_styles.dart';
import 'package:pure_health/shared/widgets/custom_sidebar.dart';
import 'package:pure_health/ml/models/chat_model.dart';
import 'package:pure_health/ml/repositories/ml_repository.dart';
import '../providers/chat_provider.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  int _selectedIndex = 4;
  final _messageController = TextEditingController();
  final _focusNode = FocusNode();
  late ScrollController _scrollController;
  late ChatProvider _chatProvider;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    // Create provider instance here
    _chatProvider = ChatProvider(MLRepository());
  }

  @override
  void dispose() {
    _messageController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    _chatProvider.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final message = _messageController.text.trim();
    _messageController.clear();

    // Create chat request
    final chatRequest = ChatRequest(
      message: message,
      userId: 'user_001',
      sessionId: 'session_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      context: {
        'app': 'PureHealth',
        'feature': 'WaterQualityChat',
      },
    );

    // Call provider method directly
    _chatProvider.sendMessage(chatRequest);

    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _showWaterQualityInput() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _WaterQualityInputDialog(
        onSubmit: (data) {
          _chatProvider.predictWaterQuality(data);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _chatProvider,
      builder: (context, _) {
        return Scaffold(
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
                    _buildHeader(),
                    // Messages
                    Expanded(
                      child: _buildMessagesArea(),
                    ),
                    // Input Area
                    _buildInputArea(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PureHealth AI Assistant',
                style: AppTextStyles.heading3.copyWith(
                  color: AppColors.charcoal,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _chatProvider.isConnected ? '🟢 Connected' : '🔴 Disconnected',
                style: AppTextStyles.bodySmall.copyWith(
                  color: _chatProvider.isConnected
                      ? AppColors.success
                      : AppColors.error,
                ),
              ),
            ],
          ),
          // Clear Chat Button
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: AppColors.white,
                  title: Text(
                    'Clear Chat',
                    style: AppTextStyles.heading4.copyWith(
                      color: AppColors.charcoal,
                    ),
                  ),
                  content: Text(
                    'Are you sure you want to clear chat history?',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.mediumGray,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.mediumGray,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _chatProvider.clearChat();
                      },
                      child: Text(
                        'Clear',
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            child: Icon(
              CupertinoIcons.trash,
              color: AppColors.mediumGray,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesArea() {
    if (_chatProvider.messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.chat_bubble_2,
              size: 64,
              color: AppColors.darkCream.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Start a conversation',
              style: AppTextStyles.heading4.copyWith(
                color: AppColors.mediumGray,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ask about water quality or get recommendations',
              style: AppTextStyles.body.copyWith(
                color: AppColors.mediumGray.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.all(16),
      itemCount: _chatProvider.messages.length,
      itemBuilder: (context, index) {
        final message = _chatProvider
            .messages[_chatProvider.messages.length - 1 - index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildMessageBubble(message),
        );
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;

    return Row(
      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!isUser) ...[
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.darkVanilla.withOpacity(0.2),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.darkVanilla.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              CupertinoIcons.sparkles,
              color: AppColors.darkVanilla,
              size: 18,
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
              color: isUser
                  ? AppColors.darkCream.withOpacity(0.2)
                  : AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.darkCream.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.charcoal.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.text,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.charcoal,
                    height: 1.5,
                  ),
                ),
                if (message.metadata != null) ...[
                  const SizedBox(height: 8),
                  _buildMetadata(message.metadata!),
                ],
                if (!isUser && message.confidence != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Confidence: ${(double.parse(message.confidence!) * 100).toStringAsFixed(1)}%',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.mediumGray.withOpacity(0.7),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (isUser) ...[
          const SizedBox(width: 8),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.darkVanilla.withOpacity(0.2),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.darkVanilla.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              CupertinoIcons.person_fill,
              color: AppColors.darkVanilla,
              size: 18,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMetadata(Map<String, dynamic> metadata) {
    if (metadata.containsKey('recommendations')) {
      final recommendations = metadata['recommendations'] as List?;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recommendations:',
            style: AppTextStyles.buttonSmall.copyWith(
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 4),
          ...?recommendations?.map((rec) {
            return Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Text(
                    '• ',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.darkVanilla,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      rec.toString(),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.charcoal,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildInputArea() {
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
          // Water Quality Button
          CupertinoButton(
            padding: const EdgeInsets.all(8),
            minSize: 40,
            onPressed: _showWaterQualityInput,
            child: Icon(
              CupertinoIcons.drop_fill,
              color: AppColors.darkVanilla,
              size: 24,
            ),
          ),
          const SizedBox(width: 8),
          // Message Input
          Expanded(
            child: TextField(
              controller: _messageController,
              focusNode: _focusNode,
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              decoration: InputDecoration(
                hintText: 'Ask about water quality...',
                hintStyle: AppTextStyles.body.copyWith(
                  color: AppColors.mediumGray.withOpacity(0.5),
                ),
                filled: true,
                fillColor: AppColors.darkCream.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(
                    color: AppColors.darkCream.withOpacity(0.2),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(
                    color: AppColors.darkCream.withOpacity(0.2),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(
                    color: AppColors.darkVanilla,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              style: AppTextStyles.body.copyWith(
                color: AppColors.charcoal,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Send Button
          FloatingActionButton(
            onPressed: _chatProvider.isLoading ? null : _sendMessage,
            backgroundColor: _chatProvider.isLoading
                ? AppColors.mediumGray
                : AppColors.darkVanilla,
            child: _chatProvider.isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.white,
                      ),
                    ),
                  )
                : Icon(
                    CupertinoIcons.arrow_up,
                    color: AppColors.white,
                  ),
          ),
        ],
      ),
    );
  }
}

// Water Quality Input Dialog
class _WaterQualityInputDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;

  const _WaterQualityInputDialog({required this.onSubmit});

  @override
  State<_WaterQualityInputDialog> createState() =>
      _WaterQualityInputDialogState();
}

class _WaterQualityInputDialogState extends State<_WaterQualityInputDialog> {
  final _pHController = TextEditingController(text: '7.0');
  final _turbidityController = TextEditingController(text: '2.0');
  final _doController = TextEditingController(text: '8.0');
  final _tempController = TextEditingController(text: '25.0');
  final _conductivityController = TextEditingController(text: '500');
  final _locationController = TextEditingController(text: 'Water Sample');

  @override
  void dispose() {
    _pHController.dispose();
    _turbidityController.dispose();
    _doController.dispose();
    _tempController.dispose();
    _conductivityController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Water Quality Parameters',
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.charcoal,
              ),
            ),
            const SizedBox(height: 16),
            _buildInputField('pH Level', _pHController, '0-14'),
            _buildInputField('Turbidity (NTU)', _turbidityController, '0-10'),
            _buildInputField('Dissolved Oxygen', _doController, '0-15'),
            _buildInputField('Temperature (°C)', _tempController, '-10-50'),
            _buildInputField('Conductivity (µS/cm)', _conductivityController, '0-2000'),
            _buildInputField('Location', _locationController, 'Text'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  widget.onSubmit({
                    'pH': double.parse(_pHController.text),
                    'turbidity': double.parse(_turbidityController.text),
                    'dissolved_oxygen': double.parse(_doController.text),
                    'temperature': double.parse(_tempController.text),
                    'conductivity': double.parse(_conductivityController.text),
                    'location': _locationController.text,
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkVanilla,
                ),
                child: Text(
                  'Analyze Water Quality',
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.mediumGray,
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.bodySmall.copyWith(
                color: AppColors.mediumGray.withOpacity(0.5),
              ),
              filled: true,
              fillColor: AppColors.darkCream.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppColors.darkCream.withOpacity(0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppColors.darkVanilla,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
            style: AppTextStyles.body.copyWith(
              color: AppColors.charcoal,
            ),
          ),
        ],
      ),
    );
  }
}
