import 'api_client.dart';
import '../models/chat_model.dart';
import '../models/water_quality_model.dart';
import '../models/prediction_model.dart';
import '../utils/ml_constants.dart';

class MLService {
  final MLApiClient apiClient;

  MLService({MLApiClient? apiClient})
      : apiClient = apiClient ?? MLApiClient();

  /// Process chat message with ML model
  Future<ChatResponse> processChat(ChatRequest request) async {
    try {
      final response = await apiClient.post(
        MLConstants.chatEndpoint,
        body: request.toJson(),
      );
      return ChatResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Predict water quality
  Future<WaterQualityPrediction> predictWaterQuality(
    WaterQualityData data,
  ) async {
    try {
      final response = await apiClient.post(
        MLConstants.predictionEndpoint,
        body: data.toJson(),
      );
      return WaterQualityPrediction.fromJson(response['prediction']);
    } catch (e) {
      rethrow;
    }
  }

  /// Detect anomalies in water quality data
  Future<List<AnomalyDetectionResult>> detectAnomalies(
    List<WaterQualityData> dataList,
  ) async {
    try {
      final response = await apiClient.post(
        MLConstants.anomalyEndpoint,
        body: {
          'data': dataList.map((e) => e.toJson()).toList(),
          'threshold': MLConstants.anomalyThreshold,
        },
      );
      
      final results = response['results'] as List?;
      return results
          ?.map((e) => AnomalyDetectionResult.fromJson(e as Map<String, dynamic>))
          .toList() ?? [];
    } catch (e) {
      rethrow;
    }
  }

  /// Get recommendations based on water quality status
  Future<List<String>> getRecommendations(String status) async {
    try {
      final response = await apiClient.post(
        MLConstants.recommendationEndpoint,
        body: {'status': status},
      );
      return List<String>.from(response['recommendations'] as List? ?? []);
    } catch (e) {
      rethrow;
    }
  }

  /// Classify alert sentiment
  Future<Map<String, dynamic>> classifyAlert(String alertText) async {
    try {
      final response = await apiClient.post(
        MLConstants.classificationEndpoint,
        body: {'text': alertText},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Make generic prediction
  Future<PredictionResponse> makePrediction(
    PredictionRequest request,
  ) async {
    try {
      final response = await apiClient.post(
        '/predictions',
        body: request.toJson(),
      );
      return PredictionResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}
