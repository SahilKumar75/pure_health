import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pure_health/core/constants/color_constants.dart';
import 'package:pure_health/core/theme/text_styles.dart';
import 'package:pure_health/shared/widgets/custom_sidebar.dart';
import 'package:pure_health/shared/widgets/custom_map_widget.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:pure_health/core/models/station_models.dart';

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
  bool _isSidebarExpanded = true; // Track sidebar expansion state (default expanded)
  late final MapController _mapController;
  double _currentZoom = 7.0; // Lower zoom to show all of Maharashtra
  
  // Real-time data
  List<WaterQualityStation> _stations = [];
  Map<String, StationData> _stationData = {};
  Timer? _dataUpdateTimer;
  int _totalStations = 0;
  int _activeAlerts = 0;
  int _safeCount = 0;
  int _warningCount = 0;
  int _criticalCount = 0;
  String? _selectedStationId;
  LatLng? _userLocation; // User's current location
  bool _isLoading = true;
  
  // Smart loading state
  Set<String> _loadedStationIds = {}; // Track which stations are already loaded
  bool _isLoadingMore = false; // Track if we're loading more stations
  Timer? _viewportLoadTimer; // Debounce viewport changes
  
  // Filters
  String? _selectedDistrict;
  String? _selectedType;
  List<String> _availableDistricts = [];

  // Safe setState wrapper
  void _safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    
    // Delay initial data load to ensure widget tree is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Load data immediately - don't wait for location
        _loadMaharashtraData();
        _startDataUpdates();
        
        // Get location in parallel (will reload nearby stations when ready)
        _getUserLocation().then((_) {
          // Reload with nearby stations once location is available
          if (mounted && _userLocation != null) {
            print('📍 Location acquired, reloading with nearby stations');
            _loadMaharashtraData();
          }
        });
      }
    });
  }

  /// Get user's current location
  Future<void> _getUserLocation() async {
    if (!mounted) return;
    
    try {
      print('📱 Checking location services...');
      
      // Check if location services are enabled with timeout
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled()
        .timeout(const Duration(seconds: 3), onTimeout: () => false);
      
      if (!serviceEnabled) {
        print('⚠️ Location services disabled, using fallback');
        if (!mounted) return;
        // Location services are not enabled, use fallback
        const fallbackLoc = LatLng(18.5204, 73.8567); // Pune, Maharashtra
        setState(() {
          _userLocation = fallbackLoc;
        });
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _mapController.move(fallbackLoc, 10.0);
          }
        });
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        print('🔐 Requesting location permission...');
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('❌ Permission denied, using fallback');
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
        print('❌ Permission permanently denied, using fallback');
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

      print('📍 Getting current position...');
      // Get actual current position with timeout
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 100,
        ),
      ).timeout(const Duration(seconds: 5), onTimeout: () {
        throw TimeoutException('Location timeout');
      });
      
      if (!mounted) return;
      
      final userLoc = LatLng(position.latitude, position.longitude);
      
      print('✅ Location acquired: ${position.latitude}, ${position.longitude}');
      
      _safeSetState(() {
        _userLocation = userLoc;
      });
      
      // Center map on user's actual location
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _mapController.move(userLoc, 12.0); // Zoom level 12 for closer view
        }
      });
    } catch (e) {
      print('⚠️ Location error: $e, using fallback');
      if (!mounted) return;
      
      // Error getting location, use fallback
      const fallbackLoc = LatLng(18.5204, 73.8567); // Pune, Maharashtra
      _safeSetState(() {
        _userLocation = fallbackLoc;
      });
      
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _mapController.move(fallbackLoc, 10.0);
        }
      });
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    _dataUpdateTimer?.cancel();
    _viewportLoadTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadMaharashtraData() async {
    if (!mounted) return;
    
    // Prevent multiple simultaneous loads
    if (_isLoading) {
      print('⏸️ Already loading, skipping duplicate request');
      return;
    }
    
    print('🔄 Starting data load... (location: ${_userLocation != null ? "available" : "pending"})');
    
    _safeSetState(() {
      _isLoading = true;
    });

    try {
      // TODO: This file uses deprecated API service - needs to be updated or removed
      // Commented out API calls since WaterQualityApiService no longer exists
      // Map<String, dynamic> mapResponse;
      
      // Smart loading: Use nearby stations if user location available, otherwise load minimal set
      // if (_userLocation != null) {
        print('📍 Loading nearby stations (30km radius)...');
        // Load only stations within 30km radius of user (optimized for performance)
        mapResponse = await _apiService.getNearbyStations(
          latitude: _userLocation!.latitude,
          longitude: _userLocation!.longitude,
          radiusKm: 30,
          limit: 200, // Max 200 nearby stations
          district: _selectedDistrict,
          type: _selectedType,
        );
        
        print('✅ Loaded ${(mapResponse['stations'] as List).length} nearby stations (30km radius)');
      } else {
        print('🗺️ Loading initial stations (no location yet)...');
        // Fallback: Load minimal stations for instant initial view
        mapResponse = await _apiService.getMapData(
          perPage: 50, // Start with just 50 stations for instant display
          district: _selectedDistrict,
          type: _selectedType,
          minimal: false,
        );
        
        print('✅ Loaded ${(mapResponse['stations'] as List).length} initial stations');
      }
      
      if (!mounted) return;

      // Parse stations from response
      final stationsJson = mapResponse['stations'] as List;
      
      // Clear previous data and loaded IDs on fresh load
      if (!mounted) return;
      
      _stations = [];
      _stationData.clear();
      _loadedStationIds.clear();
      
      for (final stationJson in stationsJson) {
        final stationId = stationJson['id'] as String;
        
        // Track loaded station
        _loadedStationIds.add(stationId);
        
        // Parse station
        final station = WaterQualityStation.fromJson({
          'id': stationId,
          'name': stationJson['name'],
          'type': stationJson['type'],
          'monitoringType': 'baseline',
          'district': 'Maharashtra', // Default since not in minimal response
          'region': 'Western',
          'latitude': stationJson['latitude'],
          'longitude': stationJson['longitude'],
          'laboratory': 'MPCB',
          'samplingFrequency': 'Monthly',
        });
        _stations.add(station);
        
        // Create basic StationData from the minimal response
        _stationData[stationId] = StationData(
          stationId: stationId,
          timestamp: DateTime.now().toIso8601String(),
          wqi: (stationJson['wqi'] ?? 50.0).toDouble(),
          status: stationJson['status'] ?? 'Unknown',
          waterQualityClass: stationJson['waterClass'] ?? 'Unknown',
          parameters: {
            'pH': 7.0,
            'DO': 6.0,
            'BOD': 3.0,
            'temperature': 25.0,
          },
          alerts: stationJson['hasAlerts'] == true ? [
            {'severity': 'medium', 'message': '${stationJson['alertCount'] ?? 0} active alerts'}
          ] : [],
        );
      }
      
      _safeSetState(() {
        _totalStations = _stations.length;
        _lastDataFetch = DateTime.now();

        // Get unique districts for filter
        _availableDistricts = _stations
            .map((s) => s.district)
            .toSet()
            .toList()
          ..sort();
        
        _updateStats();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      _safeSetState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load stations: ${e.toString()}';
      });
      
      // Show error snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading stations: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _loadMaharashtraData,
            ),
          ),
        );
      }
    }
  }

  /// Load stations dynamically when user pans/zooms (progressive loading)
  Future<void> _loadViewportStations() async {
    if (!mounted || _isLoadingMore) return;
    
    try {
      // Get current map bounds
      final bounds = _mapController.camera.visibleBounds;
      final zoom = _mapController.camera.zoom;
      
      print('🔍 Viewport loading triggered (zoom: ${zoom.toStringAsFixed(1)})');
      
      _safeSetState(() {
        _isLoadingMore = true;
      });

      // Fetch stations in current viewport
      print('🌍 Fetching viewport stations...');
      final viewportResponse = await _apiService.getViewportStations(
        north: bounds.north,
        south: bounds.south,
        east: bounds.east,
        west: bounds.west,
        zoom: zoom.toInt(),
      );

      if (!mounted) return;

      // Parse new stations
      final newStationsJson = viewportResponse['stations'] as List;
      
      List<WaterQualityStation> newStations = [];
      Map<String, StationData> newStationData = {};
      
      for (final stationJson in newStationsJson) {
        final stationId = stationJson['id'] as String;
        
        // Skip if already loaded
        if (_loadedStationIds.contains(stationId)) {
          continue;
        }
        
        // Parse new station
        final station = WaterQualityStation.fromJson({
          'id': stationId,
          'name': stationJson['name'],
          'type': stationJson['type'],
          'monitoringType': 'baseline',
          'district': 'Maharashtra',
          'region': 'Western',
          'latitude': stationJson['latitude'],
          'longitude': stationJson['longitude'],
          'laboratory': 'MPCB',
          'samplingFrequency': 'Monthly',
        });
        
        newStations.add(station);
        _loadedStationIds.add(stationId);
        
        // Create station data
        final data = StationData(
          stationId: stationId,
          timestamp: DateTime.now().toIso8601String(),
          wqi: (stationJson['wqi'] ?? 75.0).toDouble(),
          status: stationJson['status'] ?? 'Safe',
          waterQualityClass: stationJson['waterClass'] ?? 'Class-II',
          parameters: {},
          alerts: [],
        );
        
        newStationData[stationId] = data;
      }
      
      if (!mounted) return;
      
      // Add new stations to existing ones
      _safeSetState(() {
        _stations.addAll(newStations);
        _stationData.addAll(newStationData);
        _totalStations = _stations.length;
        _updateStats();
        _isLoadingMore = false;
      });
      
      if (newStations.isNotEmpty) {
        print('🗺️ Loaded ${newStations.length} new stations in viewport (Total: $_totalStations)');
      }
      
    } catch (e) {
      print('⚠️ Error loading viewport stations: $e');
      if (mounted) {
        _safeSetState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  /// Handle map move events (debounced to avoid too many API calls)
  void _onMapMove() {
    // Don't load if already loading or still loading initial data
    if (_isLoading || _isLoadingMore) return;
    
    // Only load on significant zoom (avoid loading on every small pan)
    final currentZoom = _mapController.camera.zoom;
    if (currentZoom < 8.0) return; // Don't load when zoomed out too far
    
    // Cancel previous timer
    _viewportLoadTimer?.cancel();
    
    // Set new timer - load after user stops moving for 2 seconds (increased from 1s)
    _viewportLoadTimer = Timer(const Duration(milliseconds: 2000), () {
      if (mounted && !_isLoading && !_isLoadingMore) {
        _loadViewportStations();
      }
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
      switch (data.status.toLowerCase()) {
        case 'safe':
        case 'good':
          safe++;
          break;
        case 'warning':
        case 'moderate':
          warning++;
          break;
        case 'critical':
        case 'poor':
          critical++;
          break;
      }
    });
    
    _safeSetState(() {
      _safeCount = safe;
      _warningCount = warning;
      _criticalCount = critical;
      _activeAlerts = warning + critical;
    });
  }

  void _startDataUpdates() {
    _dataUpdateTimer?.cancel(); // Cancel any existing timer
    _dataUpdateTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        _loadMaharashtraData();
      } else {
        timer.cancel(); // Cancel if widget is disposed
      }
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
    for (final station in _stations) {
      final data = _stationData[station.id];
      if (data == null) continue; // Skip if no data available
      
      final lat = station.latitude;
      final lon = station.longitude;
      final status = data.status;
      final timestamp = DateTime.parse(data.timestamp);
      final name = station.name;
      final stationType = station.type;
      
      // Status colors following MPCB standards
      Color markerColor;
      
      final statusLower = status.toLowerCase();
      if (statusLower == 'safe' || statusLower == 'good' || statusLower == 'excellent') {
        markerColor = const Color(0xFF10B981); // Green - Safe
      } else if (statusLower == 'warning' || statusLower == 'moderate') {
        markerColor = const Color(0xFFF59E0B); // Amber - Caution
      } else {
        markerColor = const Color(0xFFEF4444); // Red - Alert
      }
      
      markers.add(
        Marker(
          point: LatLng(lat, lon),
          width: 20,  // Much smaller - was 56
          height: 20, // Much smaller - was 56
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
                  _safeSetState(() {
                    _selectedStationId = station.id;
                  });
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Main station marker - simple dot
                    Container(
                      width: 12,  // Smaller marker
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: markerColor,
                        border: Border.all(color: Colors.white, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: markerColor.withOpacity(0.4),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
    
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
    
    final status = stationData.status;
    // Get parameters from the data
    final pH = stationData.parameters['pH'] as double?;
    final turbidity = stationData.parameters['turbidity'] as double?;
    final dissolvedOxygen = stationData.parameters['dissolvedOxygen'] as double?;
    final temperature = stationData.parameters['temperature'] as double?;
    final timestamp = DateTime.parse(stationData.timestamp);
    
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
                _buildReadingCard('pH Level', pH?.toStringAsFixed(2) ?? 'N/A', 'Neutral: 6.5-8.5', Icons.water_drop),
                const SizedBox(height: 12),
                _buildReadingCard('Turbidity', turbidity != null ? '${turbidity.toStringAsFixed(2)} NTU' : 'N/A', 'Max: 5 NTU', Icons.blur_on),
                const SizedBox(height: 12),
                _buildReadingCard('Dissolved Oxygen', dissolvedOxygen != null ? '${dissolvedOxygen.toStringAsFixed(2)} mg/L' : 'N/A', 'Min: 4 mg/L', Icons.air),
                const SizedBox(height: 12),
                _buildReadingCard('Temperature', temperature != null ? '${temperature.toStringAsFixed(1)}°C' : 'N/A', 'Normal: 20-30°C', Icons.thermostat),
                
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
            onMapMove: _onMapMove, // Progressive loading on pan/zoom
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
              onExpansionChanged: (bool isExpanded) {
                setState(() {
                  _isSidebarExpanded = isExpanded;
                });
              },
            ),
          ),

          // Compact Logo positioned beside sidebar at top left
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: _isSidebarExpanded ? 224 : 96, // 200px (expanded) or 72px (collapsed) + 24px margin
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
                                    ? (_stations.firstWhere((s) => s.id == _selectedStationId, orElse: () => _stations.first).name)
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
                      // Filters Section
                      _buildSectionHeader('Filters', Icons.filter_list),
                      const SizedBox(height: 16),
                      
                      // District filter
                      Focus(
                        skipTraversal: true,
                        canRequestFocus: false,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.lightCream,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.darkCream.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String?>(
                              isExpanded: true,
                              value: _selectedDistrict,
                              hint: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  'All Districts',
                                  style: AppTextStyles.body.copyWith(
                                    color: AppColors.mediumGray,
                                  ),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              borderRadius: BorderRadius.circular(12),
                              items: [
                                DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text('All Districts', style: AppTextStyles.body),
                                ),
                                ..._availableDistricts.map((district) => DropdownMenuItem<String?>(
                                  value: district,
                                  child: Text(district, style: AppTextStyles.body),
                                )),
                              ],
                              onChanged: (value) {
                                _safeSetState(() {
                                  _selectedDistrict = value;
                                });
                                _loadMaharashtraData();
                              },
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Type filter
                      Focus(
                        skipTraversal: true,
                        canRequestFocus: false,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.lightCream,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.darkCream.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String?>(
                              isExpanded: true,
                              value: _selectedType,
                              hint: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  'All Types',
                                  style: AppTextStyles.body.copyWith(
                                    color: AppColors.mediumGray,
                                  ),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              borderRadius: BorderRadius.circular(12),
                              items: [
                                DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text('All Types', style: AppTextStyles.body),
                                ),
                                DropdownMenuItem<String?>(
                                  value: 'Surface Water',
                                  child: Text('Surface Water', style: AppTextStyles.body),
                                ),
                                DropdownMenuItem<String?>(
                                  value: 'Groundwater',
                                  child: Text('Groundwater', style: AppTextStyles.body),
                                ),
                              ],
                              onChanged: (value) {
                                _safeSetState(() {
                                  _selectedType = value;
                                });
                                _loadMaharashtraData();
                              },
                            ),
                          ),
                        ),
                      ),
                      
                      // Clear filters button
                      if (_selectedDistrict != null || _selectedType != null) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _safeSetState(() {
                                _selectedDistrict = null;
                                _selectedType = null;
                              });
                              _loadMaharashtraData();
                            },
                            icon: const Icon(Icons.clear, size: 18),
                            label: const Text('Clear Filters'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.lightCream,
                              foregroundColor: AppColors.primaryBlue,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: AppColors.primaryBlue.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 20),
                      Divider(height: 1, color: AppColors.darkCream.withOpacity(0.4)),
                      const SizedBox(height: 20),
                      
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
          
          // Loading overlay
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          'Loading stations...',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.charcoal,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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
