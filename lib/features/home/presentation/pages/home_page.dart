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
import 'package:pure_health/features/home/presentation/widgets/station_details_panel.dart';
import 'package:pure_health/features/home/presentation/widgets/dashboard_panel.dart';
import 'package:pure_health/features/home/presentation/widgets/filter_chips_widget.dart';
import 'package:pure_health/features/home/presentation/widgets/marker_builder.dart';
import 'package:pure_health/features/home/presentation/widgets/map_control_bar.dart';
import 'package:pure_health/features/home/data/simulation/data_simulation_manager.dart';

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
  bool _isLoading = false;
  
  // Timers
  Timer? _viewportLoadTimer;
  late final DataSimulationManager _simulationManager;
  
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
    
    // Initialize simulation manager
    _simulationManager = DataSimulationManager(
      onDataUpdated: (updatedData) {
        if (mounted) {
          setState(() {
            _allStationData = updatedData;
            // Update visible station data
            final visibleData = <String, StationData>{};
            for (final station in _visibleStations) {
              if (updatedData.containsKey(station.id)) {
                visibleData[station.id] = updatedData[station.id]!;
              }
            }
            _stationData = visibleData;
            _updateStats();
          });
        }
      },
    );
    
    print('[INIT] App initialized - initializing local data generator');
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        // Step 1: Initialize local station generator
        print('[GENERATOR] Generating all 4495 stations locally...');
        await _stationGenerator.initialize(totalStations: 4495);
        final totalGenerated = _stationGenerator.getTotalStationCount();
        print('[GENERATOR] ✓ All $totalGenerated stations generated locally - NO BACKEND NEEDED!');
        
        // Step 2: Get user location
        await _getUserLocation();
        
        if (mounted && _userLocation != null) {
          print('[SUCCESS] Location acquired: ${_userLocation!.latitude}, ${_userLocation!.longitude}');
          _mapController.move(_userLocation!, 12.0);
          _currentZoom = 12.0;
          
          // Step 3: Load all stations
          _loadAllStations();
        } else {
          print('[WARNING] Location not available, using default center');
          _loadAllStations();
        }
      }
    });
  }

  @override
  void dispose() {
    _viewportLoadTimer?.cancel();
    _simulationManager.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

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
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _setFallbackLocation();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _setFallbackLocation();
        return;
      }

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
      _safeSetState(() {
        _userLocation = userLoc;
      });
      
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _mapController.move(userLoc, 12.0);
        }
      });
    } catch (e) {
      print('[WARNING] Location error: $e');
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

  Future<void> _loadAllStations() async {
    if (!mounted || _isLoading) return;
    
    print('[LOAD] Loading ALL stations from local generator...');
    
    _safeSetState(() {
      _isLoading = true;
    });

    try {
      final mapResponse = _stationGenerator.getMapData(
        perPage: 10000,
        district: null,
        type: null,
        minimal: false,
      );
      
      if (!mounted) return;

      final stationsJson = mapResponse['stations'] as List;
      
      _allStations = [];
      _allStationData.clear();
      
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
            'pH': {'value': 7.0, 'unit': 'pH'},
            'DO': {'value': 6.0, 'unit': 'mg/L'},
            'BOD': {'value': 3.0, 'unit': 'mg/L'},
            'temperature': {'value': 25.0, 'unit': '°C'},
            'turbidity': {'value': 2.5, 'unit': 'NTU'},
            'dissolvedOxygen': {'value': 6.0, 'unit': 'mg/L'},
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
      
      print('[SUCCESS] Loaded ${_allStations.length} stations!');
      
      _updateVisibleStations();
      
      // Start live simulation
      _simulationManager.startSimulation(
        interval: const Duration(minutes: 5),
        visibleStations: _visibleStations,
        allStationData: _allStationData,
      );
    } catch (e) {
      print('[ERROR] Error loading stations: $e');
      _safeSetState(() {
        _isLoading = false;
      });
    }
  }

  void _updateVisibleStations() {
    if (!mounted || _allStations.isEmpty) return;
    
    final bounds = _mapController.camera.visibleBounds;
    
    print('[VIEWPORT] Filtering ${_allStations.length} stations');
    
    final visibleStations = <WaterQualityStation>[];
    final visibleData = <String, StationData>{};
    
    for (final station in _allStations) {
      if (_selectedDistrict != null && station.district != _selectedDistrict) continue;
      if (_selectedType != null && station.type != _selectedType) continue;
      
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
    
    print('[VIEWPORT] Showing ${visibleStations.length} stations');
  }

  void _onMapMove() {
    _currentZoom = _mapController.camera.zoom;
    
    _viewportLoadTimer?.cancel();
    _viewportLoadTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted && _allStations.isNotEmpty) {
        _updateVisibleStations();
      }
    });
  }

  void _updateStats() {
    int safe = 0, warning = 0, critical = 0, alerts = 0;
    
    for (var data in _stationData.values) {
      alerts += data.alerts.length;
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
        case 'very_poor':
          critical++;
          break;
      }
    }
    
    _safeCount = safe;
    _warningCount = warning;
    _criticalCount = critical;
    _activeAlerts = alerts;
  }

  String _getTimeAgo(DateTime dateTime) {
    try {
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inSeconds < 60) return 'Just now';
      if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
      if (difference.inHours < 24) return '${difference.inHours}h ago';
      if (difference.inDays < 7) return '${difference.inDays}d ago';
      return '${(difference.inDays / 7).floor()}w ago';
    } catch (e) {
      return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
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
              markers: MarkerBuilder.buildStationMarkers(
                stations: _visibleStations,
                stationDataMap: _stationData,
                selectedStationId: _selectedStationId,
                userLocation: _userLocation,
                onStationTap: (station) {
                  _safeSetState(() {
                    _selectedStationId = station.id;
                  });
                },
              ),
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
                      color: AppColors.charcoal.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/Group 1000001052.png',
                  width: 40,
                  height: 40,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // Right Side Panel
            Positioned(
              right: 24,
              top: 24,
              bottom: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Filter Chips (Outside Card)
                  if (_selectedStationId == null)
                    FilterChipsWidget(
                      selectedDistrict: _selectedDistrict,
                      selectedType: _selectedType,
                      availableDistricts: _availableDistricts,
                      onDistrictChanged: (value) {
                        _safeSetState(() => _selectedDistrict = value);
                        _updateVisibleStations();
                      },
                      onTypeChanged: (value) {
                        _safeSetState(() => _selectedType = value);
                        _updateVisibleStations();
                      },
                    ),
                  if (_selectedStationId == null) const SizedBox(height: 12),
                  
                  // Floating Card
                  Expanded(
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
                                    icon: const Icon(Icons.arrow_back, color: AppColors.primaryBlue),
                                    onPressed: () {
                                      _safeSetState(() => _selectedStationId = null);
                                    },
                                  ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _selectedStationId != null
                                            ? _allStations.firstWhere((s) => s.id == _selectedStationId).name
                                            : 'Live Dashboard',
                                        style: AppTextStyles.heading3.copyWith(
                                          color: AppColors.charcoal,
                                          fontWeight: FontWeight.bold,
                                          fontSize: _selectedStationId != null ? 17 : 19,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        _selectedStationId != null
                                            ? 'MPCB Monitoring Station'
                                            : 'Real-time Monitoring',
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
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom control bar
            MapControlBar(
              isExpanded: _isBottomBarExpanded,
              currentZoom: _currentZoom,
              mapController: _mapController,
              userLocation: _userLocation,
              onRefresh: _loadAllStations,
              onExpansionChanged: (isExpanded) {
                if (mounted) {
                  setState(() {
                    _isBottomBarExpanded = isExpanded;
                  });
                }
              },
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
}
