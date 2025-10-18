import 'package:flutter/material.dart';
import 'package:pure_health/widgets/custom_map_widget.dart';
import 'package:pure_health/widgets/custom_sidebar.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';

// Enhanced data model (no changes)
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

  // --- Data (no changes) ---
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

  // --- Helper Functions (no changes) ---

  Future<void> _selectDateRangeCupertino() async {
    DateTime startDate = _selectedDateRange?.start ??
        DateTime.now().subtract(const Duration(days: 30));
    DateTime endDate = _selectedDateRange?.end ?? DateTime.now();

    // First popup for start date
    await showCupertinoModalPopup(
      context: context,
      builder: (context) {
        DateTime tempDate = startDate;
        return Container(
          height: 300,
          color: CupertinoColors.systemBackground.resolveFrom(context),
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

    // Second popup for end date
    await showCupertinoModalPopup(
      context: context,
      builder: (context) {
        DateTime tempDate = endDate;
        return Container(
          height: 300,
          color: CupertinoColors.systemBackground.resolveFrom(context),
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
        return CupertinoColors.systemGreen;
      case 'Warning':
        return CupertinoColors.systemOrange;
      case 'Critical':
        return CupertinoColors.systemRed;
      default:
        return CupertinoColors.systemGrey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Safe':
        return CupertinoIcons.checkmark_shield_fill;
      case 'Warning':
        return CupertinoIcons.exclamationmark_triangle_fill;
      case 'Critical':
        return CupertinoIcons.xmark_octagon_fill;
      default:
        return CupertinoIcons.info_circle_fill;
    }
  }

  // --- Build Method (Restructured) ---

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomCardHeight = screenHeight * 0.50;
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
            // --- Map Background ---
            Positioned.fill(
              child: CustomMapWidget(),
            ),
            // --- Sidebar ---
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
            // --- Main Content Card (Restructured) ---
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
                  // Main container is now a Column
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- 1. ADMIN OVERVIEW HEADER (Stays at top) ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Water Quality Monitoring',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Last updated: ${DateFormat('MMM d, y • HH:mm').format(_latestSimulation.date)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        if (actionRequiredCount > 0)
                          _buildActionRequiredBadge(actionRequiredCount),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // --- 2. SIDE-BY-SIDE CONTENT (SWAPPED) ---
                    Expanded(
                      // This Expanded makes the Row fill the remaining vertical space
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- (NOW ON LEFT) HISTORICAL REPORTS ---
                          Expanded(
                            flex: 2, // Takes 2 parts of the space (CHANGED)
                            child: _buildHistoricalReportsPanel(),
                          ),

                          // --- Vertical Divider (CHANGED) ---
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Container(
                              width: 1,
                              color: Colors.white.withOpacity(0.2), // A subtle divider
                            ),
                          ),

                          // --- (NOW ON RIGHT) CURRENT STATUS ---
                          Expanded(
                            flex: 3, // Takes 3 parts of the space (CHANGED)
                            child: SingleChildScrollView(
                              // Makes this panel scrollable if content overflows
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

  // --- New Widget Methods for Cleanliness ---

  Widget _buildActionRequiredBadge(int actionRequiredCount) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: CupertinoColors.systemRed.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: CupertinoColors.systemRed,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            CupertinoIcons.exclamationmark_circle_fill,
            size: 16,
            color: CupertinoColors.systemRed,
          ),
          const SizedBox(width: 6),
          Text(
            '$actionRequiredCount Action Required',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.systemRed,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStatusPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getStatusColor(_latestSimulation.status)
                      .withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getStatusColor(_latestSimulation.status),
                    width: 2,
                  ),
                ),
                child: Icon(
                  _getStatusIcon(_latestSimulation.status),
                  size: 28,
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(_latestSimulation.status),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _latestSimulation.location,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
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
                  gradient: LinearGradient(
                    colors: [
                      CupertinoColors.activeBlue,
                      CupertinoColors.systemBlue.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      '${_latestSimulation.latestResults?['overallScore'] ?? 'N/A'}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'SCORE',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetricCard(
                'pH Level',
                '${_latestSimulation.latestResults?['pH'] ?? 'N/A'}',
                'Normal: 6.5-8.5',
                CupertinoIcons.drop_fill,
                CupertinoColors.systemBlue,
              ),
              _buildMetricCard(
                'Turbidity',
                '${_latestSimulation.latestResults?['turbidity'] ?? 'N/A'} NTU',
                'Limit: <5 NTU',
                CupertinoIcons.eye_fill,
                CupertinoColors.systemTeal,
              ),
              _buildMetricCard(
                'Samples',
                '${_latestSimulation.latestResults?['samplesAnalyzed'] ?? 'N/A'}',
                'Last 24h',
                CupertinoIcons.chart_bar_fill,
                CupertinoColors.systemGreen,
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
        // --- HISTORICAL REPORTS HEADER ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Historical Reports',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.white,
                  ),
                ),
                if (_selectedDateRange != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${DateFormat.yMMMd().format(_selectedDateRange!.start)} - ${DateFormat.yMMMd().format(_selectedDateRange!.end)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white70,
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
                          horizontal: 12, vertical: 6),
                      color: CupertinoColors.systemGrey5.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      minSize: 0,
                      onPressed: _clearFilter,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            CupertinoIcons.xmark_circle_fill,
                            size: 14,
                            color: CupertinoColors.systemGrey,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Clear Filter',
                            style: TextStyle(
                              fontSize: 12,
                              color: CupertinoColors.systemGrey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                CupertinoButton(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  color: CupertinoColors.activeBlue,
                  borderRadius: BorderRadius.circular(8),
                  minSize: 0,
                  onPressed: _selectDateRangeCupertino,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        CupertinoIcons.calendar,
                        size: 16,
                        color: Colors.white,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Date Range',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
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

        // --- REPORTS LIST (SCROLLABLE) ---
        Expanded(
          // This makes the list fill the vertical space
          child: _filteredReports.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.doc_text_search,
                          size: 48,
                          color: Colors.white.withOpacity(0.4),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No reports found for selected period',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  // Use ListView.builder for scrolling
                  itemCount: _filteredReports.length,
                  itemBuilder: (context, index) {
                    final report = _filteredReports[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: EdgeInsets.zero,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              context.go('/reports/${report.id}');
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(report.status),
                                      borderRadius:
                                          BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          _getStatusColor(report.status),
                                          _getStatusColor(report.status)
                                              .withOpacity(0.7),
                                        ],
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      CupertinoIcons.doc_chart_fill,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
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
                                                  fontWeight:
                                                      FontWeight.w600,
                                                  fontSize: 14,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            if (report.requiresAction)
                                              Container(
                                                margin:
                                                    const EdgeInsets.only(
                                                        left: 8),
                                                padding:
                                                    const EdgeInsets
                                                        .symmetric(
                                                  horizontal: 6,
                                                  vertical: 3,
                                                ),
                                                decoration:
                                                    BoxDecoration(
                                                  color: CupertinoColors
                                                      .systemRed
                                                      .withOpacity(0.15),
                                                  borderRadius:
                                                      BorderRadius
                                                          .circular(5),
                                                ),
                                                child: const Text(
                                                  'ACTION',
                                                  style: TextStyle(
                                                    fontSize: 9,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    color: CupertinoColors
                                                        .systemRed,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 5),
                                        Row(
                                          children: [
                                            const Icon(
                                              CupertinoIcons.location_solid,
                                              size: 11,
                                              color: Colors.white70,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              report.location,
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 11,
                                                fontWeight:
                                                    FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            const Icon(
                                              CupertinoIcons.time,
                                              size: 11,
                                              color: Colors.white70,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              DateFormat('MMM d, y')
                                                  .format(report.date),
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 11,
                                                fontWeight:
                                                    FontWeight.w500,
                                              ),
                                            ),
                                            if (report.criticalParameters >
                                                0) ...[
                                              const SizedBox(width: 12),
                                              const Icon(
                                                CupertinoIcons
                                                    .exclamationmark_triangle_fill,
                                                size: 11,
                                                color: CupertinoColors
                                                    .systemOrange,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${report.criticalParameters} critical',
                                                style: const TextStyle(
                                                  color: CupertinoColors
                                                      .systemOrange,
                                                  fontSize: 11,
                                                  fontWeight:
                                                      FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Container(
                                        padding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(
                                                  report.status)
                                              .withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(7),
                                          border: Border.all(
                                            color: _getStatusColor(
                                                report.status),
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          report.status.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: _getStatusColor(
                                                report.status),
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 10),
                                  const Icon(
                                    CupertinoIcons.chevron_right,
                                    size: 18,
                                    color: Colors.white70,
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
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 22,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: CupertinoColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 9,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}