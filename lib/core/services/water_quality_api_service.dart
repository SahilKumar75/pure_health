import 'dart:convert';
import 'package:http/http.dart' as http;

class WaterQualityStation {
  final String id;
  final String name;
  final String type;
  final String monitoringType;
  final String district;
  final String? taluka;
  final String region;
  final double latitude;
  final double longitude;
  final double? altitude;
  final String? waterBody;
  final String? wellType;
  final String laboratory;
  final String samplingFrequency;
  final String? designatedBestUse;
  final String? landUse;
  final int? populationNearby;

  WaterQualityStation({
    required this.id,
    required this.name,
    required this.type,
    required this.monitoringType,
    required this.district,
    this.taluka,
    required this.region,
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.waterBody,
    this.wellType,
    required this.laboratory,
    required this.samplingFrequency,
    this.designatedBestUse,
    this.landUse,
    this.populationNearby,
  });

  factory WaterQualityStation.fromJson(Map<String, dynamic> json) {
    return WaterQualityStation(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      monitoringType: json['monitoringType'] as String? ?? 'baseline',
      district: json['district'] as String,
      taluka: json['taluka'] as String?,
      region: json['region'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      altitude: json['altitude'] != null ? (json['altitude'] as num).toDouble() : null,
      waterBody: json['waterBody'] as String?,
      wellType: json['wellType'] as String?,
      laboratory: json['laboratory'] as String,
      samplingFrequency: json['samplingFrequency'] as String? ?? 'Monthly',
      designatedBestUse: json['designatedBestUse'] as String?,
      landUse: json['landUse'] as String?,
      populationNearby: json['populationNearby'] as int?,
    );
  }
}

class StationData {
  final String stationId;
  final String timestamp;
  final double wqi;
  final String status;
  final String waterQualityClass;
  final Map<String, dynamic> parameters;
  final List<Map<String, dynamic>> alerts;

  StationData({
    required this.stationId,
    required this.timestamp,
    required this.wqi,
    required this.status,
    required this.waterQualityClass,
    required this.parameters,
    required this.alerts,
  });

  factory StationData.fromJson(Map<String, dynamic> json) {
    return StationData(
      stationId: json['stationId'] as String,
      timestamp: json['timestamp'] as String,
      wqi: (json['wqi'] as num).toDouble(),
      status: json['status'] as String,
      waterQualityClass: json['waterQualityClass'] as String,
      parameters: Map<String, dynamic>.from(json['parameters'] as Map),
      alerts: (json['alerts'] as List?)?.map((e) => Map<String, dynamic>.from(e as Map)).toList() ?? [],
    );
  }
}

class PaginationInfo {
  final int page;
  final int perPage;
  final int totalItems;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;

  PaginationInfo({
    required this.page,
    required this.perPage,
    required this.totalItems,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      page: json['page'] as int,
      perPage: json['per_page'] as int,
      totalItems: json['total_items'] as int,
      totalPages: json['total_pages'] as int,
      hasNext: json['has_next'] as bool,
      hasPrev: json['has_prev'] as bool,
    );
  }
}

class WaterQualityApiService {
  // Update this to match your backend URL
  static const String baseUrl = 'http://localhost:8000/api';
  
  final http.Client _client;

  WaterQualityApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Get paginated list of all stations with optional filtering
  Future<Map<String, dynamic>> getStations({
    int page = 1,
    int perPage = 100,
    String? district,
    String? type,
    String? region,
    String? search,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
    };

    if (district != null) queryParams['district'] = district;
    if (type != null) queryParams['type'] = type;
    if (region != null) queryParams['region'] = region;
    if (search != null) queryParams['search'] = search;

    final uri = Uri.parse('$baseUrl/stations').replace(queryParameters: queryParams);
    
    try {
      final response = await _client.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': data['success'],
          'pagination': PaginationInfo.fromJson(data['pagination']),
          'stations': (data['stations'] as List)
              .map((s) => WaterQualityStation.fromJson(s))
              .toList(),
          'count': data['count'],
        };
      } else {
        throw Exception('Failed to load stations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching stations: $e');
    }
  }

  /// Get all stations (loads all pages automatically)
  Future<List<WaterQualityStation>> getAllStations({
    String? district,
    String? type,
    String? region,
  }) async {
    final allStations = <WaterQualityStation>[];
    int currentPage = 1;
    bool hasMore = true;

    while (hasMore) {
      final result = await getStations(
        page: currentPage,
        perPage: 200, // Max allowed
        district: district,
        type: type,
        region: region,
      );

      final stations = result['stations'] as List<WaterQualityStation>;
      allStations.addAll(stations);

      final pagination = result['pagination'] as PaginationInfo;
      hasMore = pagination.hasNext;
      currentPage++;

      // Safety check to prevent infinite loops
      if (currentPage > 100) break;
    }

    return allStations;
  }

  /// Get map data optimized for GPS markers (minimal mode)
  Future<Map<String, dynamic>> getMapData({
    int page = 1,
    int perPage = 1000,
    String? district,
    String? type,
    bool minimal = true,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
      'minimal': minimal.toString(),
    };

    if (district != null) queryParams['district'] = district;
    if (type != null) queryParams['type'] = type;

    final uri = Uri.parse('$baseUrl/stations/map-data').replace(queryParameters: queryParams);
    
    try {
      final response = await _client.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load map data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching map data: $e');
    }
  }

  /// Get current data for all stations
  Future<List<StationData>> getAllStationData({
    int page = 1,
    int perPage = 100,
    String? district,
    String? type,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
    };

    if (district != null) queryParams['district'] = district;
    if (type != null) queryParams['type'] = type;

    final uri = Uri.parse('$baseUrl/stations/data/all').replace(queryParameters: queryParams);
    
    try {
      final response = await _client.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['data'] as List)
            .map((d) => StationData.fromJson(d))
            .toList();
      } else {
        throw Exception('Failed to load station data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching station data: $e');
    }
  }

  /// Get stations by district
  Future<Map<String, dynamic>> getStationsByDistrict(
    String district, {
    int page = 1,
    int perPage = 100,
    String? type,
    bool includeData = false,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
      'include_data': includeData.toString(),
    };

    if (type != null) queryParams['type'] = type;

    final uri = Uri.parse('$baseUrl/stations/district/$district')
        .replace(queryParameters: queryParams);
    
    try {
      final response = await _client.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load district stations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching district stations: $e');
    }
  }

  /// Get stations with active alerts
  Future<Map<String, dynamic>> getStationsWithAlerts({
    int page = 1,
    int perPage = 50,
    String? district,
    String? severity,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
    };

    if (district != null) queryParams['district'] = district;
    if (severity != null) queryParams['severity'] = severity;

    final uri = Uri.parse('$baseUrl/stations/alerts').replace(queryParameters: queryParams);
    
    try {
      final response = await _client.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load alerts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching alerts: $e');
    }
  }

  /// Get summary statistics
  Future<Map<String, dynamic>> getSummaryStatistics() async {
    final uri = Uri.parse('$baseUrl/stations/summary');
    
    try {
      final response = await _client.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['summary'];
      } else {
        throw Exception('Failed to load summary: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching summary: $e');
    }
  }

  /// Get station history
  Future<Map<String, dynamic>> getStationHistory(
    String stationId, {
    int page = 1,
    int perPage = 50,
    int? limit,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
    };

    if (limit != null) queryParams['limit'] = limit.toString();

    final uri = Uri.parse('$baseUrl/stations/$stationId/history')
        .replace(queryParameters: queryParams);
    
    try {
      final response = await _client.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load history: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching history: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}
