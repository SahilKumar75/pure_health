import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pure_health/core/constants/color_constants.dart';
import 'package:pure_health/core/theme/text_styles.dart';
import 'package:pure_health/core/services/report_service.dart';
import 'package:pure_health/core/services/data_export_service.dart';
import 'package:pure_health/shared/widgets/custom_sidebar.dart';
import 'package:pure_health/shared/widgets/skeleton_loader.dart';
import 'package:pure_health/shared/widgets/empty_state_widget.dart';
import 'package:pure_health/shared/widgets/toast_notification.dart';
import 'package:pure_health/shared/widgets/enhanced_loading_widget.dart';
import 'package:pure_health/shared/widgets/refresh_widgets.dart';
import 'package:pure_health/core/data/maharashtra_water_data.dart';
import 'package:printing/printing.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({Key? key}) : super(key: key);

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  int _selectedIndex = 6;
  bool _isGenerating = false;
  bool _isInitialLoading = true;
  List<Map<String, dynamic>> _recentReports = [];
  
  // Advanced filtering
  DateTimeRange? _selectedDateRange;
  String _selectedLocation = 'All Locations';
  String _reportType = 'Comprehensive';
  
  // Get real Maharashtra districts
  List<String> get _locations => ['All Locations', ...MaharashtraWaterData.getDistricts()];
  final List<String> _reportTypes = ['Comprehensive', 'Compliance Only', 'Trends Only', 'Summary'];

  // Real Maharashtra water quality data
  List<Map<String, dynamic>> get sampleData {
    final allSamples = MaharashtraWaterQualityData.generateAllSamples(samplesPerStation: 2);
    
    // Filter by selected location
    if (_selectedLocation != 'All Locations') {
      return allSamples.where((s) => s['district'] == _selectedLocation).toList();
    }
    
    return allSamples.take(50).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadRecentReports();
  }

  Future<void> _loadRecentReports() async {
    setState(() => _isInitialLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (mounted) {
      setState(() {
        _recentReports = [
          {
            'title': 'Weekly Report - Nov 02, 2025',
            'format': 'PDF',
            'size': '2.4 MB',
            'date': '2025-11-02'
          },
          {
            'title': 'Monthly Analysis - October',
            'format': 'Excel',
            'size': '1.8 MB',
            'date': '2025-10-31'
          },
          {
            'title': 'Quarterly Review Q3',
            'format': 'PDF',
            'size': '5.2 MB',
            'date': '2025-09-30'
          },
        ];
        _isInitialLoading = false;
      });
    }
  }

  Future<void> _refreshReports() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    await _loadRecentReports();
    if (mounted) {
      ToastNotification.success(context, 'Reports refreshed!');
    }
  }

  Future<void> _generateAndPreviewPDF() async {
    setState(() => _isGenerating = true);

    try {
      final pdfBytes = await ReportService.generatePDFReport(
        title: 'Water Quality Analysis Report',
        organization: 'Department of Water Resources',
        data: sampleData,
        generatedBy: 'Admin',
      );

      if (mounted) {
        await Printing.layoutPdf(
          onLayout: (_) => pdfBytes,
        );
        ToastNotification.success(context, 'PDF generated successfully!');
      }
    } catch (e) {
      if (mounted) {
        ToastNotification.error(context, 'Failed to generate PDF');
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  Future<void> _downloadCSV() async {
    try {
      setState(() => _isGenerating = true);
      final csvContent = await DataExportService.exportToCSV(sampleData);
      final filename = '${DataExportService.generateGovernmentFilename('water_quality')}.csv';
      
      print('CSV Generated: $filename\n$csvContent');
      
      if (mounted) {
        ToastNotification.success(context, 'CSV exported: $filename');
      }
    } catch (e) {
      if (mounted) {
        ToastNotification.error(context, 'Failed to export CSV');
      }
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  Future<void> _generateExcel() async {
    try {
      setState(() => _isGenerating = true);
      final jsonContent = await DataExportService.exportToJSON(sampleData);
      final filename = '${DataExportService.generateGovernmentFilename('water_quality')}.json';
      
      print('JSON Generated: $filename\n$jsonContent');
      
      if (mounted) {
        ToastNotification.success(context, 'Data exported: $filename');
      }
    } catch (e) {
      if (mounted) {
        ToastNotification.error(context, 'Failed to export data');
      }
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  Future<void> _generateComplianceReport() async {
    try {
      setState(() => _isGenerating = true);
      final report = await DataExportService.generateComplianceReport(sampleData);
      final filename = '${DataExportService.generateGovernmentFilename('compliance_report')}.txt';
      
      print('Compliance Report: $filename\n$report');
      
      if (mounted) {
        ToastNotification.success(context, 'Compliance report generated: $filename');
      }
    } catch (e) {
      if (mounted) {
        ToastNotification.error(context, 'Failed to generate compliance report');
      }
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightCream,
      body: Stack(
        children: [
          Row(
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
                child: _isInitialLoading
                    ? _buildLoadingState()
                    : _buildReportsContent(),
              ),
            ],
          ),
          if (_isGenerating)
            LoadingOverlay(
              isLoading: _isGenerating,
              message: 'Generating PDF Report...',
              child: Container(),
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
            width: 300,
            height: 32,
            borderRadius: BorderRadius.circular(8),
          ),
          const SizedBox(height: 8),
          SkeletonLoader(
            width: 400,
            height: 16,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: SkeletonLoader(
                  width: double.infinity,
                  height: 220,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SkeletonLoader(
                  width: double.infinity,
                  height: 220,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SkeletonLoader(
                  width: double.infinity,
                  height: 220,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SkeletonLoader(
            width: 200,
            height: 24,
            borderRadius: BorderRadius.circular(6),
          ),
          const SizedBox(height: 16),
          ...List.generate(
            3,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SkeletonLoader(
                width: double.infinity,
                height: 80,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsContent() {
    return CustomRefreshWrapper(
      onRefresh: _refreshReports,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.assessment_outlined, color: AppColors.primaryBlue, size: 32),
                const SizedBox(width: 12),
                Text(
                  'Reports & Exports',
                  style: AppTextStyles.heading2.copyWith(
                    color: AppColors.charcoal,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Generate and download water quality reports',
              style: AppTextStyles.body.copyWith(
                color: AppColors.mediumGray,
              ),
            ),
            const SizedBox(height: 32),

            // Advanced Filters Section
            _buildAdvancedFilters(),
            const SizedBox(height: 32),

          // Report Cards - Row 1
          Row(
            children: [
              _buildReportCard(
                icon: 'pdf',
                title: 'PDF Report',
                description: 'Professional PDF with charts',
                onTap: _generateAndPreviewPDF,
                color: AppColors.error.withOpacity(0.1),
                buttonColor: AppColors.error,
              ),
              const SizedBox(width: 16),
              _buildReportCard(
                icon: 'excel',
                title: 'Excel Export',
                description: 'Raw data in CSV format',
                onTap: _downloadCSV,
                color: AppColors.success.withOpacity(0.1),
                buttonColor: AppColors.success,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Report Cards - Row 2
          Row(
            children: [
              _buildReportCard(
                icon: '📊',
                title: 'JSON Export',
                description: 'Data in JSON format',
                onTap: _generateExcel,
                color: AppColors.accentPurple.withOpacity(0.1),
                buttonColor: AppColors.accentPurple,
              ),
              const SizedBox(width: 16),
              _buildReportCard(
                icon: '✓',
                title: 'Compliance Report',
                description: 'Standards compliance check',
                onTap: _generateComplianceReport,
                color: AppColors.darkVanilla.withOpacity(0.1),
                buttonColor: AppColors.accentOrange,
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Recent Reports
          Text(
            'Recent Reports',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 16),
          _recentReports.isEmpty
              ? EmptyStates.noData(
                  onAction: _generateAndPreviewPDF,
                )
              : _buildReportList(),
        ],
      ),
      ),
    );
  }

  Widget _buildReportCard({
    required String icon,
    required String title,
    required String description,
    required VoidCallback onTap,
    required Color color,
    required Color buttonColor,
  }) {
    // Map string to IconData
    IconData getIcon() {
      switch(icon) {
        case '📊':
        case 'chart':
          return Icons.insert_chart_outlined;
        case '✓':
        case 'check':
          return Icons.check_circle_outline;
        case 'pdf':
          return Icons.picture_as_pdf_outlined;
        case 'excel':
          return Icons.table_chart_outlined;
        default:
          return Icons.description_outlined;
      }
    }
    
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
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
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                getIcon(),
                size: 32,
                color: buttonColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTextStyles.heading4.copyWith(
                color: AppColors.charcoal,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.mediumGray,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(vertical: 12),
                color: buttonColor,
                borderRadius: BorderRadius.circular(8),
                onPressed: onTap,
                child: Text(
                  'Generate',
                  style: AppTextStyles.button.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportList() {
    return Column(
      children: _recentReports
          .map(
            (report) => Container(
              margin: const EdgeInsets.only(bottom: 12),
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
                    color: AppColors.charcoal.withOpacity(0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report['title']!,
                          style: AppTextStyles.button.copyWith(
                            color: AppColors.charcoal,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: report['format'] == 'PDF'
                                    ? AppColors.error.withOpacity(0.1)
                                    : AppColors.success.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                report['format']!,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: report['format'] == 'PDF'
                                      ? AppColors.error
                                      : AppColors.success,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${report['size']}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.mediumGray,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              report['date']!,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.mediumGray,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  CupertinoButton(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      CupertinoIcons.arrow_down_to_line,
                      color: AppColors.accentPink,
                      size: 22,
                    ),
                    onPressed: () {
                      ToastNotification.success(
                        context,
                        'Downloading ${report['title']}...',
                      );
                    },
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildAdvancedFilters() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.darkCream.withOpacity(0.3),
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
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.slider_horizontal_3,
                color: AppColors.accentPink,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Report Configuration',
                style: AppTextStyles.heading4.copyWith(
                  color: AppColors.charcoal,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Filter controls in row
          Row(
            children: [
              // Date Range Picker
              Expanded(
                child: _buildFilterButton(
                  label: _selectedDateRange == null
                      ? 'Select Date Range'
                      : '${_formatDate(_selectedDateRange!.start)} - ${_formatDate(_selectedDateRange!.end)}',
                  icon: CupertinoIcons.calendar,
                  onTap: _selectDateRange,
                ),
              ),
              const SizedBox(width: 12),
              
              // Location Dropdown (Maharashtra Districts)
              Expanded(
                child: _buildDropdown(
                  value: _selectedLocation,
                  items: _locations,
                  icon: CupertinoIcons.location,
                  onChanged: (value) {
                    setState(() => _selectedLocation = value!);
                    ToastNotification.info(context, 'Location: $value');
                  },
                ),
              ),
              const SizedBox(width: 12),
              
              // Report Type Dropdown
              Expanded(
                child: _buildDropdown(
                  value: _reportType,
                  items: _reportTypes,
                  icon: CupertinoIcons.doc_text,
                  onChanged: (value) {
                    setState(() => _reportType = value!);
                    ToastNotification.info(context, 'Type: $value');
                  },
                ),
              ),
            ],
          ),
          
          // Info text
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.darkVanilla.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.info_circle,
                  color: AppColors.accentOrange,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Configure filters to customize your report. All reports include the selected locations and date range.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.mediumGray,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.lightCream,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.darkCream.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.accentPink, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.charcoal,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              CupertinoIcons.chevron_down,
              color: AppColors.mediumGray,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required IconData icon,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.lightCream,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.darkCream.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accentPink, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.charcoal,
                  fontSize: 14,
                ),
                items: items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.accentPink,
              onPrimary: Colors.white,
              surface: AppColors.white,
              onSurface: AppColors.charcoal,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDateRange) {
      setState(() => _selectedDateRange = picked);
      ToastNotification.success(
        context,
        'Date range: ${_formatDate(picked.start)} - ${_formatDate(picked.end)}',
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}
