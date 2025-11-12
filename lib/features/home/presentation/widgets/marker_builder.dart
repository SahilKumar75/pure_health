import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:pure_health/core/constants/color_constants.dart';
import 'package:pure_health/core/models/station_models.dart';
import 'package:pure_health/features/home/presentation/widgets/pulsing_location_dot.dart';

class MarkerBuilder {
  static List<Marker> buildStationMarkers({
    required List<WaterQualityStation> stations,
    required Map<String, StationData> stationDataMap,
    required String? selectedStationId,
    required LatLng? userLocation,
    required Function(WaterQualityStation) onStationTap,
  }) {
    final List<Marker> markers = [];

    // Add user location marker with pulsing animation
    if (userLocation != null) {
      markers.add(
        Marker(
          point: userLocation,
          width: 60,
          height: 60,
          child: const PulsingLocationDot(),
        ),
      );
    }

    // Add station markers
    for (final station in stations) {
      final isSelected = station.id == selectedStationId;
      final stationData = stationDataMap[station.id];
      final wqi = stationData?.wqi ?? 0;
      final markerColor = _getWQIColor(wqi);

      markers.add(
        Marker(
          point: LatLng(station.latitude, station.longitude),
          width: isSelected ? 32 : 24,
          height: isSelected ? 32 : 24,
          child: GestureDetector(
            onTap: () => onStationTap(station),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: markerColor,
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(
                        color: AppColors.primaryBlue,
                        width: 3,
                      )
                    : Border.all(
                        color: AppColors.white,
                        width: 2,
                      ),
                boxShadow: [
                  BoxShadow(
                    color: markerColor.withOpacity(0.5),
                    blurRadius: isSelected ? 8 : 4,
                    spreadRadius: isSelected ? 2 : 0,
                  ),
                  if (isSelected)
                    BoxShadow(
                      color: AppColors.primaryBlue.withOpacity(0.3),
                      blurRadius: 12,
                      spreadRadius: 3,
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return markers;
  }

  static Color _getWQIColor(double wqi) {
    if (wqi >= 80) {
      return AppColors.success;
    } else if (wqi >= 60) {
      return AppColors.warning;
    } else if (wqi >= 40) {
      return AppColors.accentOrange;
    } else {
      return AppColors.error;
    }
  }
}
