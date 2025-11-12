import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pure_health/core/models/station_models.dart';

class LocalStorageService {
  static const String _lastUpdateKey = 'last_data_update';
  static const int _maxStoredReadings = 500; // Store last 500 readings per station

  static LocalStorageService? _instance;
  static SharedPreferences? _preferences;

  LocalStorageService._();

  static Future<LocalStorageService> getInstance() async {
    _instance ??= LocalStorageService._();
    _preferences ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  /// Save a new reading for a station
  Future<void> saveStationReading(StationData stationData) async {
    try {
      final historicalData = await getStationHistory(stationData.stationId);
      
      // Add new reading at the beginning
      historicalData.insert(0, stationData);
      
      // Keep only the last N readings to prevent excessive storage
      if (historicalData.length > _maxStoredReadings) {
        historicalData.removeRange(_maxStoredReadings, historicalData.length);
      }
      
      // Save to preferences
      final key = _getStationKey(stationData.stationId);
      final jsonList = historicalData.map((data) => _stationDataToJson(data)).toList();
      await _preferences!.setString(key, jsonEncode(jsonList));
      
      // Update last update timestamp
      await _preferences!.setString(_lastUpdateKey, DateTime.now().toIso8601String());
      
      print('[STORAGE] Saved reading for station ${stationData.stationId}. Total readings: ${historicalData.length}');
    } catch (e) {
      print('[STORAGE] Error saving station reading: $e');
    }
  }

  /// Save multiple station readings at once (bulk save)
  Future<void> saveMultipleReadings(Map<String, StationData> stationDataMap) async {
    try {
      for (final entry in stationDataMap.entries) {
        await saveStationReading(entry.value);
      }
      print('[STORAGE] Bulk saved ${stationDataMap.length} station readings');
    } catch (e) {
      print('[STORAGE] Error in bulk save: $e');
    }
  }

  /// Get historical data for a specific station
  Future<List<StationData>> getStationHistory(String stationId, {int? limit}) async {
    try {
      final key = _getStationKey(stationId);
      final jsonString = _preferences!.getString(key);
      
      if (jsonString == null) return [];
      
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final history = jsonList.map((json) => _stationDataFromJson(json)).toList();
      
      if (limit != null && history.length > limit) {
        return history.sublist(0, limit);
      }
      
      return history;
    } catch (e) {
      print('[STORAGE] Error getting station history: $e');
      return [];
    }
  }

  /// Get historical data for all stations
  Future<Map<String, List<StationData>>> getAllStationsHistory() async {
    try {
      final allKeys = _preferences!.getKeys();
      final stationKeys = allKeys.where((key) => key.startsWith('station_')).toList();
      
      final Map<String, List<StationData>> allHistory = {};
      
      for (final key in stationKeys) {
        final stationId = key.replaceFirst('station_', '');
        allHistory[stationId] = await getStationHistory(stationId);
      }
      
      print('[STORAGE] Retrieved history for ${allHistory.length} stations');
      return allHistory;
    } catch (e) {
      print('[STORAGE] Error getting all stations history: $e');
      return {};
    }
  }

  /// Get readings within a date range
  Future<List<StationData>> getStationReadingsInRange(
    String stationId, {
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final allReadings = await getStationHistory(stationId);
      
      return allReadings.where((data) {
        final timestamp = DateTime.parse(data.timestamp);
        return timestamp.isAfter(startDate) && timestamp.isBefore(endDate);
      }).toList();
    } catch (e) {
      print('[STORAGE] Error filtering readings by date: $e');
      return [];
    }
  }

  /// Get statistics for a station over time
  Future<Map<String, dynamic>> getStationStatistics(String stationId) async {
    try {
      final history = await getStationHistory(stationId);
      
      if (history.isEmpty) {
        return {
          'totalReadings': 0,
          'avgWqi': 0.0,
          'minWqi': 0.0,
          'maxWqi': 0.0,
          'statusDistribution': {},
        };
      }
      
      final wqiValues = history.map((data) => data.wqi).toList();
      final avgWqi = wqiValues.reduce((a, b) => a + b) / wqiValues.length;
      final minWqi = wqiValues.reduce((a, b) => a < b ? a : b);
      final maxWqi = wqiValues.reduce((a, b) => a > b ? a : b);
      
      // Status distribution
      final statusCounts = <String, int>{};
      for (final data in history) {
        statusCounts[data.status] = (statusCounts[data.status] ?? 0) + 1;
      }
      
      return {
        'totalReadings': history.length,
        'avgWqi': avgWqi,
        'minWqi': minWqi,
        'maxWqi': maxWqi,
        'statusDistribution': statusCounts,
        'oldestReading': history.last.timestamp,
        'latestReading': history.first.timestamp,
      };
    } catch (e) {
      print('[STORAGE] Error calculating statistics: $e');
      return {};
    }
  }

  /// Get the last update timestamp
  Future<DateTime?> getLastUpdateTime() async {
    try {
      final timestamp = _preferences!.getString(_lastUpdateKey);
      if (timestamp == null) return null;
      return DateTime.parse(timestamp);
    } catch (e) {
      print('[STORAGE] Error getting last update time: $e');
      return null;
    }
  }

  /// Clear all historical data
  Future<void> clearAllHistory() async {
    try {
      final allKeys = _preferences!.getKeys();
      final stationKeys = allKeys.where((key) => key.startsWith('station_')).toList();
      
      for (final key in stationKeys) {
        await _preferences!.remove(key);
      }
      
      await _preferences!.remove(_lastUpdateKey);
      print('[STORAGE] Cleared all historical data');
    } catch (e) {
      print('[STORAGE] Error clearing history: $e');
    }
  }

  /// Clear history for a specific station
  Future<void> clearStationHistory(String stationId) async {
    try {
      final key = _getStationKey(stationId);
      await _preferences!.remove(key);
      print('[STORAGE] Cleared history for station $stationId');
    } catch (e) {
      print('[STORAGE] Error clearing station history: $e');
    }
  }

  /// Get storage info (for debugging)
  Future<Map<String, dynamic>> getStorageInfo() async {
    try {
      final allKeys = _preferences!.getKeys();
      final stationKeys = allKeys.where((key) => key.startsWith('station_')).toList();
      
      int totalReadings = 0;
      for (final key in stationKeys) {
        final stationId = key.replaceFirst('station_', '');
        final history = await getStationHistory(stationId);
        totalReadings += history.length;
      }
      
      return {
        'totalStations': stationKeys.length,
        'totalReadings': totalReadings,
        'lastUpdate': await getLastUpdateTime(),
      };
    } catch (e) {
      print('[STORAGE] Error getting storage info: $e');
      return {};
    }
  }

  // Helper methods
  String _getStationKey(String stationId) => 'station_$stationId';

  Map<String, dynamic> _stationDataToJson(StationData data) {
    return {
      'stationId': data.stationId,
      'timestamp': data.timestamp,
      'wqi': data.wqi,
      'status': data.status,
      'waterQualityClass': data.waterQualityClass,
      'parameters': data.parameters,
      'alerts': data.alerts,
    };
  }

  StationData _stationDataFromJson(Map<String, dynamic> json) {
    return StationData(
      stationId: json['stationId'] as String,
      timestamp: json['timestamp'] as String,
      wqi: (json['wqi'] as num).toDouble(),
      status: json['status'] as String,
      waterQualityClass: json['waterQualityClass'] as String,
      parameters: Map<String, dynamic>.from(json['parameters']),
      alerts: List<dynamic>.from(json['alerts']),
    );
  }
}
