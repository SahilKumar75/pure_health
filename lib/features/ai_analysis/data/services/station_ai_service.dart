import 'package:dio/dio.dart';
import 'package:pure_health/core/models/station_models.dart';

class StationAIService {
  final Dio _dio;
  final String baseUrl;

  StationAIService({
    String? baseUrl,
    Dio? dio,
  })  : baseUrl = baseUrl ?? 'http://localhost:8000',
        _dio = dio ?? Dio();

  /// Get AI prediction for a station
  Future<Map<String, dynamic>> getPrediction({
    required String stationId,
    required List<StationData> historicalData,
    int predictionDays = 30,
  }) async {
    try {
      final response = await _dio.post(
        '$baseUrl/api/stations/$stationId/ai/prediction',
        data: {
          'historical_data': _formatHistoricalData(historicalData),
          'prediction_days': predictionDays,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data;
      } else {
        throw Exception(response.data['error'] ?? 'Prediction failed');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Prediction error: $e');
    }
  }

  /// Get risk assessment for a station
  Future<Map<String, dynamic>> getRiskAssessment({
    required String stationId,
    required List<StationData> historicalData,
  }) async {
    try {
      final response = await _dio.post(
        '$baseUrl/api/stations/$stationId/ai/risk',
        data: {
          'historical_data': _formatHistoricalData(historicalData),
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data;
      } else {
        throw Exception(response.data['error'] ?? 'Risk assessment failed');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Risk assessment error: $e');
    }
  }

  /// Get trend analysis for a station
  Future<Map<String, dynamic>> getTrendAnalysis({
    required String stationId,
    required List<StationData> historicalData,
  }) async {
    try {
      final response = await _dio.post(
        '$baseUrl/api/stations/$stationId/ai/trends',
        data: {
          'historical_data': _formatHistoricalData(historicalData),
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data;
      } else {
        throw Exception(response.data['error'] ?? 'Trend analysis failed');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Trend analysis error: $e');
    }
  }

  /// Get AI recommendations for a station
  Future<Map<String, dynamic>> getRecommendations({
    required String stationId,
    required List<StationData> historicalData,
  }) async {
    try {
      final response = await _dio.post(
        '$baseUrl/api/stations/$stationId/ai/recommendations',
        data: {
          'historical_data': _formatHistoricalData(historicalData),
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data;
      } else {
        throw Exception(response.data['error'] ?? 'Recommendations failed');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Recommendations error: $e');
    }
  }

  /// Format historical data for ML backend
  List<Map<String, dynamic>> _formatHistoricalData(List<StationData> data) {
    return data.map((reading) {
      final params = <String, dynamic>{
        'timestamp': reading.timestamp,
        'wqi': reading.wqi,
      };

      // Extract parameter values
      reading.parameters.forEach((key, value) {
        if (value is Map<String, dynamic> && value.containsKey('value')) {
          params[key] = value['value'];
        } else if (value is num) {
          params[key] = value;
        }
      });

      return params;
    }).toList();
  }

  /// Test connection to ML backend
  Future<bool> testConnection() async {
    try {
      final response = await _dio.get(
        '$baseUrl/api/status',
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('[AI_SERVICE] Connection test failed: $e');
      return false;
    }
  }
}
