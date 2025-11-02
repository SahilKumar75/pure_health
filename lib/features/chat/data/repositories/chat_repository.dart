import '../services/ml_services.dart';
import '../models/chat_message_model.dart';

class ChatRepository {
  /// Send message and get response from ML model
  Future<String> sendMessage(String message) async {
    return await MLService.processChatMessage(message);
  }

  /// Get water quality prediction
  Future<WaterQualityPrediction?> getWaterQualityPrediction(
    Map<String, dynamic> parameters,
  ) async {
    return await MLService.predictWaterQuality(parameters);
  }

  /// Detect anomalies in water quality data
  Future<Map<String, dynamic>?> detectAnomalies(
    List<Map<String, dynamic>> data,
  ) async {
    return await MLService.detectAnomalies(data);
  }

  /// Get personalized recommendations
  Future<List<String>> getRecommendations(String status) async {
    return await MLService.getRecommendations(status);
  }

  /// Classify alert sentiment
  Future<Map<String, dynamic>?> classifyAlert(String alertText) async {
    return await MLService.classifyAlertSentiment(alertText);
  }
}
