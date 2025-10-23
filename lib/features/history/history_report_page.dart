import 'package:flutter/material.dart';
import 'package:pure_health/widgets/custom_map_widget.dart';
import 'package:pure_health/widgets/custom_sidebar.dart';
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
  double _bottomCardHeight = 0.50; // Store as fraction of screen height
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
      // Calculate new height as fraction (subtract because drag down increases Y)
      double newHeightFraction = _bottomCardHeight - (details.delta.dy / screenHeight);
      // Clamp between 0.2 (20%) and 0.9 (90%)
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
          color: const Color(0xFF2A2A2A),
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
          color: const Color(0xFF2A2A2A),
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
        return const Color(0xFF4CAF50);
      case 'Warning':
        return const Color(0xFFFFA726);
      case 'Critical':
        return const Color(0xFFEF5350);
      default:
        return const Color(0xFF9E9E9E);
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
      backgroundColor: const Color(0xFF343434),
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
                  if (index == 0) {
                    context.go('/');
                  } else if (index == 1) {
                    context.go('/profile');
                  } else if (index == 2) {
                    context.go('/history');
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
                  onVerticalDragUpdate: (details) => _handleVerticalDrag(details, screenHeight),
                  onVerticalDragEnd: (details) {
                    setState(() {
                      _isDragging = false;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: _isDragging 
                          ? Colors.white.withOpacity(0.3)
                          : Colors.white.withOpacity(0.1),
                      border: Border(
                        top: BorderSide(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.4),
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
                decoration: const BoxDecoration(
                  color: Color(0xFF343434),
                  borderRadius: BorderRadius.zero,
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
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                            fontFamily: 'SF Pro',
                          ),
                        ),
                        if (actionRequiredCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF5350).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFEF5350).withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  CupertinoIcons.exclamationmark_circle,
                                  size: 14,
                                  color: Color(0xFFEF5350),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '$actionRequiredCount Action Required',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFEF5350),
                                    fontFamily: 'SF Pro',
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
                              color: Colors.white.withOpacity(0.15),
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
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _getStatusColor(_latestSimulation.status),
                        letterSpacing: 0.5,
                        fontFamily: 'SF Pro',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _latestSimulation.location,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                        fontFamily: 'SF Pro',
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
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      '${_latestSimulation.latestResults?['overallScore'] ?? 'N/A'}',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'SF Pro',
                      ),
                    ),
                    Text(
                      'SCORE',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withOpacity(0.6),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        fontFamily: 'SF Pro',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(height: 1, color: Colors.white.withOpacity(0.1)),
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
                const Text(
                  'Historical Reports',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontFamily: 'SF Pro',
                  ),
                ),
                if (_selectedDateRange != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${DateFormat.yMMMd().format(_selectedDateRange!.start)} - ${DateFormat.yMMMd().format(_selectedDateRange!.end)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.6),
                        fontFamily: 'SF Pro',
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
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      minSize: 0,
                      onPressed: _clearFilter,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.xmark_circle,
                            size: 14,
                            color: Colors.white.withOpacity(0.7),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Clear',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.7),
                              fontWeight: FontWeight.w600,
                              fontFamily: 'SF Pro',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                CupertinoButton(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  minSize: 0,
                  onPressed: _selectDateRangeCupertino,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        CupertinoIcons.calendar,
                        size: 14,
                        color: Colors.white,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Date Range',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'SF Pro',
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
                        color: Colors.white.withOpacity(0.3),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No reports found for selected period',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                          fontFamily: 'SF Pro',
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
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              context.go('/reports/${report.id}');
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
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                report.title,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13,
                                                  color: Colors.white,
                                                  fontFamily: 'SF Pro',
                                                ),
                                              ),
                                            ),
                                            if (report.requiresAction)
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    left: 8),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                  vertical: 3,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFEF5350)
                                                      .withOpacity(0.15),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  border: Border.all(
                                                    color: const Color(0xFFEF5350)
                                                        .withOpacity(0.3),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: const Text(
                                                  'ACTION',
                                                  style: TextStyle(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFFEF5350),
                                                    letterSpacing: 0.5,
                                                    fontFamily: 'SF Pro',
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Icon(
                                              CupertinoIcons.location_solid,
                                              size: 11,
                                              color:
                                                  Colors.white.withOpacity(0.6),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              report.location,
                                              style: TextStyle(
                                                color: Colors.white
                                                    .withOpacity(0.6),
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                                fontFamily: 'SF Pro',
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Icon(
                                              CupertinoIcons.time,
                                              size: 11,
                                              color:
                                                  Colors.white.withOpacity(0.6),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              DateFormat('MMM d, y')
                                                  .format(report.date),
                                              style: TextStyle(
                                                color: Colors.white
                                                    .withOpacity(0.6),
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                                fontFamily: 'SF Pro',
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
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: _getStatusColor(report.status),
                                        letterSpacing: 0.3,
                                        fontFamily: 'SF Pro',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    CupertinoIcons.chevron_right,
                                    size: 16,
                                    color: Colors.white.withOpacity(0.5),
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
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            size: 22,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'SF Pro',
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w600,
            fontFamily: 'SF Pro',
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 9,
            color: Colors.white.withOpacity(0.6),
            fontFamily: 'SF Pro',
          ),
        ),
      ],
    );
  }
}
