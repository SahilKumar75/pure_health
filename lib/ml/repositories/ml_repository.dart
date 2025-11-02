import '../services/ml_service.dart';
import '../models/chat_model.dart';
import '../models/water_quality_model.dart';
import '../models/prediction_model.dart';

class MLRepository {
  final MLService mlService;

  MLRepository({MLService? mlService})
      : mlService = mlService ?? MLService();

  // Chat Operations
  Future<ChatResponse> sendChatMessage(ChatRequest request) {
    return mlService.processChat(request);
  }

  // Water Quality Operations
  Future<WaterQualityPrediction> getWaterQualityPrediction(
    WaterQualityData data,
  ) {
    return mlService.predictWaterQuality(data);
  }

  Future<List<AnomalyDetectionResult>> getAnomalies(
    List<WaterQualityData> dataList,
  ) {
    return mlService.detectAnomalies(dataList);
  }

  Future<List<String>> getQualityRecommendations(String status) {
    return mlService.getRecommendations(status);
  }

  // Alert Operations
  Future<Map<String, dynamic>> classifyAlertSentiment(String text) {
    return mlService.classifyAlert(text);
  }

  // Generic Prediction
  Future<PredictionResponse> makePrediction(PredictionRequest request) {
    return mlService.makePrediction(request);
  }

  /// Analyze uploaded file data
  Future<Map<String, dynamic>> analyzeFile({
    required String fileName,
    required String content,
  }) async {
    try {
      return await mlService.apiClient.post(
        '/files/analyze',
        body: {
          'fileName': fileName,
          'content': content,
        },
      );
    } catch (e) {
      throw Exception('File analysis failed: $e');
    }
  }

  /// Generate report
  Future<Map<String, dynamic>> generateReport({
    required String title,
    required String format,
    required List<Map<String, dynamic>> messages,
  }) async {
    try {
      return await mlService.apiClient.post(
        '/report/generate',
        body: {
          'title': title,
          'format': format,
          'messages': messages,
          'totalMessages': messages.length,
          'generatedAt': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      throw Exception('Report generation failed: $e');
    }
  }
}
