import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/constants/color_constants.dart';
import '../../core/constants/maharashtra_border.dart';

class CustomMapWidget extends StatefulWidget {
  final double zoom;
  final List<Marker>? markers;
  final double sidebarWidth;
  final MapController? mapController;
  final LatLng? initialCenter;
  final VoidCallback? onMapMove; // Callback for when map is moved/zoomed

  const CustomMapWidget({
    Key? key,
    this.zoom = 13.0,
    this.markers,
    this.sidebarWidth = 72.0,
    this.mapController,
    this.initialCenter,
    this.onMapMove,
  }) : super(key: key);

  @override
  State<CustomMapWidget> createState() => _CustomMapWidgetState();
}

class _CustomMapWidgetState extends State<CustomMapWidget> {
  LatLng? _currentCenter;
  bool _loading = true;
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = widget.mapController ?? MapController();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    // Use provided initial center if available
    if (widget.initialCenter != null) {
      setState(() {
        _currentCenter = widget.initialCenter;
        _loading = false;
      });
      return;
    }
    
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      setState(() {
        _currentCenter = LatLng(28.6139, 77.2090); // fallback: New Delhi
        _loading = false;
      });
      return;
    }
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentCenter = LatLng(position.latitude, position.longitude);
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _currentCenter == null) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            AppColors.darkVanilla,
          ),
        ),
      );
    }

    // Don't add default location marker - let the parent handle all markers
    final allMarkers = <Marker>[];
    if (widget.markers != null) {
      allMarkers.addAll(widget.markers!);
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _currentCenter!,
            initialZoom: widget.zoom,
            onPositionChanged: (position, hasGesture) {
              // Call the callback when map is moved or zoomed
              if (hasGesture && widget.onMapMove != null) {
                widget.onMapMove!();
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c'],
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
            MarkerLayer(markers: allMarkers),
          ],
        ),
      ),
    );
  }
}
