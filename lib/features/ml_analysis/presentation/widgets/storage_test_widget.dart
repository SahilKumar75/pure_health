import 'package:flutter/material.dart';
import 'package:pure_health/core/services/local_storage_service.dart';
import 'package:pure_health/features/ml_analysis/data/services/historical_data_service.dart';

/// Demo widget to test the historical data storage system
/// Add this to your app to test the functionality
class StorageTestWidget extends StatefulWidget {
  const StorageTestWidget({super.key});

  @override
  State<StorageTestWidget> createState() => _StorageTestWidgetState();
}

class _StorageTestWidgetState extends State<StorageTestWidget> {
  final _log = <String>[];
  bool _isLoading = false;

  void _addLog(String message) {
    setState(() {
      _log.insert(0, '${DateTime.now().toLocal()}: $message');
      if (_log.length > 20) _log.removeLast();
    });
  }

  Future<void> _testStorageInfo() async {
    setState(() => _isLoading = true);
    try {
      final storage = await LocalStorageService.getInstance();
      final info = await storage.getStorageInfo();
      _addLog('✓ Storage Info:');
      _addLog('  - Stations: ${info['totalStations']}');
      _addLog('  - Readings: ${info['totalReadings']}');
      _addLog('  - Last Update: ${info['lastUpdate']}');
    } catch (e) {
      _addLog('✗ Error: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _testGetHistory() async {
    setState(() => _isLoading = true);
    try {
      final storage = await LocalStorageService.getInstance();
      final allHistory = await storage.getAllStationsHistory();
      
      if (allHistory.isEmpty) {
        _addLog('⚠ No historical data found. Run simulation first!');
      } else {
        _addLog('✓ Found data for ${allHistory.length} stations');
        for (final entry in allHistory.entries.take(3)) {
          _addLog('  - ${entry.key}: ${entry.value.length} readings');
        }
      }
    } catch (e) {
      _addLog('✗ Error: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _testMLData() async {
    setState(() => _isLoading = true);
    try {
      final storage = await LocalStorageService.getInstance();
      final allHistory = await storage.getAllStationsHistory();
      
      if (allHistory.isEmpty) {
        _addLog('⚠ No data available. Run simulation first!');
        setState(() => _isLoading = false);
        return;
      }

      final firstStationId = allHistory.keys.first;
      _addLog('Testing ML data for station: $firstStationId');

      final historicalService = await HistoricalDataService.create();
      
      // Test prediction data
      final predictionData = await historicalService.getMLPredictionData(firstStationId);
      if (predictionData['hasData']) {
        _addLog('✓ Prediction Data:');
        _addLog('  - Data points: ${predictionData['dataPoints']}');
        final stats = predictionData['statistics'];
        _addLog('  - Avg WQI: ${(stats['avgWqi'] as double).toStringAsFixed(1)}');
      }

      // Test trend analysis
      final trendData = await historicalService.getTrendAnalysisData(firstStationId);
      if (trendData['hasData']) {
        _addLog('✓ Trend Analysis:');
        final wqiTrend = trendData['trends']['wqi'];
        _addLog('  - WQI Trend: ${wqiTrend['direction']}');
        _addLog('  - Anomalies: ${trendData['anomalies'].length}');
      }

      // Test risk assessment
      final riskData = await historicalService.getRiskAssessmentData(firstStationId);
      if (riskData['hasData']) {
        _addLog('✓ Risk Assessment:');
        _addLog('  - Risk Level: ${riskData['riskLevel']}');
      }

    } catch (e) {
      _addLog('✗ Error: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _testExport() async {
    setState(() => _isLoading = true);
    try {
      final storage = await LocalStorageService.getInstance();
      final allHistory = await storage.getAllStationsHistory();
      
      if (allHistory.isEmpty) {
        _addLog('⚠ No data to export. Run simulation first!');
        setState(() => _isLoading = false);
        return;
      }

      final firstStationId = allHistory.keys.first;
      final historicalService = await HistoricalDataService.create();
      final exportData = await historicalService.exportDataForML(firstStationId);
      
      if (exportData['success']) {
        _addLog('✓ Export successful:');
        _addLog('  - Station: ${exportData['stationId']}');
        _addLog('  - Data points: ${exportData['dataPoints']}');
        _addLog('  - Ready for ML backend');
      }
    } catch (e) {
      _addLog('✗ Error: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _clearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text('This will delete all stored data.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final storage = await LocalStorageService.getInstance();
      await storage.clearAllHistory();
      _addLog('✓ All data cleared');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Storage System Test'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // Test Buttons
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _testStorageInfo,
                        icon: const Icon(Icons.info),
                        label: const Text('Storage Info'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _testGetHistory,
                        icon: const Icon(Icons.history),
                        label: const Text('Get History'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _testMLData,
                        icon: const Icon(Icons.analytics),
                        label: const Text('Test ML Data'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _testExport,
                        icon: const Icon(Icons.download),
                        label: const Text('Test Export'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _clearAll,
                  icon: const Icon(Icons.delete),
                  label: const Text('Clear All Data'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          
          // Log Display
          Expanded(
            child: Container(
              color: Colors.black87,
              padding: const EdgeInsets.all(16),
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : ListView.builder(
                      itemCount: _log.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            _log[index],
                            style: const TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 12,
                              fontFamily: 'monospace',
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
