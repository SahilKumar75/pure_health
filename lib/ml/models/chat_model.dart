class ChatRequest {
  final String message;
  final Map<String, dynamic>? fileData;

  ChatRequest({
    required this.message,
    this.fileData,
  });

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'file_data': fileData,
    };
  }

  factory ChatRequest.fromJson(Map<String, dynamic> json) {
    return ChatRequest(
      message: json['message'] as String? ?? '',
      fileData: json['file_data'] as Map<String, dynamic>?,
    );
  }
}

class ChatResponse {
  final String response;
  final String intent;
  final double confidence;
  final Map<String, dynamic> metadata;

  ChatResponse({
    required this.response,
    required this.intent,
    required this.confidence,
    required this.metadata,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      response: json['response'] as String? ?? '',
      intent: json['intent'] as String? ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'response': response,
      'intent': intent,
      'confidence': confidence,
      'metadata': metadata,
    };
  }
}

class WaterQualityPrediction {
  final String status;
  final double predictedValue;
  final double confidence;

  WaterQualityPrediction({
    required this.status,
    required this.predictedValue,
    required this.confidence,
  });

  factory WaterQualityPrediction.fromJson(Map<String, dynamic> json) {
    return WaterQualityPrediction(
      status: json['status'] as String? ?? 'Unknown',
      predictedValue: (json['predictedValue'] as num?)?.toDouble() ?? 0.0,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'predictedValue': predictedValue,
      'confidence': confidence,
    };
  }
}

class WaterQualityData {
  final String? pH;
  final String? turbidity;
  final String? dissolvedOxygen;
  final String? conductivity;
  final String? temperature;
  final String? date;

  WaterQualityData({
    this.pH,
    this.turbidity,
    this.dissolvedOxygen,
    this.conductivity,
    this.temperature,
    this.date,
  });

  factory WaterQualityData.fromJson(Map<String, dynamic> json) {
    return WaterQualityData(
      pH: json['pH']?.toString(),
      turbidity: json['turbidity']?.toString(),
      dissolvedOxygen: json['dissolvedOxygen']?.toString(),
      conductivity: json['conductivity']?.toString(),
      temperature: json['temperature']?.toString(),
      date: json['date']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pH': pH,
      'turbidity': turbidity,
      'dissolvedOxygen': dissolvedOxygen,
      'conductivity': conductivity,
      'temperature': temperature,
      'date': date,
    };
  }
}
