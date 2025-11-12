import 'package:pure_health/core/models/station_models.dart';
import 'package:pure_health/core/services/local_storage_service.dart';

class HistoricalDataService {
  final LocalStorageService _storageService;

  HistoricalDataService(this._storageService);

  static Future<HistoricalDataService> create() async {
    final storage = await LocalStorageService.getInstance();
    return HistoricalDataService(storage);
  }

  /// Get formatted data for ML prediction models
  Future<Map<String, dynamic>> getMLPredictionData(String stationId, {int limit = 100}) async {
    final history = await _storageService.getStationHistory(stationId, limit: limit);
    
    if (history.isEmpty) {
      return {
        'hasData': false,
        'message': 'No historical data available for prediction',
      };
    }

    // Extract time series data for key parameters
    final timestamps = <String>[];
    final wqiValues = <double>[];
    final phValues = <double?>[];
    final doValues = <double?>[];
    final turbidityValues = <double?>[];
    final temperatureValues = <double?>[];
    
    for (final data in history.reversed) {
      timestamps.add(data.timestamp);
      wqiValues.add(data.wqi);
      phValues.add(_extractParameterValue(data.parameters, 'pH'));
      doValues.add(_extractParameterValue(data.parameters, 'dissolvedOxygen'));
      turbidityValues.add(_extractParameterValue(data.parameters, 'turbidity'));
      temperatureValues.add(_extractParameterValue(data.parameters, 'temperature'));
    }

    return {
      'hasData': true,
      'stationId': stationId,
      'dataPoints': history.length,
      'timeRange': {
        'start': history.last.timestamp,
        'end': history.first.timestamp,
      },
      'timeSeries': {
        'timestamps': timestamps,
        'wqi': wqiValues,
        'pH': phValues,
        'dissolvedOxygen': doValues,
        'turbidity': turbidityValues,
        'temperature': temperatureValues,
      },
      'statistics': await _storageService.getStationStatistics(stationId),
    };
  }

  /// Get trend analysis data
  Future<Map<String, dynamic>> getTrendAnalysisData(String stationId) async {
    final history = await _storageService.getStationHistory(stationId);
    
    if (history.isEmpty) {
      return {
        'hasData': false,
        'message': 'No historical data available for trend analysis',
      };
    }

    // Calculate trends
    final wqiTrend = _calculateTrend(history.map((d) => d.wqi).toList());
    final phTrend = _calculateParameterTrend(history, 'pH');
    final doTrend = _calculateParameterTrend(history, 'dissolvedOxygen');
    
    // Detect anomalies
    final anomalies = _detectAnomalies(history);
    
    // Calculate quality degradation rate
    final degradationRate = _calculateDegradationRate(history);

    return {
      'hasData': true,
      'stationId': stationId,
      'dataPoints': history.length,
      'trends': {
        'wqi': wqiTrend,
        'pH': phTrend,
        'dissolvedOxygen': doTrend,
      },
      'anomalies': anomalies,
      'degradationRate': degradationRate,
      'timeRange': {
        'start': history.last.timestamp,
        'end': history.first.timestamp,
      },
    };
  }

  /// Get risk assessment data
  Future<Map<String, dynamic>> getRiskAssessmentData(String stationId) async {
    final history = await _storageService.getStationHistory(stationId);
    
    if (history.isEmpty) {
      return {
        'hasData': false,
        'message': 'No historical data available for risk assessment',
      };
    }

    final recentData = history.take(20).toList();
    final stats = await _storageService.getStationStatistics(stationId);
    
    // Calculate risk factors
    final wqiVolatility = _calculateVolatility(history.map((d) => d.wqi).toList());
    final alertFrequency = _calculateAlertFrequency(history);
    final criticalEvents = _countCriticalEvents(history);
    
    // Determine risk level
    final riskLevel = _determineRiskLevel(wqiVolatility, alertFrequency, stats);

    return {
      'hasData': true,
      'stationId': stationId,
      'riskLevel': riskLevel,
      'riskFactors': {
        'wqiVolatility': wqiVolatility,
        'alertFrequency': alertFrequency,
        'criticalEvents': criticalEvents,
        'averageWqi': stats['avgWqi'],
      },
      'recentReadings': recentData.length,
      'totalReadings': history.length,
    };
  }

  /// Get comparison data for multiple stations
  Future<Map<String, dynamic>> getMultiStationComparison(List<String> stationIds) async {
    final comparisonData = <String, Map<String, dynamic>>{};
    
    for (final stationId in stationIds) {
      final stats = await _storageService.getStationStatistics(stationId);
      if (stats.isNotEmpty) {
        comparisonData[stationId] = stats;
      }
    }

    return {
      'hasData': comparisonData.isNotEmpty,
      'stations': comparisonData,
      'totalStations': comparisonData.length,
    };
  }

  /// Export data for external ML processing
  Future<Map<String, dynamic>> exportDataForML(String stationId) async {
    final history = await _storageService.getStationHistory(stationId);
    
    if (history.isEmpty) {
      return {
        'success': false,
        'message': 'No data to export',
      };
    }

    // Format data in ML-friendly structure
    final features = <Map<String, dynamic>>[];
    
    for (final data in history) {
      features.add({
        'timestamp': data.timestamp,
        'wqi': data.wqi,
        'status': data.status,
        'pH': _extractParameterValue(data.parameters, 'pH'),
        'dissolvedOxygen': _extractParameterValue(data.parameters, 'dissolvedOxygen'),
        'bod': _extractParameterValue(data.parameters, 'bod'),
        'temperature': _extractParameterValue(data.parameters, 'temperature'),
        'turbidity': _extractParameterValue(data.parameters, 'turbidity'),
        'conductivity': _extractParameterValue(data.parameters, 'conductivity'),
        'tds': _extractParameterValue(data.parameters, 'totalDissolvedSolids'),
        'hasAlerts': data.alerts.isNotEmpty,
        'alertCount': data.alerts.length,
      });
    }

    return {
      'success': true,
      'stationId': stationId,
      'dataPoints': features.length,
      'features': features,
      'metadata': {
        'exportedAt': DateTime.now().toIso8601String(),
        'version': '1.0',
      },
    };
  }

  // Helper methods for calculations
  
  double? _extractParameterValue(Map<String, dynamic> parameters, String key) {
    final param = parameters[key];
    if (param == null) return null;
    
    if (param is Map<String, dynamic>) {
      final value = param['value'];
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
    }
    
    if (param is num) return param.toDouble();
    return null;
  }

  Map<String, dynamic> _calculateTrend(List<double> values) {
    if (values.length < 2) {
      return {'direction': 'stable', 'slope': 0.0};
    }

    // Simple linear regression
    final n = values.length;
    final x = List.generate(n, (i) => i.toDouble());
    final y = values;
    
    final sumX = x.reduce((a, b) => a + b);
    final sumY = y.reduce((a, b) => a + b);
    final sumXY = List.generate(n, (i) => x[i] * y[i]).reduce((a, b) => a + b);
    final sumX2 = x.map((v) => v * v).reduce((a, b) => a + b);
    
    final slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    
    String direction;
    if (slope > 0.5) {
      direction = 'improving';
    } else if (slope < -0.5) {
      direction = 'declining';
    } else {
      direction = 'stable';
    }

    return {
      'direction': direction,
      'slope': slope,
      'magnitude': slope.abs(),
    };
  }

  Map<String, dynamic> _calculateParameterTrend(List<StationData> history, String parameter) {
    final values = history
        .map((d) => _extractParameterValue(d.parameters, parameter))
        .where((v) => v != null)
        .cast<double>()
        .toList();
    
    if (values.isEmpty) {
      return {'direction': 'no_data', 'slope': 0.0};
    }
    
    return _calculateTrend(values);
  }

  List<Map<String, dynamic>> _detectAnomalies(List<StationData> history) {
    if (history.length < 10) return [];
    
    final wqiValues = history.map((d) => d.wqi).toList();
    final mean = wqiValues.reduce((a, b) => a + b) / wqiValues.length;
    final variance = wqiValues.map((v) => (v - mean) * (v - mean)).reduce((a, b) => a + b) / wqiValues.length;
    final stdDev = variance < 0 ? 0 : variance;
    
    final anomalies = <Map<String, dynamic>>[];
    
    for (var i = 0; i < history.length; i++) {
      final data = history[i];
      final deviation = (data.wqi - mean).abs();
      
      if (deviation > 2 * stdDev) {
        anomalies.add({
          'timestamp': data.timestamp,
          'wqi': data.wqi,
          'deviation': deviation,
          'severity': deviation > 3 * stdDev ? 'high' : 'medium',
        });
      }
    }
    
    return anomalies;
  }

  double _calculateDegradationRate(List<StationData> history) {
    if (history.length < 2) return 0.0;
    
    final first = history.last.wqi;
    final last = history.first.wqi;
    final change = last - first;
    
    return change / history.length;
  }

  double _calculateVolatility(List<double> values) {
    if (values.length < 2) return 0.0;
    
    final mean = values.reduce((a, b) => a + b) / values.length;
    final variance = values.map((v) => (v - mean) * (v - mean)).reduce((a, b) => a + b) / values.length;
    
    return variance < 0 ? 0 : variance;
  }

  double _calculateAlertFrequency(List<StationData> history) {
    if (history.isEmpty) return 0.0;
    
    final alertCount = history.where((d) => d.alerts.isNotEmpty).length;
    return alertCount / history.length;
  }

  int _countCriticalEvents(List<StationData> history) {
    return history.where((d) => d.wqi < 20 || d.status == 'critical').length;
  }

  String _determineRiskLevel(double volatility, double alertFrequency, Map<String, dynamic> stats) {
    final avgWqi = stats['avgWqi'] as double? ?? 50.0;
    
    if (avgWqi < 30 || volatility > 200 || alertFrequency > 0.5) {
      return 'high';
    } else if (avgWqi < 50 || volatility > 100 || alertFrequency > 0.3) {
      return 'medium';
    } else {
      return 'low';
    }
  }
}
