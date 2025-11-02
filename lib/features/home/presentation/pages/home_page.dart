import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pure_health/core/constants/color_constants.dart';
import 'package:pure_health/core/theme/text_styles.dart';
import 'package:pure_health/shared/widgets/custom_sidebar.dart';
import 'package:pure_health/shared/widgets/custom_map_widget.dart';
import 'package:pure_health/shared/widgets/vertical_floating_card.dart';
import 'package:pure_health/shared/widgets/custom_alert.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool _isSidebarExpanded = false;
  bool _isBottomBarExpanded = false;
  late final MapController _mapController;
  double _currentZoom = 13.0;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  void _createAlert() {
    CustomAlert.showCreateAlertForm(context);
  }

  void _zoomIn() {
    setState(() {
      _currentZoom = (_currentZoom + 1).clamp(1.0, 18.0);
      _mapController.move(_mapController.camera.center, _currentZoom);
    });
  }

  void _zoomOut() {
    setState(() {
      _currentZoom = (_currentZoom - 1).clamp(1.0, 18.0);
      _mapController.move(_mapController.camera.center, _currentZoom);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Calculate sidebar width dynamically
    final sidebarWidth = _isSidebarExpanded ? 216.0 : 88.0;

    return Scaffold(
      backgroundColor: AppColors.lightCream,
      body: NotificationListener<SidebarExpandNotification>(
        onNotification: (notification) {
          setState(() {
            _isSidebarExpanded = notification.isExpanded;
          });
          return true;
        },
        child: Stack(
          children: [
            // Map widget as the base layer
            CustomMapWidget(
              zoom: _currentZoom,
              sidebarWidth: 72.0,
              mapController: _mapController,
            ),
            // Sidebar with glass effect positioned on the left
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: CustomSidebar(
                selectedIndex: _selectedIndex,
                onItemSelected: (int index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
              ),
            ),
            // Logo positioned beside sidebar at top left
            Positioned(
              left: sidebarWidth + 24,
              top: 24,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(20),
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo image from assets
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.darkVanilla.withOpacity(0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/Group 1000001052.png',
                          width: 48,
                          height: 48,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Logo text
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'PureHealth',
                          style: AppTextStyles.heading3.copyWith(
                            color: AppColors.charcoal,
                            letterSpacing: -0.6,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Water Quality Monitor',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.mediumGray,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Chat floating card on the right
            const VerticalFloatingCard(
              width: 400,
              initiallyCollapsed: false,
              alignment: Alignment.centerRight,
            ),
            // Bottom center expandable control bar
            Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: Center(
                child: MouseRegion(
                  onEnter: (_) => setState(() => _isBottomBarExpanded = true),
                  onExit: (_) => setState(() => _isBottomBarExpanded = false),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    height: 56,
                    width: _isBottomBarExpanded ? 320 : 160,
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: AppColors.darkCream.withOpacity(0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.charcoal.withOpacity(0.1),
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
                          // Zoom Out button
                          if (_isBottomBarExpanded)
                            AnimatedOpacity(
                              opacity: 1.0,
                              duration: const Duration(milliseconds: 200),
                              child: _buildIconButton(
                                icon: CupertinoIcons.minus_circle_fill,
                                onPressed: _zoomOut,
                              ),
                            ),
                          // Zoom In button
                          if (_isBottomBarExpanded)
                            AnimatedOpacity(
                              opacity: 1.0,
                              duration: const Duration(milliseconds: 200),
                              child: _buildIconButton(
                                icon: CupertinoIcons.plus_circle_fill,
                                onPressed: _zoomIn,
                              ),
                            ),
                          // Create Alert button (always visible)
                          Flexible(
                            child: CupertinoButton(
                              padding: EdgeInsets.symmetric(
                                horizontal: _isBottomBarExpanded ? 16 : 20,
                                vertical: 12,
                              ),
                              onPressed: _createAlert,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    CupertinoIcons.add_circled_solid,
                                    color: AppColors.darkVanilla,
                                    size: 24,
                                  ),
                                  if (_isBottomBarExpanded) ...[
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        'Create Alert',
                                        style: AppTextStyles.button.copyWith(
                                          color: AppColors.charcoal,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return CupertinoButton(
      padding: const EdgeInsets.all(8),
      minSize: 40,
      onPressed: onPressed,
      child: Icon(
        icon,
        color: AppColors.charcoal,
        size: 24,
      ),
    );
  }
}
