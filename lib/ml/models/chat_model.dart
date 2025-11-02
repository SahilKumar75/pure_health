class ChatRequest {
  final String message;
  final String userId;
  final String sessionId;
  final DateTime timestamp;
  final Map<String, dynamic>? context;

  ChatRequest({
    required this.message,
    required this.userId,
    required this.sessionId,
    required this.timestamp,
    this.context,
  });

  Map<String, dynamic> toJson() => {
    'message': message,
    'userId': userId,
    'sessionId': sessionId,
    'timestamp': timestamp.toIso8601String(),
    'context': context,
  };
}

class ChatResponse {
  final String id;
  final String response;
  final double confidence;
  final String intent;
  final List<String> entities;
  final Map<String, dynamic>? metadata;

  ChatResponse({
    required this.id,
    required this.response,
    required this.confidence,
    required this.intent,
    required this.entities,
    this.metadata,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      id: json['id'] as String,
      response: json['response'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      intent: json['intent'] as String,
      entities: List<String>.from(json['entities'] as List? ?? []),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}
