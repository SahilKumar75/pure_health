import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:pure_health/core/constants/color_constants.dart';
import 'package:pure_health/core/theme/text_styles.dart';
import 'package:pure_health/core/utils/responsive_utils.dart';
import 'package:pure_health/shared/widgets/trend_chart.dart';
import 'package:pure_health/shared/widgets/parameter_comparison_chart.dart';
import 'package:pure_health/shared/widgets/zone_heatmap.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTimeRange? _selectedDateRange;
  List<String> _selectedParameters = ['pH', 'Turbidity', 'DO'];
  String _selectedZone = 'All Zones';
  
  final List<String> _availableParameters = [
    'pH',
    'Turbidity',
    'DO',
    'Temperature',
    'Conductivity',
  ];

  final List<String> _availableZones = [
    'All Zones',
    'Zone A',
    'Zone B',
    'Zone C',
    'Zone D',
  ];

  // Sample data
  final List<Map<String, dynamic>> _sampleData = [
    {
      'pH': 7.2,
      'turbidity': 2.1,
      'status': 'Safe',
      'location': 'Zone A',
      'temperature': 25.0,
      'conductivity': 500,
      'timestamp': '2025-10-28 08:00'
    },
    {
      'pH': 6.8,
      'turbidity': 3.5,
      'status': 'Safe',
      'location': 'Zone B',
      'temperature': 26.5,
      'conductivity': 550,
      'timestamp': '2025-10-29 08:00'
    },
    {
      'pH': 7.5,
      'turbidity': 1.8,
      'status': 'Safe',
      'location': 'Zone A',
      'temperature': 24.0,
      'conductivity': 480,
      'timestamp': '2025-10-30 08:00'
    },
    {
      'pH': 8.1,
      'turbidity': 4.2,
      'status': 'Warning',
      'location': 'Zone C',
      'temperature': 27.0,
      'conductivity': 620,
      'timestamp': '2025-10-31 08:00'
    },
    {
      'pH': 7.0,
      'turbidity': 2.8,
      'status': 'Safe',
      'location': 'Zone B',
      'temperature': 25.5,
      'conductivity': 530,
      'timestamp': '2025-11-01 08:00'
    },
    {
      'pH': 7.3,
      'turbidity': 2.3,
      'status': 'Safe',
      'location': 'Zone D',
      'temperature': 26.0,
      'conductivity': 510,
      'timestamp': '2025-11-02 08:00'
    },
    {
      'pH': 6.9,
      'turbidity': 3.1,
      'status': 'Safe',
      'location': 'Zone A',
      'temperature': 24.5,
      'conductivity': 495,
      'timestamp': '2025-11-03 08:00'
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _selectedDateRange = DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 7)),
      end: DateTime.now(),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildFilterBar(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTrendsTab(),
                  _buildComparisonTab(),
                  _buildZoneAnalysisTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    CupertinoIcons.chart_bar_alt_fill,
                    color: AppColors.primaryBlue,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Advanced Analytics',
                    style: AppTextStyles.heading2.copyWith(
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Deep insights into water quality patterns and trends',
                style: AppTextStyles.body.copyWith(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: _exportReport,
                icon: const Icon(Icons.download),
                label: const Text('Export Report'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryBlue,
                  side: BorderSide(color: AppColors.primaryBlue),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {});
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 12,
        alignment: WrapAlignment.start,
        children: [
          _buildDateRangeFilter(),
          _buildParameterFilter(),
          _buildZoneFilter(),
          _buildApplyButton(),
        ],
      ),
    );
  }

  Widget _buildDateRangeFilter() {
    return InkWell(
      onTap: _selectDateRange,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primaryBlue),
          borderRadius: BorderRadius.circular(8),
          color: AppColors.lightBlue.withOpacity(0.3),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.calendar,
              size: 18,
              color: AppColors.primaryBlue,
            ),
            const SizedBox(width: 8),
            Text(
              _selectedDateRange != null
                  ? '${DateFormat('MMM dd').format(_selectedDateRange!.start)} - ${DateFormat('MMM dd').format(_selectedDateRange!.end)}'
                  : 'Select Date Range',
              style: AppTextStyles.body.copyWith(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParameterFilter() {
    return PopupMenuButton<String>(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[400]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.slider_horizontal_3,
              size: 18,
              color: Colors.grey[700],
            ),
            const SizedBox(width: 8),
            Text(
              'Parameters (${_selectedParameters.length})',
              style: AppTextStyles.body.copyWith(
                color: Colors.grey[700],
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              color: Colors.grey[700],
            ),
          ],
        ),
      ),
      itemBuilder: (context) => _availableParameters.map((param) {
        final isSelected = _selectedParameters.contains(param);
        return CheckedPopupMenuItem<String>(
          value: param,
          checked: isSelected,
          child: Text(param),
        );
      }).toList(),
      onSelected: (param) {
        setState(() {
          if (_selectedParameters.contains(param)) {
            if (_selectedParameters.length > 1) {
              _selectedParameters.remove(param);
            }
          } else {
            _selectedParameters.add(param);
          }
        });
      },
    );
  }

  Widget _buildZoneFilter() {
    return PopupMenuButton<String>(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[400]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.location_solid,
              size: 18,
              color: Colors.grey[700],
            ),
            const SizedBox(width: 8),
            Text(
              _selectedZone,
              style: AppTextStyles.body.copyWith(
                color: Colors.grey[700],
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              color: Colors.grey[700],
            ),
          ],
        ),
      ),
      itemBuilder: (context) => _availableZones.map((zone) {
        return PopupMenuItem<String>(
          value: zone,
          child: Text(zone),
        );
      }).toList(),
      onSelected: (zone) {
        setState(() {
          _selectedZone = zone;
        });
      },
    );
  }

  Widget _buildApplyButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {});
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryBlue,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        'Apply Filters',
        style: AppTextStyles.button.copyWith(
          color: Colors.white,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primaryBlue,
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: AppColors.primaryBlue,
        indicatorWeight: 3,
        labelStyle: AppTextStyles.body.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        tabs: const [
          Tab(text: 'Trends'),
          Tab(text: 'Comparison'),
          Tab(text: 'Zone Analysis'),
        ],
      ),
    );
  }

  Widget _buildTrendsTab() {
    final chartData = _convertToChartData();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Time Series Analysis', 'Track parameter changes over time'),
          const SizedBox(height: 20),
          TrendChart(
            data: chartData,
            title: 'Multi-Parameter Trends',
            selectedParameters: _selectedParameters,
            dateRange: _selectedDateRange,
          ),
          const SizedBox(height: 32),
          _buildStatsCards(),
        ],
      ),
    );
  }

  Widget _buildComparisonTab() {
    final chartData = _convertToChartData();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Parameter Comparison', 'Compare average values across parameters'),
          const SizedBox(height: 20),
          ParameterComparisonChart(
            data: chartData,
            title: 'Average Parameter Values',
            showThresholds: true,
          ),
          const SizedBox(height: 32),
          _buildComplianceTable(),
        ],
      ),
    );
  }

  Widget _buildZoneAnalysisTab() {
    final chartData = _convertToChartData();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Zone Distribution', 'Analyze water quality across different zones'),
          const SizedBox(height: 20),
          ZoneHeatmap(
            data: chartData,
            title: 'Zone Quality Heatmap',
            selectedParameter: 'overall',
          ),
          const SizedBox(height: 32),
          _buildZoneRankings(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.heading3.copyWith(
            color: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: AppTextStyles.body.copyWith(
            color: Colors.grey[600],
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCards() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildStatCard('Average pH', '7.11', AppColors.chartBlue, Icons.water_drop),
        _buildStatCard('Avg Turbidity', '2.83 NTU', AppColors.chartOrange, Icons.blur_on),
        _buildStatCard('Avg DO', '9.11 mg/L', AppColors.chartGreen, Icons.air),
        _buildStatCard('Avg Temp', '25.5°C', AppColors.chartRed, Icons.thermostat),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Container(
      width: ResponsiveUtils.isDesktop(context) ? 200 : 150,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.charcoal,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplianceTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WHO/EPA Compliance Summary',
            style: AppTextStyles.heading4.copyWith(
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 16),
          _buildComplianceRow('pH Level', '6.5 - 8.5', '7.11', true),
          _buildComplianceRow('Turbidity', '< 5 NTU', '2.83 NTU', true),
          _buildComplianceRow('Dissolved Oxygen', '> 5 mg/L', '9.11 mg/L', true),
          _buildComplianceRow('Temperature', '< 30°C', '25.5°C', true),
          _buildComplianceRow('Conductivity', '< 800 μS/cm', '525 μS/cm', true),
        ],
      ),
    );
  }

  Widget _buildComplianceRow(String parameter, String threshold, String actual, bool compliant) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              parameter,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              threshold,
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              actual,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: compliant ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  compliant ? Icons.check_circle : Icons.warning,
                  size: 14,
                  color: compliant ? AppColors.success : AppColors.error,
                ),
                const SizedBox(width: 4),
                Text(
                  compliant ? 'Pass' : 'Fail',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: compliant ? AppColors.success : AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoneRankings() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Zone Performance Rankings',
            style: AppTextStyles.heading4.copyWith(
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 16),
          _buildRankingRow(1, 'Zone A', 95.0, AppColors.success),
          _buildRankingRow(2, 'Zone B', 88.0, AppColors.chartGreen),
          _buildRankingRow(3, 'Zone D', 82.0, AppColors.warning),
          _buildRankingRow(4, 'Zone C', 75.0, AppColors.chartOrange),
        ],
      ),
    );
  }

  Widget _buildRankingRow(int rank, String zone, double score, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: AppTextStyles.body.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              zone,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            width: 150,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: score / 100,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${score.toStringAsFixed(0)}%',
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  List<WaterQualityDataPoint> _convertToChartData() {
    return _sampleData.map((data) {
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
        dissolvedOxygen: ((data['pH'] as num) + 2).toDouble(),
        temperature: (data['temperature'] as num).toDouble(),
        conductivity: (data['conductivity'] as num).toDouble(),
        location: data['location'] as String,
      );
    }).toList();
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.charcoal,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  void _exportReport() {
    // Export logic will be implemented
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Analytics report export feature coming soon'),
        backgroundColor: AppColors.primaryBlue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
