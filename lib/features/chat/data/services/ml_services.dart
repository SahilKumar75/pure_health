import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_message_model.dart';

class MLService {
  static const String _baseUrl = 'http://localhost:8000/api'; // Change to your ML server
  static const Duration _timeout = Duration(seconds: 30);

  /// Process user message and get AI response
  static Future<String> processChatMessage(String userMessage) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/chat/process'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'message': userMessage,
              'timestamp': DateTime.now().toIso8601String(),
            }),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'] as String? ?? 'Unable to process message';
      } else {
        return 'Error: ${response.statusCode}';
      }
    } catch (e) {
      return 'Error processing message: $e';
    }
  }

  /// Predict water quality based on parameters
  static Future<WaterQualityPrediction?> predictWaterQuality(
    Map<String, dynamic> parameters,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/predictions/water-quality'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'parameters': parameters,
              'timestamp': DateTime.now().toIso8601String(),
            }),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return WaterQualityPrediction.fromJson(data['prediction']);
      } else {
        return null;
      }
    } catch (e) {
      print('Error predicting water quality: $e');
      return null;
    }
  }

  /// Get anomaly detection results
  static Future<Map<String, dynamic>?> detectAnomalies(
    List<Map<String, dynamic>> data,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/predictions/anomalies'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'data': data,
              'threshold': 0.7,
            }),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      print('Error detecting anomalies: $e');
      return null;
    }
  }

  /// Get water quality recommendations
  static Future<List<String>> getRecommendations(
    String waterQualityStatus,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/recommendations'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'status': waterQualityStatus,
            }),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<String>.from(data['recommendations'] as List? ?? []);
      } else {
        return [];
      }
    } catch (e) {
      print('Error getting recommendations: $e');
      return [];
    }
  }

  /// Classify text sentiment (for alert classification)
  static Future<Map<String, dynamic>?> classifyAlertSentiment(
    String alertText,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/classification/alert-sentiment'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'text': alertText,
            }),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      print('Error classifying sentiment: $e');
      return null;
    }
  }
}
