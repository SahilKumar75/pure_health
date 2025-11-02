class MLConstants {
  // For macOS local machine, use your IP address from the terminal
  // From your terminal output: Running on http://192.168.223.121:8000
  static const String baseUrl = 'http://192.168.223.121:8000/api';
  
  // Alternative: If running on same Mac in simulator
  // static const String baseUrl = 'http://localhost:8000/api';
  
  static const String mlServerUrl = 'http://192.168.223.121:5000';
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
