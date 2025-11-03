import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:pure_health/core/constants/color_constants.dart';
import 'package:pure_health/core/theme/text_styles.dart';
import 'package:pure_health/core/theme/government_theme.dart';
import 'package:pure_health/core/utils/responsive_utils.dart';
import 'package:pure_health/core/utils/accessibility_utils.dart';
import 'package:pure_health/core/services/notification_service.dart';
import 'package:pure_health/shared/widgets/custom_sidebar.dart';
import 'package:pure_health/shared/widgets/water_quality_charts.dart';
import 'package:pure_health/shared/widgets/skeleton_loader.dart';
import 'package:pure_health/shared/widgets/empty_state_widget.dart';
import 'package:pure_health/shared/widgets/toast_notification.dart';
import 'package:pure_health/shared/widgets/responsive_grid.dart';
import 'package:pure_health/shared/widgets/responsive_button.dart';
import 'package:pure_health/shared/widgets/refresh_widgets.dart';
import 'package:pure_health/shared/widgets/hover_animations.dart';
import 'package:pure_health/shared/widgets/page_transitions.dart';
import 'package:pure_health/shared/widgets/advanced_data_table.dart';
import 'package:pure_health/shared/widgets/compliance_monitor.dart';
import 'package:pure_health/shared/widgets/notification_bell.dart';
import 'package:pure_health/shared/widgets/trend_chart.dart';
import 'package:pure_health/shared/widgets/parameter_comparison_chart.dart';
import 'package:pure_health/shared/widgets/zone_heatmap.dart';
import 'package:pure_health/core/data/maharashtra_water_data.dart';
import 'package:intl/intl.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with AccessibilityMixin {
  int _selectedIndex = 1;
  bool _isLoading = false;
  bool _hasError = false;
  bool _autoRefreshEnabled = true;
  DateTime? _lastUpdated;
  Timer? _refreshTimer;
  bool _showNewDataIndicator = false;

  // Real Maharashtra water quality data
  List<Map<String, dynamic>> sampleData = [];

  // Load real Maharashtra data
  void _loadMaharashtraData() {
    final stations = MaharashtraWaterData.getAllStations();
    final allSamples = <Map<String, dynamic>>[];
    
    // Get recent samples from top 5 stations
    final topStations = stations.take(5).toList();
    for (final station in topStations) {
      final samples = MaharashtraWaterQualityData.generateSamplesForStation(
        station,
        sampleCount: 3,
        startDate: DateTime.now().subtract(const Duration(days: 2)),
      );
      allSamples.addAll(samples);
    }
    
    // Sort by timestamp descending
    allSamples.sort((a, b) => 
      DateTime.parse(b['timestamp'] as String)
          .compareTo(DateTime.parse(a['timestamp'] as String))
    );
    
    setState(() {
      sampleData = allSamples.take(20).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _lastUpdated = DateTime.now();
    _loadMaharashtraData(); // Load real Maharashtra data first
    _loadData();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    if (_autoRefreshEnabled) {
      _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
        if (mounted && !_isLoading) {
          _refreshDataSilently();
        }
      });
    }
  }

  void _toggleAutoRefresh() {
    setState(() {
      _autoRefreshEnabled = !_autoRefreshEnabled;
      if (_autoRefreshEnabled) {
        _startAutoRefresh();
        ToastNotification.success(context, 'Auto-refresh enabled (30s)');
      } else {
        _refreshTimer?.cancel();
        ToastNotification.info(context, 'Auto-refresh disabled');
      }
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (mounted) {
      setState(() {
        _isLoading = false;
        _lastUpdated = DateTime.now();
      });
    }
  }

  Future<void> _refreshDataSilently() async {
    // Silent refresh without showing loading indicator
    try {
      // Simulate API call - in production, fetch new data here
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Check parameters and generate alerts
      _checkParametersForAlerts();
      
      if (mounted) {
        setState(() {
          _lastUpdated = DateTime.now();
          _showNewDataIndicator = true;
        });
        
        // Hide indicator after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() => _showNewDataIndicator = false);
          }
        });
      }
    } catch (e) {
      // Silently handle errors for background refresh
    }
  }

  void _checkParametersForAlerts() {
    final notificationService = Provider.of<NotificationService>(context, listen: false);
    
    // Check all data points for threshold violations
    for (var data in sampleData) {
      notificationService.checkWaterQualityParameters(data);
    }
  }

  List<WaterQualityDataPoint> _convertToChartData() {
    return sampleData.map((data) {
      DateTime timestamp;
      try {
        timestamp = DateFormat('yyyy-MM-dd HH:mm').parse(data['timestamp']);
      } catch (e) {
        timestamp = DateTime.now();
      }

      return WaterQualityDataPoint(
        timestamp: timestamp,
        ph: (data['pH'] as num).toDouble(),
        turbidity: (data['turbidity'] as num).toDouble(),
        dissolvedOxygen: ((data['pH'] as num) + 2).toDouble(), // Simulated DO
        temperature: (data['temperature'] as num).toDouble(),
        conductivity: (data['conductivity'] as num).toDouble(),
        location: data['location'] as String,
      );
    }).toList();
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        setState(() => _isLoading = false);
        ToastNotification.success(
          context,
          'Dashboard data refreshed successfully!',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
        ToastNotification.error(
          context,
          'Failed to refresh data. Please try again.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    
    return Scaffold(
      backgroundColor: AppColors.lightCream,
      body: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      backgroundColor: AppColors.lightCream,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.dashboard_outlined, color: AppColors.primaryBlue, size: 20),
            const SizedBox(width: 8),
            Text(
              'Dashboard',
              style: AppTextStyles.heading4.copyWith(
                color: AppColors.charcoal,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          ResponsiveIconButton(
            icon: CupertinoIcons.refresh,
            onPressed: _isLoading ? null : _refreshData,
            color: AppColors.accentPink,
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _hasError
              ? _buildErrorState()
              : sampleData.isEmpty
                  ? _buildEmptyState()
                  : _buildDashboardContent(),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        CustomSidebar(
          selectedIndex: _selectedIndex,
          onItemSelected: (index) {
            setState(() => _selectedIndex = index);
          },
        ),
        Expanded(
          child: _isLoading
              ? _buildLoadingState()
              : _hasError
                  ? _buildErrorState()
                  : sampleData.isEmpty
                      ? _buildEmptyState()
                      : _buildDashboardContent(),
        ),
      ],
    );
  }

  Widget _buildDashboardContent() {
    return CustomRefreshWrapper(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(context.horizontalPadding),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!context.isMobile) _buildHeader(),
            if (!context.isMobile) const SizedBox(height: 32),
            _buildSummaryCards(),
            SizedBox(height: ResponsiveUtils.getSpacing(context, mobile: 20, tablet: 28, desktop: 32)),
            _buildChartsSection(),
            SizedBox(height: ResponsiveUtils.getSpacing(context, mobile: 20, tablet: 28, desktop: 32)),
            _buildAdvancedVisualizationsSection(),
            SizedBox(height: ResponsiveUtils.getSpacing(context, mobile: 20, tablet: 28, desktop: 32)),
            _buildDataTable(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return ResponsiveRow(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.dashboard_outlined,
                    color: AppColors.primaryBlue,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Water Quality Dashboard',
                    style: AppTextStyles.heading2.copyWith(
                      color: AppColors.charcoal,
                      fontWeight: FontWeight.w800,
                      fontSize: ResponsiveUtils.getScaledFontSize(context, 28),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (_showNewDataIndicator)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppColors.success,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.checkmark_circle_fill,
                            size: 14,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Updated',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Real-time monitoring and analysis',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.mediumGray,
                      fontSize: ResponsiveUtils.getScaledFontSize(context, 15),
                    ),
                  ),
                  if (_lastUpdated != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      '•',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.mediumGray,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Last updated: ${_getTimeAgo(_lastUpdated!)}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.mediumGray,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        Row(
          children: [
            // Notification Bell
            const NotificationBell(),
            const SizedBox(width: 8),
            // Auto-refresh toggle
            Tooltip(
              message: _autoRefreshEnabled ? 'Disable auto-refresh' : 'Enable auto-refresh',
              child: IconButton(
                onPressed: _toggleAutoRefresh,
                icon: Icon(
                  _autoRefreshEnabled
                      ? CupertinoIcons.pause_circle
                      : CupertinoIcons.play_circle,
                  color: _autoRefreshEnabled
                      ? GovernmentTheme.governmentBlue
                      : AppColors.mediumGray,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ResponsiveButton(
              label: _isLoading ? 'Refreshing...' : 'Refresh',
              icon: CupertinoIcons.refresh,
              onPressed: _isLoading ? null : _refreshData,
              isLoading: _isLoading,
              size: context.isMobile ? ButtonSize.small : ButtonSize.medium,
            ),
          ],
        ),
      ],
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  Widget _buildSummaryCards() {
    if (context.isMobile) {
      return Column(
        children: [
          ResponsiveGrid(
            mobileColumns: 2,
            tabletColumns: 4,
            desktopColumns: 4,
            spacing: 12,
            runSpacing: 12,
            children: [
              AnimatedListItem(
                index: 0,
                child: _buildSummaryCardWithIcon(
                  'Total Samples',
                  '${sampleData.length}',
                  AppColors.primaryBlue,
                  Icons.water_drop_outlined,
                ),
              ),
              AnimatedListItem(
                index: 1,
                child: _buildSummaryCardWithIcon(
                  'Safe',
                  '${_countStatus("Safe")}',
                  AppColors.success,
                  Icons.check_circle_outline,
                ),
              ),
              AnimatedListItem(
                index: 2,
                child: _buildSummaryCardWithIcon(
                  'Warning',
                  '${_countStatus("Warning")}',
                  AppColors.warning,
                  Icons.warning_amber_outlined,
                ),
              ),
              AnimatedListItem(
                index: 3,
                child: _buildSummaryCardWithIcon(
                  'Critical',
                  '${_countStatus("Critical")}',
                  AppColors.error,
                  Icons.error_outline,
                ),
              ),
            ],
          ),
        ],
      );
    }

    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          AnimatedListItem(
            index: 0,
            child: _buildSummaryCard(
              'Total Records',
              '${sampleData.length}',
              AppColors.darkVanilla,
            ),
          ),
          const SizedBox(width: 16),
          AnimatedListItem(
            index: 1,
            child: _buildSummaryCard(
              'Safe',
              '${_countStatus("Safe")}',
              AppColors.success,
            ),
          ),
          const SizedBox(width: 16),
          AnimatedListItem(
            index: 2,
            child: _buildSummaryCard(
              'Warning',
              '${_countStatus("Warning")}',
              AppColors.warning,
            ),
          ),
          const SizedBox(width: 16),
          AnimatedListItem(
            index: 3,
            child: _buildSummaryCard(
              'Critical',
              '${_countStatus("Critical")}',
              AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Charts & Analytics',
          style: AppTextStyles.heading3.copyWith(
            color: AppColors.charcoal,
          ),
        ),
        const SizedBox(height: 16),
        
        // pH Trend and Turbidity side by side (pH wider)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: WaterQualityCharts.buildPHTrendChart(sampleData),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: WaterQualityCharts.buildTurbidityChart(sampleData),
            ),
          ],
        ),
        const SizedBox(height: 24),
        
        // Status Pie Chart (full width)
        WaterQualityCharts.buildStatusPieChart({
          'Safe': _countStatus('Safe'),
          'Warning': _countStatus('Warning'),
          'Critical': _countStatus('Critical'),
        }),
        const SizedBox(height: 24),
        
        // Location Status and Compliance side by side (matching heights)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: WaterQualityCharts.buildLocationStatus(sampleData),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: _buildComplianceSection(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header skeleton
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLoader(
                    width: 300,
                    height: 32,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  const SizedBox(height: 8),
                  SkeletonLoader(
                    width: 200,
                    height: 16,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
              SkeletonLoader(
                width: 120,
                height: 40,
                borderRadius: BorderRadius.circular(8),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          // Summary cards skeleton
          SizedBox(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: List.generate(
                4,
                (index) => Padding(
                  padding: EdgeInsets.only(right: index < 3 ? 16 : 0),
                  child: SkeletonLoader(
                    width: 160,
                    height: 120,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          
          // Charts skeleton
          SkeletonLoader(
            width: double.infinity,
            height: 400,
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(height: 24),
          SkeletonLoader(
            width: double.infinity,
            height: 400,
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return EmptyStates.error(
      title: 'Failed to Load Data',
      message: 'Unable to fetch dashboard data. Please check your connection and try again.',
      onRetry: _refreshData,
    );
  }

  Widget _buildEmptyState() {
    return EmptyStates.noData(
      title: 'No Water Quality Data',
      message: 'Start monitoring to see analytics and insights here.',
      actionLabel: 'Start Monitoring',
      onAction: () {
        ToastNotification.info(
          context,
          'Navigate to monitoring section to begin',
        );
      },
    );
  }

  int _countStatus(String status) {
    return sampleData.where((item) => item['status'] == status).length;
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return _buildSummaryCardWithIcon(title, value, color, null);
  }

  Widget _buildSummaryCardWithIcon(String title, String value, Color color, IconData? icon) {
    // Create accessible label
    final semanticLabel = '$title: $value';
    
    return Semantics(
      label: semanticLabel,
      button: false,
      container: true,
      child: HoverCard(
        child: Container(
          width: 160,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.charcoal.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ExcludeSemantics(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.buttonSmall.copyWith(
                          color: AppColors.mediumGray,
                        ),
                      ),
                    ),
                    if (icon != null)
                      Icon(
                        icon,
                        color: color.withOpacity(0.6),
                        size: 20,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      value,
                      style: AppTextStyles.heading2.copyWith(
                        color: color,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Container(
                      width: 4,
                      height: 50,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildComplianceSection() {
    return ComplianceMonitor(
      data: sampleData,
    );
  }

  Widget _buildAdvancedVisualizationsSection() {
    final chartData = _convertToChartData();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.analytics_outlined,
              color: AppColors.primaryBlue,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'Advanced Analytics',
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.primaryBlue,
                fontSize: 20,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        
        // Trend Chart
        TrendChart(
          data: chartData,
          title: 'Water Quality Trends (Last 7 Days)',
          selectedParameters: const ['pH', 'Turbidity', 'DO'],
        ),
        
        const SizedBox(height: 24),
        
        // Parameter Comparison and Heatmap in responsive layout
        ResponsiveRow(
          children: [
            Expanded(
              flex: ResponsiveUtils.isDesktop(context) ? 1 : 2,
              child: ParameterComparisonChart(
                data: chartData,
                title: 'Current Parameter Averages',
                showThresholds: true,
              ),
            ),
            SizedBox(width: ResponsiveUtils.getSpacing(context, mobile: 0, tablet: 16, desktop: 24)),
            Expanded(
              flex: ResponsiveUtils.isDesktop(context) ? 1 : 2,
              child: ZoneHeatmap(
                data: chartData,
                title: 'Location Quality Distribution',
                selectedParameter: 'overall',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDataTable() {
    return AdvancedDataTable(
      columns: const [
        DataTableColumn(
          key: 'location',
          label: 'Location',
          sortable: true,
          filterable: true,
        ),
        DataTableColumn(
          key: 'pH',
          label: 'pH Level',
          sortable: true,
          filterable: true,
        ),
        DataTableColumn(
          key: 'turbidity',
          label: 'Turbidity (NTU)',
          sortable: true,
          filterable: true,
        ),
        DataTableColumn(
          key: 'dissolvedOxygen',
          label: 'Dissolved Oxygen (mg/L)',
          sortable: true,
          filterable: true,
        ),
        DataTableColumn(
          key: 'temperature',
          label: 'Temperature',
          sortable: true,
          filterable: true,
        ),
        DataTableColumn(
          key: 'status',
          label: 'Status',
          sortable: true,
          filterable: true,
        ),
      ],
      data: sampleData,
      rowsPerPage: 10,
    );
  }
}
