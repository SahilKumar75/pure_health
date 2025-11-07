class ApiConstants {
  // Base URLs
  static const String baseUrl = 'http://localhost:8000/api';
  static const String productionUrl = 'https://your-production-url.com/api';
  
  // Environment
  static const bool isProduction = false;
  static String get apiBaseUrl => isProduction ? productionUrl : baseUrl;
  
  // Endpoints
  static const String stations = '/stations';
  static const String stationsData = '/stations/data/all';
  static const String stationDetail = '/stations'; // + /{id}
  static const String stationsByDistrict = '/stations/district'; // + /{district}
  static const String stationsByType = '/stations/type'; // + /{type}
  static const String stationsAlerts = '/stations/alerts';
  static const String stationsMapData = '/stations/map-data';
  static const String stationsSummary = '/stations/summary';
  static const String stationHistory = '/stations'; // + /{id}/history
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
  
  // Pagination defaults
  static const int defaultPageSize = 100;
  static const int maxPageSize = 200;
  static const int mapPageSize = 1000;
}
