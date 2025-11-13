import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/disease_risk_model.dart';

/// Service to load and manage historical disease data
class HistoricalDiseaseDataService {
  static final HistoricalDiseaseDataService _instance =
      HistoricalDiseaseDataService._internal();
  factory HistoricalDiseaseDataService() => _instance;
  HistoricalDiseaseDataService._internal();

  // Cache for loaded data
  final Map<String, List<StationDataWithDisease>> _stationDataCache = {};
  Map<String, dynamic>? _indexData;
  Map<String, dynamic>? _sampleData;  // NEW: Cache for sample data
  bool _isIndexLoaded = false;
  bool _isSampleDataLoaded = false;  // NEW

  /// Load the index file to get metadata
  Future<Map<String, dynamic>> loadIndex() async {
    if (_isIndexLoaded && _indexData != null) {
      return _indexData!;
    }

    try {
      final String jsonString =
          await rootBundle.loadString('assets/historical_data/sample_index.json');
      _indexData = json.decode(jsonString) as Map<String, dynamic>;
      _isIndexLoaded = true;
      return _indexData!;
    } catch (e) {
      print('❌ Error loading index: $e');
      return {
        'total_stations': 0,
        'days_per_station': 0,
        'total_readings': 0,
        'error': e.toString(),
      };
    }
  }

  /// Load all sample data at once (it's small enough)
  Future<Map<String, dynamic>> _loadSampleData() async {
    if (_isSampleDataLoaded && _sampleData != null) {
      return _sampleData!;
    }

    try {
      final String jsonString =
          await rootBundle.loadString('assets/historical_data/sample_disease_data.json');
      _sampleData = json.decode(jsonString) as Map<String, dynamic>;
      _isSampleDataLoaded = true;
      return _sampleData!;
    } catch (e) {
      print('❌ Error loading sample data: $e');
      return {};
    }
  }

  /// Load historical data for a specific station
  Future<List<StationDataWithDisease>> loadStationData(String stationId) async {
    // Check cache first
    if (_stationDataCache.containsKey(stationId)) {
      return _stationDataCache[stationId]!;
    }

    try {
      // Load the sample data (all at once since it's small)
      final sampleData = await _loadSampleData();
      
      // Extract data for the specific station
      if (sampleData.containsKey(stationId)) {
        final stationData = sampleData[stationId] as Map<String, dynamic>;
        final readings = (stationData['readings'] as List<dynamic>)
            .map((r) => StationDataWithDisease.fromJson(r as Map<String, dynamic>))
            .toList();

        _stationDataCache[stationId] = readings;
        return readings;
      } else {
        // Station not in sample data - this is expected for most stations
        // Return empty list and let UI handle it gracefully
        _stationDataCache[stationId] = [];
        return [];
      }
    } catch (e) {
      print('❌ Error loading station data for $stationId: $e');
      return [];
    }
  }

  /// Load data for a date range
  Future<List<StationDataWithDisease>> loadStationDataForDateRange(
    String stationId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final allData = await loadStationData(stationId);
    return allData
        .where((reading) =>
            reading.timestamp.isAfter(startDate.subtract(const Duration(days: 1))) &&
            reading.timestamp.isBefore(endDate.add(const Duration(days: 1))))
        .toList();
  }

  /// Get latest reading for a station
  Future<StationDataWithDisease?> getLatestReading(String stationId) async {
    final allData = await loadStationData(stationId);
    if (allData.isEmpty) return null;

    // Sort by timestamp descending and get the first
    allData.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return allData.first;
  }

  /// Get disease risk statistics for a station over time
  Future<Map<String, List<int>>> getDiseaseRiskTrends(
    String stationId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final data = await loadStationDataForDateRange(stationId, startDate, endDate);
    
    final trends = <String, List<int>>{
      'cholera': [],
      'typhoid': [],
      'dysentery': [],
      'hepatitis_a': [],
      'malaria': [],
      'dengue': [],
      'skin_infections': [],
    };

    for (var reading in data) {
      for (var risk in reading.diseaseRisks) {
        if (trends.containsKey(risk.diseaseType)) {
          trends[risk.diseaseType]!.add(risk.riskScore);
        }
      }
    }

    return trends;
  }

  /// Get outbreak probability over time
  Future<List<OutbreakProbability>> getOutbreakTrend(
    String stationId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final data = await loadStationDataForDateRange(stationId, startDate, endDate);
    return data.map((reading) => reading.outbreakProbability).toList();
  }

  /// Get high-risk periods (days with high/critical outbreak probability)
  Future<List<DateTime>> getHighRiskPeriods(
    String stationId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final data = await loadStationDataForDateRange(stationId, startDate, endDate);
    return data
        .where((reading) =>
            reading.outbreakProbability.level == 'high' ||
            reading.outbreakProbability.level == 'medium')
        .map((reading) => reading.timestamp)
        .toList();
  }

  /// Get seasonal disease patterns
  Future<Map<String, Map<String, double>>> getSeasonalDiseasePatterns(
    String stationId,
  ) async {
    final allData = await loadStationData(stationId);
    
    final seasonalData = <String, Map<String, List<int>>>{
      'Pre-Monsoon': {},
      'Monsoon': {},
      'Post-Monsoon': {},
      'Winter': {},
    };

    // Collect data by season
    for (var reading in allData) {
      final season = reading.season;
      if (!seasonalData.containsKey(season)) continue;

      for (var risk in reading.diseaseRisks) {
        seasonalData[season]![risk.diseaseType] ??= [];
        seasonalData[season]![risk.diseaseType]!.add(risk.riskScore);
      }
    }

    // Calculate averages
    final averages = <String, Map<String, double>>{};
    for (var season in seasonalData.keys) {
      averages[season] = {};
      for (var disease in seasonalData[season]!.keys) {
        final scores = seasonalData[season]![disease]!;
        if (scores.isNotEmpty) {
          averages[season]![disease] =
              scores.reduce((a, b) => a + b) / scores.length;
        }
      }
    }

    return averages;
  }

  /// Clear cache
  void clearCache() {
    _stationDataCache.clear();
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    return {
      'cached_stations': _stationDataCache.keys.toList(),
      'cache_size': _stationDataCache.length,
      'index_loaded': _isIndexLoaded,
    };
  }
}
