import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class CustomMapWidget extends StatefulWidget {
  final double zoom;
  final List<Marker>? markers;
  final double sidebarWidth;
  final MapController? mapController;

  const CustomMapWidget({
    Key? key,
    this.zoom = 13.0,
    this.markers,
    this.sidebarWidth = 72.0,
    this.mapController,
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
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
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
      return const Center(child: CircularProgressIndicator());
    }
    
    // Build the current location marker
    final currentLocationMarker = Marker(
      point: _currentCenter!,
      width: 48,
      height: 48,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.15),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
          border: Border.all(
            color: Colors.blueAccent,
            width: 2,
          ),
        ),
        child: const Icon(
          CupertinoIcons.location_solid,
          color: Colors.blueAccent,
          size: 28,
        ),
      ),
    );

    // Combine user markers and current location marker
    final allMarkers = <Marker>[];
    if (widget.markers != null) {
      allMarkers.addAll(widget.markers!);
    }
    allMarkers.add(currentLocationMarker);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _currentCenter!,
          initialZoom: widget.zoom,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
          ),
          MarkerLayer(markers: allMarkers),
        ],
      ),
    );
  }
}
