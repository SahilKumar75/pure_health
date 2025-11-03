import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pure_health/core/constants/color_constants.dart';
import 'package:pure_health/core/theme/text_styles.dart';
import 'package:pure_health/shared/widgets/custom_sidebar.dart';
import 'package:pure_health/shared/widgets/custom_map_widget.dart';
import 'package:pure_health/shared/widgets/vertical_floating_card.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:pure_health/core/data/maharashtra_water_data.dart';
import 'dart:async';
import '../../../../core/models/monitoring_location.dart';

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
  List<MonitoringLocation> _stations = [];
  Map<String, Map<String, dynamic>> _stationData = {};
  Timer? _dataUpdateTimer;
  int _totalStations = 0;
  int _activeAlerts = 0;
  int _safeCount = 0;
  int _warningCount = 0;
  int _criticalCount = 0;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _loadMaharashtraData();
    _startDataUpdates();
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
      _stations = allStations;
      _totalStations = allStations.length;
      
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
          };
        }
      }
      
      _updateStats();
    });
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
    
    _stationData.forEach((stationId, data) {
      final lat = data['latitude'] as double;
      final lon = data['longitude'] as double;
      final status = data['status'] as String;
      
      // Status colors
      Color markerColor;
      IconData markerIcon;
      
      switch (status) {
        case 'Safe':
          markerColor = AppColors.success;
          markerIcon = Icons.check_circle;
          break;
        case 'Warning':
          markerColor = AppColors.warning;
          markerIcon = Icons.warning;
          break;
        case 'Critical':
          markerColor = AppColors.error;
          markerIcon = Icons.error;
          break;
        default:
          markerColor = AppColors.charcoal;
          markerIcon = Icons.location_on;
      }
      
      markers.add(
        Marker(
          point: LatLng(lat, lon),
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () {
              _showStationDetails(stationId, data);
            },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: markerColor,
                border: Border.all(color: AppColors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: markerColor.withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                markerIcon,
                color: AppColors.white,
                size: 22,
              ),
            ),
          ),
        ),
      );
    });
    
    return markers;
  }

  void _showStationDetails(String stationId, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              Icons.location_on,
              color: AppColors.primaryBlue,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                data['name'] as String,
                style: AppTextStyles.heading3.copyWith(
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Status', data['status'] as String, 
              _getStatusColor(data['status'] as String)),
            const SizedBox(height: 12),
            _buildDetailRow('pH Level', '${(data['pH'] as double).toStringAsFixed(2)}', 
              AppColors.charcoal),
            const SizedBox(height: 12),
            _buildDetailRow('Turbidity', '${(data['turbidity'] as double).toStringAsFixed(2)} NTU', 
              AppColors.charcoal),
            const SizedBox(height: 12),
            _buildDetailRow('Dissolved Oxygen', '${(data['dissolvedOxygen'] as double).toStringAsFixed(2)} mg/L', 
              AppColors.charcoal),
            const SizedBox(height: 12),
            _buildDetailRow('Temperature', '${(data['temperature'] as double).toStringAsFixed(1)}°C', 
              AppColors.charcoal),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: AppColors.primaryBlue)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.body.copyWith(
            color: AppColors.charcoal.withOpacity(0.7),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.body.copyWith(
            color: valueColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
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

          // Logo positioned beside sidebar at top left
          Positioned(
            left: 96,
            top: 24,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(20),
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo image from assets
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.darkVanilla.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/Group 1000001052.png',
                        width: 48,
                        height: 48,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Logo text
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'PureHealth',
                        style: AppTextStyles.heading3.copyWith(
                          color: AppColors.charcoal,
                          letterSpacing: -0.6,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Maharashtra Water Quality Monitoring',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.mediumGray,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Quick Stats Overlay - Top Left (below logo)
          Positioned(
            left: 96,
            top: 140,
            child: Container(
              width: 300,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.96),
                borderRadius: BorderRadius.circular(20),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.analytics_outlined,
                        color: AppColors.primaryBlue,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'System Status',
                        style: AppTextStyles.heading4.copyWith(
                          color: AppColors.primaryBlue,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildStatRow(
                    'Total Stations',
                    _totalStations.toString(),
                    Icons.location_on,
                    AppColors.primaryBlue,
                  ),
                  const SizedBox(height: 10),
                  _buildStatRow(
                    'Active Alerts',
                    _activeAlerts.toString(),
                    Icons.notifications_active,
                    _activeAlerts > 0 ? AppColors.warning : AppColors.success,
                  ),
                  const SizedBox(height: 10),
                  Divider(height: 1, color: AppColors.darkCream.withOpacity(0.3)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatusBadge('Safe', _safeCount, AppColors.success),
                      _buildStatusBadge('Warning', _warningCount, AppColors.warning),
                      _buildStatusBadge('Critical', _criticalCount, AppColors.error),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Map Legend - Compact, Bottom Left
          Positioned(
            left: 96,
            bottom: 100,
            child: Container(
              width: 280,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.96),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.map_outlined,
                        color: AppColors.primaryBlue,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Map Legend',
                        style: AppTextStyles.heading4.copyWith(
                          color: AppColors.primaryBlue,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildLegendItem('Safe', 'Within limits', AppColors.success, Icons.check_circle),
                  const SizedBox(height: 8),
                  _buildLegendItem('Warning', 'Approaching limits', AppColors.warning, Icons.warning),
                  const SizedBox(height: 8),
                  _buildLegendItem('Critical', 'Exceeds limits', AppColors.error, Icons.error),
                ],
              ),
            ),
          ),

          // Chat floating card on the right - initially collapsed to reduce clutter
          const VerticalFloatingCard(
            width: 380,
            initiallyCollapsed: true,
            alignment: Alignment.centerRight,
          ),

          // Bottom center expandable control bar
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
                  width: _isBottomBarExpanded ? 200 : 100,
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: AppColors.darkCream.withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.charcoal.withOpacity(0.1),
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
                        // Zoom Out button
                        if (_isBottomBarExpanded)
                          AnimatedOpacity(
                            opacity: 1.0,
                            duration: const Duration(milliseconds: 200),
                            child: _buildIconButton(
                              icon: CupertinoIcons.minus_circle_fill,
                              onPressed: _zoomOut,
                            ),
                          ),
                        // Zoom In button
                        if (_isBottomBarExpanded)
                          AnimatedOpacity(
                            opacity: 1.0,
                            duration: const Duration(milliseconds: 200),
                            child: _buildIconButton(
                              icon: CupertinoIcons.plus_circle_fill,
                              onPressed: _zoomIn,
                            ),
                          ),
                        // Zoom button (always visible)
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
                              color: AppColors.darkVanilla,
                              size: 20,
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

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return CupertinoButton(
      padding: const EdgeInsets.all(8),
      minSize: 40,
      onPressed: onPressed,
      child: Icon(
        icon,
        color: onPressed != null ? AppColors.charcoal : AppColors.mediumGray,
        size: 24,
      ),
    );
  }
}
