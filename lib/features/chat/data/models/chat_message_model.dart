class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? confidence;
  final Map<String, dynamic>? metadata;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.confidence,
    this.metadata,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      text: json['text'] as String,
      isUser: json['isUser'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
      confidence: json['confidence'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'confidence': confidence,
      'metadata': metadata,
    };
  }
}

class WaterQualityPrediction {
  final String parameter;
  final double predictedValue;
  final String status;
  final double confidence;
  final List<String> recommendations;

  WaterQualityPrediction({
    required this.parameter,
    required this.predictedValue,
    required this.status,
    required this.confidence,
    required this.recommendations,
  });

  factory WaterQualityPrediction.fromJson(Map<String, dynamic> json) {
    return WaterQualityPrediction(
      parameter: json['parameter'] as String,
      predictedValue: (json['predictedValue'] as num).toDouble(),
      status: json['status'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      recommendations: List<String>.from(json['recommendations'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'parameter': parameter,
      'predictedValue': predictedValue,
      'status': status,
      'confidence': confidence,
      'recommendations': recommendations,
    };
  }
}
