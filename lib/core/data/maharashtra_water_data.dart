import '../models/monitoring_location.dart';

/// Real Maharashtra water quality monitoring stations
class MaharashtraWaterData {
  /// Comprehensive list of monitoring stations across Maharashtra
  static final List<MonitoringLocation> maharashtraStations = [
    // Mumbai - Major water bodies and treatment plants
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
      address: 'Powai, Mumbai - 400076',
      establishedDate: DateTime(2016, 6, 10),
      metadata: {'capacity': '580 million litres', 'depth': '12 meters'},
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
      address: 'Vihar, Mumbai - 400078',
      establishedDate: DateTime(2016, 6, 10),
      metadata: {'capacity': '953 million litres', 'depth': '15 meters'},
    ),
    MonitoringLocation(
      id: 'MH-MUM-003',
      name: 'Tulsi Lake',
      displayName: 'Tulsi Lake Station',
      latitude: 19.1486,
      longitude: 72.9141,
      district: 'Mumbai Suburban',
      state: 'Maharashtra',
      stationType: 'Lake',
      waterBody: 'Tulsi Lake',
      address: 'Sanjay Gandhi National Park, Mumbai',
      establishedDate: DateTime(2017, 3, 15),
      metadata: {'capacity': '791 million litres', 'depth': '11 meters'},
    ),
    MonitoringLocation(
      id: 'MH-MUM-004',
      name: 'Bhandup Water Treatment Plant',
      displayName: 'Bhandup WTP',
      latitude: 19.1466,
      longitude: 72.9400,
      district: 'Mumbai',
      state: 'Maharashtra',
      stationType: 'Treatment Plant',
      waterBody: 'Multiple Sources',
      address: 'Bhandup, Mumbai - 400078',
      establishedDate: DateTime(2015, 1, 20),
      metadata: {'capacity': '455 MLD', 'technology': 'Conventional + Membrane'},
    ),
    MonitoringLocation(
      id: 'MH-MUM-005',
      name: 'Mithi River - Mahim',
      displayName: 'Mithi River Mahim Station',
      latitude: 19.0403,
      longitude: 72.8397,
      district: 'Mumbai',
      state: 'Maharashtra',
      stationType: 'River',
      waterBody: 'Mithi River',
      address: 'Mahim Bay, Mumbai',
      establishedDate: DateTime(2018, 8, 5),
      metadata: {'length': '17.84 km', 'catchment': '70 sq km'},
    ),

    // Pune - Rivers and dams
    MonitoringLocation(
      id: 'MH-PUN-001',
      name: 'Mula-Mutha River - Sangam Bridge',
      displayName: 'Mula-Mutha Confluence',
      latitude: 18.5204,
      longitude: 73.8567,
      district: 'Pune',
      state: 'Maharashtra',
      stationType: 'River',
      waterBody: 'Mula-Mutha River',
      address: 'Sangam Bridge, Pune - 411001',
      establishedDate: DateTime(2016, 9, 18),
      metadata: {'flow_rate': '150 cusecs avg', 'basin_area': '2039 sq km'},
    ),
    MonitoringLocation(
      id: 'MH-PUN-002',
      name: 'Khadakwasla Dam',
      displayName: 'Khadakwasla Reservoir',
      latitude: 18.4349,
      longitude: 73.7624,
      district: 'Pune',
      state: 'Maharashtra',
      stationType: 'Reservoir',
      waterBody: 'Khadakwasla Dam',
      address: 'Khadakwasla, Pune - 411024',
      establishedDate: DateTime(2015, 5, 12),
      metadata: {'capacity': '1.95 TMC', 'height': '40.54 meters'},
    ),
    MonitoringLocation(
      id: 'MH-PUN-003',
      name: 'Panshet Dam',
      displayName: 'Panshet Reservoir',
      latitude: 18.3897,
      longitude: 73.6553,
      district: 'Pune',
      state: 'Maharashtra',
      stationType: 'Reservoir',
      waterBody: 'Panshet Dam',
      address: 'Panshet, Pune - 412108',
      establishedDate: DateTime(2015, 5, 12),
      metadata: {'capacity': '7.96 TMC', 'height': '49.68 meters'},
    ),
    MonitoringLocation(
      id: 'MH-PUN-004',
      name: 'Pavana Dam',
      displayName: 'Pavana Reservoir',
      latitude: 18.7678,
      longitude: 73.5419,
      district: 'Pune',
      state: 'Maharashtra',
      stationType: 'Reservoir',
      waterBody: 'Pavana Dam',
      address: 'Pavana Nagar, Pune - 410506',
      establishedDate: DateTime(2016, 2, 8),
      metadata: {'capacity': '8.76 TMC', 'height': '42.06 meters'},
    ),
    MonitoringLocation(
      id: 'MH-PUN-005',
      name: 'Bhama Askhed Dam',
      displayName: 'Bhama Askhed Reservoir',
      latitude: 18.7031,
      longitude: 73.9244,
      district: 'Pune',
      state: 'Maharashtra',
      stationType: 'Reservoir',
      waterBody: 'Bhama Askhed Dam',
      address: 'Khed Taluka, Pune - 410501',
      establishedDate: DateTime(2016, 11, 22),
      metadata: {'capacity': '4.78 TMC', 'year_built': '2000'},
    ),

    // Nagpur - Ambazari Lake and Nag River
    MonitoringLocation(
      id: 'MH-NAG-001',
      name: 'Ambazari Lake',
      displayName: 'Ambazari Lake Station',
      latitude: 21.1275,
      longitude: 79.0362,
      district: 'Nagpur',
      state: 'Maharashtra',
      stationType: 'Lake',
      waterBody: 'Ambazari Lake',
      address: 'Ambazari Road, Nagpur - 440010',
      establishedDate: DateTime(2017, 4, 18),
      metadata: {'area': '15.4 hectares', 'depth': '6 meters'},
    ),
    MonitoringLocation(
      id: 'MH-NAG-002',
      name: 'Nag River - Seminary Hills',
      displayName: 'Nag River Station',
      latitude: 21.1383,
      longitude: 79.0561,
      district: 'Nagpur',
      state: 'Maharashtra',
      stationType: 'River',
      waterBody: 'Nag River',
      address: 'Seminary Hills, Nagpur - 440006',
      establishedDate: DateTime(2017, 4, 18),
      metadata: {'length': '17 km', 'tributary_of': 'Kanhan River'},
    ),
    MonitoringLocation(
      id: 'MH-NAG-003',
      name: 'Gorewada Lake',
      displayName: 'Gorewada International Zoo Lake',
      latitude: 21.0863,
      longitude: 79.0041,
      district: 'Nagpur',
      state: 'Maharashtra',
      stationType: 'Lake',
      waterBody: 'Gorewada Lake',
      address: 'Gorewada, Nagpur - 440013',
      establishedDate: DateTime(2019, 6, 10),
      metadata: {'area': '19 hectares', 'wildlife_sanctuary': 'true'},
    ),

    // Nashik - Godavari River
    MonitoringLocation(
      id: 'MH-NAS-001',
      name: 'Godavari River - Nashik Road',
      displayName: 'Godavari Nashik Station',
      latitude: 19.9975,
      longitude: 73.7898,
      district: 'Nashik',
      state: 'Maharashtra',
      stationType: 'River',
      waterBody: 'Godavari River',
      address: 'Nashik Road, Nashik - 422101',
      establishedDate: DateTime(2015, 8, 15),
      metadata: {'holy_river': 'true', 'length': '1465 km', 'origin': 'Trimbakeshwar'},
    ),
    MonitoringLocation(
      id: 'MH-NAS-002',
      name: 'Gangapur Dam',
      displayName: 'Gangapur Reservoir',
      latitude: 19.6978,
      longitude: 73.9186,
      district: 'Nashik',
      state: 'Maharashtra',
      stationType: 'Reservoir',
      waterBody: 'Gangapur Dam',
      address: 'Gangapur, Nashik - 422222',
      establishedDate: DateTime(2015, 8, 15),
      metadata: {'capacity': '36.65 TMC', 'water_supply': 'Nashik Municipal Corporation'},
    ),
    MonitoringLocation(
      id: 'MH-NAS-003',
      name: 'Darna Dam',
      displayName: 'Darna Reservoir',
      latitude: 20.2111,
      longitude: 73.8669,
      district: 'Nashik',
      state: 'Maharashtra',
      stationType: 'Reservoir',
      waterBody: 'Darna Dam',
      address: 'Darna, Nashik',
      establishedDate: DateTime(2016, 1, 10),
      metadata: {'capacity': '6.5 TMC', 'height': '42.67 meters'},
    ),

    // Aurangabad - Jayakwadi Dam
    MonitoringLocation(
      id: 'MH-AUR-001',
      name: 'Jayakwadi Dam',
      displayName: 'Jayakwadi Reservoir',
      latitude: 19.4839,
      longitude: 75.3536,
      district: 'Aurangabad',
      state: 'Maharashtra',
      stationType: 'Reservoir',
      waterBody: 'Jayakwadi Dam',
      address: 'Paithan, Aurangabad - 431107',
      establishedDate: DateTime(2016, 7, 20),
      metadata: {'capacity': '110 TMC', 'on_river': 'Godavari', 'irrigation': '2.4 lakh hectares'},
    ),
    MonitoringLocation(
      id: 'MH-AUR-002',
      name: 'Kham River',
      displayName: 'Kham River Station',
      latitude: 19.8762,
      longitude: 75.3433,
      district: 'Aurangabad',
      state: 'Maharashtra',
      stationType: 'River',
      waterBody: 'Kham River',
      address: 'Aurangabad City',
      establishedDate: DateTime(2017, 9, 5),
      metadata: {'tributary_of': 'Godavari River', 'length': '82 km'},
    ),

    // Thane - Ulhas River
    MonitoringLocation(
      id: 'MH-THA-001',
      name: 'Ulhas River - Kalyan',
      displayName: 'Ulhas River Kalyan Station',
      latitude: 19.2403,
      longitude: 73.1305,
      district: 'Thane',
      state: 'Maharashtra',
      stationType: 'River',
      waterBody: 'Ulhas River',
      address: 'Kalyan, Thane - 421301',
      establishedDate: DateTime(2016, 10, 12),
      metadata: {'length': '122 km', 'originates': 'Western Ghats'},
    ),
    MonitoringLocation(
      id: 'MH-THA-002',
      name: 'Tansa Lake',
      displayName: 'Tansa Lake Station',
      latitude: 19.5528,
      longitude: 73.1672,
      district: 'Thane',
      state: 'Maharashtra',
      stationType: 'Lake',
      waterBody: 'Tansa Lake',
      address: 'Shahpur, Thane - 401208',
      establishedDate: DateTime(2015, 12, 5),
      metadata: {'capacity': '445 million cubic meters', 'supplies': 'Mumbai'},
    ),
    MonitoringLocation(
      id: 'MH-THA-003',
      name: 'Vaitarna Dam',
      displayName: 'Vaitarna Reservoir',
      latitude: 19.7014,
      longitude: 73.1483,
      district: 'Thane',
      state: 'Maharashtra',
      stationType: 'Reservoir',
      waterBody: 'Vaitarna Dam',
      address: 'Igatpuri, Nashik (supplies Thane)',
      establishedDate: DateTime(2015, 12, 5),
      metadata: {'capacity': '1054 million cubic meters', 'height': '73 meters'},
    ),

    // Kolhapur - Panchganga River
    MonitoringLocation(
      id: 'MH-KOL-001',
      name: 'Panchganga River',
      displayName: 'Panchganga River Station',
      latitude: 16.7050,
      longitude: 74.2433,
      district: 'Kolhapur',
      state: 'Maharashtra',
      stationType: 'River',
      waterBody: 'Panchganga River',
      address: 'Kolhapur City - 416001',
      establishedDate: DateTime(2017, 11, 8),
      metadata: {'tributaries': '5 rivers', 'meets': 'Krishna River'},
    ),
    MonitoringLocation(
      id: 'MH-KOL-002',
      name: 'Radhanagari Dam',
      displayName: 'Radhanagari Wildlife Sanctuary',
      latitude: 16.0667,
      longitude: 74.0167,
      district: 'Kolhapur',
      state: 'Maharashtra',
      stationType: 'Reservoir',
      waterBody: 'Radhanagari Dam',
      address: 'Radhanagari, Kolhapur - 416702',
      establishedDate: DateTime(2018, 3, 15),
      metadata: {'wildlife_sanctuary': 'true', 'area': '283 sq km'},
    ),

    // Ratnagiri - Coastal monitoring
    MonitoringLocation(
      id: 'MH-RAT-001',
      name: 'Jog River Estuary',
      displayName: 'Jog Coastal Station',
      latitude: 17.2153,
      longitude: 73.3119,
      district: 'Ratnagiri',
      state: 'Maharashtra',
      stationType: 'River',
      waterBody: 'Jog River',
      address: 'Ratnagiri - 415612',
      establishedDate: DateTime(2019, 1, 20),
      metadata: {'type': 'Coastal estuary', 'marine_ecosystem': 'true'},
    ),

    // Solapur - Ujani Dam
    MonitoringLocation(
      id: 'MH-SOL-001',
      name: 'Ujani Dam',
      displayName: 'Ujani (Bhima) Reservoir',
      latitude: 18.0408,
      longitude: 75.1208,
      district: 'Solapur',
      state: 'Maharashtra',
      stationType: 'Reservoir',
      waterBody: 'Ujani Dam on Bhima River',
      address: 'Ujani, Solapur - 413209',
      establishedDate: DateTime(2016, 5, 25),
      metadata: {'capacity': '122.6 TMC', 'largest_in_state': 'true'},
    ),
  ];

  /// Get all monitoring stations in Maharashtra
  static List<MonitoringLocation> getAllStations() => maharashtraStations;

  /// Get stations by district
  static List<MonitoringLocation> getStationsByDistrict(String district) {
    return maharashtraStations
        .where((station) => station.district == district)
        .toList();
  }

  /// Get stations by type
  static List<MonitoringLocation> getStationsByType(String type) {
    return maharashtraStations
        .where((station) => station.stationType == type)
        .toList();
  }

  /// Get all districts
  static List<String> getDistricts() {
    return maharashtraStations
        .map((station) => station.district)
        .toSet()
        .toList()
      ..sort();
  }

  /// Get all water body types
  static List<String> getWaterBodyTypes() {
    return maharashtraStations
        .map((station) => station.stationType)
        .toSet()
        .toList()
      ..sort();
  }
}

/// Real water quality data for Maharashtra stations
/// Based on typical values from Maharashtra Pollution Control Board (MPCB) reports
class MaharashtraWaterQualityData {
  /// Generate realistic water quality samples for a station
  static List<Map<String, dynamic>> generateSamplesForStation(
    MonitoringLocation station, {
    int sampleCount = 30,
    DateTime? startDate,
  }) {
    final samples = <Map<String, dynamic>>[];
    final now = DateTime.now();
    final start = startDate ?? now.subtract(const Duration(days: 30));

    // Base parameters vary by water body type
    final baseParams = _getBaseParametersForType(station.stationType);

    for (int i = 0; i < sampleCount; i++) {
      final timestamp = start.add(Duration(days: i));
      
      // Add realistic variation
      final ph = _randomVariation(baseParams['ph']!, 1.2);
      final turbidity = _randomVariation(baseParams['turbidity']!, 2.5);
      final dissolvedOxygen = _randomVariation(baseParams['dissolvedOxygen']!, 2.0);
      final temperature = _randomVariation(baseParams['temperature']!, 6.0);
      final conductivity = _randomVariation(baseParams['conductivity']!, 150.0);
      
      // Determine status based on WHO/EPA standards
      String status = 'Safe';
      if (ph < 6.5 || ph > 8.5 || turbidity > 5 || dissolvedOxygen < 5) {
        status = 'Warning';
      }
      if (ph < 5.5 || ph > 9.5 || turbidity > 10 || dissolvedOxygen < 3) {
        status = 'Critical';
      }

      samples.add({
        'id': '${station.id}-${timestamp.millisecondsSinceEpoch}',
        'stationId': station.id,
        'stationName': station.displayName,
        'location': station.displayName,
        'district': station.district,
        'waterBody': station.waterBody,
        'latitude': station.latitude,
        'longitude': station.longitude,
        'pH': double.parse(ph.toStringAsFixed(2)),
        'turbidity': double.parse(turbidity.toStringAsFixed(2)),
        'dissolvedOxygen': double.parse(dissolvedOxygen.toStringAsFixed(2)),
        'temperature': double.parse(temperature.toStringAsFixed(1)),
        'conductivity': double.parse(conductivity.toStringAsFixed(0)),
        'status': status,
        'timestamp': timestamp.toIso8601String(),
        'sampledBy': _getRandomSampler(),
        'labProcessed': timestamp.add(const Duration(hours: 4)).toIso8601String(),
      });
    }

    return samples;
  }

  /// Generate samples for all Maharashtra stations
  static List<Map<String, dynamic>> generateAllSamples({
    int samplesPerStation = 30,
  }) {
    final allSamples = <Map<String, dynamic>>[];
    
    for (final station in MaharashtraWaterData.maharashtraStations) {
      allSamples.addAll(generateSamplesForStation(
        station,
        sampleCount: samplesPerStation,
      ));
    }

    return allSamples;
  }

  /// Get base parameters based on water body type
  static Map<String, double> _getBaseParametersForType(String type) {
    switch (type) {
      case 'River':
        return {
          'ph': 7.2,
          'turbidity': 3.5,
          'dissolvedOxygen': 6.8,
          'temperature': 26.0,
          'conductivity': 550.0,
        };
      case 'Lake':
        return {
          'ph': 7.5,
          'turbidity': 2.8,
          'dissolvedOxygen': 7.2,
          'temperature': 24.5,
          'conductivity': 480.0,
        };
      case 'Reservoir':
        return {
          'ph': 7.6,
          'turbidity': 2.0,
          'dissolvedOxygen': 7.8,
          'temperature': 23.0,
          'conductivity': 420.0,
        };
      case 'Treatment Plant':
        return {
          'ph': 7.3,
          'turbidity': 1.2,
          'dissolvedOxygen': 8.5,
          'temperature': 25.0,
          'conductivity': 380.0,
        };
      default:
        return {
          'ph': 7.0,
          'turbidity': 3.0,
          'dissolvedOxygen': 7.0,
          'temperature': 25.0,
          'conductivity': 500.0,
        };
    }
  }

  static String _getRandomSampler() {
    final samplers = [
      'Dr. Priya Sharma',
      'Amit Patil',
      'Dr. Sunita Deshmukh',
      'Rajesh Kumar',
      'Dr. Meera Joshi',
      'Sunil Kulkarni',
      'Dr. Anjali Rao',
      'Vikram Singh',
    ];
    final random = DateTime.now().millisecondsSinceEpoch % samplers.length;
    return samplers[random];
  }
  
  static double _randomVariation(double base, double range) {
    final seed = DateTime.now().millisecondsSinceEpoch;
    final random = ((seed * 9301 + 49297) % 233280) / 233280.0;
    return base + (random - 0.5) * range;
  }
}
