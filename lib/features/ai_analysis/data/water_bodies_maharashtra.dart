import 'models/water_body_location.dart';

/// Comprehensive list of water bodies in Maharashtra
class MaharashtraWaterBodies {
  static final List<WaterBodyLocation> allWaterBodies = [
    // Major Rivers
    WaterBodyLocation(
      name: 'Godavari River - Nashik',
      type: 'river',
      latitude: 19.9975,
      longitude: 73.7898,
      district: 'Nashik',
      region: 'North Maharashtra',
    ),
    WaterBodyLocation(
      name: 'Godavari River - Aurangabad',
      type: 'river',
      latitude: 19.8762,
      longitude: 75.3433,
      district: 'Aurangabad',
      region: 'Marathwada',
    ),
    WaterBodyLocation(
      name: 'Godavari River - Nanded',
      type: 'river',
      latitude: 19.1383,
      longitude: 77.3210,
      district: 'Nanded',
      region: 'Marathwada',
    ),
    WaterBodyLocation(
      name: 'Krishna River - Sangli',
      type: 'river',
      latitude: 16.8524,
      longitude: 74.5815,
      district: 'Sangli',
      region: 'Western Maharashtra',
    ),
    WaterBodyLocation(
      name: 'Krishna River - Satara',
      type: 'river',
      latitude: 17.6805,
      longitude: 73.9702,
      district: 'Satara',
      region: 'Western Maharashtra',
    ),
    WaterBodyLocation(
      name: 'Bhima River - Pune',
      type: 'river',
      latitude: 18.6556,
      longitude: 73.7622,
      district: 'Pune',
      region: 'Western Maharashtra',
    ),
    WaterBodyLocation(
      name: 'Bhima River - Solapur',
      type: 'river',
      latitude: 17.6599,
      longitude: 75.9064,
      district: 'Solapur',
      region: 'Western Maharashtra',
    ),
    WaterBodyLocation(
      name: 'Tapi River - Dhule',
      type: 'river',
      latitude: 20.9011,
      longitude: 74.7775,
      district: 'Dhule',
      region: 'North Maharashtra',
    ),
    WaterBodyLocation(
      name: 'Tapi River - Jalgaon',
      type: 'river',
      latitude: 21.0077,
      longitude: 75.5626,
      district: 'Jalgaon',
      region: 'North Maharashtra',
    ),
    WaterBodyLocation(
      name: 'Narmada River - Nandurbar',
      type: 'river',
      latitude: 21.3667,
      longitude: 74.2333,
      district: 'Nandurbar',
      region: 'North Maharashtra',
    ),
    WaterBodyLocation(
      name: 'Penganga River - Yavatmal',
      type: 'river',
      latitude: 20.3974,
      longitude: 78.1280,
      district: 'Yavatmal',
      region: 'Vidarbha',
    ),
    WaterBodyLocation(
      name: 'Wardha River - Wardha',
      type: 'river',
      latitude: 20.7453,
      longitude: 78.5970,
      district: 'Wardha',
      region: 'Vidarbha',
    ),
    WaterBodyLocation(
      name: 'Wainganga River - Bhandara',
      type: 'river',
      latitude: 21.1704,
      longitude: 79.6522,
      district: 'Bhandara',
      region: 'Vidarbha',
    ),
    WaterBodyLocation(
      name: 'Pranhita River - Chandrapur',
      type: 'river',
      latitude: 19.9615,
      longitude: 79.2961,
      district: 'Chandrapur',
      region: 'Vidarbha',
    ),

    // Major Dams and Reservoirs
    WaterBodyLocation(
      name: 'Jayakwadi Dam',
      type: 'dam',
      latitude: 19.4833,
      longitude: 75.3667,
      district: 'Aurangabad',
      region: 'Marathwada',
    ),
    WaterBodyLocation(
      name: 'Koyna Dam',
      type: 'dam',
      latitude: 17.3965,
      longitude: 73.7518,
      district: 'Satara',
      region: 'Western Maharashtra',
    ),
    WaterBodyLocation(
      name: 'Bhandardara Dam (Wilson Dam)',
      type: 'dam',
      latitude: 19.5478,
      longitude: 73.7469,
      district: 'Ahmednagar',
      region: 'North Maharashtra',
    ),
    WaterBodyLocation(
      name: 'Mulshi Dam',
      type: 'dam',
      latitude: 18.4689,
      longitude: 73.4869,
      district: 'Pune',
      region: 'Western Maharashtra',
    ),
    WaterBodyLocation(
      name: 'Panshet Dam',
      type: 'dam',
      latitude: 18.4075,
      longitude: 73.5228,
      district: 'Pune',
      region: 'Western Maharashtra',
    ),
    WaterBodyLocation(
      name: 'Khadakwasla Dam',
      type: 'dam',
      latitude: 18.4473,
      longitude: 73.7544,
      district: 'Pune',
      region: 'Western Maharashtra',
    ),
    WaterBodyLocation(
      name: 'Ujjani Dam',
      type: 'dam',
      latitude: 17.9167,
      longitude: 75.1333,
      district: 'Solapur',
      region: 'Western Maharashtra',
    ),
    WaterBodyLocation(
      name: 'Radhanagari Dam',
      type: 'dam',
      latitude: 16.4167,
      longitude: 74.0167,
      district: 'Kolhapur',
      region: 'Western Maharashtra',
    ),
    WaterBodyLocation(
      name: 'Upper Vaitarna Dam',
      type: 'dam',
      latitude: 19.6167,
      longitude: 73.4000,
      district: 'Thane',
      region: 'Konkan',
    ),
    WaterBodyLocation(
      name: 'Bhatsa Dam',
      type: 'dam',
      latitude: 19.7167,
      longitude: 73.3500,
      district: 'Thane',
      region: 'Konkan',
    ),
    WaterBodyLocation(
      name: 'Tansa Dam',
      type: 'dam',
      latitude: 19.4833,
      longitude: 73.2167,
      district: 'Thane',
      region: 'Konkan',
    ),
    WaterBodyLocation(
      name: 'Gangapur Dam',
      type: 'dam',
      latitude: 19.7042,
      longitude: 75.0219,
      district: 'Nashik',
      region: 'North Maharashtra',
    ),
    WaterBodyLocation(
      name: 'Darna Dam',
      type: 'dam',
      latitude: 20.3000,
      longitude: 74.8167,
      district: 'Nashik',
      region: 'North Maharashtra',
    ),
    WaterBodyLocation(
      name: 'Totladoh Dam',
      type: 'dam',
      latitude: 21.1167,
      longitude: 79.5500,
      district: 'Nagpur',
      region: 'Vidarbha',
    ),
    WaterBodyLocation(
      name: 'Isapur Dam',
      type: 'dam',
      latitude: 19.2667,
      longitude: 77.1833,
      district: 'Yavatmal',
      region: 'Vidarbha',
    ),
    WaterBodyLocation(
      name: 'Pench Dam',
      type: 'dam',
      latitude: 21.6667,
      longitude: 79.2500,
      district: 'Nagpur',
      region: 'Vidarbha',
    ),

    // Lakes
    WaterBodyLocation(
      name: 'Lonar Lake',
      type: 'lake',
      latitude: 19.9833,
      longitude: 76.5167,
      district: 'Buldhana',
      region: 'Vidarbha',
    ),
    WaterBodyLocation(
      name: 'Powai Lake',
      type: 'lake',
      latitude: 19.1197,
      longitude: 72.9050,
      district: 'Mumbai',
      region: 'Konkan',
    ),
    WaterBodyLocation(
      name: 'Vihar Lake',
      type: 'lake',
      latitude: 19.1097,
      longitude: 72.9050,
      district: 'Mumbai',
      region: 'Konkan',
    ),
    WaterBodyLocation(
      name: 'Tulsi Lake',
      type: 'lake',
      latitude: 19.1597,
      longitude: 72.8750,
      district: 'Mumbai',
      region: 'Konkan',
    ),
    WaterBodyLocation(
      name: 'Rankala Lake',
      type: 'lake',
      latitude: 16.6952,
      longitude: 74.2363,
      district: 'Kolhapur',
      region: 'Western Maharashtra',
    ),
    WaterBodyLocation(
      name: 'Pashan Lake',
      type: 'lake',
      latitude: 18.5369,
      longitude: 73.7983,
      district: 'Pune',
      region: 'Western Maharashtra',
    ),
    WaterBodyLocation(
      name: 'Katraj Lake',
      type: 'lake',
      latitude: 18.4478,
      longitude: 73.8653,
      district: 'Pune',
      region: 'Western Maharashtra',
    ),
    WaterBodyLocation(
      name: 'Khindsi Lake',
      type: 'lake',
      latitude: 21.1461,
      longitude: 78.7444,
      district: 'Nagpur',
      region: 'Vidarbha',
    ),
    WaterBodyLocation(
      name: 'Ambazari Lake',
      type: 'lake',
      latitude: 21.1200,
      longitude: 79.0392,
      district: 'Nagpur',
      region: 'Vidarbha',
    ),
    WaterBodyLocation(
      name: 'Salim Ali Lake',
      type: 'lake',
      latitude: 19.8444,
      longitude: 75.3283,
      district: 'Aurangabad',
      region: 'Marathwada',
    ),

    // Coastal Water Bodies
    WaterBodyLocation(
      name: 'Arabian Sea - Mumbai Coast',
      type: 'coastal',
      latitude: 18.9220,
      longitude: 72.8347,
      district: 'Mumbai',
      region: 'Konkan',
    ),
    WaterBodyLocation(
      name: 'Arabian Sea - Ratnagiri',
      type: 'coastal',
      latitude: 17.0000,
      longitude: 73.3000,
      district: 'Ratnagiri',
      region: 'Konkan',
    ),
    WaterBodyLocation(
      name: 'Arabian Sea - Sindhudurg',
      type: 'coastal',
      latitude: 16.0000,
      longitude: 73.5000,
      district: 'Sindhudurg',
      region: 'Konkan',
    ),
    WaterBodyLocation(
      name: 'Arabian Sea - Palghar',
      type: 'coastal',
      latitude: 19.6969,
      longitude: 72.7658,
      district: 'Palghar',
      region: 'Konkan',
    ),

    // Tributaries and Smaller Rivers
    WaterBodyLocation(
      name: 'Purna River - Akola',
      type: 'river',
      latitude: 20.7002,
      longitude: 77.0082,
      district: 'Akola',
      region: 'Vidarbha',
    ),
    WaterBodyLocation(
      name: 'Mula River - Pune',
      type: 'river',
      latitude: 18.5314,
      longitude: 73.8446,
      district: 'Pune',
      region: 'Western Maharashtra',
    ),
    WaterBodyLocation(
      name: 'Mutha River - Pune',
      type: 'river',
      latitude: 18.5196,
      longitude: 73.8553,
      district: 'Pune',
      region: 'Western Maharashtra',
    ),
    WaterBodyLocation(
      name: 'Pavana River - Pune',
      type: 'river',
      latitude: 18.7322,
      longitude: 73.4289,
      district: 'Pune',
      region: 'Western Maharashtra',
    ),
    WaterBodyLocation(
      name: 'Indrayani River - Pune',
      type: 'river',
      latitude: 18.9894,
      longitude: 73.7821,
      district: 'Pune',
      region: 'Western Maharashtra',
    ),
    WaterBodyLocation(
      name: 'Karha River - Satara',
      type: 'river',
      latitude: 17.6869,
      longitude: 74.0156,
      district: 'Satara',
      region: 'Western Maharashtra',
    ),
    WaterBodyLocation(
      name: 'Kukadi River - Ahmednagar',
      type: 'river',
      latitude: 19.0950,
      longitude: 74.7380,
      district: 'Ahmednagar',
      region: 'North Maharashtra',
    ),
    WaterBodyLocation(
      name: 'Sina River - Nashik',
      type: 'river',
      latitude: 20.0017,
      longitude: 73.7898,
      district: 'Nashik',
      region: 'North Maharashtra',
    ),
    WaterBodyLocation(
      name: 'Kadva River - Nashik',
      type: 'river',
      latitude: 20.1000,
      longitude: 73.8500,
      district: 'Nashik',
      region: 'North Maharashtra',
    ),
    WaterBodyLocation(
      name: 'Girna River - Jalgaon',
      type: 'river',
      latitude: 21.0222,
      longitude: 75.5797,
      district: 'Jalgaon',
      region: 'North Maharashtra',
    ),
    WaterBodyLocation(
      name: 'Puma River - Dhule',
      type: 'river',
      latitude: 20.9042,
      longitude: 74.7749,
      district: 'Dhule',
      region: 'North Maharashtra',
    ),
    WaterBodyLocation(
      name: 'Dudhna River - Nashik',
      type: 'river',
      latitude: 20.5847,
      longitude: 74.2006,
      district: 'Nashik',
      region: 'North Maharashtra',
    ),

    // Additional Reservoirs and Irrigation Projects
    WaterBodyLocation(
      name: 'Mula Reservoir',
      type: 'reservoir',
      latitude: 19.1667,
      longitude: 74.4167,
      district: 'Ahmednagar',
      region: 'North Maharashtra',
    ),
    WaterBodyLocation(
      name: 'Pravara Reservoir',
      type: 'reservoir',
      latitude: 19.5333,
      longitude: 74.6000,
      district: 'Ahmednagar',
      region: 'North Maharashtra',
    ),
    WaterBodyLocation(
      name: 'Yeldari Dam',
      type: 'dam',
      latitude: 19.6000,
      longitude: 76.4667,
      district: 'Parbhani',
      region: 'Marathwada',
    ),
    WaterBodyLocation(
      name: 'Manjra Dam',
      type: 'dam',
      latitude: 18.4333,
      longitude: 76.6000,
      district: 'Latur',
      region: 'Marathwada',
    ),
    WaterBodyLocation(
      name: 'Vishnupuri Barrage',
      type: 'barrage',
      latitude: 19.1500,
      longitude: 77.3167,
      district: 'Nanded',
      region: 'Marathwada',
    ),
    WaterBodyLocation(
      name: 'Siddheshwar Dam',
      type: 'dam',
      latitude: 18.9667,
      longitude: 76.7167,
      district: 'Hingoli',
      region: 'Marathwada',
    ),
    WaterBodyLocation(
      name: 'Majalgaon Dam',
      type: 'dam',
      latitude: 19.1500,
      longitude: 76.2333,
      district: 'Beed',
      region: 'Marathwada',
    ),
  ];

  /// Get water bodies by district
  static List<WaterBodyLocation> getByDistrict(String district) {
    return allWaterBodies
        .where((wb) => wb.district.toLowerCase() == district.toLowerCase())
        .toList();
  }

  /// Get water bodies by type
  static List<WaterBodyLocation> getByType(String type) {
    return allWaterBodies
        .where((wb) => wb.type.toLowerCase() == type.toLowerCase())
        .toList();
  }

  /// Get water bodies by region
  static List<WaterBodyLocation> getByRegion(String region) {
    return allWaterBodies
        .where((wb) => wb.region.toLowerCase() == region.toLowerCase())
        .toList();
  }

  /// Search water bodies by name
  static List<WaterBodyLocation> searchByName(String query) {
    final lowerQuery = query.toLowerCase();
    return allWaterBodies
        .where((wb) => wb.name.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// Get all districts
  static List<String> getAllDistricts() {
    return allWaterBodies.map((wb) => wb.district).toSet().toList()..sort();
  }

  /// Get all regions
  static List<String> getAllRegions() {
    return allWaterBodies.map((wb) => wb.region).toSet().toList()..sort();
  }

  /// Get all water body types
  static List<String> getAllTypes() {
    return allWaterBodies.map((wb) => wb.type).toSet().toList()..sort();
  }
}
