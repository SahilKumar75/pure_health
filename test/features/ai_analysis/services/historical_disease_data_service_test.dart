import 'package:flutter_test/flutter_test.dart';
import 'package:pure_health/features/ai_analysis/data/services/historical_disease_data_service.dart';

void main() {
  group('HistoricalDiseaseDataService Tests', () {
    late HistoricalDiseaseDataService service;

    setUp(() {
      service = HistoricalDiseaseDataService();
    });

    test('Load index metadata', () async {
      final index = await service.loadIndex();
      
      expect(index, isNotNull);
      expect(index['total_stations'], 4495);
      expect(index['days_per_station'], 365);
      expect(index['total_readings'], 1640675);
      expect(index['batches'], 45);
    });

    test('Load station data', () async {
      final data = await service.loadStationData('MH-PUN-SW-001');
      
      expect(data, isNotEmpty);
      expect(data.length, 365); // 1 year of data
      expect(data.first.stationId, 'MH-PUN-SW-001');
      expect(data.first.diseaseRisks.length, 7); // 7 diseases
    });

    test('Get latest reading', () async {
      final latest = await service.getLatestReading('MH-PUN-SW-001');
      
      expect(latest, isNotNull);
      expect(latest!.diseaseRisks.length, 7);
      expect(latest.outbreakProbability, isNotNull);
    });

    test('Get disease risk trends', () async {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 30));
      
      final trends = await service.getDiseaseRiskTrends(
        'MH-PUN-SW-001',
        startDate,
        endDate,
      );
      
      expect(trends, isNotEmpty);
      expect(trends.keys, contains('cholera'));
      expect(trends.keys, contains('malaria'));
      expect(trends['cholera'], isNotEmpty);
    });

    test('Get seasonal patterns', () async {
      final patterns = await service.getSeasonalDiseasePatterns('MH-PUN-SW-001');
      
      expect(patterns, isNotEmpty);
      expect(patterns.keys.length, greaterThan(0));
      
      // Check if we have seasonal data
      final seasons = ['Pre-Monsoon', 'Monsoon', 'Post-Monsoon', 'Winter'];
      for (var season in seasons) {
        if (patterns.containsKey(season)) {
          expect(patterns[season], isNotEmpty);
        }
      }
    });

    test('Cache functionality', () async {
      // First load
      final data1 = await service.loadStationData('MH-PUN-SW-001');
      
      // Second load (should use cache)
      final data2 = await service.loadStationData('MH-PUN-SW-001');
      
      expect(data1.length, data2.length);
      
      final stats = service.getCacheStats();
      expect(stats['cache_size'], greaterThan(0));
      expect(stats['cached_stations'], contains('MH-PUN-SW-001'));
    });

    test('Clear cache', () {
      service.clearCache();
      final stats = service.getCacheStats();
      expect(stats['cache_size'], 0);
    });
  });
}
