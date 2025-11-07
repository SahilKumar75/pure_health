import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:pure_health/core/constants/color_constants.dart';
import 'package:pure_health/core/theme/text_styles.dart';
import 'package:pure_health/core/utils/responsive_utils.dart';
import 'package:pure_health/core/utils/accessibility_utils.dart';
import 'package:pure_health/core/services/notification_service.dart';
import 'package:pure_health/shared/widgets/custom_sidebar.dart';
import 'package:pure_health/shared/widgets/skeleton_loader.dart';
import 'package:pure_health/shared/widgets/empty_state_widget.dart';
import 'package:pure_health/shared/widgets/toast_notification.dart';
import 'package:pure_health/shared/widgets/responsive_button.dart';
import 'package:pure_health/shared/widgets/refresh_widgets.dart';
import 'package:pure_health/shared/widgets/advanced_data_table.dart';
import 'package:pure_health/shared/widgets/zone_heatmap.dart';
import 'package:pure_health/shared/widgets/trend_chart.dart';
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
  Timer? _refreshTimer;

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

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (mounted) {
      setState(() {
        _isLoading = false;
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
          // Data refreshed silently
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
        dissolvedOxygen: (data['dissolvedOxygen'] as num).toDouble(),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Analytics Dashboard',
                style: TextStyle(
                  fontSize: 24,
                  color: const Color(0xFF101828),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'AI-powered water quality trends, analysis, and 2-month predictions',
                style: TextStyle(
                  fontSize: 16,
                  color: const Color(0xFF4A5565),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: () {
            ToastNotification.info(context, 'Generating AI report...');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF030213),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: Icon(Icons.assessment, size: 16, color: Colors.white),
          label: Text(
            'Generate AI Report',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            'Avg Water Quality',
            '76%',
            '-3.2%',
            'vs last week',
            true,
            Icons.water_drop,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            'pH Level',
            '7.4',
            '+0.2',
            'vs last week',
            false,
            Icons.science,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            'Turbidity (NTU)',
            '12.3',
            '+1.5',
            'vs last week',
            false,
            Icons.blur_on,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            'Dissolved O₂',
            '7.2 mg/L',
            '-0.3',
            'vs last week',
            true,
            Icons.air,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    String change,
    String changeLabel,
    bool isPositive,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF4A5565),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Icon(icon, size: 20, color: const Color(0xFF4A5565).withOpacity(0.6)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: const Color(0xFF101828),
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                change,
                style: TextStyle(
                  fontSize: 12,
                  color: isPositive ? const Color(0xFF00A63E) : const Color(0xFFE7000B),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                changeLabel,
                style: TextStyle(
                  fontSize: 12,
                  color: const Color(0xFF6A7282),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Water Quality Trend and Station Comparison side by side
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: _buildTrendChart(),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: _buildStationComparison(),
            ),
          ],
        ),
        const SizedBox(height: 24),
        
        // AI Prediction Section (full width)
        _buildAIPredictionPanel(),
        const SizedBox(height: 24),
        
        // Contamination Risk and pH Level Analysis side by side
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildContaminationRiskChart(),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildPHLevelAnalysis(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTrendChart() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Water Quality Trend (Last 7 Days)',
            style: TextStyle(
              fontSize: 18,
              color: const Color(0xFF101828),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 280,
            child: _buildLineChart(),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Dissolved O₂ (mg/L)', const Color(0xFF10B981)),
              const SizedBox(width: 24),
              _buildLegendItem('Quality Score (%)', const Color(0xFF3B82F6)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart() {
    return CustomPaint(
      painter: _LineChartPainter(),
      child: Container(),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: const Color(0xFF6A7282),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStationComparison() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Station Comparison',
            style: TextStyle(
              fontSize: 18,
              color: const Color(0xFF101828),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 280,
            child: _buildBarChart(),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Quality Score', const Color(0xFF3B82F6)),
              const SizedBox(width: 24),
              _buildLegendItem('Turbidity (NTU)', const Color(0xFFEF4444)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    return CustomPaint(
      painter: _BarChartPainter(),
      child: Container(),
    );
  }

  Widget _buildAIPredictionPanel() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF7C3AED),
            const Color(0xFF9333EA),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AI Prediction - Next 2 Months (8 Weeks)',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF9333EA),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Text(
                  'AI-Generated Forecast',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 220,
            child: CustomPaint(
              painter: _AreaChartPainter(),
              child: Container(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPredictionLegend('Current Data', Colors.white),
              const SizedBox(width: 24),
              _buildPredictionLegend('Predicted Trend', Colors.white.withOpacity(0.7)),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'AI Insight: Water quality is predicted to decline by 8% over the next 4 weeks due to seasonal changes and increased industrial activity, reaching a low point at Week 3 (68% quality score). Recovery is expected starting Week 5 as mitigation measures take effect.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w400,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildAIPredictionBadge2('Confidence: 94.2%'),
              const SizedBox(width: 12),
              _buildAIPredictionBadge2('Model: LSTM Neural Network'),
              const SizedBox(width: 12),
              _buildAIPredictionBadge2('Last Updated: Nov 6, 2025'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAIPredictionBadge2(String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildContaminationRiskChart() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.warning_amber, color: const Color(0xFFFF9800), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Contamination Risk Forecast',
                  style: TextStyle(
                    fontSize: 16,
                    color: const Color(0xFF101828),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFFFF8E1),
                  const Color(0xFFFFECB3),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFD54F).withOpacity(0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9800),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'MODERATE RISK',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '3 stations showing elevated contamination indicators',
                  style: TextStyle(
                    fontSize: 15,
                    color: const Color(0xFF101828),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                _buildRiskMetricRow('Turbidity Level', 'High', const Color(0xFFFF9800)),
                const SizedBox(height: 8),
                _buildRiskMetricRow('E.coli Detection', 'Moderate', const Color(0xFFFFA500)),
                const SizedBox(height: 8),
                _buildRiskMetricRow('Chemical Traces', 'Low', const Color(0xFF00A63E)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickStat('Affected Stations', '3/15', const Color(0xFFFF9800)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickStat('Risk Level', '42%', const Color(0xFFFF9800)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: CustomPaint(
              painter: _MonthlyBarChartPainter(),
              child: Container(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskMetricRow(String label, String status, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: const Color(0xFF6A7282),
            fontWeight: FontWeight.w500,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text(
            status,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: const Color(0xFF6A7282),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPHLevelAnalysis() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.science, color: const Color(0xFF2B7FFF), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'pH Level Analysis',
                  style: TextStyle(
                    fontSize: 16,
                    color: const Color(0xFF101828),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFE3F2FD),
                  const Color(0xFFBBDEFB),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2B7FFF).withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '7.4',
                      style: TextStyle(
                        fontSize: 48,
                        color: const Color(0xFF2B7FFF),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        'pH',
                        style: TextStyle(
                          fontSize: 20,
                          color: const Color(0xFF6A7282),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Current Average',
                  style: TextStyle(
                    fontSize: 13,
                    color: const Color(0xFF6A7282),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildPHStatBox(
                  'Optimal Range',
                  '6.5 - 8.5',
                  const Color(0xFF00A63E),
                  Icons.check_circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPHStatBox(
                  'Stations Alert',
                  '2',
                  const Color(0xFFE7000B),
                  Icons.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: CustomPaint(
              painter: _PHLineChartPainter(),
              child: Container(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPHStatBox(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: const Color(0xFF6A7282),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
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
        
        // Location Quality Distribution (keeping as requested)
        ZoneHeatmap(
          data: chartData,
          title: 'Location Quality Distribution',
          selectedParameter: 'overall',
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

// Custom Painters for Charts
class _LineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    // Draw grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Quality Score line (blue) - representing 76-82% range
    paint.color = const Color(0xFF3B82F6);
    final qualityPoints = [
      Offset(0, size.height * 0.18),              // 82%
      Offset(size.width * 0.2, size.height * 0.22), // 78%
      Offset(size.width * 0.4, size.height * 0.19), // 81%
      Offset(size.width * 0.6, size.height * 0.24), // 76%
      Offset(size.width * 0.8, size.height * 0.20), // 80%
      Offset(size.width, size.height * 0.21),      // 79%
    ];
    
    final qualityPath = Path();
    qualityPath.moveTo(qualityPoints[0].dx, qualityPoints[0].dy);
    for (int i = 1; i < qualityPoints.length; i++) {
      qualityPath.lineTo(qualityPoints[i].dx, qualityPoints[i].dy);
    }
    canvas.drawPath(qualityPath, paint);

    // Draw dots
    final dotPaint = Paint()
      ..color = const Color(0xFF3B82F6)
      ..style = PaintingStyle.fill;
    for (var point in qualityPoints) {
      canvas.drawCircle(point, 4, dotPaint);
      canvas.drawCircle(point, 5, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2);
    }

    // Dissolved O2 line (green) - representing 6.8-7.5 mg/L range
    paint.color = const Color(0xFF10B981);
    final o2Points = [
      Offset(0, size.height * 0.50),              // 7.5 mg/L
      Offset(size.width * 0.2, size.height * 0.54), // 7.1 mg/L
      Offset(size.width * 0.4, size.height * 0.52), // 7.3 mg/L
      Offset(size.width * 0.6, size.height * 0.58), // 6.8 mg/L
      Offset(size.width * 0.8, size.height * 0.53), // 7.2 mg/L
      Offset(size.width, size.height * 0.55),      // 7.0 mg/L
    ];
    
    final o2Path = Path();
    o2Path.moveTo(o2Points[0].dx, o2Points[0].dy);
    for (int i = 1; i < o2Points.length; i++) {
      o2Path.lineTo(o2Points[i].dx, o2Points[i].dy);
    }
    canvas.drawPath(o2Path, paint);

    // Draw dots
    dotPaint.color = const Color(0xFF10B981);
    for (var point in o2Points) {
      canvas.drawCircle(point, 4, dotPaint);
      canvas.drawCircle(point, 5, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2);
    }

    // Draw labels
    final textPainter = TextPainter(
      textDirection: ui.TextDirection.ltr,
    );
    
    final labels = ['Day 1', 'Day 3', 'Day 5', 'Day 7'];
    for (int i = 0; i < 4; i++) {
      textPainter.text = TextSpan(
        text: labels[i],
        style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(size.width * i / 3.3, size.height - 15),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BarChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Draw grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final barWidth = size.width / 15;
    final stations = ['Station A', 'Station C', 'Station E'];
    final qualityData = [85.0, 72.0, 58.0]; // Quality scores in percentage
    final turbidityData = [12.0, 24.0, 18.0]; // Turbidity in NTU (scaled for visibility)

    for (int i = 0; i < 3; i++) {
      final x = size.width * (i + 0.5) / 3.5;
      
      // Quality Score (blue)
      final qualityHeight = size.height * 0.7 * (qualityData[i] / 100);
      final qualityPaint = Paint()..color = const Color(0xFF3B82F6);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - barWidth, size.height - qualityHeight - 20, barWidth * 0.8, qualityHeight),
          const Radius.circular(4),
        ),
        qualityPaint,
      );

      // Turbidity (red)
      final turbidityHeight = size.height * 0.7 * (turbidityData[i] / 30); // Scale to 30 for visibility
      final turbidityPaint = Paint()..color = const Color(0xFFEF4444);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x + 5, size.height - turbidityHeight - 20, barWidth * 0.8, turbidityHeight),
          const Radius.circular(4),
        ),
        turbidityPaint,
      );
    }

    // Draw labels
    final textPainter = TextPainter(textDirection: ui.TextDirection.ltr);
    for (int i = 0; i < 3; i++) {
      textPainter.text = TextSpan(
        text: stations[i],
        style: const TextStyle(color: Color(0xFF6B7280), fontSize: 11),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(size.width * (i + 0.3) / 3.5, size.height - 15),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AreaChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Draw grid lines with better visibility
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Create prediction area path - showing decline then recovery
    final points = [
      Offset(0, size.height * 0.24),              // Week 0: 76%
      Offset(size.width * 0.14, size.height * 0.28), // Week 1: 72%
      Offset(size.width * 0.28, size.height * 0.33), // Week 2: 67%
      Offset(size.width * 0.42, size.height * 0.38), // Week 3: 62% (low point)
      Offset(size.width * 0.56, size.height * 0.36), // Week 4: 64%
      Offset(size.width * 0.70, size.height * 0.31), // Week 5: 69% (recovery)
      Offset(size.width * 0.84, size.height * 0.27), // Week 6: 73%
      Offset(size.width, size.height * 0.24),      // Week 8: 76%
    ];

    // Fill area with lighter purple
    final areaPath = Path();
    areaPath.moveTo(0, size.height);
    for (var point in points) {
      areaPath.lineTo(point.dx, point.dy);
    }
    areaPath.lineTo(size.width, size.height);
    areaPath.close();

    final areaPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    canvas.drawPath(areaPath, areaPaint);

    // Draw solid line for current data (first 3 points)
    final currentPath = Path();
    currentPath.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i <= 2; i++) {
      currentPath.lineTo(points[i].dx, points[i].dy);
    }

    final currentLinePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawPath(currentPath, currentLinePaint);

    // Draw dashed prediction line (remaining points)
    final dashPaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    for (int i = 2; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final distance = (p2 - p1).distance;
      final dashLength = 10.0;
      final gapLength = 6.0;
      final totalLength = dashLength + gapLength;
      final dashCount = (distance / totalLength).floor();

      for (int j = 0; j < dashCount; j++) {
        final start = Offset.lerp(p1, p2, j * totalLength / distance)!;
        final end = Offset.lerp(p1, p2, (j * totalLength + dashLength) / distance)!;
        canvas.drawLine(start, end, dashPaint);
      }
    }

    // Draw dots on data points
    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < points.length; i++) {
      canvas.drawCircle(points[i], 5, dotPaint);
      // Add border to dots for better visibility
      canvas.drawCircle(
        points[i], 
        6, 
        Paint()
          ..color = const Color(0xFF7C3AED)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
      );
    }

    // Draw labels
    final textPainter = TextPainter(textDirection: ui.TextDirection.ltr);
    final labels = ['Now', 'Week 1', 'Week 2', 'Week 3', 'Week 4', 'Week 5', 'Week 6', 'Week 8'];
    for (int i = 0; i < labels.length; i++) {
      textPainter.text = TextSpan(
        text: labels[i],
        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(size.width * i / 7.5, size.height - 15),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MonthlyBarChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Draw grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final barWidth = size.width / 6;
    final months = ['Oct', 'Nov', 'Dec (P)', 'Jan (P)'];
    final values = [15, 22, 28, 26];

    for (int i = 0; i < 4; i++) {
      final x = size.width * (i + 0.5) / 4.5;
      final barHeight = size.height * (values[i] / 30);
      
      final paint = Paint()..color = const Color(0xFFF59E0B);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, size.height - barHeight - 30, barWidth * 0.7, barHeight),
          const Radius.circular(4),
        ),
        paint,
      );
    }

    // Draw labels
    final textPainter = TextPainter(textDirection: ui.TextDirection.ltr);
    for (int i = 0; i < 4; i++) {
      textPainter.text = TextSpan(
        text: months[i],
        style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(size.width * (i + 0.35) / 4.5, size.height - 20),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PHLineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Draw grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // pH line (purple) - representing 7.2-7.6 pH range
    final paint = Paint()
      ..color = const Color(0xFF8B5CF6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final points = [
      Offset(0, size.height * 0.40),              // 7.2 pH
      Offset(size.width * 0.16, size.height * 0.35), // 7.3 pH
      Offset(size.width * 0.33, size.height * 0.30), // 7.4 pH
      Offset(size.width * 0.50, size.height * 0.25), // 7.5 pH
      Offset(size.width * 0.66, size.height * 0.20), // 7.6 pH
      Offset(size.width * 0.83, size.height * 0.25), // 7.5 pH
      Offset(size.width, size.height * 0.30),      // 7.4 pH
    ];
    
    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, paint);

    // Draw dots
    final dotPaint = Paint()
      ..color = const Color(0xFF8B5CF6)
      ..style = PaintingStyle.fill;
    for (var point in points) {
      canvas.drawCircle(point, 5, dotPaint);
      canvas.drawCircle(point, 6, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2);
    }

    // Draw labels
    final textPainter = TextPainter(textDirection: ui.TextDirection.ltr);
    final labels = ['Day 1', 'Day 2', 'Day 3', 'Day 4', 'Day 5', 'Day 6', 'Day 7'];
    for (int i = 0; i < 7; i++) {
      if (i % 2 == 0) { // Show every other label to avoid crowding
        textPainter.text = TextSpan(
          text: labels[i],
          style: const TextStyle(color: Color(0xFF6B7280), fontSize: 11),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(size.width * i / 6.5, size.height - 15),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
