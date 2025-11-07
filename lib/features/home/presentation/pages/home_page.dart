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
import 'package:pure_health/core/services/local_station_generator.dart';
import 'package:pure_health/core/models/station_models.dart';
import 'package:pure_health/features/home/presentation/widgets/pulsing_location_dot.dart';
import 'package:pure_health/features/home/presentation/widgets/station_details_panel.dart';
import 'package:pure_health/features/home/presentation/widgets/dashboard_panel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // UI State
  int _selectedIndex = 0;
  bool _isBottomBarExpanded = false;
  bool _isSidebarExpanded = true;
  
  // Map State
  late final MapController _mapController;
  double _currentZoom = 7.0;
  
  // Local Data Generator (no backend needed!)
  final LocalStationGenerator _stationGenerator = LocalStationGenerator();
  
  // Data State
  List<WaterQualityStation> _allStations = []; // ALL 4495 stations
  Map<String, StationData> _allStationData = {}; // Data for all stations
  List<WaterQualityStation> _visibleStations = []; // Only stations in viewport
  Map<String, StationData> _stationData = {}; // Data for visible stations
  
  // Loading State
  bool _isLoading = false;  // START as false so first load can proceed
  
  // Timers
  Timer? _dataUpdateTimer;
  Timer? _viewportLoadTimer;
  
  // Statistics
  int _totalStations = 0;
  int _activeAlerts = 0;
  int _safeCount = 0;
  int _warningCount = 0;
  int _criticalCount = 0;
  
  // Selection & Filters
  String? _selectedStationId;
  String? _selectedDistrict;
  String? _selectedType;
  List<String> _availableDistricts = [];
  
  // Location
  LatLng? _userLocation;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    
    print('[INIT] App initialized - initializing local data generator');
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        // Step 1: Initialize local station generator
        print('[GENERATOR] Generating all 4495 stations locally...');
        await _stationGenerator.initialize(totalStations: 4495);
        final totalGenerated = _stationGenerator.getTotalStationCount();
        print('[GENERATOR] ✓ All $totalGenerated stations generated locally - NO BACKEND NEEDED!');
        print('[GENERATOR] Ready to use!');
        
        // Step 2: Get user location
        await _getUserLocation();
        
        if (mounted && _userLocation != null) {
          print('[SUCCESS] Location acquired: ${_userLocation!.latitude}, ${_userLocation!.longitude}');
          print('[LOCATION] Moving map to user location');
          
          // Move map to user location
          _mapController.move(_userLocation!, 12.0); // Start at zoom 12
          _currentZoom = 12.0;
          
          // Step 3: Load nearby stations (30km radius)
          print('[LOAD] Loading stations within 30km radius');
          _loadMaharashtraData();
          
          // Step 4: Start periodic updates
          _startDataUpdates();
        } else {
          print('[WARNING] Location not available, using default center');
          // Fallback: load initial data at default location
          _loadMaharashtraData();
          _startDataUpdates();
        }
      }
    });
  }

  @override
  void dispose() {
    // Cancel timers first
    _dataUpdateTimer?.cancel();
    _viewportLoadTimer?.cancel();
    
    // Then dispose resources
    _mapController.dispose();
    
    super.dispose();
  }

  // Safe setState wrapper
  void _safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  /// Get user's current location with timeout
  Future<void> _getUserLocation() async {
    if (!mounted) return;
    
    try {
      print('[DEVICE] Checking location services...');
      
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled()
        .timeout(const Duration(seconds: 3), onTimeout: () => false);
      
      if (!serviceEnabled) {
        print('[WARNING] Location services disabled, using fallback');
        _setFallbackLocation();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        print('[PERMISSION] Requesting location permission...');
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('[ERROR] Permission denied, using fallback');
          _setFallbackLocation();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('[ERROR] Permission permanently denied, using fallback');
        _setFallbackLocation();
        return;
      }

      print('[LOCATION] Getting current position...');
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
      print('[SUCCESS] Location acquired: ${position.latitude}, ${position.longitude}');
      
      _safeSetState(() {
        _userLocation = userLoc;
      });
      
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _mapController.move(userLoc, 12.0);
        }
      });
    } catch (e) {
      print('[WARNING] Location error: $e, using fallback');
      _setFallbackLocation();
    }
  }

  void _setFallbackLocation() {
    if (!mounted) return;
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

  Future<void> _loadMaharashtraData() async {
    if (!mounted) return;
    
    if (_isLoading) {
      print('[SKIP] Already loading, skipping duplicate request');
      return;
    }
    
    print('[LOAD] Starting data load from LOCAL GENERATOR... (location: ${_userLocation != null ? "available" : "pending"})');
    print('[TIME] Current time: ${DateTime.now()}');
    
    _safeSetState(() {
      _isLoading = true;
    });
    print('[SUCCESS] _isLoading set to true');

    try {
      // Load ALL stations at once (no filtering)
      print('[LOAD] Loading ALL 4495 stations from embedded data...');
      
      final mapResponse = _stationGenerator.getMapData(
        perPage: 10000, // Request all stations
        district: null,
        type: null,
        minimal: false,
      );
      
      if (!mounted) {
        print('[WARNING] Widget unmounted, aborting data processing');
        return;
      }

      print('[DATA] Processing ${(mapResponse['stations'] as List).length} stations...');

      final stationsJson = mapResponse['stations'] as List;
      
      _allStations = [];
      _allStationData.clear();
      
      // Store ALL stations in memory
      for (final stationJson in stationsJson) {
        final stationId = stationJson['id'] as String;
        
        final station = WaterQualityStation.fromJson({
          'id': stationId,
          'name': stationJson['name'],
          'type': stationJson['type'],
          'monitoringType': 'baseline',
          'district': stationJson['district'],
          'region': 'Western',
          'latitude': stationJson['latitude'],
          'longitude': stationJson['longitude'],
          'laboratory': 'MPCB',
          'samplingFrequency': 'Monthly',
        });
        _allStations.add(station);
        
        _allStationData[stationId] = StationData(
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
        _availableDistricts = _allStations.map((s) => s.district).toSet().toList()..sort();
        _isLoading = false;
      });
      print('[SUCCESS] Loaded ALL ${_allStations.length} stations into memory!');
      print('[DONE] Now filtering by viewport...');
      
      // Filter by current viewport
      _updateVisibleStations();
    } catch (e) {
      if (!mounted) {
        print('[WARNING] Widget unmounted during error handling');
        return;
      }
      
      print('[ERROR] Error loading stations: $e');
      print('[ERROR] Error type: ${e.runtimeType}');
      print('[ERROR] Stack trace: ${StackTrace.current}');
      
      _safeSetState(() {
        _isLoading = false;
      });
      print('[DONE] _isLoading set to false after error');
      
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

  // Filter stations based on current viewport
  void _updateVisibleStations() {
    if (!mounted || _allStations.isEmpty) return;
    
    final bounds = _mapController.camera.visibleBounds;
    final zoom = _mapController.camera.zoom;
    
    print('[VIEWPORT] Filtering ${_allStations.length} stations for viewport');
    print('[VIEWPORT] Bounds: N=${bounds.north.toStringAsFixed(2)}, S=${bounds.south.toStringAsFixed(2)}, E=${bounds.east.toStringAsFixed(2)}, W=${bounds.west.toStringAsFixed(2)}');
    print('[VIEWPORT] Zoom: ${zoom.toStringAsFixed(1)}');
    
    final visibleStations = <WaterQualityStation>[];
    final visibleData = <String, StationData>{};
    
    for (final station in _allStations) {
      // Apply district filter if selected
      if (_selectedDistrict != null && station.district != _selectedDistrict) continue;
      
      // Apply type filter if selected
      if (_selectedType != null && station.type != _selectedType) continue;
      
      // Check if station is within viewport bounds
      if (station.latitude >= bounds.south &&
          station.latitude <= bounds.north &&
          station.longitude >= bounds.west &&
          station.longitude <= bounds.east) {
        visibleStations.add(station);
        if (_allStationData.containsKey(station.id)) {
          visibleData[station.id] = _allStationData[station.id]!;
        }
      }
    }
    
    _safeSetState(() {
      _visibleStations = visibleStations;
      _stationData = visibleData;
      _totalStations = visibleStations.length;
      _updateStats();
    });
    
    print('[VIEWPORT] Showing ${visibleStations.length} stations in current view');
  }

  void _onMapMove() {
    final currentZoom = _mapController.camera.zoom;
    
    // Update current zoom
    _currentZoom = currentZoom;
    
    // Debounce: Only update after map stops moving for 300ms
    _viewportLoadTimer?.cancel();
    _viewportLoadTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted && _allStations.isNotEmpty) {
        _updateVisibleStations();
      }
    });
  }

  void _updateStats() {
    int safe = 0, warning = 0, critical = 0;
    
    for (var data in _stationData.values) {
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
    }
    
    _safeSetState(() {
      _safeCount = safe;
      _warningCount = warning;
      _criticalCount = critical;
      _activeAlerts = warning + critical;
    });
  }

  void _startDataUpdates() {
    // DISABLED: No need for periodic updates since all data is local
    // Data doesn't change, it's all embedded in the frontend
    print('[INFO] Periodic updates disabled - all data is static and local');
    _dataUpdateTimer?.cancel();
    
    // Original code kept for reference but commented out:
    // _dataUpdateTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
    //   if (mounted) {
    //     _loadMaharashtraData();
    //   } else {
    //     timer.cancel();
    //   }
    // });
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

  List<Marker> _buildStationMarkers() {
    final markers = <Marker>[];
    
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
    
    for (final station in _visibleStations) {
      final data = _stationData[station.id];
      if (data == null) continue;
      
      Color markerColor;
      final statusLower = data.status.toLowerCase();
      if (statusLower == 'safe' || statusLower == 'good' || statusLower == 'excellent') {
        markerColor = const Color(0xFF10B981);
      } else if (statusLower == 'warning' || statusLower == 'moderate') {
        markerColor = const Color(0xFFF59E0B);
      } else {
        markerColor = const Color(0xFFEF4444);
      }
      
      final timestamp = DateTime.parse(data.timestamp);
      
      markers.add(
        Marker(
          point: LatLng(station.latitude, station.longitude),
          width: 20,
          height: 20,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Tooltip(
              message: '${station.name}\n${station.type}\nStatus: ${data.status}\nUpdated: ${_getTimeAgo(timestamp)}',
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
                child: Container(
                  width: 12,
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
              ),
            ),
          ),
        ),
      );
    }
    
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    // Guard against building after disposal
    if (!mounted) {
      return const SizedBox.shrink();
    }
    
    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: Scaffold(
        backgroundColor: AppColors.lightCream,
        body: Stack(
          children: [
            // Map
            CustomMapWidget(
            zoom: _currentZoom,
            sidebarWidth: 72.0,
            mapController: _mapController,
            markers: _buildStationMarkers(),
            initialCenter: const LatLng(19.7515, 75.7139),
            onMapMove: _onMapMove,
          ),

          // Sidebar
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: CustomSidebar(
              selectedIndex: _selectedIndex,
              onItemSelected: (int index) {
                if (mounted) {
                  setState(() {
                    _selectedIndex = index;
                  });
                }
              },
              onExpansionChanged: (bool isExpanded) {
                if (mounted) {
                  setState(() {
                    _isSidebarExpanded = isExpanded;
                  });
                }
              },
            ),
          ),

          // Logo
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: _isSidebarExpanded ? 224 : 96,
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

          // Right Side Panel
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
                    // Header
                    Row(
                      children: [
                        if (_selectedStationId != null) 
                          IconButton(
                            icon: Icon(Icons.arrow_back, color: AppColors.primaryBlue),
                            onPressed: () {
                              if (mounted) {
                                setState(() => _selectedStationId = null);
                              }
                            },
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
                                    ? (_allStations.firstWhere((s) => s.id == _selectedStationId, orElse: () => _allStations.first).name)
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
                    if (_selectedStationId != null && _stationData[_selectedStationId] != null) 
                      StationDetailsPanel(
                        stationId: _selectedStationId!,
                        station: _allStations.firstWhere((s) => s.id == _selectedStationId),
                        stationData: _stationData[_selectedStationId]!,
                        getTimeAgo: _getTimeAgo,
                      )
                    else
                      DashboardPanel(
                        totalStations: _totalStations,
                        activeAlerts: _activeAlerts,
                        safeCount: _safeCount,
                        warningCount: _warningCount,
                        criticalCount: _criticalCount,
                        selectedDistrict: _selectedDistrict,
                        selectedType: _selectedType,
                        availableDistricts: _availableDistricts,
                        onDistrictChanged: (value) {
                          _safeSetState(() {
                            _selectedDistrict = value;
                          });
                          _loadMaharashtraData();
                        },
                        onTypeChanged: (value) {
                          _safeSetState(() {
                            _selectedType = value;
                          });
                          _loadMaharashtraData();
                        },
                        onClearFilters: () {
                          _safeSetState(() {
                            _selectedDistrict = null;
                            _selectedType = null;
                          });
                          _loadMaharashtraData();
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom control bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 24,
            child: Center(
              child: MouseRegion(
                onEnter: (_) {
                  if (mounted) {
                    setState(() => _isBottomBarExpanded = true);
                  }
                },
                onExit: (_) {
                  if (mounted) {
                    setState(() => _isBottomBarExpanded = false);
                  }
                },
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
                        if (_isBottomBarExpanded) ...[
                          _buildControlButton(
                            icon: CupertinoIcons.minus_circle_fill,
                            tooltip: 'Zoom Out',
                            onPressed: () {
                              if (mounted) {
                                setState(() {
                                  _currentZoom = (_currentZoom - 1).clamp(1.0, 18.0);
                                  _mapController.move(_mapController.camera.center, _currentZoom);
                                });
                              }
                            },
                          ),
                          _buildControlButton(
                            icon: CupertinoIcons.plus_circle_fill,
                            tooltip: 'Zoom In',
                            onPressed: () {
                              if (mounted) {
                                setState(() {
                                  _currentZoom = (_currentZoom + 1).clamp(1.0, 18.0);
                                  _mapController.move(_mapController.camera.center, _currentZoom);
                                });
                              }
                            },
                          ),
                          Container(
                            height: 32,
                            width: 1,
                            color: AppColors.darkCream.withOpacity(0.3),
                          ),
                          _buildControlButton(
                            icon: CupertinoIcons.location_fill,
                            tooltip: 'My Location',
                            onPressed: () {
                              if (mounted) {
                                if (_userLocation != null) {
                                  print('[LOCATION] Centering map on user location');
                                  setState(() {
                                    _currentZoom = 12.0;
                                    _mapController.move(_userLocation!, _currentZoom);
                                  });
                                } else {
                                  print('[WARNING] User location not available');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Location not available'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                          _buildControlButton(
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
                          Container(
                            height: 32,
                            width: 1,
                            color: AppColors.darkCream.withOpacity(0.3),
                          ),
                          _buildControlButton(
                            icon: CupertinoIcons.fullscreen,
                            tooltip: 'Toggle Fullscreen',
                            onPressed: () {},
                          ),
                          _buildControlButton(
                            icon: CupertinoIcons.settings_solid,
                            tooltip: 'Map Settings',
                            onPressed: () {},
                          ),
                        ],
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
