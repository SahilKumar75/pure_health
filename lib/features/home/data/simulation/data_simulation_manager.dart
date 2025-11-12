import 'dart:async';
import 'dart:math';
import 'package:pure_health/core/models/station_models.dart';
import 'package:pure_health/core/services/local_storage_service.dart';

class DataSimulationManager {
  Timer? _dataUpdateTimer;
  final Random _random = Random();
  final Function(Map<String, StationData>) onDataUpdated;
  bool _isDisposed = false;
  LocalStorageService? _storageService;

  DataSimulationManager({required this.onDataUpdated}) {
    _initializeStorage();
  }

  Future<void> _initializeStorage() async {
    _storageService = await LocalStorageService.getInstance();
    print('[SIMULATION] Storage service initialized');
  }

  void startSimulation({
    required Duration interval,
    required List<WaterQualityStation> visibleStations,
    required Map<String, StationData> allStationData,
  }) {
    if (_isDisposed) return;
    _dataUpdateTimer?.cancel();
    _dataUpdateTimer = Timer.periodic(interval, (_) {
      if (!_isDisposed) {
        _simulateDataUpdates(visibleStations, allStationData);
      }
    });
  }

  void stopSimulation() {
    _dataUpdateTimer?.cancel();
    _dataUpdateTimer = null;
  }

  void dispose() {
    _isDisposed = true;
    stopSimulation();
  }

  void _simulateDataUpdates(
    List<WaterQualityStation> visibleStations,
    Map<String, StationData> allStationData,
  ) async {
    if (_isDisposed) return;
    
    print('[SIMULATION] Simulating WQI changes for ${visibleStations.length} visible stations...');

    final updatedData = Map<String, StationData>.from(allStationData);

    for (final station in visibleStations) {
      final stationId = station.id;
      final currentData = allStationData[stationId];

      if (currentData == null) continue;

      // Simulate realistic WQI fluctuation (±5 points, staying within 0-100)
      final currentWqi = currentData.wqi;
      final change = (_random.nextDouble() * 10) - 5; // -5 to +5
      var newWqi = (currentWqi + change).clamp(0.0, 100.0);

      // Round to 1 decimal place
      newWqi = double.parse(newWqi.toStringAsFixed(1));

      // Determine new status based on WQI
      String newStatus;
      String newWaterQualityClass;

      if (newWqi >= 80) {
        newStatus = 'good';
        newWaterQualityClass = 'Excellent';
      } else if (newWqi >= 60) {
        newStatus = 'moderate';
        newWaterQualityClass = 'Good';
      } else if (newWqi >= 40) {
        newStatus = 'poor';
        newWaterQualityClass = 'Fair';
      } else if (newWqi >= 20) {
        newStatus = 'very_poor';
        newWaterQualityClass = 'Poor';
      } else {
        newStatus = 'critical';
        newWaterQualityClass = 'Critical';
      }

      // Create alerts if WQI is below threshold
      final alerts = <dynamic>[];
      if (newWqi < 40) {
        alerts.add({
          'type': 'water_quality',
          'severity': newWqi < 20 ? 'high' : 'medium',
          'message': 'Water quality ${newWqi < 20 ? 'critical' : 'degraded'} - WQI: ${newWqi.toStringAsFixed(1)}'
        });
      }

      // Generate updated parameters with realistic ranges
      final updatedParameters = _generateRealisticParameters(station.type);

      updatedData[stationId] = StationData(
        stationId: stationId,
        timestamp: DateTime.now().toIso8601String(),
        wqi: newWqi,
        status: newStatus,
        waterQualityClass: newWaterQualityClass,
        parameters: updatedParameters,
        alerts: alerts,
      );
    }

    print('[SIMULATION] Updated data for ${visibleStations.length} stations');
    
    // Save to local storage
    if (_storageService != null) {
      await _storageService!.saveMultipleReadings(updatedData);
    }
    
    if (!_isDisposed) {
      onDataUpdated(updatedData);
    }
  }

  Map<String, dynamic> _generateRealisticParameters(String stationType) {
    // Generate realistic parameter ranges based on water type
    final isSurfaceWater = stationType == 'Surface Water';

    return {
      'pH': {
        'value': (6.0 + _random.nextDouble() * 2.5).toStringAsFixed(1),
        'unit': 'pH',
        'status': 'normal',
      },
      'dissolvedOxygen': {
        'value': (4.0 + _random.nextDouble() * 4.0).toStringAsFixed(1),
        'unit': 'mg/L',
        'status': 'normal',
      },
      'bod': {
        'value': (1.0 + _random.nextDouble() * 4.0).toStringAsFixed(1),
        'unit': 'mg/L',
        'status': 'normal',
      },
      'temperature': {
        'value': (20.0 + _random.nextDouble() * 10.0).toStringAsFixed(1),
        'unit': '°C',
        'status': 'normal',
      },
      'turbidity': {
        'value': (0.5 + _random.nextDouble() * 4.5).toStringAsFixed(1),
        'unit': 'NTU',
        'status': 'normal',
      },
      'conductivity': {
        'value': isSurfaceWater
            ? (200 + _random.nextDouble() * 300).toStringAsFixed(0)
            : (400 + _random.nextDouble() * 600).toStringAsFixed(0),
        'unit': 'µS/cm',
        'status': 'normal',
      },
      'totalDissolvedSolids': {
        'value': isSurfaceWater
            ? (100 + _random.nextDouble() * 200).toStringAsFixed(0)
            : (200 + _random.nextDouble() * 400).toStringAsFixed(0),
        'unit': 'mg/L',
        'status': 'normal',
      },
    };
  }
}
