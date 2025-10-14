import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class CustomMapWidget extends StatefulWidget {
  final double zoom;
  final List<Marker>? markers;

  const CustomMapWidget({
    Key? key,
    this.zoom = 13.0,
    this.markers,
  }) : super(key: key);

  @override
  State<CustomMapWidget> createState() => _CustomMapWidgetState();
}

class _CustomMapWidgetState extends State<CustomMapWidget> {
  LatLng? _currentCenter;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
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
    return FlutterMap(
      mapController: MapController(),
      options: MapOptions(
        initialCenter: _currentCenter!,
        initialZoom: widget.zoom,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c'],
        ),
        if (widget.markers != null)
          MarkerLayer(markers: widget.markers!),
      ],
    );
  }
}
