import 'package:flutter/material.dart';
import '../../data/repositories/chat_repository.dart';
import '../../data/models/chat_message_model.dart';
import '../../domain/usecases/process_message_usecase.dart';

class ChatProvider extends ChangeNotifier {
  final ChatRepository repository;
  
  late ProcessMessageUsecase _processMessageUsecase;
  late GetWaterQualityPredictionUsecase _getPredictionUsecase;
  late GetRecommendationsUsecase _getRecommendationsUsecase;

  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _error;

  ChatProvider(this.repository) {
    _processMessageUsecase = ProcessMessageUsecase(repository);
    _getPredictionUsecase = GetWaterQualityPredictionUsecase(repository);
    _getRecommendationsUsecase = GetRecommendationsUsecase(repository);
  }

  // Getters
  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Send message and get AI response
  Future<void> sendMessage(String userMessage) async {
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      // Add user message
      final userMsg = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: userMessage,
        isUser: true,
        timestamp: DateTime.now(),
      );
      _messages.add(userMsg);
      notifyListeners();

      // Get AI response
      final response = await _processMessageUsecase(userMessage);

      // Add AI response
      final aiMsg = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
        confidence: '0.95',
      );
      _messages.add(aiMsg);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get water quality prediction
  Future<void> predictWaterQuality(Map<String, dynamic> parameters) async {
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      final prediction = await _getPredictionUsecase(parameters);
      if (prediction != null) {
        final message = ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text:
              'Prediction: ${prediction.parameter} = ${prediction.predictedValue} (${prediction.status})',
          isUser: false,
          timestamp: DateTime.now(),
          confidence: prediction.confidence.toString(),
          metadata: {
            'parameter': prediction.parameter,
            'value': prediction.predictedValue,
            'recommendations': prediction.recommendations,
          },
        );
        _messages.add(message);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear chat history
  void clearChat() {
    _messages.clear();
    notifyListeners();
  }
}
