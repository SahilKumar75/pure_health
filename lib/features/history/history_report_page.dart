import 'package:flutter/material.dart';
import 'package:pure_health/widgets/custom_sidebar.dart';
import 'package:pure_health/widgets/glass_container.dart';
import 'package:go_router/go_router.dart';

class HistoryReportPage extends StatefulWidget {
  const HistoryReportPage({Key? key}) : super(key: key);

  @override
  State<HistoryReportPage> createState() => _HistoryReportPageState();
}

class _HistoryReportPageState extends State<HistoryReportPage> {
  int _selectedIndex = 2;

  void _onItemSelected(int index) {
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
              onItemSelected: _onItemSelected,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Report History',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: 5, // Example count
                        itemBuilder: (context, index) {
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              leading: const Icon(Icons.description),
                              title: Text('Report #${index + 1}'),
                              subtitle: const Text('Details about this report...'),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () {
                                // Navigate to report details
                              },
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
