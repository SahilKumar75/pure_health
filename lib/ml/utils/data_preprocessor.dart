import '../models/water_quality_model.dart';

class DataPreprocessor {
  /// Normalize water quality data to 0-1 range
  static Map<String, double> normalizeWaterQuality(WaterQualityData data) {
    return {
      'pH_normalized': (data.pH / 14.0).clamp(0.0, 1.0),
      'turbidity_normalized': (data.turbidity / 10.0).clamp(0.0, 1.0),
      'do_normalized': (data.dissolved_oxygen / 15.0).clamp(0.0, 1.0),
      'temp_normalized': ((data.temperature + 10) / 40).clamp(0.0, 1.0),
      'conductivity_normalized': (data.conductivity / 2000).clamp(0.0, 1.0),
    };
  }

  /// Validate water quality data
  static bool validateWaterQuality(WaterQualityData data) {
    return data.pH >= 0 &&
        data.pH <= 14 &&
        data.turbidity >= 0 &&
        data.dissolved_oxygen >= 0 &&
        data.temperature > -50 &&
        data.temperature < 100 &&
        data.conductivity >= 0;
  }

  /// Calculate water quality score
  static double calculateQualityScore(WaterQualityData data) {
    double score = 100.0;

    if (data.pH < 6.5 || data.pH > 8.5) score -= 20;
    if (data.turbidity > 5) score -= 15;
    if (data.dissolved_oxygen < 5) score -= 25;
    if (data.temperature < 0 || data.temperature > 35) score -= 10;
    if (data.lead != null && data.lead! > 0.015) score -= 15;
    if (data.arsenic != null && data.arsenic! > 0.01) score -= 20;

    return score.clamp(0.0, 100.0);
  }

  /// Determine water quality status
  static String determineStatus(double score) {
    if (score >= 80) return 'Safe';
    if (score >= 60) return 'Warning';
    return 'Critical';
  }
}
