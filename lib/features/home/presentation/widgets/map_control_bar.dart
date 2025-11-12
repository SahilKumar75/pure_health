import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pure_health/core/constants/color_constants.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

class MapControlBar extends StatelessWidget {
  final bool isExpanded;
  final double currentZoom;
  final MapController mapController;
  final LatLng? userLocation;
  final VoidCallback onRefresh;
  final Function(bool) onExpansionChanged;

  const MapControlBar({
    super.key,
    required this.isExpanded,
    required this.currentZoom,
    required this.mapController,
    required this.userLocation,
    required this.onRefresh,
    required this.onExpansionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 24,
      child: Center(
        child: MouseRegion(
          onEnter: (_) => onExpansionChanged(true),
          onExit: (_) => onExpansionChanged(false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: 56,
            width: isExpanded ? 440 : 100,
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isExpanded) ...[
                    _buildControlButton(
                      context,
                      icon: CupertinoIcons.minus_circle_fill,
                      tooltip: 'Zoom Out',
                      onPressed: () {
                        final newZoom = (currentZoom - 1).clamp(1.0, 18.0);
                        mapController.move(mapController.camera.center, newZoom);
                      },
                    ),
                    _buildControlButton(
                      context,
                      icon: CupertinoIcons.plus_circle_fill,
                      tooltip: 'Zoom In',
                      onPressed: () {
                        final newZoom = (currentZoom + 1).clamp(1.0, 18.0);
                        mapController.move(mapController.camera.center, newZoom);
                      },
                    ),
                    Container(
                      height: 32,
                      width: 1,
                      color: AppColors.darkCream.withOpacity(0.3),
                    ),
                    _buildControlButton(
                      context,
                      icon: CupertinoIcons.location_fill,
                      tooltip: 'My Location',
                      onPressed: userLocation != null
                          ? () {
                              mapController.move(userLocation!, 12.0);
                            }
                          : null,
                    ),
                    _buildControlButton(
                      context,
                      icon: CupertinoIcons.refresh_circled_solid,
                      tooltip: 'Refresh Data',
                      onPressed: () {
                        onRefresh();
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
                      context,
                      icon: CupertinoIcons.fullscreen,
                      tooltip: 'Toggle Fullscreen',
                      onPressed: () {},
                    ),
                    _buildControlButton(
                      context,
                      icon: CupertinoIcons.settings_solid,
                      tooltip: 'Map Settings',
                      onPressed: () {},
                    ),
                  ],
                  if (!isExpanded)
                    Flexible(
                      child: CupertinoButton(
                        padding: const EdgeInsets.all(12),
                        onPressed: () => onExpansionChanged(true),
                        child: Icon(
                          CupertinoIcons.line_horizontal_3,
                          color: AppColors.primaryBlue,
                          size: 22,
                        ),
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

  Widget _buildControlButton(
    BuildContext context, {
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
          color: onPressed != null
              ? AppColors.primaryBlue
              : AppColors.mediumGray,
          size: 22,
        ),
      ),
    );
  }
}
