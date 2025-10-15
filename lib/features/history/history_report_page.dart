import 'package:flutter/material.dart';
import 'package:pure_health/widgets/custom_sidebar.dart';
import 'package:pure_health/widgets/glass_container.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart'; // Add this package for date formatting
import 'package:flutter/cupertino.dart';

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
  int _selectedIndex = 2; // Assuming 'History' is at index 2 in your sidebar

  // --- State Management for Reports and Filtering ---

  // Dummy data representing all reports from the ML simulation
  final List<Report> _allReports = List.generate(
    20,
    (index) => Report(
      id: 'report_${index + 1}',
      title: 'ML Simulation Report #${index + 1}',
      date: DateTime(2025, 10, 15).subtract(Duration(days: index * 3)), // Reports every 3 days
      details: 'This contains the full analysis and data from the simulation on a given date.',
    ),
  );

  late List<Report> _filteredReports;
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    // Initially, show all reports
    _filteredReports = _allReports;
  }

  // --- Date Picker Logic ---

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

    if (startDate != null && endDate != null) {
      setState(() {
        _selectedDateRange = DateTimeRange(start: startDate, end: endDate);
        final endDateInclusive = endDate.add(const Duration(days: 1));
        _filteredReports = _allReports.where((report) {
          return report.date.isAfter(startDate) && report.date.isBefore(endDateInclusive);
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GlassContainer(
        borderRadius: BorderRadius.zero,
        blur: 18,
        opacity: 0.14,
        padding: EdgeInsets.zero,
        child: Row(
          children: [
            CustomSidebar(
              selectedIndex: _selectedIndex,
              onItemSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: GlassContainer(
                  borderRadius: BorderRadius.circular(32),
                  blur: 12,
                  opacity: 0.18,
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Report History',
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedDateRange == null
                                ? 'Showing all reports'
                                : 'Reports from ${DateFormat.yMMMd().format(_selectedDateRange!.start)} to ${DateFormat.yMMMd().format(_selectedDateRange!.end)}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.black87),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.7),
                              foregroundColor: Colors.black87,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                            ),
                            onPressed: _selectDateRangeCupertino,
                            icon: const Icon(Icons.calendar_today),
                            label: const Text('Select Date Range'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _filteredReports.isEmpty
                            ? const Center(
                                child: Text(
                                  'No reports found for the selected date range.',
                                  style: TextStyle(fontSize: 18, color: Colors.black54),
                                ),
                              )
                            : ListView.builder(
                                itemCount: _filteredReports.length,
                                itemBuilder: (context, index) {
                                  final report = _filteredReports[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: GlassContainer(
                                      borderRadius: BorderRadius.circular(20),
                                      blur: 8,
                                      opacity: 0.22,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      child: ListTile(
                                        leading: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.blue.withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          padding: const EdgeInsets.all(8),
                                          child: const Icon(Icons.description_outlined, color: Colors.blue, size: 28),
                                        ),
                                        title: Text(
                                          report.title,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
                                        ),
                                        subtitle: Text(
                                          'Generated on: ${DateFormat.yMMMd().format(report.date)}',
                                          style: const TextStyle(color: Colors.black54, fontSize: 14),
                                        ),
                                        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black38),
                                        onTap: () {
                                          context.go('/reports/${report.id}');
                                        },
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
            ),
          ],
        ),
      ),
    );
  }
}