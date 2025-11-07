import 'dart:async';
import 'dart:math';

/// Live Water Station Service
/// Mimics real-time water quality monitoring stations in Maharashtra
/// Based on typical MPCB (Maharashtra Pollution Control Board) monitoring patterns
class LiveWaterStationService {
  static final LiveWaterStationService _instance = LiveWaterStationService._internal();
  factory LiveWaterStationService() => _instance;
  LiveWaterStationService._internal();

  final Random _random = Random();
  Timer? _updateTimer;
  final Map<String, Map<String, dynamic>> _stationData = {};
  final List<StreamController<Map<String, dynamic>>> _controllers = [];

  /// Get all monitoring stations in Maharashtra
  List<Map<String, dynamic>> getAllStations() {
    return _maharashtraStations;
  }

  /// Start live data simulation
  /// Stations typically update every 15 minutes (900 seconds)
  void startLiveSimulation({Duration interval = const Duration(minutes: 15)}) {
    stopLiveSimulation();
    
    // Initialize all stations
    for (var station in _maharashtraStations) {
      _stationData[station['id']] = _generateStationReading(station);
    }

    // Update data at specified intervals
    _updateTimer = Timer.periodic(interval, (timer) {
      for (var station in _maharashtraStations) {
        final reading = _generateStationReading(station);
        _stationData[station['id']] = reading;
        
        // Broadcast to listeners
        for (var controller in _controllers) {
          if (!controller.isClosed) {
            controller.add(reading);
          }
        }
      }
    });
  }

  /// Stop live simulation
  void stopLiveSimulation() {
    _updateTimer?.cancel();
    _updateTimer = null;
  }

  /// Get current station data
  Map<String, dynamic>? getStationData(String stationId) {
    return _stationData[stationId];
  }

  /// Get all current station data
  Map<String, Map<String, dynamic>> getAllStationData() {
    return Map.from(_stationData);
  }

  /// Stream of live updates
  Stream<Map<String, dynamic>> getLiveUpdates() {
    final controller = StreamController<Map<String, dynamic>>.broadcast();
    _controllers.add(controller);
    return controller.stream;
  }

  /// Generate realistic station reading based on MPCB standards
  Map<String, dynamic> _generateStationReading(Map<String, dynamic> station) {
    final baseParams = station['baseParameters'] as Map<String, double>;
    final now = DateTime.now();
    
    // Add realistic variations based on time of day and season
    final hourFactor = _getHourFactor(now.hour);
    final seasonFactor = _getSeasonFactor(now.month);
    
    // pH: 6.5-8.5 (ideal range as per MPCB standards)
    final ph = (baseParams['ph']! + _randomVariation(0.3) * hourFactor).clamp(6.0, 9.0);
    
    // Turbidity: NTU (Nephelometric Turbidity Units) - should be < 10 NTU ideally
    final turbidity = (baseParams['turbidity']! + _randomVariation(5.0) * hourFactor * seasonFactor).clamp(0.1, 50.0);
    
    // Dissolved Oxygen: mg/L - should be > 5 mg/L for healthy water
    final dissolvedOxygen = (baseParams['dissolvedOxygen']! + _randomVariation(1.5) * hourFactor).clamp(2.0, 12.0);
    
    // Temperature: °C
    final temperature = (baseParams['temperature']! + _randomVariation(3.0) * seasonFactor).clamp(15.0, 35.0);
    
    // Conductivity: µS/cm (microsiemens per centimeter)
    final conductivity = (baseParams['conductivity']! + _randomVariation(100.0)).clamp(50.0, 2000.0);
    
    // Total Dissolved Solids: mg/L - should be < 500 mg/L
    final tds = (baseParams['tds']! + _randomVariation(50.0)).clamp(50.0, 1500.0);
    
    // Biochemical Oxygen Demand: mg/L - should be < 3 mg/L for drinking water
    final bod = (baseParams['bod']! + _randomVariation(1.0) * seasonFactor).clamp(0.5, 20.0);
    
    // Chemical Oxygen Demand: mg/L
    final cod = (baseParams['cod']! + _randomVariation(5.0) * seasonFactor).clamp(5.0, 100.0);
    
    // Chlorides: mg/L - should be < 250 mg/L
    final chlorides = (baseParams['chlorides']! + _randomVariation(20.0)).clamp(10.0, 600.0);
    
    // Nitrates: mg/L - should be < 45 mg/L
    final nitrates = (baseParams['nitrates']! + _randomVariation(5.0)).clamp(0.1, 50.0);
    
    // Calculate Water Quality Index (WQI) based on parameters
    final wqi = _calculateWQI(ph, turbidity, dissolvedOxygen, temperature, tds, bod, chlorides, nitrates);
    
    return {
      'stationId': station['id'],
      'stationName': station['name'],
      'location': station['location'],
      'latitude': station['latitude'],
      'longitude': station['longitude'],
      'timestamp': now.toIso8601String(),
      'parameters': {
        'pH': double.parse(ph.toStringAsFixed(2)),
        'turbidity': double.parse(turbidity.toStringAsFixed(2)),
        'dissolvedOxygen': double.parse(dissolvedOxygen.toStringAsFixed(2)),
        'temperature': double.parse(temperature.toStringAsFixed(1)),
        'conductivity': double.parse(conductivity.toStringAsFixed(1)),
        'tds': double.parse(tds.toStringAsFixed(1)),
        'bod': double.parse(bod.toStringAsFixed(2)),
        'cod': double.parse(cod.toStringAsFixed(2)),
        'chlorides': double.parse(chlorides.toStringAsFixed(1)),
        'nitrates': double.parse(nitrates.toStringAsFixed(2)),
      },
      'wqi': double.parse(wqi.toStringAsFixed(1)),
      'status': _getWaterQualityStatus(wqi),
      'alerts': _checkForAlerts(ph, turbidity, dissolvedOxygen, tds, bod, chlorides, nitrates),
      'district': station['district'],
      'region': station['region'],
      'waterSource': station['waterSource'],
      'stationType': station['type'],
    };
  }

  /// Calculate Water Quality Index (WQI)
  /// Based on weighted average of key parameters
  double _calculateWQI(double ph, double turbidity, double do_, double temp, 
                       double tds, double bod, double chlorides, double nitrates) {
    // Ideal values as per MPCB/BIS standards
    const phIdeal = 7.0;
    
    // Calculate sub-indices (0-100 scale)
    final phIndex = 100 - (((ph - phIdeal).abs() / 1.5) * 100).clamp(0, 100);
    final turbidityIndex = 100 - ((turbidity / 50.0) * 100).clamp(0, 100);
    final doIndex = (do_ / 12.0) * 100;
    final tdsIndex = 100 - ((tds / 1500.0) * 100).clamp(0, 100);
    final bodIndex = 100 - ((bod / 20.0) * 100).clamp(0, 100);
    final chloridesIndex = 100 - ((chlorides / 600.0) * 100).clamp(0, 100);
    final nitratesIndex = 100 - ((nitrates / 50.0) * 100).clamp(0, 100);
    
    // Weighted average (pH and DO are most critical)
    final wqi = (phIndex * 0.20) + 
                (turbidityIndex * 0.15) + 
                (doIndex * 0.20) + 
                (tdsIndex * 0.15) + 
                (bodIndex * 0.10) + 
                (chloridesIndex * 0.10) + 
                (nitratesIndex * 0.10);
    
    return wqi.clamp(0, 100);
  }

  /// Get water quality status based on WQI
  String _getWaterQualityStatus(double wqi) {
    if (wqi >= 90) return 'Excellent';
    if (wqi >= 70) return 'Good';
    if (wqi >= 50) return 'Fair';
    if (wqi >= 25) return 'Poor';
    return 'Very Poor';
  }

  /// Check for parameter alerts
  List<String> _checkForAlerts(double ph, double turbidity, double do_, 
                                double tds, double bod, double chlorides, double nitrates) {
    final alerts = <String>[];
    
    if (ph < 6.5 || ph > 8.5) alerts.add('pH outside safe range (6.5-8.5)');
    if (turbidity > 10) alerts.add('High turbidity (>10 NTU)');
    if (do_ < 5) alerts.add('Low dissolved oxygen (<5 mg/L)');
    if (tds > 500) alerts.add('High TDS (>500 mg/L)');
    if (bod > 3) alerts.add('High BOD (>3 mg/L)');
    if (chlorides > 250) alerts.add('High chlorides (>250 mg/L)');
    if (nitrates > 45) alerts.add('High nitrates (>45 mg/L)');
    
    return alerts;
  }

  /// Hour factor (early morning and evening have different readings)
  double _getHourFactor(int hour) {
    if (hour >= 6 && hour < 10) return 0.8; // Early morning - cleaner
    if (hour >= 10 && hour < 16) return 1.2; // Midday - more activity
    if (hour >= 16 && hour < 20) return 1.4; // Evening - peak activity
    return 0.9; // Night - minimal activity
  }

  /// Season factor (monsoon affects water quality)
  double _getSeasonFactor(int month) {
    // Monsoon months (June-September) have higher turbidity and different parameters
    if (month >= 6 && month <= 9) return 1.5; // Monsoon
    if (month >= 3 && month <= 5) return 1.2; // Summer
    return 1.0; // Winter
  }

  /// Random variation helper
  double _randomVariation(double range) {
    return (_random.nextDouble() - 0.5) * 2 * range;
  }

  /// Dispose resources
  void dispose() {
    stopLiveSimulation();
    for (var controller in _controllers) {
      controller.close();
    }
    _controllers.clear();
  }

  /// Maharashtra Water Quality Monitoring Stations
  /// Based on major cities, rivers, and water bodies across Maharashtra
  static final List<Map<String, dynamic>> _maharashtraStations = [
    // Mumbai Metropolitan Region
    {
      'id': 'MH-MUM-001',
      'name': 'Bandra Reclamation',
      'district': 'Mumbai',
      'region': 'Konkan',
      'location': 'Bandra West',
      'latitude': 19.0596,
      'longitude': 72.8295,
      'waterSource': 'Arabian Sea - Coastal',
      'type': 'Coastal Monitoring',
      'baseParameters': {
        'ph': 7.8,
        'turbidity': 12.0,
        'dissolvedOxygen': 6.5,
        'temperature': 27.0,
        'conductivity': 850.0,
        'tds': 450.0,
        'bod': 4.5,
        'cod': 25.0,
        'chlorides': 380.0,
        'nitrates': 8.5,
      }
    },
    {
      'id': 'MH-MUM-002',
      'name': 'Mithi River - Mahim',
      'district': 'Mumbai',
      'region': 'Konkan',
      'location': 'Mahim',
      'latitude': 19.0369,
      'longitude': 72.8406,
      'waterSource': 'Mithi River',
      'type': 'River Monitoring',
      'baseParameters': {
        'ph': 7.2,
        'turbidity': 18.0,
        'dissolvedOxygen': 5.2,
        'temperature': 28.0,
        'conductivity': 920.0,
        'tds': 580.0,
        'bod': 6.8,
        'cod': 35.0,
        'chlorides': 420.0,
        'nitrates': 12.0,
      }
    },
    {
      'id': 'MH-MUM-003',
      'name': 'Powai Lake',
      'district': 'Mumbai',
      'region': 'Konkan',
      'location': 'Powai',
      'latitude': 19.1197,
      'longitude': 72.9059,
      'waterSource': 'Powai Lake',
      'type': 'Lake Monitoring',
      'baseParameters': {
        'ph': 7.4,
        'turbidity': 8.5,
        'dissolvedOxygen': 7.2,
        'temperature': 26.5,
        'conductivity': 680.0,
        'tds': 380.0,
        'bod': 3.2,
        'cod': 18.0,
        'chlorides': 280.0,
        'nitrates': 6.5,
      }
    },

    // Pune Region
    {
      'id': 'MH-PUN-001',
      'name': 'Mula River - Sangam Bridge',
      'district': 'Pune',
      'region': 'Pune',
      'location': 'Sangamwadi',
      'latitude': 18.5277,
      'longitude': 73.8642,
      'waterSource': 'Mula River',
      'type': 'River Monitoring',
      'baseParameters': {
        'ph': 7.3,
        'turbidity': 10.0,
        'dissolvedOxygen': 6.8,
        'temperature': 25.0,
        'conductivity': 720.0,
        'tds': 420.0,
        'bod': 4.0,
        'cod': 22.0,
        'chlorides': 320.0,
        'nitrates': 9.0,
      }
    },
    {
      'id': 'MH-PUN-002',
      'name': 'Mutha River - Deccan',
      'district': 'Pune',
      'region': 'Pune',
      'location': 'Deccan Gymkhana',
      'latitude': 18.5074,
      'longitude': 73.8372,
      'waterSource': 'Mutha River',
      'type': 'River Monitoring',
      'baseParameters': {
        'ph': 7.4,
        'turbidity': 9.0,
        'dissolvedOxygen': 7.0,
        'temperature': 24.5,
        'conductivity': 700.0,
        'tds': 400.0,
        'bod': 3.8,
        'cod': 20.0,
        'chlorides': 300.0,
        'nitrates': 8.0,
      }
    },
    {
      'id': 'MH-PUN-003',
      'name': 'Khadakwasla Reservoir',
      'district': 'Pune',
      'region': 'Pune',
      'location': 'Khadakwasla',
      'latitude': 18.4367,
      'longitude': 73.7584,
      'waterSource': 'Khadakwasla Dam',
      'type': 'Reservoir Monitoring',
      'baseParameters': {
        'ph': 7.6,
        'turbidity': 6.5,
        'dissolvedOxygen': 7.8,
        'temperature': 23.5,
        'conductivity': 580.0,
        'tds': 320.0,
        'bod': 2.5,
        'cod': 15.0,
        'chlorides': 220.0,
        'nitrates': 5.5,
      }
    },

    // Nagpur Region
    {
      'id': 'MH-NAG-001',
      'name': 'Nag River - Seminary Hills',
      'district': 'Nagpur',
      'region': 'Vidarbha',
      'location': 'Seminary Hills',
      'latitude': 21.1346,
      'longitude': 79.0820,
      'waterSource': 'Nag River',
      'type': 'River Monitoring',
      'baseParameters': {
        'ph': 7.1,
        'turbidity': 14.0,
        'dissolvedOxygen': 5.8,
        'temperature': 27.5,
        'conductivity': 780.0,
        'tds': 480.0,
        'bod': 5.2,
        'cod': 28.0,
        'chlorides': 350.0,
        'nitrates': 10.5,
      }
    },
    {
      'id': 'MH-NAG-002',
      'name': 'Ambazari Lake',
      'district': 'Nagpur',
      'region': 'Vidarbha',
      'location': 'Ambazari',
      'latitude': 21.1206,
      'longitude': 79.0473,
      'waterSource': 'Ambazari Lake',
      'type': 'Lake Monitoring',
      'baseParameters': {
        'ph': 7.5,
        'turbidity': 7.5,
        'dissolvedOxygen': 7.4,
        'temperature': 26.0,
        'conductivity': 650.0,
        'tds': 360.0,
        'bod': 3.0,
        'cod': 17.0,
        'chlorides': 260.0,
        'nitrates': 6.8,
      }
    },

    // Nashik Region
    {
      'id': 'MH-NAS-001',
      'name': 'Godavari River - Panchavati',
      'district': 'Nashik',
      'region': 'Nashik',
      'location': 'Panchavati',
      'latitude': 19.9975,
      'longitude': 73.7898,
      'waterSource': 'Godavari River',
      'type': 'River Monitoring',
      'baseParameters': {
        'ph': 7.7,
        'turbidity': 8.0,
        'dissolvedOxygen': 7.5,
        'temperature': 24.0,
        'conductivity': 620.0,
        'tds': 350.0,
        'bod': 2.8,
        'cod': 16.0,
        'chlorides': 240.0,
        'nitrates': 6.0,
      }
    },
    {
      'id': 'MH-NAS-002',
      'name': 'Gangapur Dam',
      'district': 'Nashik',
      'region': 'Nashik',
      'location': 'Gangapur',
      'latitude': 20.0281,
      'longitude': 73.9372,
      'waterSource': 'Gangapur Reservoir',
      'type': 'Reservoir Monitoring',
      'baseParameters': {
        'ph': 7.8,
        'turbidity': 5.5,
        'dissolvedOxygen': 8.0,
        'temperature': 23.0,
        'conductivity': 540.0,
        'tds': 290.0,
        'bod': 2.2,
        'cod': 13.0,
        'chlorides': 200.0,
        'nitrates': 4.5,
      }
    },

    // Aurangabad Region
    {
      'id': 'MH-AUR-001',
      'name': 'Kham River',
      'district': 'Aurangabad',
      'region': 'Marathwada',
      'location': 'Aurangabad City',
      'latitude': 19.8762,
      'longitude': 75.3433,
      'waterSource': 'Kham River',
      'type': 'River Monitoring',
      'baseParameters': {
        'ph': 7.2,
        'turbidity': 11.0,
        'dissolvedOxygen': 6.2,
        'temperature': 26.5,
        'conductivity': 740.0,
        'tds': 440.0,
        'bod': 4.2,
        'cod': 24.0,
        'chlorides': 330.0,
        'nitrates': 9.5,
      }
    },
    {
      'id': 'MH-AUR-002',
      'name': 'Jayakwadi Dam',
      'district': 'Aurangabad',
      'region': 'Marathwada',
      'location': 'Paithan',
      'latitude': 19.4858,
      'longitude': 75.3803,
      'waterSource': 'Jayakwadi Reservoir',
      'type': 'Reservoir Monitoring',
      'baseParameters': {
        'ph': 7.6,
        'turbidity': 6.0,
        'dissolvedOxygen': 7.6,
        'temperature': 25.0,
        'conductivity': 600.0,
        'tds': 340.0,
        'bod': 2.6,
        'cod': 15.5,
        'chlorides': 230.0,
        'nitrates': 5.8,
      }
    },

    // Kolhapur Region
    {
      'id': 'MH-KOL-001',
      'name': 'Panchganga River',
      'district': 'Kolhapur',
      'region': 'Western Maharashtra',
      'location': 'Kolhapur City',
      'latitude': 16.7050,
      'longitude': 74.2433,
      'waterSource': 'Panchganga River',
      'type': 'River Monitoring',
      'baseParameters': {
        'ph': 7.3,
        'turbidity': 9.5,
        'dissolvedOxygen': 7.0,
        'temperature': 24.5,
        'conductivity': 680.0,
        'tds': 390.0,
        'bod': 3.5,
        'cod': 19.0,
        'chlorides': 290.0,
        'nitrates': 7.5,
      }
    },

    // Solapur Region
    {
      'id': 'MH-SOL-001',
      'name': 'Sina River',
      'district': 'Solapur',
      'region': 'Western Maharashtra',
      'location': 'Solapur City',
      'latitude': 17.6599,
      'longitude': 75.9064,
      'waterSource': 'Sina River',
      'type': 'River Monitoring',
      'baseParameters': {
        'ph': 7.1,
        'turbidity': 12.5,
        'dissolvedOxygen': 6.0,
        'temperature': 27.0,
        'conductivity': 760.0,
        'tds': 460.0,
        'bod': 4.8,
        'cod': 26.0,
        'chlorides': 360.0,
        'nitrates': 10.0,
      }
    },

    // Thane Region
    {
      'id': 'MH-THA-001',
      'name': 'Ulhas River - Thane',
      'district': 'Thane',
      'region': 'Konkan',
      'location': 'Thane City',
      'latitude': 19.2183,
      'longitude': 72.9781,
      'waterSource': 'Ulhas River',
      'type': 'River Monitoring',
      'baseParameters': {
        'ph': 7.2,
        'turbidity': 13.0,
        'dissolvedOxygen': 6.3,
        'temperature': 27.5,
        'conductivity': 790.0,
        'tds': 470.0,
        'bod': 5.0,
        'cod': 27.0,
        'chlorides': 370.0,
        'nitrates': 9.8,
      }
    },
    {
      'id': 'MH-THA-002',
      'name': 'Tansa Lake',
      'district': 'Thane',
      'region': 'Konkan',
      'location': 'Tansa',
      'latitude': 19.7333,
      'longitude': 73.2333,
      'waterSource': 'Tansa Reservoir',
      'type': 'Reservoir Monitoring',
      'baseParameters': {
        'ph': 7.6,
        'turbidity': 5.8,
        'dissolvedOxygen': 7.9,
        'temperature': 24.0,
        'conductivity': 560.0,
        'tds': 310.0,
        'bod': 2.3,
        'cod': 14.0,
        'chlorides': 210.0,
        'nitrates': 5.2,
      }
    },

    // Raigad Region
    {
      'id': 'MH-RAI-001',
      'name': 'Patalganga River',
      'district': 'Raigad',
      'region': 'Konkan',
      'location': 'Panvel',
      'latitude': 18.9894,
      'longitude': 73.1175,
      'waterSource': 'Patalganga River',
      'type': 'River Monitoring',
      'baseParameters': {
        'ph': 7.3,
        'turbidity': 10.5,
        'dissolvedOxygen': 6.6,
        'temperature': 26.0,
        'conductivity': 710.0,
        'tds': 410.0,
        'bod': 3.9,
        'cod': 21.0,
        'chlorides': 310.0,
        'nitrates': 8.2,
      }
    },

    // Satara Region
    {
      'id': 'MH-SAT-001',
      'name': 'Krishna River - Karad',
      'district': 'Satara',
      'region': 'Western Maharashtra',
      'location': 'Karad',
      'latitude': 17.2892,
      'longitude': 74.1817,
      'waterSource': 'Krishna River',
      'type': 'River Monitoring',
      'baseParameters': {
        'ph': 7.5,
        'turbidity': 7.8,
        'dissolvedOxygen': 7.3,
        'temperature': 24.0,
        'conductivity': 640.0,
        'tds': 370.0,
        'bod': 3.1,
        'cod': 17.5,
        'chlorides': 270.0,
        'nitrates': 6.7,
      }
    },

    // Ahmednagar Region
    {
      'id': 'MH-AHM-001',
      'name': 'Pravara River',
      'district': 'Ahmednagar',
      'region': 'Western Maharashtra',
      'location': 'Sangamner',
      'latitude': 19.5664,
      'longitude': 74.2159,
      'waterSource': 'Pravara River',
      'type': 'River Monitoring',
      'baseParameters': {
        'ph': 7.4,
        'turbidity': 8.8,
        'dissolvedOxygen': 7.1,
        'temperature': 25.0,
        'conductivity': 670.0,
        'tds': 385.0,
        'bod': 3.3,
        'cod': 18.5,
        'chlorides': 285.0,
        'nitrates': 7.2,
      }
    },

    // Amravati Region
    {
      'id': 'MH-AMR-001',
      'name': 'Pedhi River',
      'district': 'Amravati',
      'region': 'Vidarbha',
      'location': 'Amravati City',
      'latitude': 20.9320,
      'longitude': 77.7523,
      'waterSource': 'Pedhi River',
      'type': 'River Monitoring',
      'baseParameters': {
        'ph': 7.2,
        'turbidity': 11.5,
        'dissolvedOxygen': 6.4,
        'temperature': 27.0,
        'conductivity': 750.0,
        'tds': 450.0,
        'bod': 4.5,
        'cod': 25.0,
        'chlorides': 340.0,
        'nitrates': 9.3,
      }
    },

    // Akola Region
    {
      'id': 'MH-AKO-001',
      'name': 'Morna River',
      'district': 'Akola',
      'region': 'Vidarbha',
      'location': 'Akola City',
      'latitude': 20.7002,
      'longitude': 77.0082,
      'waterSource': 'Morna River',
      'type': 'River Monitoring',
      'baseParameters': {
        'ph': 7.1,
        'turbidity': 13.0,
        'dissolvedOxygen': 5.9,
        'temperature': 28.0,
        'conductivity': 800.0,
        'tds': 490.0,
        'bod': 5.3,
        'cod': 29.0,
        'chlorides': 380.0,
        'nitrates': 11.0,
      }
    },
  ];
}
