import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pure_health/core/constants/color_constants.dart';
import 'package:pure_health/core/theme/text_styles.dart';
import 'package:pure_health/shared/widgets/custom_sidebar.dart';
import 'package:pure_health/shared/widgets/water_quality_charts.dart';
import 'package:pure_health/shared/widgets/skeleton_loader.dart';
import 'package:pure_health/shared/widgets/empty_state_widget.dart';
import 'package:pure_health/shared/widgets/toast_notification.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 1;
  bool _isLoading = false;
  bool _hasError = false;

  // Sample data - Replace with real backend data
  List<Map<String, dynamic>> sampleData = [
    {
      'pH': 7.2,
      'turbidity': 2.1,
      'status': 'Safe',
      'location': 'Zone A',
      'temperature': 25.0,
      'conductivity': 500,
      'timestamp': '2025-11-02 08:00'
    },
    {
      'pH': 6.8,
      'turbidity': 3.5,
      'status': 'Warning',
      'location': 'Zone B',
      'temperature': 22.0,
      'conductivity': 480,
      'timestamp': '2025-11-02 09:00'
    },
    {
      'pH': 5.5,
      'turbidity': 8.2,
      'status': 'Critical',
      'location': 'Zone C',
      'temperature': 28.0,
      'conductivity': 620,
      'timestamp': '2025-11-02 10:00'
    },
    {
      'pH': 7.1,
      'turbidity': 2.0,
      'status': 'Safe',
      'location': 'Zone A',
      'temperature': 24.5,
      'conductivity': 510,
      'timestamp': '2025-11-02 11:00'
    },
    {
      'pH': 7.3,
      'turbidity': 2.3,
      'status': 'Safe',
      'location': 'Zone D',
      'temperature': 25.2,
      'conductivity': 505,
      'timestamp': '2025-11-02 12:00'
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
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
    return Scaffold(
      backgroundColor: AppColors.lightCream,
      body: Row(
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
      ),
    );
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          _buildSummaryCards(),
          const SizedBox(height: 32),
          _buildChartsSection(),
          const SizedBox(height: 32),
          _buildDataTable(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📊 Water Quality Dashboard',
              style: AppTextStyles.heading2.copyWith(
                color: AppColors.charcoal,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Real-time monitoring and analysis',
              style: AppTextStyles.body.copyWith(
                color: AppColors.mediumGray,
              ),
            ),
          ],
        ),
        CupertinoButton(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          onPressed: _isLoading ? null : _refreshData,
          child: Row(
            children: [
              if (_isLoading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                const Icon(CupertinoIcons.refresh, size: 18),
              const SizedBox(width: 8),
              Text(
                _isLoading ? 'Refreshing...' : 'Refresh',
                style: AppTextStyles.button.copyWith(
                  color: _isLoading
                      ? AppColors.mediumGray
                      : AppColors.darkVanilla,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards() {
    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildSummaryCard(
            '📋 Total Records',
            '${sampleData.length}',
            AppColors.darkVanilla,
          ),
          const SizedBox(width: 16),
          _buildSummaryCard(
            '✅ Safe',
            '${_countStatus("Safe")}',
            AppColors.success,
          ),
          const SizedBox(width: 16),
          _buildSummaryCard(
            '⚠️ Warning',
            '${_countStatus("Warning")}',
            AppColors.warning,
          ),
          const SizedBox(width: 16),
          _buildSummaryCard(
            '❌ Critical',
            '${_countStatus("Critical")}',
            AppColors.error,
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
        WaterQualityCharts.buildPHTrendChart(sampleData),
        const SizedBox(height: 24),
        WaterQualityCharts.buildTurbidityChart(sampleData),
        const SizedBox(height: 24),
        WaterQualityCharts.buildStatusPieChart({
          'Safe': _countStatus('Safe'),
          'Warning': _countStatus('Warning'),
          'Critical': _countStatus('Critical'),
        }),
        const SizedBox(height: 24),
        WaterQualityCharts.buildTemperatureConductivityChart(sampleData),
        const SizedBox(height: 24),
        WaterQualityCharts.buildLocationStatus(sampleData),
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
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.darkCream.withOpacity(0.2),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyles.buttonSmall.copyWith(
              color: AppColors.mediumGray,
            ),
          ),
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
    );
  }

  Widget _buildDataTable() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.darkCream.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.darkCream.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Text(
              '📋 Recent Data',
              style: AppTextStyles.heading4.copyWith(
                color: AppColors.charcoal,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              dataRowHeight: 56,
              headingRowColor: MaterialStateColor.resolveWith(
                (states) => AppColors.darkCream.withOpacity(0.05),
              ),
              columns: [
                DataColumn(
                  label: Text(
                    'Location',
                    style: AppTextStyles.buttonSmall.copyWith(
                      color: AppColors.charcoal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'pH',
                    style: AppTextStyles.buttonSmall.copyWith(
                      color: AppColors.charcoal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Turbidity',
                    style: AppTextStyles.buttonSmall.copyWith(
                      color: AppColors.charcoal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Temp',
                    style: AppTextStyles.buttonSmall.copyWith(
                      color: AppColors.charcoal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Status',
                    style: AppTextStyles.buttonSmall.copyWith(
                      color: AppColors.charcoal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              rows: sampleData
                  .map(
                    (data) => DataRow(
                      cells: [
                        DataCell(
                          Text(
                            data['location'],
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.charcoal,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            (data['pH'] as num).toStringAsFixed(1),
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.charcoal,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            (data['turbidity'] as num).toStringAsFixed(1),
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.charcoal,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            '${(data['temperature'] as num).toStringAsFixed(1)}°C',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.charcoal,
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: data['status'] == 'Safe'
                                  ? AppColors.success.withOpacity(0.2)
                                  : data['status'] == 'Warning'
                                      ? AppColors.warning.withOpacity(0.2)
                                      : AppColors.error.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              data['status'],
                              style: AppTextStyles.buttonSmall.copyWith(
                                color: data['status'] == 'Safe'
                                    ? AppColors.success
                                    : data['status'] == 'Warning'
                                        ? AppColors.warning
                                        : AppColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
