import 'dart:math';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:latlong2/latlong.dart';

class LocalStationGenerator {
  List<Map<String, dynamic>> _allStations = [];
  bool _isInitialized = false;
  
  // Load stations from embedded JSON file
  Future<void> initialize({int totalStations = 4495}) async {
    if (_isInitialized) {
      print('[GENERATOR] Already initialized with ${_allStations.length} stations');
      return;
    }
    
    print('[GENERATOR] Loading ${totalStations} stations from embedded data...');
    
    try {
      // Load the JSON file from assets
      final String jsonString = await rootBundle.loadString('assets/all_stations_data.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      final List<dynamic> stationsJson = jsonData['stations'];
      _allStations = stationsJson.map((station) {
        final wqi = station['wqi'] as double;
        final status = _getStatusFromWQI(wqi);
        final waterClass = _getWaterClass(wqi);
        final hasAlerts = wqi < 70;
        final alertCount = hasAlerts ? ((wqi - 40).abs() / 3).round() : 0;
        
        return {
          'id': station['id'],
          'name': station['name'],
          'type': station['type'],
          'district': station['district'],
          'latitude': station['latitude'],
          'longitude': station['longitude'],
          'wqi': wqi,
          'status': status,
          'waterClass': waterClass,
          'hasAlerts': hasAlerts,
          'alertCount': alertCount,
        };
      }).toList();
      
      _isInitialized = true;
      print('[GENERATOR] ✓ Loaded exactly ${_allStations.length} stations from backend data');
      print('[GENERATOR] - ALL data directly from Python backend');
      print('[GENERATOR] - NO BACKEND SERVER NEEDED!');
      print('[GENERATOR] - Ready to use!');
    } catch (e) {
      print('[GENERATOR] ERROR loading stations: $e');
      throw Exception('Failed to load station data');
    }
  }
  
  String _getStatusFromWQI(double wqi) {
    if (wqi >= 80) return 'Excellent';
    if (wqi >= 65) return 'Good';
    if (wqi >= 50) return 'Moderate';
    return 'Poor';
  }
  
  String _getWaterClass(double wqi) {
    if (wqi >= 80) return 'Class A - Drinking without treatment';
    if (wqi >= 70) return 'Class B - Outdoor bathing (organized)';
    if (wqi >= 60) return 'Class C - Drinking with conventional treatment';
    if (wqi >= 50) return 'Class D - Fish & Wildlife propagation';
    return 'Class E - Irrigation & Industrial use';
  }
  
  // Get total station count
  int getTotalStationCount() => _allStations.length;
  
  // Get stations within radius
  Map<String, dynamic> getNearbyStations({
    required double latitude,
    required double longitude,
    double radiusKm = 30,
    int limit = 200,
    String? district,
    String? type,
  }) {
    print('[GENERATOR] Getting stations within ${radiusKm}km of ($latitude, $longitude)');
    
    final nearbyStations = <Map<String, dynamic>>[];
    
    for (var station in _allStations) {
      // Filter by district if specified
      if (district != null && station['district'] != district) continue;
      
      // Filter by type if specified
      if (type != null && station['type'] != type) continue;
      
      // Calculate distance
      final distance = _calculateDistance(
        latitude,
        longitude,
        station['latitude'] as double,
        station['longitude'] as double,
      );
      
      if (distance <= radiusKm) {
        final stationWithDistance = Map<String, dynamic>.from(station);
        stationWithDistance['distance'] = distance;
        nearbyStations.add(stationWithDistance);
      }
      
      if (nearbyStations.length >= limit) break;
    }
    
    // Sort by distance
    nearbyStations.sort((a, b) => 
      (a['distance'] as double).compareTo(b['distance'] as double)
    );
    
    print('[GENERATOR] Found ${nearbyStations.length} stations');
    
    return {
      'success': true,
      'stations': nearbyStations,
      'totalFound': nearbyStations.length,
      'radius': radiusKm,
      'userLocation': {
        'latitude': latitude,
        'longitude': longitude,
      }
    };
  }
  
  // Get paginated stations
  Map<String, dynamic> getMapData({
    int page = 1,
    int perPage = 50,
    String? district,
    String? type,
    bool minimal = false,
  }) {
    print('[GENERATOR] Getting map data (page: $page, perPage: $perPage)');
    
    var filteredStations = _allStations;
    
    // Filter by district
    if (district != null) {
      filteredStations = filteredStations
          .where((s) => s['district'] == district)
          .toList();
    }
    
    // Filter by type
    if (type != null) {
      filteredStations = filteredStations
          .where((s) => s['type'] == type)
          .toList();
    }
    
    // If requesting many stations (like 1000+), return all filtered stations
    if (perPage >= 1000) {
      print('[GENERATOR] Returning ALL ${filteredStations.length} stations (no pagination)');
      return {
        'success': true,
        'stations': filteredStations,
        'count': filteredStations.length,
        'pagination': {
          'page': 1,
          'per_page': filteredStations.length,
          'total_items': filteredStations.length,
          'total_pages': 1,
          'has_next': false,
          'has_prev': false,
        },
        'filters': {
          'district': district,
          'type': type,
          'minimal': minimal,
        }
      };
    }
    
    // Paginate for smaller requests
    final startIndex = (page - 1) * perPage;
    final endIndex = (startIndex + perPage).clamp(0, filteredStations.length);
    final pageStations = filteredStations.sublist(
      startIndex.clamp(0, filteredStations.length),
      endIndex,
    );
    
    print('[GENERATOR] Returning ${pageStations.length} of ${filteredStations.length} total stations');
    
    return {
      'success': true,
      'stations': pageStations,
      'count': pageStations.length,
      'pagination': {
        'page': page,
        'per_page': perPage,
        'total_items': filteredStations.length,
        'total_pages': (filteredStations.length / perPage).ceil(),
        'has_next': endIndex < filteredStations.length,
        'has_prev': page > 1,
      },
      'filters': {
        'district': district,
        'type': type,
        'minimal': minimal,
      }
    };
  }
  
  // Get stations in viewport
  Map<String, dynamic> getViewportStations({
    required double north,
    required double south,
    required double east,
    required double west,
    int zoom = 10,
  }) {
    print('[GENERATOR] Getting viewport stations (N:$north, S:$south, E:$east, W:$west, Zoom:$zoom)');
    
    final viewportStations = <Map<String, dynamic>>[];
    
    for (var station in _allStations) {
      final lat = station['latitude'] as double;
      final lon = station['longitude'] as double;
      
      // Check if station is within viewport bounds
      if (lat >= south && lat <= north && lon >= west && lon <= east) {
        viewportStations.add(station);
      }
    }
    
    print('[GENERATOR] Found ${viewportStations.length} stations in viewport');
    
    return {
      'success': true,
      'stations': viewportStations,
      'count': viewportStations.length,
    };
  }
  
  // Calculate distance between two points (Haversine formula)
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // km
    
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);
    
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }
  
  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }
}
