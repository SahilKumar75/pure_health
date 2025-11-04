import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pure_health/core/constants/color_constants.dart';
import 'package:pure_health/core/theme/text_styles.dart';
import 'package:pure_health/shared/widgets/custom_sidebar.dart';
import 'package:pure_health/shared/widgets/custom_map_widget.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:pure_health/core/data/maharashtra_water_data.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

// Pulsing location dot widget
class PulsingLocationDot extends StatefulWidget {
  const PulsingLocationDot({super.key});

  @override
  State<PulsingLocationDot> createState() => _PulsingLocationDotState();
}

class _PulsingLocationDotState extends State<PulsingLocationDot> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Animated pulsing outer ring
            Transform.scale(
              scale: _animation.value,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryBlue.withOpacity(0.15),
                ),
              ),
            ),
            // Middle ring
            Transform.scale(
              scale: 0.7,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryBlue.withOpacity(0.25),
                ),
              ),
            ),
            // Inner dot with white border (fixed size)
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryBlue,
                border: Border.all(color: AppColors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.6),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool _isBottomBarExpanded = false;
  late final MapController _mapController;
  double _currentZoom = 7.0; // Lower zoom to show all of Maharashtra
  
  // Real-time data
  Map<String, Map<String, dynamic>> _stationData = {};
  Timer? _dataUpdateTimer;
  int _totalStations = 0;
  int _activeAlerts = 0;
  int _safeCount = 0;
  int _warningCount = 0;
  int _criticalCount = 0;
  DateTime _lastDataFetch = DateTime.now();
  String? _selectedStationId;
  LatLng? _userLocation; // User's current location

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _loadMaharashtraData();
    _startDataUpdates();
    _getUserLocation();
  }

  /// Get user's current location
  Future<void> _getUserLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are not enabled, use fallback
        const fallbackLoc = LatLng(18.5204, 73.8567); // Pune, Maharashtra
        setState(() {
          _userLocation = fallbackLoc;
        });
        Future.delayed(const Duration(milliseconds: 500), () {
          _mapController.move(fallbackLoc, 10.0);
        });
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permission denied, use fallback
          const fallbackLoc = LatLng(18.5204, 73.8567); // Pune, Maharashtra
          setState(() {
            _userLocation = fallbackLoc;
          });
          Future.delayed(const Duration(milliseconds: 500), () {
            _mapController.move(fallbackLoc, 10.0);
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Permissions are permanently denied, use fallback
        const fallbackLoc = LatLng(18.5204, 73.8567); // Pune, Maharashtra
        setState(() {
          _userLocation = fallbackLoc;
        });
        Future.delayed(const Duration(milliseconds: 500), () {
          _mapController.move(fallbackLoc, 10.0);
        });
        return;
      }

      // Get actual current position
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 100,
        ),
      );
      
      final userLoc = LatLng(position.latitude, position.longitude);
      
      setState(() {
        _userLocation = userLoc;
      });
      
      // Center map on user's actual location
      Future.delayed(const Duration(milliseconds: 500), () {
        _mapController.move(userLoc, 12.0); // Zoom level 12 for closer view
      });
    } catch (e) {
      // Error getting location, use fallback
      const fallbackLoc = LatLng(18.5204, 73.8567); // Pune, Maharashtra
      setState(() {
        _userLocation = fallbackLoc;
      });
      
      Future.delayed(const Duration(milliseconds: 500), () {
        _mapController.move(fallbackLoc, 10.0);
      });
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    _dataUpdateTimer?.cancel();
    super.dispose();
  }

  void _loadMaharashtraData() {
    final allStations = MaharashtraWaterData.getAllStations();
    
    setState(() {
      _totalStations = allStations.length;
      _lastDataFetch = DateTime.now();
      
      // Generate sample data for each station
      for (var station in allStations) {
        final samples = MaharashtraWaterQualityData.generateSamplesForStation(
          station,
          sampleCount: 1,
        );
        if (samples.isNotEmpty) {
          final sample = samples.first;
          _stationData[station.id] = {
            'pH': sample['pH'] as double,
            'turbidity': sample['turbidity'] as double,
            'dissolvedOxygen': sample['dissolvedOxygen'] as double,
            'temperature': sample['temperature'] as double,
            'status': sample['status'] as String,
            'latitude': station.latitude,
            'longitude': station.longitude,
            'name': station.displayName,
            'stationType': station.stationType,
            'timestamp': _lastDataFetch,
          };
        }
      }
      
      _updateStats();
    });
  }

  String _getTimeAgo(DateTime timestamp) {
    final difference = DateTime.now().difference(timestamp);
    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _updateStats() {
    int safe = 0, warning = 0, critical = 0;
    
    _stationData.forEach((key, data) {
      switch (data['status']) {
        case 'Safe':
          safe++;
          break;
        case 'Warning':
          warning++;
          break;
        case 'Critical':
          critical++;
          break;
      }
    });
    
    setState(() {
      _safeCount = safe;
      _warningCount = warning;
      _criticalCount = critical;
      _activeAlerts = warning + critical;
    });
  }

  void _startDataUpdates() {
    _dataUpdateTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _loadMaharashtraData();
    });
  }

  List<Marker> _buildStationMarkers() {
    final markers = <Marker>[];
    
    // Add user's current location marker (pulsing blue dot - Google Maps style)
    if (_userLocation != null) {
      markers.add(
        Marker(
          point: _userLocation!,
          width: 50,
          height: 50,
          child: const PulsingLocationDot(),
        ),
      );
    }
    
    // Add MPCB monitoring station markers
    _stationData.forEach((stationId, data) {
      final lat = data['latitude'] as double;
      final lon = data['longitude'] as double;
      final status = data['status'] as String;
      final timestamp = data['timestamp'] as DateTime;
      final name = data['name'] as String;
      final stationType = data['stationType'] as String;
      
      // Status colors following MPCB standards
      Color markerColor;
      Color backgroundColor;
      
      switch (status) {
        case 'Safe':
          markerColor = const Color(0xFF10B981); // Green - Safe
          backgroundColor = const Color(0xFF10B981).withOpacity(0.2);
          break;
        case 'Warning':
          markerColor = const Color(0xFFF59E0B); // Amber - Caution
          backgroundColor = const Color(0xFFF59E0B).withOpacity(0.2);
          break;
        case 'Critical':
          markerColor = const Color(0xFFEF4444); // Red - Alert
          backgroundColor = const Color(0xFFEF4444).withOpacity(0.2);
          break;
        default:
          markerColor = AppColors.charcoal;
          backgroundColor = AppColors.charcoal.withOpacity(0.2);
      }
      
      markers.add(
        Marker(
          point: LatLng(lat, lon),
          width: 56,
          height: 56,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Tooltip(
              message: '$name\n$stationType\nStatus: $status\nUpdated: ${_getTimeAgo(timestamp)}',
              preferBelow: false,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.charcoal.withOpacity(0.95),
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedStationId = stationId;
                  });
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer glow/pulse effect
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: backgroundColor,
                      ),
                    ),
                    // Main station marker
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: markerColor,
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.water_drop,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
    
    return markers;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Safe':
        return AppColors.success;
      case 'Warning':
        return AppColors.warning;
      case 'Critical':
        return AppColors.error;
      default:
        return AppColors.charcoal;
    }
  }

  void _zoomIn() {
    setState(() {
      _currentZoom = (_currentZoom + 1).clamp(1.0, 18.0);
      _mapController.move(_mapController.camera.center, _currentZoom);
    });
  }

  void _zoomOut() {
    setState(() {
      _currentZoom = (_currentZoom - 1).clamp(1.0, 18.0);
      _mapController.move(_mapController.camera.center, _currentZoom);
    });
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.body.copyWith(
                color: AppColors.charcoal.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: AppTextStyles.heading4.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            shape: BoxShape.circle,
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              count.toString(),
              style: AppTextStyles.heading3.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.charcoal.withOpacity(0.7),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, String description, Color color, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.white, size: 14),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.charcoal,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              Text(
                description,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.charcoal.withOpacity(0.6),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.primaryBlue,
          size: 20,
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: AppTextStyles.heading4.copyWith(
            color: AppColors.primaryBlue,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStationDetailsPanel() {
    if (_selectedStationId == null) return const SizedBox.shrink();
    
    final stationData = _stationData[_selectedStationId];
    if (stationData == null) return const SizedBox.shrink();
    
    final status = stationData['status'] as String;
    // Station name is shown in the panel header above
    final pH = stationData['pH'] as double;
    final turbidity = stationData['turbidity'] as double;
    final dissolvedOxygen = stationData['dissolvedOxygen'] as double;
    final temperature = stationData['temperature'] as double;
    final timestamp = stationData['timestamp'] as DateTime;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Status Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getStatusColor(status).withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _getStatusColor(status),
              width: 1.5,
            ),
          ),
          child: Text(
            status,
            style: AppTextStyles.caption.copyWith(
              color: _getStatusColor(status),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Updated ${_getTimeAgo(timestamp)}',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.mediumGray,
            fontSize: 12,
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Current Readings
        _buildSectionHeader('Current Readings', Icons.analytics),
        const SizedBox(height: 16),
                _buildReadingCard('pH Level', pH.toStringAsFixed(2), 'Neutral: 6.5-8.5', Icons.water_drop),
                const SizedBox(height: 12),
                _buildReadingCard('Turbidity', '${turbidity.toStringAsFixed(2)} NTU', 'Max: 5 NTU', Icons.blur_on),
                const SizedBox(height: 12),
                _buildReadingCard('Dissolved Oxygen', '${dissolvedOxygen.toStringAsFixed(2)} mg/L', 'Min: 4 mg/L', Icons.air),
                const SizedBox(height: 12),
                _buildReadingCard('Temperature', '${temperature.toStringAsFixed(1)}°C', 'Normal: 20-30°C', Icons.thermostat),
                
                const SizedBox(height: 24),
                
                // AI Predictions
                _buildSectionHeader('AI Predictions', Icons.trending_up),
                const SizedBox(height: 16),
                _buildPredictionCard('Next 7 Days', 'Quality expected to remain ${status.toLowerCase()}', Icons.calendar_today),
                const SizedBox(height: 12),
                _buildPredictionCard('Risk Level', 'Low contamination risk', Icons.shield),
                
                const SizedBox(height: 24),
                
                // Quick Insights
                _buildSectionHeader('Key Insights', Icons.lightbulb_outline),
                const SizedBox(height: 16),
                _buildInsightItem('✓ All parameters within safe limits', AppColors.success),
                const SizedBox(height: 8),
                _buildInsightItem('↗ Slight pH increase trend observed', AppColors.warning),
                const SizedBox(height: 8),
                _buildInsightItem('→ Regular monitoring recommended', AppColors.primaryBlue),
                
                const SizedBox(height: 24),
                
                // Actions
                _buildSectionHeader('Available Actions', Icons.touch_app),
                const SizedBox(height: 16),
        _buildActionButton2('View Full Report', Icons.description, () {}),
        const SizedBox(height: 10),
        _buildActionButton2('Export Data', Icons.download, () {}),
        const SizedBox(height: 10),
        _buildActionButton2('Set Alert', Icons.notifications, () {}),
      ],
    );
  }

  Widget _buildReadingCard(String label, String value, String range, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightCream,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.darkCream.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primaryBlue, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.mediumGray,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTextStyles.heading4.copyWith(
                    color: AppColors.charcoal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  range,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.mediumGray,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionCard(String title, String description, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.success.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.success, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.charcoal,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.mediumGray,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(String text, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.body.copyWith(
              color: AppColors.charcoal,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton2(String label, IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.primaryBlue.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primaryBlue, size: 18),
            const SizedBox(width: 10),
            Text(
              label,
              style: AppTextStyles.body.copyWith(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightCream,
      body: Stack(
        children: [
          // Map widget as the base layer with monitoring station markers
          CustomMapWidget(
            zoom: _currentZoom,
            sidebarWidth: 72.0,
            mapController: _mapController,
            markers: _buildStationMarkers(),
            initialCenter: const LatLng(19.7515, 75.7139), // Center of Maharashtra
          ),

          // Sidebar positioned on the left
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: CustomSidebar(
              selectedIndex: _selectedIndex,
              onItemSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ),

          // Compact Logo positioned beside sidebar at top left
          Positioned(
            left: 96,
            top: 24,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.darkCream.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.charcoal.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/Group 1000001052.png',
                  width: 40,
                  height: 40,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // Right Side Panel - Comprehensive Info Card
          Positioned(
            right: 24,
            top: 24,
            bottom: 24,
            child: Container(
              width: 340,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.97),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.darkCream.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.charcoal.withOpacity(0.12),
                    blurRadius: 32,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with back button if station selected
                    Row(
                      children: [
                        if (_selectedStationId != null) 
                          IconButton(
                            icon: Icon(Icons.arrow_back, color: AppColors.primaryBlue),
                            onPressed: () => setState(() => _selectedStationId = null),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        if (_selectedStationId != null) const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _selectedStationId != null ? Icons.water_drop : Icons.dashboard_rounded,
                            color: AppColors.primaryBlue,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedStationId != null 
                                    ? (_stationData[_selectedStationId]?['name'] as String? ?? 'Station Details')
                                    : 'PureHealth',
                                style: AppTextStyles.heading3.copyWith(
                                  color: AppColors.charcoal,
                                  fontWeight: FontWeight.bold,
                                  fontSize: _selectedStationId != null ? 18 : 20,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                _selectedStationId != null
                                    ? 'MPCB Monitoring Station'
                                    : 'Maharashtra Water Monitoring',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.mediumGray,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 28),
                    
                    // Show station details OR dashboard
                    if (_selectedStationId != null) 
                      _buildStationDetailsPanel()
                    else ...[
                      // System Status Section
                      _buildSectionHeader('System Status', Icons.analytics_outlined),
                    const SizedBox(height: 16),
                    _buildStatRow(
                      'Total Stations',
                      _totalStations.toString(),
                      Icons.location_on,
                      AppColors.primaryBlue,
                    ),
                    const SizedBox(height: 12),
                    _buildStatRow(
                      'Active Alerts',
                      _activeAlerts.toString(),
                      Icons.notifications_active,
                      _activeAlerts > 0 ? AppColors.warning : AppColors.success,
                    ),
                    const SizedBox(height: 12),
                    _buildStatRow(
                      'Last Updated',
                      'Just now',
                      Icons.access_time,
                      AppColors.mediumGray,
                    ),
                    
                    const SizedBox(height: 20),
                    Divider(height: 1, color: AppColors.darkCream.withOpacity(0.4)),
                    const SizedBox(height: 20),
                    
                    // Status Distribution
                    _buildSectionHeader('Status Distribution', Icons.pie_chart_outline),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatusBadge('Safe', _safeCount, AppColors.success),
                        _buildStatusBadge('Warning', _warningCount, AppColors.warning),
                        _buildStatusBadge('Critical', _criticalCount, AppColors.error),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    Divider(height: 1, color: AppColors.darkCream.withOpacity(0.4)),
                    const SizedBox(height: 20),
                    
                    // Map Legend
                    _buildSectionHeader('Map Legend', Icons.map_outlined),
                    const SizedBox(height: 16),
                    _buildLegendItem('Safe', 'Within limits', AppColors.success, Icons.check_circle),
                    const SizedBox(height: 12),
                    _buildLegendItem('Warning', 'Approaching limits', AppColors.warning, Icons.warning),
                    const SizedBox(height: 12),
                    _buildLegendItem('Critical', 'Exceeds limits', AppColors.error, Icons.error),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Bottom center expandable control bar with more options
          Positioned(
            left: 0,
            right: 0,
            bottom: 24,
            child: Center(
              child: MouseRegion(
                onEnter: (_) => setState(() => _isBottomBarExpanded = true),
                onExit: (_) => setState(() => _isBottomBarExpanded = false),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  height: 56,
                  width: _isBottomBarExpanded ? 440 : 100,
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: AppColors.darkCream.withOpacity(0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.charcoal.withOpacity(0.12),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Expanded options
                        if (_isBottomBarExpanded) ...[
                          // Zoom Out
                          AnimatedOpacity(
                            opacity: 1.0,
                            duration: const Duration(milliseconds: 200),
                            child: _buildControlButton(
                              icon: CupertinoIcons.minus_circle_fill,
                              tooltip: 'Zoom Out',
                              onPressed: _zoomOut,
                            ),
                          ),
                          // Zoom In
                          AnimatedOpacity(
                            opacity: 1.0,
                            duration: const Duration(milliseconds: 200),
                            child: _buildControlButton(
                              icon: CupertinoIcons.plus_circle_fill,
                              tooltip: 'Zoom In',
                              onPressed: _zoomIn,
                            ),
                          ),
                          // Vertical divider
                          Container(
                            height: 32,
                            width: 1,
                            color: AppColors.darkCream.withOpacity(0.3),
                          ),
                          // Reset View
                          AnimatedOpacity(
                            opacity: 1.0,
                            duration: const Duration(milliseconds: 200),
                            child: _buildControlButton(
                              icon: CupertinoIcons.location_fill,
                              tooltip: 'Reset View',
                              onPressed: () {
                                setState(() {
                                  _currentZoom = 7.0;
                                  _mapController.move(
                                    const LatLng(19.7515, 75.7139),
                                    _currentZoom,
                                  );
                                });
                              },
                            ),
                          ),
                          // Refresh Data
                          AnimatedOpacity(
                            opacity: 1.0,
                            duration: const Duration(milliseconds: 200),
                            child: _buildControlButton(
                              icon: CupertinoIcons.refresh_circled_solid,
                              tooltip: 'Refresh Data',
                              onPressed: () {
                                _loadMaharashtraData();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Data refreshed'),
                                    duration: const Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              },
                            ),
                          ),
                          // Vertical divider
                          Container(
                            height: 32,
                            width: 1,
                            color: AppColors.darkCream.withOpacity(0.3),
                          ),
                          // Fullscreen
                          AnimatedOpacity(
                            opacity: 1.0,
                            duration: const Duration(milliseconds: 200),
                            child: _buildControlButton(
                              icon: CupertinoIcons.fullscreen,
                              tooltip: 'Toggle Fullscreen',
                              onPressed: () {},
                            ),
                          ),
                          // Settings
                          AnimatedOpacity(
                            opacity: 1.0,
                            duration: const Duration(milliseconds: 200),
                            child: _buildControlButton(
                              icon: CupertinoIcons.settings_solid,
                              tooltip: 'Map Settings',
                              onPressed: () {},
                            ),
                          ),
                        ],
                        // Collapsed state - Menu icon
                        if (!_isBottomBarExpanded)
                          CupertinoButton(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            onPressed: () =>
                                setState(() => _isBottomBarExpanded = true),
                            child: Icon(
                              CupertinoIcons.line_horizontal_3,
                              color: AppColors.primaryBlue,
                              size: 22,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: CupertinoButton(
        padding: const EdgeInsets.all(8),
        minSize: 44,
        onPressed: onPressed,
        child: Icon(
          icon,
          color: onPressed != null ? AppColors.primaryBlue : AppColors.mediumGray,
          size: 22,
        ),
      ),
    );
  }
}
