import 'package:flutter/material.dart';
import 'package:pure_health/ml/models/chat_model.dart';

class ChatProvider extends ChangeNotifier {
  List<ChatResponse> _responses = [];
  bool _isLoading = false;

  List<ChatResponse> get responses => _responses;
  bool get isLoading => _isLoading;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void addResponse(ChatResponse response) {
    _responses.add(response);
    notifyListeners();
  }

  void clearResponses() {
    _responses.clear();
    notifyListeners();
  }
}
