class PredictionRequest {
  final String modelType;
  final Map<String, dynamic> features;
  final String? sessionId;
  final Map<String, dynamic>? metadata;

  PredictionRequest({
    required this.modelType,
    required this.features,
    this.sessionId,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'modelType': modelType,
    'features': features,
    'sessionId': sessionId,
    'metadata': metadata,
  };
}

class PredictionResponse {
  final String id;
  final String modelType;
  final List<PredictionResult> results;
  final double executionTime;
  final String modelVersion;

  PredictionResponse({
    required this.id,
    required this.modelType,
    required this.results,
    required this.executionTime,
    required this.modelVersion,
  });

  factory PredictionResponse.fromJson(Map<String, dynamic> json) {
    return PredictionResponse(
      id: json['id'] as String,
      modelType: json['modelType'] as String,
      results: (json['results'] as List?)
          ?.map((x) => PredictionResult.fromJson(x as Map<String, dynamic>))
          .toList() ?? [],
      executionTime: (json['executionTime'] as num).toDouble(),
      modelVersion: json['modelVersion'] as String,
    );
  }
}

class PredictionResult {
  final String label;
  final double probability;
  final Map<String, dynamic>? metadata;

  PredictionResult({
    required this.label,
    required this.probability,
    this.metadata,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    return PredictionResult(
      label: json['label'] as String,
      probability: (json['probability'] as num).toDouble(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}
