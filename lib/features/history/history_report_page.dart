import 'package:flutter/material.dart';
import 'package:pure_health/core/constants/color_constants.dart';
import 'package:pure_health/core/theme/text_styles.dart';
import 'package:pure_health/shared/widgets/custom_map_widget.dart';
import 'package:pure_health/shared/widgets/custom_sidebar.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';

class Report {
  final String id;
  final String title;
  final DateTime date;
  final String details;
  final String status;
  final String location;
  final Map<String, dynamic>? latestResults;
  final int criticalParameters;
  final bool requiresAction;

  Report({
    required this.id,
    required this.title,
    required this.date,
    required this.details,
    this.status = "Safe",
    this.location = "Unknown",
    this.latestResults,
    this.criticalParameters = 0,
    this.requiresAction = false,
  });
}

class HistoryReportPage extends StatefulWidget {
  const HistoryReportPage({super.key});

  @override
  State<HistoryReportPage> createState() => _HistoryReportPageState();
}

class _HistoryReportPageState extends State<HistoryReportPage> {
  int _selectedIndex = 2;
  bool _isSidebarExpanded = false;
  double _bottomCardHeight = 0.50;
  bool _isDragging = false;

  final Report _latestSimulation = Report(
    id: 'latest',
    title: 'Live Water Quality Status',
    date: DateTime.now(),
    details: 'Real-time groundwater analysis',
    status: 'Safe',
    location: 'Main Distribution Network',
    criticalParameters: 0,
    requiresAction: false,
    latestResults: {
      'pH': 7.2,
      'turbidity': 2.1,
      'lead': 0.005,
      'arsenic': 0.003,
      'overallScore': 92,
      'samplesAnalyzed': 48,
      'alertsCount': 0,
    },
  );

  final List<Report> _allReports = List.generate(
    20,
    (index) => Report(
      id: 'report_${index + 1}',
      title: 'Water Quality Report #${index + 1}',
      date: DateTime(2025, 10, 15).subtract(Duration(days: index * 3)),
      details: 'Comprehensive analysis report',
      status: index % 5 == 0
          ? 'Critical'
          : index % 3 == 0
              ? 'Warning'
              : 'Safe',
      location: index % 2 == 0 ? 'Zone A' : 'Zone B',
      criticalParameters: index % 5 == 0 ? 2 : 0,
      requiresAction: index % 5 == 0,
    ),
  );

  late List<Report> _filteredReports;
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _filteredReports = _allReports;
  }

  void _handleVerticalDrag(DragUpdateDetails details, double screenHeight) {
    setState(() {
      _isDragging = true;
      double newHeightFraction = _bottomCardHeight - (details.delta.dy / screenHeight);
      _bottomCardHeight = newHeightFraction.clamp(0.2, 0.9);
    });
  }

  Future<void> _selectDateRangeCupertino() async {
    DateTime startDate = _selectedDateRange?.start ??
        DateTime.now().subtract(const Duration(days: 30));
    DateTime endDate = _selectedDateRange?.end ?? DateTime.now();

    await showCupertinoModalPopup(
      context: context,
      builder: (context) {
        DateTime tempDate = startDate;
        return Container(
          height: 300,
          color: AppColors.white,
          child: Column(
            children: [
              SizedBox(
                height: 200,
                child: CupertinoDatePicker(
                  initialDateTime: startDate,
                  mode: CupertinoDatePickerMode.date,
                  maximumDate: DateTime.now(),
                  minimumDate: DateTime(2024),
                  onDateTimeChanged: (date) {
                    tempDate = date;
                  },
                ),
              ),
              CupertinoButton(
                child: const Text('Select Start Date'),
                onPressed: () {
                  startDate = tempDate;
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );

    await showCupertinoModalPopup(
      context: context,
      builder: (context) {
        DateTime tempDate = endDate;
        return Container(
          height: 300,
          color: AppColors.white,
          child: Column(
            children: [
              SizedBox(
                height: 200,
                child: CupertinoDatePicker(
                  initialDateTime: endDate,
                  mode: CupertinoDatePickerMode.date,
                  maximumDate: DateTime.now(),
                  minimumDate: startDate,
                  onDateTimeChanged: (date) {
                    tempDate = date;
                  },
                ),
              ),
              CupertinoButton(
                child: const Text('Select End Date'),
                onPressed: () {
                  endDate = tempDate;
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );

    setState(() {
      _selectedDateRange = DateTimeRange(start: startDate, end: endDate);
      final endDateInclusive = endDate.add(const Duration(days: 1));
      _filteredReports = _allReports.where((report) {
        return report.date.isAfter(startDate) &&
            report.date.isBefore(endDateInclusive);
      }).toList();
    });
  }

  void _clearFilter() {
    setState(() {
      _selectedDateRange = null;
      _filteredReports = _allReports;
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
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

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Safe':
        return CupertinoIcons.checkmark_circle_fill;
      case 'Warning':
        return CupertinoIcons.exclamationmark_triangle_fill;
      case 'Critical':
        return CupertinoIcons.exclamationmark_circle_fill;
      default:
        return CupertinoIcons.info_circle_fill;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomCardHeight = screenHeight * _bottomCardHeight;
    final sidebarWidth = _isSidebarExpanded ? 216.0 : 88.0;

    final actionRequiredCount =
        _filteredReports.where((r) => r.requiresAction).length;

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
            Positioned.fill(
              child: CustomMapWidget(),
            ),
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
                  if (context.mounted) {
                    switch (index) {
                      case 0:
                        context.go('/');
                        break;
                      case 2:
                        context.go('/history');
                        break;
                    }
                  }
                },
              ),
            ),
            // Drag handle bar
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: sidebarWidth,
              right: 0,
              bottom: bottomCardHeight,
              height: 8,
              child: MouseRegion(
                cursor: SystemMouseCursors.resizeUpDown,
                child: GestureDetector(
                  onVerticalDragUpdate: (details) =>
                      _handleVerticalDrag(details, screenHeight),
                  onVerticalDragEnd: (details) {
                    setState(() {
                      _isDragging = false;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: _isDragging
                          ? AppColors.darkCream.withOpacity(0.3)
                          : AppColors.darkCream.withOpacity(0.1),
                      border: Border(
                        top: BorderSide(
                          color: AppColors.darkCream.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.darkCream.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Bottom content panel
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: sidebarWidth,
              right: 0,
              bottom: 0,
              height: bottomCardHeight,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.zero,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.charcoal.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Last updated: ${DateFormat('MMM d, y • HH:mm').format(_latestSimulation.date)}',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.mediumGray,
                          ),
                        ),
                        if (actionRequiredCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.error.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  CupertinoIcons.exclamationmark_circle,
                                  size: 14,
                                  color: AppColors.error,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '$actionRequiredCount Action Required',
                                  style: AppTextStyles.buttonSmall.copyWith(
                                    color: AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: _buildHistoricalReportsPanel(),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Container(
                              width: 1,
                              color: AppColors.darkCream.withOpacity(0.2),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: SingleChildScrollView(
                              child: _buildCurrentStatusPanel(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStatusPanel() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkCream.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.darkCream.withOpacity(0.2),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getStatusColor(_latestSimulation.status)
                      .withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _getStatusColor(_latestSimulation.status)
                        .withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  _getStatusIcon(_latestSimulation.status),
                  size: 24,
                  color: _getStatusColor(_latestSimulation.status),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _latestSimulation.status.toUpperCase(),
                      style: AppTextStyles.heading4.copyWith(
                        color: _getStatusColor(_latestSimulation.status),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _latestSimulation.location,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.mediumGray,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.darkCream.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.darkCream.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      '${_latestSimulation.latestResults?['overallScore'] ?? 'N/A'}',
                      style: AppTextStyles.heading1.copyWith(
                        color: AppColors.charcoal,
                      ),
                    ),
                    Text(
                      'SCORE',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.mediumGray,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(
            height: 1,
            color: AppColors.darkCream.withOpacity(0.2),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetricCard(
                'pH Level',
                '${_latestSimulation.latestResults?['pH'] ?? 'N/A'}',
                'Normal: 6.5-8.5',
                CupertinoIcons.drop_fill,
              ),
              _buildMetricCard(
                'Turbidity',
                '${_latestSimulation.latestResults?['turbidity'] ?? 'N/A'} NTU',
                'Limit: <5 NTU',
                CupertinoIcons.eye_fill,
              ),
              _buildMetricCard(
                'Samples',
                '${_latestSimulation.latestResults?['samplesAnalyzed'] ?? 'N/A'}',
                'Last 24h',
                CupertinoIcons.chart_bar_fill,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoricalReportsPanel() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Historical Reports',
                  style: AppTextStyles.heading4.copyWith(
                    color: AppColors.charcoal,
                  ),
                ),
                if (_selectedDateRange != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${DateFormat.yMMMd().format(_selectedDateRange!.start)} - ${DateFormat.yMMMd().format(_selectedDateRange!.end)}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.mediumGray,
                      ),
                    ),
                  ),
              ],
            ),
            Row(
              children: [
                if (_selectedDateRange != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: CupertinoButton(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      color: AppColors.darkCream.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      minSize: 0,
                      onPressed: _clearFilter,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.xmark_circle,
                            size: 14,
                            color: AppColors.mediumGray,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Clear',
                            style: AppTextStyles.buttonSmall.copyWith(
                              color: AppColors.mediumGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                CupertinoButton(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  color: AppColors.darkCream.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  minSize: 0,
                  onPressed: _selectDateRangeCupertino,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.calendar,
                        size: 14,
                        color: AppColors.charcoal,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Date Range',
                        style: AppTextStyles.buttonSmall.copyWith(
                          color: AppColors.charcoal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _filteredReports.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.doc_text_search,
                        size: 48,
                        color: AppColors.darkCream.withOpacity(0.3),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No reports found for selected period',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.mediumGray,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _filteredReports.length,
                  itemBuilder: (context, index) {
                    final report = _filteredReports[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.darkCream.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.darkCream.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              // Navigate to report details
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 3,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(report.status),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(report.status)
                                          .withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: _getStatusColor(report.status)
                                            .withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Icon(
                                      CupertinoIcons.doc_text_fill,
                                      color: _getStatusColor(report.status),
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          report.title,
                                          style: AppTextStyles.button.copyWith(
                                            color: AppColors.charcoal,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Icon(
                                              CupertinoIcons.location_solid,
                                              size: 11,
                                              color: AppColors.mediumGray,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              report.location,
                                              style: AppTextStyles.bodySmall
                                                  .copyWith(
                                                color: AppColors.mediumGray,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Icon(
                                              CupertinoIcons.time,
                                              size: 11,
                                              color: AppColors.mediumGray,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              DateFormat('MMM d, y')
                                                  .format(report.date),
                                              style: AppTextStyles.bodySmall
                                                  .copyWith(
                                                color: AppColors.mediumGray,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(report.status)
                                          .withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: _getStatusColor(report.status)
                                            .withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      report.status.toUpperCase(),
                                      style: AppTextStyles.buttonSmall.copyWith(
                                        color: _getStatusColor(report.status),
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    CupertinoIcons.chevron_right,
                                    size: 16,
                                    color: AppColors.mediumGray,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String label,
    String value,
    String subtitle,
    IconData icon,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.darkCream.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.darkCream.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            size: 22,
            color: AppColors.darkVanilla,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.heading4.copyWith(
            color: AppColors.charcoal,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.charcoal,
          ),
        ),
        Text(
          subtitle,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.mediumGray,
          ),
        ),
      ],
    );
  }
}
