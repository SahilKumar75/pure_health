import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import '../models/analysis_report.dart';
import '../models/water_body_location.dart';

class AIAnalysisService {
  final Dio _dio;
  final String baseUrl;

  AIAnalysisService({this.baseUrl = 'http://localhost:8000'})
      : _dio = Dio(BaseOptions(
          connectTimeout: const Duration(minutes: 1),
          receiveTimeout: const Duration(minutes: 1),
          contentType: 'application/json',
        )) {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => print('🔍 API: $obj'),
      ),
    );
  }

  /// Upload file and get initial analysis
  Future<Map<String, dynamic>> uploadFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'xlsx', 'xls', 'json', 'pdf', 'txt'],
        withData: true,
      );

      if (result == null) {
        throw Exception('No file selected');
      }

      final file = result.files.first;
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          file.bytes!,
          filename: file.name,
        ),
      });

      final response = await _dio.post(
        '$baseUrl/api/ai/upload',
        data: formData,
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Upload failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Upload error: ${e.message}');
    }
  }

  /// Generate comprehensive analysis report
  Future<AnalysisReport> generateReport({
    required Map<String, dynamic> fileData,
    WaterBodyLocation? location,
  }) async {
    try {
      final response = await _dio.post(
        '$baseUrl/api/ai/analyze',
        data: {
          'file_data': fileData,
          'location': location?.toJson(),
          'include_predictions': true,
          'prediction_months': 2,
          'include_risk_assessment': true,
          'include_trend_analysis': true,
          'include_recommendations': true,
        },
      );

      if (response.statusCode == 200) {
        return AnalysisReport.fromJson(response.data);
      } else {
        throw Exception('Analysis failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Analysis error: ${e.message}');
    }
  }

  /// Get predictions for next 2 months
  Future<Map<String, dynamic>> getPredictions(
      Map<String, dynamic> fileData) async {
    try {
      final response = await _dio.post(
        '$baseUrl/api/ai/predictions',
        data: {
          'file_data': fileData,
          'months': 2,
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Prediction failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Prediction error: ${e.message}');
    }
  }

  /// Get risk assessment
  Future<RiskAssessment> getRiskAssessment(
      Map<String, dynamic> fileData) async {
    try {
      final response = await _dio.post(
        '$baseUrl/api/ai/risk-assessment',
        data: {'file_data': fileData},
      );

      if (response.statusCode == 200) {
        return RiskAssessment.fromJson(response.data);
      } else {
        throw Exception('Risk assessment failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Risk assessment error: ${e.message}');
    }
  }

  /// Get trend analysis
  Future<TrendAnalysis> getTrendAnalysis(
      Map<String, dynamic> fileData) async {
    try {
      final response = await _dio.post(
        '$baseUrl/api/ai/trend-analysis',
        data: {'file_data': fileData},
      );

      if (response.statusCode == 200) {
        return TrendAnalysis.fromJson(response.data);
      } else {
        throw Exception('Trend analysis failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Trend analysis error: ${e.message}');
    }
  }

  /// Get recommendations
  Future<List<Recommendation>> getRecommendations(
      Map<String, dynamic> fileData) async {
    try {
      final response = await _dio.post(
        '$baseUrl/api/ai/recommendations',
        data: {'file_data': fileData},
      );

      if (response.statusCode == 200) {
        return (response.data['recommendations'] as List)
            .map((r) => Recommendation.fromJson(r))
            .toList();
      } else {
        throw Exception('Recommendations failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Recommendations error: ${e.message}');
    }
  }

  /// Save report to history
  Future<void> saveReportToHistory(AnalysisReport report) async {
    try {
      final response = await _dio.post(
        '$baseUrl/api/ai/save-report',
        data: report.toJson(),
      );

      if (response.statusCode != 200) {
        throw Exception('Save failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Save error: ${e.message}');
    }
  }

  /// Get saved reports
  Future<List<AnalysisReport>> getSavedReports() async {
    try {
      final response = await _dio.get('$baseUrl/api/ai/reports');

      if (response.statusCode == 200) {
        return (response.data['reports'] as List)
            .map((r) => AnalysisReport.fromJson(r))
            .toList();
      } else {
        throw Exception('Failed to get reports: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Get reports error: ${e.message}');
    }
  }

  /// Delete report
  Future<void> deleteReport(String reportId) async {
    try {
      final response = await _dio.delete('$baseUrl/api/ai/reports/$reportId');

      if (response.statusCode != 200) {
        throw Exception('Delete failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Delete error: ${e.message}');
    }
  }
}
