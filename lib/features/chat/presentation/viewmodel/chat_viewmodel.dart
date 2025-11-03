import 'package:flutter/material.dart';
import '../../../../core/services/ai_chat_service.dart';

class ChatViewModel extends ChangeNotifier {
  final AIChatService _chatService;

  bool _isLoading = false;
  bool _hasMessages = false;
  String? _fileInfo;
  bool _fileUploaded = false;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();

    ChatViewModel()
      : _chatService =
            AIChatService(baseUrl: 'http://localhost:8000');

  bool get isLoading => _isLoading;
  bool get hasMessages => _hasMessages;
  String? get fileInfo => _fileInfo;
  bool get fileUploaded => _fileUploaded;
  ScrollController get scrollController => _scrollController;
  TextEditingController get messageController => _messageController;
  List<dynamic> get messages => _chatService.messages;

  Future<void> uploadFile() async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _chatService.uploadFile();

      _fileInfo = '${result['fileName']} • ${result['recordsCount']} records';
      _fileUploaded = true;

      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String message) async {
    try {
      _isLoading = true;
      _hasMessages = true;
      notifyListeners();

      await _chatService.sendMessage(message);

      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });

      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearChat() {
    _chatService.clearHistory();
    _hasMessages = false;
    _fileUploaded = false;
    _fileInfo = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}
