class MLConstants {
  // API Configuration
  static const String baseUrl = 'http://10.0.2.2:8000/api'; // Android emulator
  // For physical device or iOS: use actual IP like 'http://192.168.x.x:8000/api'
  
  static const String mlServerUrl = 'http://10.0.2.2:5000';
  static const Duration requestTimeout = Duration(seconds: 30);

  // Model Endpoints
  static const String chatEndpoint = '/chat/process';
  static const String predictionEndpoint = '/predictions/water-quality';
  static const String anomalyEndpoint = '/predictions/anomalies';
  static const String recommendationEndpoint = '/recommendations';
  static const String classificationEndpoint = '/classification/alert-sentiment';

  // Model Versions
  static const String chatModelVersion = 'v1.0';
  static const String predictionModelVersion = 'v1.0';
  static const String classificationModelVersion = 'v1.0';

  // Thresholds
  static const double confidenceThreshold = 0.7;
  static const double anomalyThreshold = 0.8;
  static const double predictionAccuracy = 0.85;

  // Cache Settings
  static const int cacheExpireSeconds = 3600;
  static const int maxCacheSize = 100;
}
