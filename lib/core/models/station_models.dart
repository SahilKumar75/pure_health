class WaterQualityStation {
  final String id;
  final String name;
  final String type;
  final String monitoringType;
  final String district;
  final String region;
  final double latitude;
  final double longitude;
  final String laboratory;
  final String samplingFrequency;

  WaterQualityStation({
    required this.id,
    required this.name,
    required this.type,
    required this.monitoringType,
    required this.district,
    required this.region,
    required this.latitude,
    required this.longitude,
    required this.laboratory,
    required this.samplingFrequency,
  });

  factory WaterQualityStation.fromJson(Map<String, dynamic> json) {
    return WaterQualityStation(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      monitoringType: json['monitoringType'] as String,
      district: json['district'] as String,
      region: json['region'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      laboratory: json['laboratory'] as String,
      samplingFrequency: json['samplingFrequency'] as String,
    );
  }
}

class StationData {
  final String stationId;
  final String timestamp;
  final double wqi;
  final String status;
  final String waterQualityClass;
  final Map<String, dynamic> parameters;
  final List<dynamic> alerts;

  StationData({
    required this.stationId,
    required this.timestamp,
    required this.wqi,
    required this.status,
    required this.waterQualityClass,
    required this.parameters,
    required this.alerts,
  });
}
