import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pure_health/core/models/monitoring_location.dart';
import 'package:pure_health/core/constants/color_constants.dart';
import 'package:pure_health/core/theme/text_styles.dart';
import 'package:pure_health/shared/widgets/water_quality_map.dart';

class LocationsPage extends StatefulWidget {
  const LocationsPage({super.key});

  @override
  State<LocationsPage> createState() => _LocationsPageState();
}

class _LocationsPageState extends State<LocationsPage> {
  MonitoringLocation? _selectedLocation;
  String _selectedState = 'All States';
  String _selectedDistrict = 'All Districts';
  String _selectedType = 'All Types';
  bool _showMapView = true;

  final List<MonitoringLocation> _locations = MonitoringLocationData.indianLocations;

  // Mock status data - in real app, this comes from backend
  final Map<String, String> _locationStatus = {
    'DL-YMN-001': 'Warning',
    'DL-YMN-002': 'Critical',
    'DL-YMN-003': 'Safe',
    'MH-MUM-001': 'Safe',
    'MH-MUM-002': 'Safe',
    'KA-BLR-001': 'Warning',
    'KA-BLR-002': 'Safe',
    'WB-KOL-001': 'Safe',
    'WB-KOL-002': 'Safe',
    'TN-CHE-001': 'Safe',
    'TN-CHE-002': 'Safe',
    'TS-HYD-001': 'Warning',
    'MH-PUN-001': 'Safe',
    'GJ-AMD-001': 'Safe',
    'RJ-JAI-001': 'Safe',
  };

  List<MonitoringLocation> get _filteredLocations {
    return _locations.where((loc) {
      if (_selectedState != 'All States' && loc.state != _selectedState) return false;
      if (_selectedDistrict != 'All Districts' && loc.district != _selectedDistrict) return false;
      if (_selectedType != 'All Types' && loc.stationType != _selectedType) return false;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildFilterBar(),
            Expanded(
              child: _showMapView ? _buildMapView() : _buildListView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: AppColors.primaryBlue,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Monitoring Stations',
                    style: AppTextStyles.heading2.copyWith(
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${_filteredLocations.length} active stations across India',
                style: AppTextStyles.body.copyWith(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _showMapView = !_showMapView;
                  });
                },
                icon: Icon(
                  _showMapView ? Icons.list : Icons.map_outlined,
                  color: AppColors.primaryBlue,
                ),
                tooltip: _showMapView ? 'List View' : 'Map View',
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {
                  // Add new location
                },
                icon: const Icon(Icons.add_location_alt),
                label: const Text('Add Station'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    final states = ['All States', ...MonitoringLocationData.getAllStates()];
    final districts = ['All Districts', ...MonitoringLocationData.getAllDistricts()];
    final types = ['All Types', ...MonitoringLocationData.getAllStationTypes()];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildDropdown(
              'State',
              _selectedState,
              states,
              (value) => setState(() {
                _selectedState = value!;
                _selectedDistrict = 'All Districts';
              }),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildDropdown(
              'District',
              _selectedDistrict,
              districts,
              (value) => setState(() => _selectedDistrict = value!),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildDropdown(
              'Type',
              _selectedType,
              types,
              (value) => setState(() => _selectedType = value!),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedState = 'All States';
                _selectedDistrict = 'All Districts';
                _selectedType = 'All Types';
                _selectedLocation = null;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[100],
              foregroundColor: Colors.grey[700],
              elevation: 0,
            ),
            child: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(
                item,
                style: AppTextStyles.body.copyWith(fontSize: 13),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildMapView() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: WaterQualityMap(
              locations: _filteredLocations,
              selectedLocation: _selectedLocation,
              locationStatus: _locationStatus,
              onLocationTap: (location) {
                setState(() {
                  _selectedLocation = location;
                });
              },
            ),
          ),
        ),
        Container(
          width: 400,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              left: BorderSide(color: Colors.grey[200]!),
            ),
          ),
          child: _selectedLocation != null
              ? _buildLocationDetails(_selectedLocation!)
              : _buildNoSelectionPlaceholder(),
        ),
      ],
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _filteredLocations.length,
      itemBuilder: (context, index) {
        final location = _filteredLocations[index];
        final status = _locationStatus[location.id] ?? 'Safe';
        
        return _buildLocationCard(location, status);
      },
    );
  }

  Widget _buildLocationCard(MonitoringLocation location, String status) {
    Color statusColor;
    switch (status) {
      case 'Critical':
        statusColor = AppColors.error;
        break;
      case 'Warning':
        statusColor = AppColors.warning;
        break;
      default:
        statusColor = AppColors.success;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedLocation = location;
            _showMapView = true;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getStationIcon(location.stationType),
                  color: statusColor,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location.displayName,
                      style: AppTextStyles.heading4.copyWith(
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${location.district}, ${location.state}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      location.waterBody,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationDetails(MonitoringLocation location) {
    final status = _locationStatus[location.id] ?? 'Safe';
    Color statusColor;
    switch (status) {
      case 'Critical':
        statusColor = AppColors.error;
        break;
      case 'Warning':
        statusColor = AppColors.warning;
        break;
      default:
        statusColor = AppColors.success;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  location.displayName,
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() => _selectedLocation = null);
                },
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: statusColor.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.water_drop, color: statusColor, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Status: $status',
                  style: AppTextStyles.body.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          _buildDetailSection('Station Information', [
            _buildDetailRow('Station ID', location.id),
            _buildDetailRow('Type', location.stationType),
            _buildDetailRow('Water Body', location.waterBody),
            _buildDetailRow('Established', location.establishedDate.year.toString()),
          ]),
          
          const SizedBox(height: 24),
          _buildDetailSection('Location', [
            _buildDetailRow('State', location.state),
            _buildDetailRow('District', location.district),
            _buildDetailRow('Address', location.address),
            _buildDetailRow('Latitude', location.latitude.toStringAsFixed(4)),
            _buildDetailRow('Longitude', location.longitude.toStringAsFixed(4)),
          ]),
          
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // View full details
            },
            icon: const Icon(Icons.assessment),
            label: const Text('View Quality Report'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 44),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              // Navigate to location
            },
            icon: const Icon(Icons.directions),
            label: const Text('Get Directions'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryBlue,
              side: BorderSide(color: AppColors.primaryBlue),
              minimumSize: const Size(double.infinity, 44),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSelectionPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_searching,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Select a station on the map',
            style: AppTextStyles.body.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Click any marker to view details',
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.heading4.copyWith(
            color: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.charcoal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStationIcon(String stationType) {
    switch (stationType.toLowerCase()) {
      case 'river':
        return Icons.water;
      case 'lake':
        return Icons.water_drop;
      case 'reservoir':
        return Icons.water_damage;
      case 'groundwater':
        return Icons.layers;
      case 'treatment plant':
        return Icons.factory_outlined;
      default:
        return Icons.location_on;
    }
  }
}
