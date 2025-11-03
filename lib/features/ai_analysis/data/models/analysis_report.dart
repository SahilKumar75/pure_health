import 'water_body_location.dart';

class AnalysisReport {
  final String id;
  final DateTime timestamp;
  final String fileName;
  final WaterBodyLocation? location;
  
  // Predictions
  final Map<String, dynamic> predictions;
  final DateTime predictionStartDate;
  final DateTime predictionEndDate;
  
  // Risk Assessment
  final RiskAssessment riskAssessment;
  
  // Trend Analysis
  final TrendAnalysis trendAnalysis;
  
  // Recommendations
  final List<Recommendation> recommendations;
  
  // Raw data
  final Map<String, dynamic>? rawData;

  AnalysisReport({
    required this.id,
    required this.timestamp,
    required this.fileName,
    this.location,
    required this.predictions,
    required this.predictionStartDate,
    required this.predictionEndDate,
    required this.riskAssessment,
    required this.trendAnalysis,
    required this.recommendations,
    this.rawData,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'fileName': fileName,
        'location': location?.toJson(),
        'predictions': predictions,
        'predictionStartDate': predictionStartDate.toIso8601String(),
        'predictionEndDate': predictionEndDate.toIso8601String(),
        'riskAssessment': riskAssessment.toJson(),
        'trendAnalysis': trendAnalysis.toJson(),
        'recommendations': recommendations.map((r) => r.toJson()).toList(),
        'rawData': rawData,
      };

  factory AnalysisReport.fromJson(Map<String, dynamic> json) {
    return AnalysisReport(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      fileName: json['fileName'],
      location: json['location'] != null
          ? WaterBodyLocation.fromJson(json['location'])
          : null,
      predictions: json['predictions'],
      predictionStartDate: DateTime.parse(json['predictionStartDate']),
      predictionEndDate: DateTime.parse(json['predictionEndDate']),
      riskAssessment: RiskAssessment.fromJson(json['riskAssessment']),
      trendAnalysis: TrendAnalysis.fromJson(json['trendAnalysis']),
      recommendations: (json['recommendations'] as List)
          .map((r) => Recommendation.fromJson(r))
          .toList(),
      rawData: json['rawData'],
    );
  }
}

class RiskAssessment {
  final String overallRiskLevel; // low, medium, high, critical
  final double riskScore; // 0-100
  final List<RiskFactor> riskFactors;
  final String summary;

  RiskAssessment({
    required this.overallRiskLevel,
    required this.riskScore,
    required this.riskFactors,
    required this.summary,
  });

  Map<String, dynamic> toJson() => {
        'overallRiskLevel': overallRiskLevel,
        'riskScore': riskScore,
        'riskFactors': riskFactors.map((f) => f.toJson()).toList(),
        'summary': summary,
      };

  factory RiskAssessment.fromJson(Map<String, dynamic> json) {
    return RiskAssessment(
      overallRiskLevel: json['overallRiskLevel'],
      riskScore: json['riskScore'],
      riskFactors: (json['riskFactors'] as List)
          .map((f) => RiskFactor.fromJson(f))
          .toList(),
      summary: json['summary'],
    );
  }
}

class RiskFactor {
  final String parameter;
  final String level; // low, medium, high
  final double currentValue;
  final double thresholdValue;
  final String description;

  RiskFactor({
    required this.parameter,
    required this.level,
    required this.currentValue,
    required this.thresholdValue,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
        'parameter': parameter,
        'level': level,
        'currentValue': currentValue,
        'thresholdValue': thresholdValue,
        'description': description,
      };

  factory RiskFactor.fromJson(Map<String, dynamic> json) {
    return RiskFactor(
      parameter: json['parameter'],
      level: json['level'],
      currentValue: json['currentValue'],
      thresholdValue: json['thresholdValue'],
      description: json['description'],
    );
  }
}

class TrendAnalysis {
  final Map<String, TrendData> parameterTrends;
  final String overallTrend; // improving, stable, declining
  final String summary;

  TrendAnalysis({
    required this.parameterTrends,
    required this.overallTrend,
    required this.summary,
  });

  Map<String, dynamic> toJson() => {
        'parameterTrends': parameterTrends.map((k, v) => MapEntry(k, v.toJson())),
        'overallTrend': overallTrend,
        'summary': summary,
      };

  factory TrendAnalysis.fromJson(Map<String, dynamic> json) {
    return TrendAnalysis(
      parameterTrends: (json['parameterTrends'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, TrendData.fromJson(v)),
      ),
      overallTrend: json['overallTrend'],
      summary: json['summary'],
    );
  }
}

class TrendData {
  final String direction; // increasing, decreasing, stable
  final double changePercentage;
  final List<double> historicalValues;
  final List<DateTime> timestamps;

  TrendData({
    required this.direction,
    required this.changePercentage,
    required this.historicalValues,
    required this.timestamps,
  });

  Map<String, dynamic> toJson() => {
        'direction': direction,
        'changePercentage': changePercentage,
        'historicalValues': historicalValues,
        'timestamps': timestamps.map((t) => t.toIso8601String()).toList(),
      };

  factory TrendData.fromJson(Map<String, dynamic> json) {
    return TrendData(
      direction: json['direction'],
      changePercentage: json['changePercentage'],
      historicalValues: List<double>.from(json['historicalValues']),
      timestamps: (json['timestamps'] as List)
          .map((t) => DateTime.parse(t))
          .toList(),
    );
  }
}

class Recommendation {
  final String priority; // high, medium, low
  final String category; // treatment, monitoring, policy, infrastructure
  final String title;
  final String description;
  final List<String> actionItems;
  final String timeframe; // immediate, short-term, long-term

  Recommendation({
    required this.priority,
    required this.category,
    required this.title,
    required this.description,
    required this.actionItems,
    required this.timeframe,
  });

  Map<String, dynamic> toJson() => {
        'priority': priority,
        'category': category,
        'title': title,
        'description': description,
        'actionItems': actionItems,
        'timeframe': timeframe,
      };

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      priority: json['priority'],
      category: json['category'],
      title: json['title'],
      description: json['description'],
      actionItems: List<String>.from(json['actionItems']),
      timeframe: json['timeframe'],
    );
  }
}
