import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pure_health/core/constants/color_constants.dart';
import 'package:pure_health/core/theme/text_styles.dart';
import 'package:pure_health/core/theme/government_theme.dart';
import 'package:pure_health/core/services/data_export_service.dart';
import 'package:pure_health/shared/widgets/custom_sidebar.dart';
import 'package:pure_health/shared/widgets/skeleton_loader.dart';
import 'package:pure_health/shared/widgets/empty_state_widget.dart';
import 'package:pure_health/shared/widgets/toast_notification.dart';
import 'package:pure_health/shared/widgets/refresh_widgets.dart';
import 'package:pure_health/shared/widgets/advanced_data_table.dart';
import 'package:pure_health/core/data/maharashtra_water_data.dart';

class HistoryReportPage extends StatefulWidget {
  const HistoryReportPage({super.key});

  @override
  State<HistoryReportPage> createState() => _HistoryReportPageState();
}

class _HistoryReportPageState extends State<HistoryReportPage> {
  int _selectedIndex = 3; // History moved after AI Analysis
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
      // Load real Maharashtra data
      final allSamples = MaharashtraWaterQualityData.generateAllSamples(samplesPerStation: 5);
      
      // Convert to history format
      final historyRecords = allSamples.map((sample) {
        String action = 'Routine monitoring';
        if (sample['status'] == 'Warning') {
          action = 'Increased monitoring';
        } else if (sample['status'] == 'Critical') {
          action = 'Emergency response';
        }
        
        return {
          'date': DateTime.parse(sample['timestamp'] as String).toString().split(' ')[0],
          'location': sample['stationName'] as String,
          'pH': sample['pH'],
          'turbidity': sample['turbidity'],
          'dissolvedOxygen': sample['dissolvedOxygen'],
          'temperature': sample['temperature'],
          'conductivity': sample['conductivity'],
          'status': sample['status'],
          'action': action,
          'district': sample['district'],
          'waterBody': sample['waterBody'],
        };
      }).toList();
      
      // Sort by date descending
      historyRecords.sort((a, b) => 
        (b['date'] as String).compareTo(a['date'] as String)
      );
      
      setState(() {
        _historyData = historyRecords;
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
            Row(
              children: [
                Icon(Icons.history, color: AppColors.primaryBlue, size: 32),
                const SizedBox(width: 12),
                Text(
                  'Water Quality History',
                  style: AppTextStyles.heading2.copyWith(
                    color: AppColors.charcoal,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
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
    return Column(
      children: [
        // Header with export buttons
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: GovernmentTheme.governmentBlue.withOpacity(0.05),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            border: Border(
              bottom: BorderSide(
                color: GovernmentTheme.governmentBlue.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Historical Water Quality Records',
                    style: AppTextStyles.heading3.copyWith(
                      color: AppColors.charcoal,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_filteredData.length} records available',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.mediumGray,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildExportButton(
                    icon: CupertinoIcons.doc_text,
                    label: 'Export CSV',
                    onPressed: _exportToCSV,
                  ),
                  const SizedBox(width: 12),
                  _buildExportButton(
                    icon: CupertinoIcons.arrow_down_doc,
                    label: 'Export JSON',
                    onPressed: _exportToJSON,
                  ),
                ],
              ),
            ],
          ),
        ),
        // Advanced Data Table
        AdvancedDataTable(
          columns: const [
            DataTableColumn(
              key: 'date',
              label: 'Date',
              sortable: true,
              filterable: true,
            ),
            DataTableColumn(
              key: 'location',
              label: 'Location',
              sortable: true,
              filterable: true,
            ),
            DataTableColumn(
              key: 'pH',
              label: 'pH Level',
              sortable: true,
              filterable: true,
            ),
            DataTableColumn(
              key: 'turbidity',
              label: 'Turbidity (NTU)',
              sortable: true,
              filterable: true,
            ),
            DataTableColumn(
              key: 'status',
              label: 'Status',
              sortable: true,
              filterable: true,
            ),
            DataTableColumn(
              key: 'action',
              label: 'Action Taken',
              sortable: false,
              filterable: true,
            ),
          ],
          data: _filteredData,
          rowsPerPage: 15,
        ),
      ],
    );
  }

  Widget _buildExportButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: GovernmentTheme.governmentBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Future<void> _exportToCSV() async {
    try {
      final csvContent = await DataExportService.exportToCSV(_filteredData);
      final filename = DataExportService.generateGovernmentFilename('history');
      
      // In production, save file here
      print('CSV Export: $filename\n$csvContent');
      
      if (mounted) {
        ToastNotification.success(context, 'Exported $filename');
      }
    } catch (e) {
      if (mounted) {
        ToastNotification.error(context, 'Export failed');
      }
    }
  }

  Future<void> _exportToJSON() async {
    try {
      final jsonContent = await DataExportService.exportToJSON(_filteredData);
      final filename = DataExportService.generateGovernmentFilename('history');
      
      // In production, save file here
      print('JSON Export: $filename\n$jsonContent');
      
      if (mounted) {
        ToastNotification.success(context, 'Exported $filename.json');
      }
    } catch (e) {
      if (mounted) {
        ToastNotification.error(context, 'Export failed');
      }
    }
  }
}
