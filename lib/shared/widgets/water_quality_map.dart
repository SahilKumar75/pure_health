import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/models/monitoring_location.dart';
import '../../core/constants/color_constants.dart';
import '../../core/constants/maharashtra_border.dart';
import '../../core/theme/text_styles.dart';

class WaterQualityMap extends StatefulWidget {
  final List<MonitoringLocation> locations;
  final Function(MonitoringLocation)? onLocationTap;
  final MonitoringLocation? selectedLocation;
  final Map<String, String>? locationStatus; // location id -> status (Safe, Warning, Critical)

  const WaterQualityMap({
    super.key,
    required this.locations,
    this.onLocationTap,
    this.selectedLocation,
    this.locationStatus,
  });

  @override
  State<WaterQualityMap> createState() => _WaterQualityMapState();
}

class _WaterQualityMapState extends State<WaterQualityMap> {
  final MapController _mapController = MapController();
  
  // Default center of India
  static const LatLng _indiaCenter = LatLng(20.5937, 78.9629);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.selectedLocation != null) {
        _centerOnLocation(widget.selectedLocation!);
      }
    });
  }

  void _centerOnLocation(MonitoringLocation location) {
    _mapController.move(
      LatLng(location.latitude, location.longitude),
      12.0,
    );
  }

  Color _getMarkerColor(MonitoringLocation location) {
    final status = widget.locationStatus?[location.id] ?? 'Safe';
    switch (status) {
      case 'Critical':
        return AppColors.error;
      case 'Warning':
        return AppColors.warning;
      case 'Safe':
      default:
        return AppColors.success;
    }
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: widget.selectedLocation != null
                  ? LatLng(widget.selectedLocation!.latitude, widget.selectedLocation!.longitude)
                  : _indiaCenter,
              initialZoom: widget.selectedLocation != null ? 12.0 : 5.0,
              minZoom: 4.0,
              maxZoom: 18.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.purehealth.app',
                maxZoom: 19,
              ),
              // Maharashtra border polygon
              PolygonLayer(
                polygons: [
                  Polygon(
                    points: MaharashtraBorder.borderCoordinates,
                    color: AppColors.primaryBlue.withOpacity(0.1),
                    borderColor: AppColors.primaryBlue,
                    borderStrokeWidth: 2.5,
                  ),
                ],
              ),
              MarkerLayer(
                markers: widget.locations.map((location) {
                  final isSelected = widget.selectedLocation?.id == location.id;
                  final markerColor = _getMarkerColor(location);
                  
                  return Marker(
                    point: LatLng(location.latitude, location.longitude),
                    width: isSelected ? 50 : 40,
                    height: isSelected ? 50 : 40,
                    child: GestureDetector(
                      onTap: () {
                        widget.onLocationTap?.call(location);
                        _centerOnLocation(location);
                      },
                      child: _buildCustomMarker(
                        location,
                        markerColor,
                        isSelected,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          
          // Map Controls
          Positioned(
            top: 16,
            right: 16,
            child: Column(
              children: [
                _buildMapControl(
                  icon: Icons.add,
                  onTap: () {
                    final zoom = _mapController.camera.zoom;
                    _mapController.move(_mapController.camera.center, zoom + 1);
                  },
                ),
                const SizedBox(height: 8),
                _buildMapControl(
                  icon: Icons.remove,
                  onTap: () {
                    final zoom = _mapController.camera.zoom;
                    _mapController.move(_mapController.camera.center, zoom - 1);
                  },
                ),
                const SizedBox(height: 8),
                _buildMapControl(
                  icon: Icons.my_location,
                  onTap: () {
                    if (widget.selectedLocation != null) {
                      _centerOnLocation(widget.selectedLocation!);
                    } else {
                      _mapController.move(_indiaCenter, 5.0);
                    }
                  },
                ),
              ],
            ),
          ),
          
          // Legend
          Positioned(
            bottom: 16,
            left: 16,
            child: _buildLegend(),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomMarker(MonitoringLocation location, Color color, bool isSelected) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: color,
          width: isSelected ? 4 : 3,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: isSelected ? 12 : 8,
            spreadRadius: isSelected ? 3 : 2,
          ),
        ],
      ),
      child: Center(
        child: Icon(
          _getStationIcon(location.stationType),
          color: color,
          size: isSelected ? 24 : 20,
        ),
      ),
    );
  }

  Widget _buildMapControl({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Icon(icon, color: AppColors.primaryBlue, size: 20),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Water Quality Status',
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 8),
          _buildLegendItem('Safe', AppColors.success),
          const SizedBox(height: 4),
          _buildLegendItem('Warning', AppColors.warning),
          const SizedBox(height: 4),
          _buildLegendItem('Critical', AppColors.error),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}
