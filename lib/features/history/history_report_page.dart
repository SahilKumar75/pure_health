import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pure_health/core/constants/color_constants.dart';
import 'package:pure_health/core/theme/text_styles.dart';
import 'package:pure_health/shared/widgets/custom_sidebar.dart';
import 'package:pure_health/shared/widgets/skeleton_loader.dart';
import 'package:pure_health/shared/widgets/empty_state_widget.dart';
import 'package:pure_health/shared/widgets/toast_notification.dart';
import 'package:pure_health/shared/widgets/refresh_widgets.dart';

class HistoryReportPage extends StatefulWidget {
  const HistoryReportPage({super.key});

  @override
  State<HistoryReportPage> createState() => _HistoryReportPageState();
}

class _HistoryReportPageState extends State<HistoryReportPage> {
  int _selectedIndex = 2;
  bool _isLoading = true;
  List<Map<String, dynamic>> _historyData = [];
  List<Map<String, dynamic>> _filteredData = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadHistoryData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadHistoryData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    
    if (mounted) {
      setState(() {
        _historyData = [
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
        _filteredData = List.from(_historyData);
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshHistory() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    await _loadHistoryData();
    if (mounted) {
      ToastNotification.success(context, 'History refreshed!');
    }
  }

  void _filterData(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredData = List.from(_historyData);
      } else {
        _filteredData = _historyData
            .where((record) =>
                record['location']
                    .toString()
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                record['status']
                    .toString()
                    .toLowerCase()
                    .contains(query.toLowerCase()))
            .toList();
      }
    });
    ToastNotification.info(
      context,
      'Found ${_filteredData.length} records',
    );
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
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
          Expanded(
            child: _isLoading ? _buildLoadingState() : _buildHistoryContent(),
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
          SkeletonLoader(
            width: 350,
            height: 32,
            borderRadius: BorderRadius.circular(8),
          ),
          const SizedBox(height: 8),
          SkeletonLoader(
            width: 450,
            height: 16,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: SkeletonLoader(
                  width: double.infinity,
                  height: 56,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 12),
              SkeletonLoader(
                width: 120,
                height: 56,
                borderRadius: BorderRadius.circular(12),
              ),
            ],
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

  Widget _buildHistoryContent() {
    return CustomRefreshWrapper(
      onRefresh: _refreshHistory,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
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
                  controller: _searchController,
                  onChanged: (value) {},
                  decoration: InputDecoration(
                    hintText: 'Search by location or status...',
                    hintStyle: AppTextStyles.body.copyWith(
                      color: AppColors.mediumGray,
                    ),
                    prefixIcon: Icon(
                      CupertinoIcons.search,
                      color: AppColors.darkVanilla,
                    ),
                    filled: true,
                    fillColor: AppColors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.darkCream.withOpacity(0.2),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.accentPink,
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.darkCream.withOpacity(0.2),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              CupertinoButton(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                color: AppColors.accentPink,
                borderRadius: BorderRadius.circular(12),
                onPressed: () => _filterData(_searchController.text),
                child: Row(
                  children: [
                    const Icon(CupertinoIcons.search, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Search',
                      style: AppTextStyles.button.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              CupertinoButton(
                padding: const EdgeInsets.all(16),
                color: AppColors.darkVanilla,
                borderRadius: BorderRadius.circular(12),
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                    _filteredData = List.from(_historyData);
                  });
                  ToastNotification.info(context, 'Filters cleared');
                },
                child: const Icon(CupertinoIcons.refresh, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // History Table or Empty State
          _filteredData.isEmpty
              ? EmptyStates.noResults()
              : _buildHistoryTable(),
        ],
      ),
      ),
    );
  }

  Widget _buildHistoryTable() {
    return Container(
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Water Quality Records',
                  style: AppTextStyles.heading4.copyWith(
                    color: AppColors.charcoal,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentPink.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_filteredData.length} records',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.accentPink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              dataRowHeight: 60,
              headingRowColor: MaterialStateColor.resolveWith(
                (states) => AppColors.darkCream.withOpacity(0.05),
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
              rows: _filteredData
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
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            (record['pH'] as num).toStringAsFixed(1),
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.charcoal,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            (record['turbidity'] as num).toStringAsFixed(1),
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.charcoal,
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: record['status'] == 'Safe'
                                  ? AppColors.success.withOpacity(0.15)
                                  : record['status'] == 'Warning'
                                      ? AppColors.warning.withOpacity(0.15)
                                      : AppColors.error.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              record['status'],
                              style: AppTextStyles.buttonSmall.copyWith(
                                color: record['status'] == 'Safe'
                                    ? AppColors.success
                                    : record['status'] == 'Warning'
                                        ? AppColors.warning
                                        : AppColors.error,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            record['action'],
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.mediumGray,
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
