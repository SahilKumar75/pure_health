import 'package:flutter/material.dart';
import 'package:pure_health/ml/models/chat_model.dart';
import 'package:pure_health/ml/models/water_quality_model.dart';
import 'package:pure_health/ml/repositories/ml_repository.dart';

/// Local chat message model for UI display
class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? confidence;
  final Map<String, dynamic>? metadata;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.confidence,
    this.metadata,
  });
}

class ChatProvider extends ChangeNotifier {
  final MLRepository _mlRepository;

  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _error;
  bool _isConnected = true;

  ChatProvider(this._mlRepository) {
    _initializeChat();
  }

  // Getters
  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isConnected => _isConnected;

  void _initializeChat() {
    // Add welcome message
    _messages.add(
      ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text:
            'Hello! I\'m your PureHealth AI Assistant. I can help you analyze water quality data and provide recommendations. How can I help you today?',
        isUser: false,
        timestamp: DateTime.now(),
        confidence: '1.0',
      ),
    );
  }

  Future<void> sendMessage(ChatRequest request) async {
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      // Add user message
      final userMsg = ChatMessage(
        id: request.message.hashCode.toString(),
        text: request.message,
        isUser: true,
        timestamp: DateTime.now(),
      );
      _messages.add(userMsg);
      notifyListeners();

      // Get AI response from ML repository
      final response = await _mlRepository.sendChatMessage(request);

      // Add AI response
      final aiMsg = ChatMessage(
        id: response.id,
        text: response.response,
        isUser: false,
        timestamp: DateTime.now(),
        confidence: response.confidence.toString(),
        metadata: {
          'intent': response.intent,
          'entities': response.entities,
        },
      );
      _messages.add(aiMsg);
      _isConnected = true;
    } catch (e) {
      _error = e.toString();
      _isConnected = false;

      // Add error message
      final errorMsg = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: 'Sorry, I encountered an error: ${e.toString()}',
        isUser: false,
        timestamp: DateTime.now(),
        confidence: '0.0',
      );
      _messages.add(errorMsg);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> predictWaterQuality(Map<String, dynamic> params) async {
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      // Create water quality data from parameters
      final data = WaterQualityData(
        pH: (params['pH'] as num).toDouble(),
        turbidity: (params['turbidity'] as num).toDouble(),
        dissolved_oxygen: (params['dissolved_oxygen'] as num).toDouble(),
        temperature: (params['temperature'] as num).toDouble(),
        conductivity: (params['conductivity'] as num).toDouble(),
        timestamp: DateTime.now(),
        location: params['location'] as String? ?? 'Unknown',
      );

      // Get prediction from ML repository
      final prediction = await _mlRepository.getWaterQualityPrediction(data);

      // Create and add response message
      final message = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: 'Water Quality Analysis:\n\n'
            '${prediction.parameter}: ${prediction.predictedValue.toStringAsFixed(2)}\n'
            'Status: ${prediction.status}\n'
            'Confidence: ${(prediction.confidence * 100).toStringAsFixed(1)}%',
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
      _isConnected = true;
    } catch (e) {
      _error = e.toString();
      _isConnected = false;

      final errorMsg = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: 'Error analyzing water quality: $e',
        isUser: false,
        timestamp: DateTime.now(),
        confidence: '0.0',
      );
      _messages.add(errorMsg);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearChat() {
    _messages.clear();
    _initializeChat();
    notifyListeners();
  }
}
