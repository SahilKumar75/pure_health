/// Model for disease risk data
class DiseaseRisk {
  final String diseaseType;
  final int riskScore; // 0-100
  final String category; // waterborne, vector_borne, water_washed

  const DiseaseRisk({
    required this.diseaseType,
    required this.riskScore,
    required this.category,
  });

  factory DiseaseRisk.fromJson(String diseaseType, int riskScore) {
    return DiseaseRisk(
      diseaseType: diseaseType,
      riskScore: riskScore,
      category: _getCategoryForDisease(diseaseType),
    );
  }

  static String _getCategoryForDisease(String diseaseType) {
    const waterborne = ['cholera', 'typhoid', 'dysentery', 'hepatitis_a'];
    const vectorBorne = ['malaria', 'dengue'];
    const waterWashed = ['skin_infections'];

    if (waterborne.contains(diseaseType)) return 'waterborne';
    if (vectorBorne.contains(diseaseType)) return 'vector_borne';
    if (waterWashed.contains(diseaseType)) return 'water_washed';
    return 'unknown';
  }

  String get displayName {
    switch (diseaseType) {
      case 'cholera':
        return 'Cholera';
      case 'typhoid':
        return 'Typhoid';
      case 'dysentery':
        return 'Dysentery';
      case 'hepatitis_a':
        return 'Hepatitis A';
      case 'malaria':
        return 'Malaria';
      case 'dengue':
        return 'Dengue';
      case 'skin_infections':
        return 'Skin Infections';
      default:
        return diseaseType;
    }
  }

  String get riskLevel {
    if (riskScore >= 80) return 'Critical';
    if (riskScore >= 60) return 'High';
    if (riskScore >= 40) return 'Medium';
    if (riskScore >= 20) return 'Low';
    return 'Very Low';
  }

  Map<String, dynamic> toJson() => {
        'diseaseType': diseaseType,
        'riskScore': riskScore,
        'category': category,
      };
}

/// Model for outbreak probability
class OutbreakProbability {
  final String level; // very_low, low, medium, high
  final int score; // 0-100
  final List<String> highRiskDiseases;
  final int diseaseCount;

  const OutbreakProbability({
    required this.level,
    required this.score,
    required this.highRiskDiseases,
    required this.diseaseCount,
  });

  factory OutbreakProbability.fromJson(Map<String, dynamic> json) {
    return OutbreakProbability(
      level: json['level'] as String,
      score: json['score'] as int,
      highRiskDiseases: (json['high_risk_diseases'] as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
      diseaseCount: json['disease_count'] as int,
    );
  }

  String get displayLevel {
    switch (level) {
      case 'very_low':
        return 'Very Low';
      case 'low':
        return 'Low';
      case 'medium':
        return 'Medium';
      case 'high':
        return 'High';
      default:
        return level;
    }
  }

  String get statusColor {
    switch (level) {
      case 'very_low':
        return '#4CAF50'; // Green
      case 'low':
        return '#8BC34A'; // Light Green
      case 'medium':
        return '#FF9800'; // Orange
      case 'high':
        return '#F44336'; // Red
      default:
        return '#9E9E9E'; // Gray
    }
  }

  Map<String, dynamic> toJson() => {
        'level': level,
        'score': score,
        'high_risk_diseases': highRiskDiseases,
        'disease_count': diseaseCount,
      };
}

/// Enhanced station data with disease prediction
class StationDataWithDisease {
  final String stationId;
  final DateTime timestamp;
  final String season;
  final Map<String, dynamic> waterQualityParams;
  final double stagnationIndex;
  final double rainfallIndex;
  final double wqi;
  final String status;
  final String waterQualityClass;
  final List<DiseaseRisk> diseaseRisks;
  final OutbreakProbability outbreakProbability;

  const StationDataWithDisease({
    required this.stationId,
    required this.timestamp,
    required this.season,
    required this.waterQualityParams,
    required this.stagnationIndex,
    required this.rainfallIndex,
    required this.wqi,
    required this.status,
    required this.waterQualityClass,
    required this.diseaseRisks,
    required this.outbreakProbability,
  });

  factory StationDataWithDisease.fromJson(Map<String, dynamic> json) {
    // Parse disease risks
    final diseaseRisksMap = json['disease_risks'] as Map<String, dynamic>;
    final diseaseRisks = diseaseRisksMap.entries
        .map((e) => DiseaseRisk.fromJson(e.key, (e.value as num).toInt()))
        .toList();

    // Extract water quality parameters
    final waterQualityParams = <String, dynamic>{
      'ph': json['ph'],
      'temperature': json['temperature'],
      'turbidity': json['turbidity'],
      'tds': json['tds'],
      'conductivity': json['conductivity'],
      'totalHardness': json['totalHardness'],
      'totalAlkalinity': json['totalAlkalinity'],
      'calcium': json['calcium'],
      'magnesium': json['magnesium'],
      'sodium': json['sodium'],
      'chlorides': json['chlorides'],
      'sulfates': json['sulfates'],
      'nitrates': json['nitrates'],
      'phosphates': json['phosphates'],
      'fluoride': json['fluoride'],
      'iron': json['iron'],
      'arsenic': json['arsenic'],
      'lead': json['lead'],
      'chromium': json['chromium'],
      'cadmium': json['cadmium'],
      'totalColiform': json['totalColiform'],
      'fecalColiform': json['fecalColiform'],
      'dissolvedOxygen': json['dissolvedOxygen'],
      'bod': json['bod'],
      'cod': json['cod'],
    };

    return StationDataWithDisease(
      stationId: json['stationId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      season: json['season'] as String,
      waterQualityParams: waterQualityParams,
      stagnationIndex: (json['stagnationIndex'] as num).toDouble(),
      rainfallIndex: (json['rainfallIndex'] as num).toDouble(),
      wqi: (json['wqi'] as num).toDouble(),
      status: json['status'] as String,
      waterQualityClass: json['waterQualityClass'] as String,
      diseaseRisks: diseaseRisks,
      outbreakProbability:
          OutbreakProbability.fromJson(json['outbreak_probability'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'stationId': stationId,
        'timestamp': timestamp.toIso8601String(),
        'season': season,
        ...waterQualityParams,
        'stagnationIndex': stagnationIndex,
        'rainfallIndex': rainfallIndex,
        'wqi': wqi,
        'status': status,
        'waterQualityClass': waterQualityClass,
        'disease_risks': {
          for (var risk in diseaseRisks) risk.diseaseType: risk.riskScore
        },
        'outbreak_probability': outbreakProbability.toJson(),
      };
}
