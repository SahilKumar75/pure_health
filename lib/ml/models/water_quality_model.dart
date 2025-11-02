class WaterQualityData {
  final double pH;
  final double turbidity;
  final double dissolved_oxygen;
  final double temperature;
  final double conductivity;
  final double? lead;
  final double? arsenic;
  final double? bacteria;
  final DateTime timestamp;
  final String location;

  WaterQualityData({
    required this.pH,
    required this.turbidity,
    required this.dissolved_oxygen,
    required this.temperature,
    required this.conductivity,
    this.lead,
    this.arsenic,
    this.bacteria,
    required this.timestamp,
    required this.location,
  });

  Map<String, dynamic> toJson() => {
    'pH': pH,
    'turbidity': turbidity,
    'dissolved_oxygen': dissolved_oxygen,
    'temperature': temperature,
    'conductivity': conductivity,
    'lead': lead,
    'arsenic': arsenic,
    'bacteria': bacteria,
    'timestamp': timestamp.toIso8601String(),
    'location': location,
  };

  factory WaterQualityData.fromJson(Map<String, dynamic> json) {
    return WaterQualityData(
      pH: (json['pH'] as num).toDouble(),
      turbidity: (json['turbidity'] as num).toDouble(),
      dissolved_oxygen: (json['dissolved_oxygen'] as num).toDouble(),
      temperature: (json['temperature'] as num).toDouble(),
      conductivity: (json['conductivity'] as num).toDouble(),
      lead: json['lead'] != null ? (json['lead'] as num).toDouble() : null,
      arsenic: json['arsenic'] != null ? (json['arsenic'] as num).toDouble() : null,
      bacteria: json['bacteria'] != null ? (json['bacteria'] as num).toDouble() : null,
      timestamp: DateTime.parse(json['timestamp'] as String),
      location: json['location'] as String,
    );
  }
}

class WaterQualityPrediction {
  final String parameter;
  final double predictedValue;
  final String status; // Safe, Warning, Critical
  final double confidence;
  final List<String> recommendations;
  final Map<String, dynamic>? details;

  WaterQualityPrediction({
    required this.parameter,
    required this.predictedValue,
    required this.status,
    required this.confidence,
    required this.recommendations,
    this.details,
  });

  factory WaterQualityPrediction.fromJson(Map<String, dynamic> json) {
    return WaterQualityPrediction(
      parameter: json['parameter'] as String,
      predictedValue: (json['predictedValue'] as num).toDouble(),
      status: json['status'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      recommendations: List<String>.from(json['recommendations'] as List? ?? []),
      details: json['details'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
    'parameter': parameter,
    'predictedValue': predictedValue,
    'status': status,
    'confidence': confidence,
    'recommendations': recommendations,
    'details': details,
  };
}

class AnomalyDetectionResult {
  final bool isAnomaly;
  final double score;
  final String parameter;
  final String reason;
  final List<double> normalRange;

  AnomalyDetectionResult({
    required this.isAnomaly,
    required this.score,
    required this.parameter,
    required this.reason,
    required this.normalRange,
  });

  factory AnomalyDetectionResult.fromJson(Map<String, dynamic> json) {
    return AnomalyDetectionResult(
      isAnomaly: json['isAnomaly'] as bool,
      score: (json['score'] as num).toDouble(),
      parameter: json['parameter'] as String,
      reason: json['reason'] as String,
      normalRange: List<double>.from(
        (json['normalRange'] as List?)?.map((x) => (x as num).toDouble()) ?? [],
      ),
    );
  }
}
