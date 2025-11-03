import 'package:flutter/material.dart';

/// Represents a water quality monitoring station with GPS coordinates
class MonitoringLocation {
  final String id;
  final String name;
  final String displayName;
  final double latitude;
  final double longitude;
  final String district;
  final String state;
  final String stationType;
  final String waterBody;
  final String address;
  final DateTime establishedDate;
  final bool isActive;
  final Map<String, dynamic>? metadata;

  const MonitoringLocation({
    required this.id,
    required this.name,
    required this.displayName,
    required this.latitude,
    required this.longitude,
    required this.district,
    required this.state,
    required this.stationType,
    required this.waterBody,
    required this.address,
    required this.establishedDate,
    this.isActive = true,
    this.metadata,
  });

  factory MonitoringLocation.fromJson(Map<String, dynamic> json) {
    return MonitoringLocation(
      id: json['id'] as String,
      name: json['name'] as String,
      displayName: json['displayName'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      district: json['district'] as String,
      state: json['state'] as String,
      stationType: json['stationType'] as String,
      waterBody: json['waterBody'] as String,
      address: json['address'] as String,
      establishedDate: DateTime.parse(json['establishedDate'] as String),
      isActive: json['isActive'] as bool? ?? true,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'displayName': displayName,
      'latitude': latitude,
      'longitude': longitude,
      'district': district,
      'state': state,
      'stationType': stationType,
      'waterBody': waterBody,
      'address': address,
      'establishedDate': establishedDate.toIso8601String(),
      'isActive': isActive,
      'metadata': metadata,
    };
  }

  MonitoringLocation copyWith({
    String? id,
    String? name,
    String? displayName,
    double? latitude,
    double? longitude,
    String? district,
    String? state,
    String? stationType,
    String? waterBody,
    String? address,
    DateTime? establishedDate,
    bool? isActive,
    Map<String, dynamic>? metadata,
  }) {
    return MonitoringLocation(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      district: district ?? this.district,
      state: state ?? this.state,
      stationType: stationType ?? this.stationType,
      waterBody: waterBody ?? this.waterBody,
      address: address ?? this.address,
      establishedDate: establishedDate ?? this.establishedDate,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'MonitoringLocation(name: $name, lat: $latitude, lng: $longitude, district: $district)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MonitoringLocation && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Station type enum
enum StationType {
  river,
  lake,
  reservoir,
  groundwater,
  treatmentPlant,
  distributionPoint;

  String get displayName {
    switch (this) {
      case StationType.river:
        return 'River Monitoring Station';
      case StationType.lake:
        return 'Lake Monitoring Station';
      case StationType.reservoir:
        return 'Reservoir Monitoring Station';
      case StationType.groundwater:
        return 'Groundwater Monitoring Station';
      case StationType.treatmentPlant:
        return 'Treatment Plant';
      case StationType.distributionPoint:
        return 'Distribution Point';
    }
  }

  IconData get icon {
    switch (this) {
      case StationType.river:
        return Icons.water;
      case StationType.lake:
        return Icons.water_drop;
      case StationType.reservoir:
        return Icons.water_damage;
      case StationType.groundwater:
        return Icons.layers;
      case StationType.treatmentPlant:
        return Icons.factory_outlined;
      case StationType.distributionPoint:
        return Icons.location_city;
    }
  }
}

/// Sample monitoring locations in India (real coordinates)
class MonitoringLocationData {
  static final List<MonitoringLocation> indianLocations = [
    // Delhi - Yamuna River Stations
    MonitoringLocation(
      id: 'DL-YMN-001',
      name: 'Yamuna River - Wazirabad',
      displayName: 'Wazirabad Monitoring Station',
      latitude: 28.7041,
      longitude: 77.2311,
      district: 'North Delhi',
      state: 'Delhi',
      stationType: 'River',
      waterBody: 'Yamuna River',
      address: 'Wazirabad Barrage, Delhi',
      establishedDate: DateTime(2015, 4, 15),
    ),
    MonitoringLocation(
      id: 'DL-YMN-002',
      name: 'Yamuna River - Nizamuddin',
      displayName: 'Nizamuddin Bridge Station',
      latitude: 28.5895,
      longitude: 77.2505,
      district: 'Central Delhi',
      state: 'Delhi',
      stationType: 'River',
      waterBody: 'Yamuna River',
      address: 'Nizamuddin Bridge, Delhi',
      establishedDate: DateTime(2015, 4, 15),
    ),
    MonitoringLocation(
      id: 'DL-YMN-003',
      name: 'Yamuna River - Okhla',
      displayName: 'Okhla Barrage Station',
      latitude: 28.5355,
      longitude: 77.3119,
      district: 'South Delhi',
      state: 'Delhi',
      stationType: 'River',
      waterBody: 'Yamuna River',
      address: 'Okhla Barrage, Delhi',
      establishedDate: DateTime(2015, 4, 15),
    ),

    // Mumbai - Water Bodies
    MonitoringLocation(
      id: 'MH-MUM-001',
      name: 'Powai Lake',
      displayName: 'Powai Lake Monitoring Station',
      latitude: 19.1224,
      longitude: 72.9060,
      district: 'Mumbai Suburban',
      state: 'Maharashtra',
      stationType: 'Lake',
      waterBody: 'Powai Lake',
      address: 'Powai, Mumbai',
      establishedDate: DateTime(2016, 6, 10),
    ),
    MonitoringLocation(
      id: 'MH-MUM-002',
      name: 'Vihar Lake',
      displayName: 'Vihar Lake Station',
      latitude: 19.1355,
      longitude: 72.9132,
      district: 'Mumbai Suburban',
      state: 'Maharashtra',
      stationType: 'Lake',
      waterBody: 'Vihar Lake',
      address: 'Vihar, Mumbai',
      establishedDate: DateTime(2016, 6, 10),
    ),

    // Bangalore - Lakes
    MonitoringLocation(
      id: 'KA-BLR-001',
      name: 'Bellandur Lake',
      displayName: 'Bellandur Lake Station',
      latitude: 12.9306,
      longitude: 77.6797,
      district: 'Bangalore Urban',
      state: 'Karnataka',
      stationType: 'Lake',
      waterBody: 'Bellandur Lake',
      address: 'Bellandur, Bangalore',
      establishedDate: DateTime(2017, 8, 20),
    ),
    MonitoringLocation(
      id: 'KA-BLR-002',
      name: 'Ulsoor Lake',
      displayName: 'Ulsoor Lake Station',
      latitude: 12.9820,
      longitude: 77.6217,
      district: 'Bangalore Urban',
      state: 'Karnataka',
      stationType: 'Lake',
      waterBody: 'Ulsoor Lake',
      address: 'Ulsoor, Bangalore',
      establishedDate: DateTime(2017, 8, 20),
    ),

    // Kolkata - Hooghly River
    MonitoringLocation(
      id: 'WB-KOL-001',
      name: 'Hooghly River - Howrah',
      displayName: 'Howrah Bridge Station',
      latitude: 22.5848,
      longitude: 88.3469,
      district: 'Kolkata',
      state: 'West Bengal',
      stationType: 'River',
      waterBody: 'Hooghly River',
      address: 'Howrah Bridge, Kolkata',
      establishedDate: DateTime(2016, 3, 12),
    ),
    MonitoringLocation(
      id: 'WB-KOL-002',
      name: 'Hooghly River - Dakshineswar',
      displayName: 'Dakshineswar Station',
      latitude: 22.6548,
      longitude: 88.3568,
      district: 'North 24 Parganas',
      state: 'West Bengal',
      stationType: 'River',
      waterBody: 'Hooghly River',
      address: 'Dakshineswar, Kolkata',
      establishedDate: DateTime(2016, 3, 12),
    ),

    // Chennai - Water Treatment
    MonitoringLocation(
      id: 'TN-CHE-001',
      name: 'Poondi Reservoir',
      displayName: 'Poondi Reservoir Station',
      latitude: 13.3717,
      longitude: 79.8545,
      district: 'Tiruvallur',
      state: 'Tamil Nadu',
      stationType: 'Reservoir',
      waterBody: 'Poondi Reservoir',
      address: 'Poondi, Tamil Nadu',
      establishedDate: DateTime(2018, 1, 5),
    ),
    MonitoringLocation(
      id: 'TN-CHE-002',
      name: 'Red Hills Lake',
      displayName: 'Red Hills Station',
      latitude: 13.1582,
      longitude: 80.1830,
      district: 'Thiruvallur',
      state: 'Tamil Nadu',
      stationType: 'Lake',
      waterBody: 'Red Hills Lake',
      address: 'Red Hills, Chennai',
      establishedDate: DateTime(2018, 1, 5),
    ),

    // Hyderabad - Lakes
    MonitoringLocation(
      id: 'TS-HYD-001',
      name: 'Hussain Sagar Lake',
      displayName: 'Hussain Sagar Station',
      latitude: 17.4239,
      longitude: 78.4738,
      district: 'Hyderabad',
      state: 'Telangana',
      stationType: 'Lake',
      waterBody: 'Hussain Sagar Lake',
      address: 'Tank Bund, Hyderabad',
      establishedDate: DateTime(2017, 5, 25),
    ),

    // Pune - Rivers
    MonitoringLocation(
      id: 'MH-PUN-001',
      name: 'Mula-Mutha River',
      displayName: 'Mula-Mutha Confluence',
      latitude: 18.5204,
      longitude: 73.8567,
      district: 'Pune',
      state: 'Maharashtra',
      stationType: 'River',
      waterBody: 'Mula-Mutha River',
      address: 'Pune City',
      establishedDate: DateTime(2016, 9, 18),
    ),

    // Ahmedabad - Sabarmati River
    MonitoringLocation(
      id: 'GJ-AMD-001',
      name: 'Sabarmati River - Ellis Bridge',
      displayName: 'Ellis Bridge Station',
      latitude: 23.0302,
      longitude: 72.5674,
      district: 'Ahmedabad',
      state: 'Gujarat',
      stationType: 'River',
      waterBody: 'Sabarmati River',
      address: 'Ellis Bridge, Ahmedabad',
      establishedDate: DateTime(2017, 2, 14),
    ),

    // Jaipur - Treatment Plants
    MonitoringLocation(
      id: 'RJ-JAI-001',
      name: 'Ramgarh Water Treatment Plant',
      displayName: 'Ramgarh WTP',
      latitude: 26.9524,
      longitude: 75.8199,
      district: 'Jaipur',
      state: 'Rajasthan',
      stationType: 'Treatment Plant',
      waterBody: 'Ramgarh Lake',
      address: 'Ramgarh, Jaipur',
      establishedDate: DateTime(2018, 7, 8),
    ),
  ];

  static MonitoringLocation? getById(String id) {
    try {
      return indianLocations.firstWhere((loc) => loc.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<MonitoringLocation> getByState(String state) {
    return indianLocations.where((loc) => loc.state == state).toList();
  }

  static List<MonitoringLocation> getByDistrict(String district) {
    return indianLocations.where((loc) => loc.district == district).toList();
  }

  static List<MonitoringLocation> getByType(String type) {
    return indianLocations.where((loc) => loc.stationType == type).toList();
  }

  static List<String> getAllStates() {
    return indianLocations.map((loc) => loc.state).toSet().toList()..sort();
  }

  static List<String> getAllDistricts() {
    return indianLocations.map((loc) => loc.district).toSet().toList()..sort();
  }

  static List<String> getAllStationTypes() {
    return indianLocations.map((loc) => loc.stationType).toSet().toList()..sort();
  }
}
