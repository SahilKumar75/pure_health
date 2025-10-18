import 'package:flutter/material.dart';
import 'package:pure_health/widgets/custom_map_widget.dart';
import 'package:pure_health/widgets/custom_sidebar.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:pure_health/widgets/glass_container.dart';


// A simple data model for the reports
class Report {
  final String id;
  final String title;
  final DateTime date;
  final String details;


  Report({
    required this.id,
    required this.title,
    required this.date,
    required this.details,
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


  // Dummy data representing all reports from the ML simulation
  final List<Report> _allReports = List.generate(
    20,
    (index) => Report(
      id: 'report_${index + 1}',
      title: 'ML Simulation Report #${index + 1}',
      date: DateTime(2025, 10, 15).subtract(Duration(days: index * 3)),
      details: 'This contains the full analysis and data from the simulation on a given date.',
    ),
  );


  late List<Report> _filteredReports;
  DateTimeRange? _selectedDateRange;


  @override
  void initState() {
    super.initState();
    _filteredReports = _allReports;
  }


  Future<void> _selectDateRangeCupertino() async {
    DateTime startDate = _selectedDateRange?.start ?? DateTime.now().subtract(const Duration(days: 30));
    DateTime endDate = _selectedDateRange?.end ?? DateTime.now();


    // Select start date
    await showCupertinoModalPopup(
      context: context,
      builder: (context) {
        DateTime tempDate = startDate;
        return Container(
          height: 300,
          color: Colors.white,
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


    // Select end date
    await showCupertinoModalPopup(
      context: context,
      builder: (context) {
        DateTime tempDate = endDate;
        return Container(
          height: 300,
          color: Colors.white,
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
        return report.date.isAfter(startDate) && report.date.isBefore(endDateInclusive);
      }).toList();
    });
  }


  void _clearFilter() {
    setState(() {
      _selectedDateRange = null;
      _filteredReports = _allReports;
    });
  }


  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomCardHeight = screenHeight * 0.35; // 35% of screen height
    // Dynamic sidebar width based on expansion state
    final sidebarWidth = _isSidebarExpanded ? 216.0 : 88.0;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: NotificationListener<SidebarExpandNotification>(
        onNotification: (notification) {
          setState(() {
            _isSidebarExpanded = notification.isExpanded;
          });
          return true;
        },
        child: Stack(
          children: [
            // Full screen map (behind everything, under sidebar too)
            Positioned.fill(
              child: CustomMapWidget(),
            ),
            // Sidebar on top of map
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
            // Bottom card - animates with sidebar expansion
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: sidebarWidth,
              right: 0,
              bottom: 0,
              height: bottomCardHeight,
              child: GlassContainer(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                blur: 16,
                opacity: 0.15,
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Report History',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Row(
                          children: [
                            if (_selectedDateRange != null)
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: CupertinoButton(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  color: CupertinoColors.systemGrey5,
                                  borderRadius: BorderRadius.circular(10),
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
                                        'Clear',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: CupertinoColors.systemGrey,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            CupertinoButton(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              color: CupertinoColors.activeBlue,
                              borderRadius: BorderRadius.circular(10),
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
                                    'Select Date',
                                    style: TextStyle(
                                      fontSize: 13,
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
                    const SizedBox(height: 8),
                    Text(
                      _selectedDateRange == null
                          ? 'Showing all reports'
                          : 'From ${DateFormat.yMMMd().format(_selectedDateRange!.start)} to ${DateFormat.yMMMd().format(_selectedDateRange!.end)}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
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
                                    color: Colors.grey.withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'No reports found',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black54,
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
                                  child: GlassContainer(
                                    borderRadius: BorderRadius.circular(12),
                                    blur: 8,
                                    opacity: 0.15,
                                    padding: EdgeInsets.zero,
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
                                                decoration: BoxDecoration(
                                                  gradient: const LinearGradient(
                                                    colors: [
                                                      CupertinoColors.activeBlue,
                                                      CupertinoColors.systemBlue,
                                                    ],
                                                  ),
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                padding: const EdgeInsets.all(10),
                                                child: const Icon(
                                                  CupertinoIcons.doc_text_fill,
                                                  color: Colors.white,
                                                  size: 22,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      report.title,
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 15,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 3),
                                                    Text(
                                                      'Generated: ${DateFormat.yMMMd().format(report.date)}',
                                                      style: const TextStyle(
                                                        color: Colors.black54,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const Icon(
                                                CupertinoIcons.chevron_right,
                                                size: 18,
                                                color: Colors.black38,
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
