import 'package:pure_health/ml/models/chat_model.dart';

class MLService {
  Future<ChatResponse> processChat(ChatRequest request) async {
    return ChatResponse(
      response: 'Chat response',
      intent: 'chat',
      confidence: 0.9,
      metadata: {},
    );
  }

  Future<WaterQualityPrediction> predict(dynamic data) async {
    return WaterQualityPrediction(
      status: 'Safe',
      predictedValue: 85.0,
      confidence: 0.95,
    );
  }
}
