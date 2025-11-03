class WaterBodyLocation {
  final String name;
  final String type; // river, lake, dam, reservoir, etc.
  final double latitude;
  final double longitude;
  final String district;
  final String region;

  WaterBodyLocation({
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.district,
    required this.region,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type,
        'latitude': latitude,
        'longitude': longitude,
        'district': district,
        'region': region,
      };

  factory WaterBodyLocation.fromJson(Map<String, dynamic> json) {
    return WaterBodyLocation(
      name: json['name'],
      type: json['type'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      district: json['district'],
      region: json['region'],
    );
  }
}
