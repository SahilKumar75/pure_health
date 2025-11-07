import 'package:flutter/material.dart';
import 'dart:async';
import '../../../../core/services/live_water_station_service.dart';

/// Live Water Station Monitoring Page
/// Displays real-time water quality data from Maharashtra monitoring stations
class LiveMonitoringPage extends StatefulWidget {
  const LiveMonitoringPage({super.key});

  @override
  State<LiveMonitoringPage> createState() => _LiveMonitoringPageState();
}

class _LiveMonitoringPageState extends State<LiveMonitoringPage> {
  final LiveWaterStationService _service = LiveWaterStationService();
  late StreamSubscription _subscription;
  Map<String, Map<String, dynamic>> _stationData = {};
  String _selectedDistrict = 'All';
  String _selectedStatus = 'All';
  DateTime? _lastUpdate;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  void _initializeService() {
    // Start live simulation with 15 minute intervals
    _service.startLiveSimulation(interval: const Duration(minutes: 15));
    
    // Initialize data for all stations
    for (var station in _service.getAllStations()) {
      final data = _service.getStationData(station['id']);
      if (data != null) {
        _stationData[station['id']] = data;
      }
    }
    
    // Listen to live updates
    _subscription = _service.getLiveUpdates().listen((data) {
      setState(() {
        _stationData[data['stationId']] = data;
        _lastUpdate = DateTime.now();
      });
    });
    
    setState(() {
      _lastUpdate = DateTime.now();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    _service.stopLiveSimulation();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredStations {
    var stations = _service.getAllStations();
    
    if (_selectedDistrict != 'All') {
      stations = stations.where((s) => s['district'] == _selectedDistrict).toList();
    }
    
    if (_selectedStatus != 'All') {
      stations = stations.where((s) {
        final data = _stationData[s['id']];
        return data != null && data['status'] == _selectedStatus;
      }).toList();
    }
    
    return stations;
  }

  Set<String> get _districts {
    return {'All', ..._service.getAllStations().map((s) => s['district'] as String)};
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Excellent':
        return const Color(0xFF10B981);
      case 'Good':
        return const Color(0xFF3B82F6);
      case 'Fair':
        return const Color(0xFFF59E0B);
      case 'Poor':
        return const Color(0xFFEF4444);
      case 'Very Poor':
        return const Color(0xFF991B1B);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildFilters(),
            _buildStationList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.water_drop,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live Water Quality Monitoring',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Maharashtra Water Monitoring Network',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatCard(
                'Active Stations',
                '${_service.getAllStations().length}',
                Icons.cell_tower,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                'Last Update',
                _lastUpdate != null
                    ? '${_lastUpdate!.hour}:${_lastUpdate!.minute.toString().padLeft(2, '0')}'
                    : '--:--',
                Icons.update,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                'Update Interval',
                '15 min',
                Icons.timer,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildDropdown(
              'District',
              _selectedDistrict,
              _districts.toList()..sort(),
              (value) => setState(() => _selectedDistrict = value!),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildDropdown(
              'Status',
              _selectedStatus,
              ['All', 'Excellent', 'Good', 'Fair', 'Poor', 'Very Poor'],
              (value) => setState(() => _selectedStatus = value!),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    void Function(String?) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(label),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(
                item,
                style: const TextStyle(fontSize: 14),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildStationList() {
    final stations = _filteredStations;
    
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: stations.length,
        itemBuilder: (context, index) {
          final station = stations[index];
          final data = _stationData[station['id']];
          
          return _buildStationCard(station, data);
        },
      ),
    );
  }

  Widget _buildStationCard(Map<String, dynamic> station, Map<String, dynamic>? data) {
    if (data == null) {
      return const SizedBox.shrink();
    }

    final wqi = data['wqi'] as double;
    final status = data['status'] as String;
    final parameters = data['parameters'] as Map<String, dynamic>;
    final alerts = data['alerts'] as List;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Station Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getStatusColor(status).withOpacity(0.1),
                  _getStatusColor(status).withOpacity(0.05),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getStatusColor(status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.water,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['stationName'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${station['waterSource']} • ${station['district']}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      wqi.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(status),
                      ),
                    ),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(status),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Alerts
          if (alerts.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFFFEF2F2),
                border: Border(
                  bottom: BorderSide(color: Color(0xFFFECACA)),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFEF4444),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${alerts.length} Alert${alerts.length > 1 ? 's' : ''}: ${alerts.first}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFEF4444),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Parameters Grid
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Water Quality Parameters',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    _buildParameterCard(
                      'pH',
                      parameters['pH'].toString(),
                      '',
                      parameters['pH'] >= 6.5 && parameters['pH'] <= 8.5,
                    ),
                    _buildParameterCard(
                      'Turbidity',
                      parameters['turbidity'].toString(),
                      'NTU',
                      parameters['turbidity'] < 10,
                    ),
                    _buildParameterCard(
                      'DO',
                      parameters['dissolvedOxygen'].toString(),
                      'mg/L',
                      parameters['dissolvedOxygen'] > 5,
                    ),
                    _buildParameterCard(
                      'Temp',
                      parameters['temperature'].toString(),
                      '°C',
                      true,
                    ),
                    _buildParameterCard(
                      'TDS',
                      parameters['tds'].toString(),
                      'mg/L',
                      parameters['tds'] < 500,
                    ),
                    _buildParameterCard(
                      'BOD',
                      parameters['bod'].toString(),
                      'mg/L',
                      parameters['bod'] < 3,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Station Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  '${station['latitude']}, ${station['longitude']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  _formatTimestamp(data['timestamp']),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParameterCard(String label, String value, String unit, bool isNormal) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isNormal ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isNormal ? const Color(0xFFBBF7D0) : const Color(0xFFFECACA),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isNormal ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 2),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    final dt = DateTime.parse(timestamp);
    final now = DateTime.now();
    final diff = now.difference(dt);
    
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${dt.day}/${dt.month} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
