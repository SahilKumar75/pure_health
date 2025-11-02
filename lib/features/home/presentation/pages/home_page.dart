import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pure_health/core/constants/color_constants.dart';
import 'package:pure_health/core/theme/text_styles.dart';
import 'package:pure_health/shared/widgets/custom_sidebar.dart';
import 'package:pure_health/shared/widgets/custom_map_widget.dart';
import 'package:pure_health/shared/widgets/vertical_floating_card.dart';
import 'package:pure_health/shared/widgets/custom_alert.dart';
import 'package:pure_health/ml/repositories/ml_repository.dart';
import 'package:pure_health/ml/models/water_quality_model.dart';
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
  late MLRepository _mlRepository;

  // ML predictions state
  String _waterQualityStatus = 'Analyzing...';
  double _qualityScore = 0;
  bool _isAnalyzing = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _mlRepository = MLRepository();
    _analyzeWaterQuality();
  }

  /// Analyze water quality using ML
  Future<void> _analyzeWaterQuality() async {
    setState(() {
      _isAnalyzing = true;
      _statusMessage = 'Fetching water quality data...';
    });

    try {
      // Create sample water quality data (in real app, get from sensors)
      final waterData = WaterQualityData(
        pH: 7.2,
        turbidity: 2.1,
        dissolved_oxygen: 8.5,
        temperature: 25.0,
        conductivity: 500.0,
        timestamp: DateTime.now(),
        location: 'Main Water Source',
      );

      // Get prediction from ML model
      final prediction =
          await _mlRepository.getWaterQualityPrediction(waterData);

      setState(() {
        _waterQualityStatus = prediction.status;
        _qualityScore = prediction.predictedValue;
        _statusMessage = null;
        _isAnalyzing = false;
      });

      // Show notification if status is warning or critical
      if (prediction.status != 'Safe') {
        _showQualityAlert(prediction);
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error analyzing water quality: $e';
        _isAnalyzing = false;
      });
      _showErrorSnackbar('Failed to analyze water quality');
    }
  }

  /// Show quality alert dialog
  void _showQualityAlert(WaterQualityPrediction prediction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              prediction.status == 'Warning'
                  ? CupertinoIcons.exclamationmark_triangle_fill
                  : CupertinoIcons.exclamationmark_circle_fill,
              color: prediction.status == 'Warning'
                  ? AppColors.warning
                  : AppColors.error,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              'Water Quality ${prediction.status}',
              style: AppTextStyles.heading3.copyWith(
                color: prediction.status == 'Warning'
                    ? AppColors.warning
                    : AppColors.error,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Parameter: ${prediction.parameter}',
              style: AppTextStyles.body.copyWith(
                color: AppColors.charcoal,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Value: ${prediction.predictedValue.toStringAsFixed(2)}',
              style: AppTextStyles.body.copyWith(
                color: AppColors.mediumGray,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Recommendations:',
              style: AppTextStyles.buttonSmall.copyWith(
                color: AppColors.charcoal,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...prediction.recommendations.map((rec) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.darkVanilla,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        rec,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.mediumGray,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Dismiss',
              style: AppTextStyles.button.copyWith(
                color: AppColors.mediumGray,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _createAlert();
            },
            child: Text(
              'Create Alert',
              style: AppTextStyles.button.copyWith(
                color: AppColors.darkVanilla,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
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

  /// Refresh water quality data
  Future<void> _refreshWaterQuality() async {
    await _analyzeWaterQuality();
  }

  Color _getStatusColor() {
    switch (_waterQualityStatus) {
      case 'Safe':
        return AppColors.success;
      case 'Warning':
        return AppColors.warning;
      case 'Critical':
        return AppColors.error;
      default:
        return AppColors.mediumGray;
    }
  }

  IconData _getStatusIcon() {
    switch (_waterQualityStatus) {
      case 'Safe':
        return CupertinoIcons.checkmark_circle_fill;
      case 'Warning':
        return CupertinoIcons.exclamationmark_triangle_fill;
      case 'Critical':
        return CupertinoIcons.exclamationmark_circle_fill;
      default:
        return CupertinoIcons.question_circle_fill;
    }
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
                  // Handle navigation with GoRouter
                  if (context.mounted) {
                    switch (index) {
                      case 0:
                        context.go('/');
                        break;
                      case 1:
                        context.go('/profile');
                        break;
                      case 2:
                        context.go('/history');
                        break;
                      case 3:
                        context.go('/settings');
                        break;
                      case 4:
                        context.go('/chat');
                        break;
                    }
                  }
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
            // Water Quality Status Card (Top Right)
            Positioned(
              right: 24,
              top: 24,
              child: _buildWaterQualityStatusCard(),
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
                          // Refresh button
                          if (_isBottomBarExpanded)
                            AnimatedOpacity(
                              opacity: 1.0,
                              duration: const Duration(milliseconds: 200),
                              child: _buildIconButton(
                                icon: CupertinoIcons.refresh,
                                onPressed: _isAnalyzing
                                    ? null
                                    : _refreshWaterQuality,
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

  Widget _buildWaterQualityStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getStatusIcon(),
                color: _getStatusColor(),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Water Quality',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.mediumGray,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_isAnalyzing)
            SizedBox(
              width: 120,
              child: LinearProgressIndicator(
                backgroundColor: AppColors.darkCream.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.darkVanilla,
                ),
              ),
            )
          else
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _waterQualityStatus,
                  style: AppTextStyles.heading4.copyWith(
                    color: _getStatusColor(),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Score: ${_qualityScore.toStringAsFixed(1)}/100',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.mediumGray,
                  ),
                ),
              ],
            ),
          if (_statusMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              _statusMessage!,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.error,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return CupertinoButton(
      padding: const EdgeInsets.all(8),
      minSize: 40,
      onPressed: onPressed,
      child: Icon(
        icon,
        color: onPressed != null ? AppColors.charcoal : AppColors.mediumGray,
        size: 24,
      ),
    );
  }
}
