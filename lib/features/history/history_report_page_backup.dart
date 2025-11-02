import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pure_health/core/constants/color_constants.dart';
import 'package:pure_health/core/theme/text_styles.dart';
import 'package:pure_health/shared/widgets/custom_sidebar.dart';

class HistoryReportPage extends StatefulWidget {
  const HistoryReportPage({super.key});

  @override
  State<HistoryReportPage> createState() => _HistoryReportPageState();
}

class _HistoryReportPageState extends State<HistoryReportPage> {
  int _selectedIndex = 2;

  final List<Map<String, dynamic>> historyData = [
    {
      'date': '2025-11-02',
      'location': 'Zone A',
      'pH': 7.2,
      'turbidity': 2.1,
      'status': 'Safe',
      'action': 'Routine monitoring'
    },
    {
      'date': '2025-11-01',
      'location': 'Zone B',
      'pH': 6.8,
      'turbidity': 3.5,
      'status': 'Warning',
      'action': 'Increased monitoring'
    },
    {
      'date': '2025-10-31',
      'location': 'Zone C',
      'pH': 5.5,
      'turbidity': 8.2,
      'status': 'Critical',
      'action': 'Emergency response'
    },
    {
      'date': '2025-10-30',
      'location': 'Zone A',
      'pH': 7.1,
      'turbidity': 2.0,
      'status': 'Safe',
      'action': 'Routine monitoring'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightCream,
      body: Row(
        children: [
          CustomSidebar(
            selectedIndex: _selectedIndex,
            onItemSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    '📋 Water Quality History',
                    style: AppTextStyles.heading2.copyWith(
                      color: AppColors.charcoal,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'View historical water quality records and actions taken',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.mediumGray,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Filter Section
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search by location...',
                            prefixIcon: Icon(
                              CupertinoIcons.search,
                              color: AppColors.darkVanilla,
                            ),
                            filled: true,
                            fillColor: AppColors.darkCream.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppColors.darkVanilla,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.tune),
                        label: const Text('Filter'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkVanilla,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),

                    ],
                  ),
                  const SizedBox(height: 24),
                  // History Table
                  Container(
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
                            'Water Quality Records',
                            style: AppTextStyles.heading4.copyWith(
                              color: AppColors.charcoal,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            dataRowHeight: 60,
                            headingRowColor: MaterialStateColor.resolveWith(
                              (states) =>
                                  AppColors.darkCream.withOpacity(0.05),
                            ),
                            columns: [
                              DataColumn(
                                label: Text(
                                  'Date',
                                  style: AppTextStyles.buttonSmall.copyWith(
                                    color: AppColors.charcoal,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
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
                                  'Status',
                                  style: AppTextStyles.buttonSmall.copyWith(
                                    color: AppColors.charcoal,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Action Taken',
                                  style: AppTextStyles.buttonSmall.copyWith(
                                    color: AppColors.charcoal,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                            rows: historyData
                                .map(
                                  (record) => DataRow(
                                    cells: [
                                      DataCell(
                                        Text(
                                          record['date'],
                                          style: AppTextStyles.body.copyWith(
                                            color: AppColors.charcoal,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          record['location'],
                                          style: AppTextStyles.body.copyWith(
                                            color: AppColors.charcoal,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          (record['pH'] as num)
                                              .toStringAsFixed(1),
                                          style: AppTextStyles.body.copyWith(
                                            color: AppColors.charcoal,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          (record['turbidity'] as num)
                                              .toStringAsFixed(1),
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
                                            color: record['status'] == 'Safe'
                                                ? AppColors.success
                                                    .withOpacity(0.2)
                                                : record['status'] == 'Warning'
                                                    ? AppColors.warning
                                                        .withOpacity(0.2)
                                                    : AppColors.error
                                                        .withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            record['status'],
                                            style:
                                                AppTextStyles.buttonSmall
                                                    .copyWith(
                                              color: record['status'] == 'Safe'
                                                  ? AppColors.success
                                                  : record['status'] ==
                                                          'Warning'
                                                      ? AppColors.warning
                                                      : AppColors.error,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          record['action'],
                                          style: AppTextStyles.body.copyWith(
                                            color: AppColors.charcoal,
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
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
