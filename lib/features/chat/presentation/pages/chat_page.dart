import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:file_picker/file_picker.dart';
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
  List<PlatformFile>? _selectedFiles;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
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

  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['csv', 'xlsx', 'xls', 'json', 'txt', 'pdf'],
    );

    if (result != null) {
      setState(() {
        _selectedFiles = result.files;
      });

      // Send files for analysis
      _analyzeFiles(result.files);
    }
  }

  Future<void> _analyzeFiles(List<PlatformFile> files) async {
    String fileInfo = files
        .map((f) => '📄 ${f.name} (${(f.size / 1024).toStringAsFixed(2)} KB)')
        .join('\n');

    // Create message about files
    final chatRequest = ChatRequest(
      message: 'Please analyze these water data files:\n$fileInfo',
      userId: 'gov_user_001',
      sessionId: 'session_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      context: {
        'app': 'PureHealth',
        'feature': 'GovernmentAIAnalyst',
        'fileCount': files.length,
        'fileNames': files.map((f) => f.name).toList(),
      },
    );

    await _chatProvider.sendMessage(chatRequest);
    _scrollToBottom();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final message = _messageController.text.trim();
    _messageController.clear();
    setState(() {
      _selectedFiles = null;
    });

    final chatRequest = ChatRequest(
      message: message,
      userId: 'gov_user_001',
      sessionId: 'session_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      context: {
        'app': 'PureHealth',
        'feature': 'GovernmentAIAnalyst',
      },
    );

    _chatProvider.sendMessage(chatRequest);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _generateReport() {
    showDialog(
      context: context,
      builder: (context) => _ReportGenerationDialog(
        chatProvider: _chatProvider,
      ),
    );
  }

  void _exportChat() {
    // Export entire chat conversation as PDF/CSV
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        title: Text(
          'Export Chat Conversation',
          style: AppTextStyles.heading4.copyWith(
            color: AppColors.charcoal,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                'Export as PDF',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.charcoal,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _chatProvider.exportAsPDF();
              },
            ),
            ListTile(
              title: Text(
                'Export as CSV',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.charcoal,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _chatProvider.exportAsCSV();
              },
            ),
          ],
        ),
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
                    _buildHeader(),
                    Expanded(
                      child: _buildMessagesArea(),
                    ),
                    if (_selectedFiles != null && _selectedFiles!.isNotEmpty)
                      _buildFilePreview(),
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
                'Government Water AI Assistant',
                style: AppTextStyles.heading3.copyWith(
                  color: AppColors.charcoal,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    _chatProvider.isConnected ? '🟢 Connected' : '🔴 Disconnected',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: _chatProvider.isConnected
                          ? AppColors.success
                          : AppColors.error,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${_chatProvider.messages.length} messages',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.mediumGray,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                onPressed: _generateReport,
                child: Icon(
                  CupertinoIcons.doc_fill,
                  color: AppColors.darkVanilla,
                  size: 20,
                ),
              ),
              CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                onPressed: _exportChat,
                child: Icon(
                  CupertinoIcons.arrow_down_to_line,
                  color: AppColors.darkVanilla,
                  size: 20,
                ),
              ),
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
                        'Clear all conversation history?',
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
              CupertinoIcons.bubble_left_bubble_right_fill,
              size: 80,
              color: AppColors.darkCream.withOpacity(0.2),
            ),
            const SizedBox(height: 24),
            Text(
              'Government Water Data Analysis',
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.charcoal,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Analyze water quality data through conversation',
              style: AppTextStyles.body.copyWith(
                color: AppColors.mediumGray,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Features:',
              style: AppTextStyles.heading4.copyWith(
                color: AppColors.charcoal,
              ),
            ),
            const SizedBox(height: 8),
            Column(
              children: [
                _buildFeatureBullet('Chat-based analysis'),
                _buildFeatureBullet('File upload (CSV, Excel, JSON)'),
                _buildFeatureBullet('Real-time ML predictions'),
                _buildFeatureBullet('Report generation'),
                _buildFeatureBullet('Data export'),
              ],
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
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildMessageBubble(message),
        );
      },
    );
  }

  Widget _buildFeatureBullet(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CupertinoIcons.checkmark_circle_fill,
            size: 16,
            color: AppColors.darkVanilla,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: AppTextStyles.body.copyWith(
              color: AppColors.charcoal,
            ),
          ),
        ],
      ),
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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.darkVanilla.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.darkVanilla.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.psychology,
              color: AppColors.darkVanilla,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
        ],
        Flexible(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
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
                  const SizedBox(height: 12),
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
          const SizedBox(width: 12),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.darkVanilla.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.darkVanilla.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              CupertinoIcons.person_fill,
              color: AppColors.darkVanilla,
              size: 20,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMetadata(Map<String, dynamic> metadata) {
    if (metadata.containsKey('recommendations')) {
      final recommendations = metadata['recommendations'] as List?;
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.darkVanilla.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recommendations:',
              style: AppTextStyles.buttonSmall.copyWith(
                color: AppColors.charcoal,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...?recommendations?.map((rec) {
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '→ ',
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
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildFilePreview() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkCream.withOpacity(0.1),
        border: Border(
          top: BorderSide(
            color: AppColors.darkCream.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Text(
              'Attached Files: ',
              style: AppTextStyles.buttonSmall.copyWith(
                color: AppColors.charcoal,
              ),
            ),
            ..._selectedFiles!.map((file) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.darkVanilla.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.darkVanilla.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getFileIcon(file.extension ?? ''),
                        size: 14,
                        color: AppColors.darkVanilla,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        file.name,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.charcoal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  IconData _getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'csv':
        return CupertinoIcons.table;
      case 'xlsx':
      case 'xls':
        return CupertinoIcons.table;
      case 'pdf':
        return CupertinoIcons.doc_fill;
      case 'json':
        return CupertinoIcons.doc_text_fill;
      default:
        return CupertinoIcons.doc;
    }
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
          // File Upload Button
          CupertinoButton(
            padding: const EdgeInsets.all(8),
            minSize: 40,
            onPressed: _pickFiles,
            child: Icon(
              CupertinoIcons.paperclip,
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
                hintText: 'Ask about water quality or upload files...',
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

// Report Generation Dialog
class _ReportGenerationDialog extends StatefulWidget {
  final ChatProvider chatProvider;

  const _ReportGenerationDialog({required this.chatProvider});

  @override
  State<_ReportGenerationDialog> createState() =>
      _ReportGenerationDialogState();
}

class _ReportGenerationDialogState extends State<_ReportGenerationDialog> {
  final _reportTitleController = TextEditingController(
    text: 'Water Quality Analysis Report',
  );
  String _selectedFormat = 'PDF';
  bool _isGenerating = false;

  @override
  void dispose() {
    _reportTitleController.dispose();
    super.dispose();
  }

  Future<void> _generateReport() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      // Generate report with ML analysis
      await widget.chatProvider.generateReport(
        title: _reportTitleController.text,
        format: _selectedFormat,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Report generated successfully as $_selectedFormat',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating report: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Generate Report',
        style: AppTextStyles.heading3.copyWith(
          color: AppColors.charcoal,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Report Title:',
            style: AppTextStyles.buttonSmall.copyWith(
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _reportTitleController,
            decoration: InputDecoration(
              hintText: 'Enter report title',
              filled: true,
              fillColor: AppColors.darkCream.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.darkVanilla,
                  width: 2,
                ),
              ),
            ),
            style: AppTextStyles.body.copyWith(
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Format:',
            style: AppTextStyles.buttonSmall.copyWith(
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: ['PDF', 'Excel', 'CSV'].map((format) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(format),
                    selected: _selectedFormat == format,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFormat = format;
                      });
                    },
                    selectedColor: AppColors.darkVanilla,
                    labelStyle: AppTextStyles.buttonSmall.copyWith(
                      color: _selectedFormat == format
                          ? AppColors.white
                          : AppColors.charcoal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
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
          onPressed: _isGenerating ? null : _generateReport,
          child: Text(
            _isGenerating ? 'Generating...' : 'Generate',
            style: AppTextStyles.button.copyWith(
              color: AppColors.darkVanilla,
            ),
          ),
        ),
      ],
    );
  }
}
