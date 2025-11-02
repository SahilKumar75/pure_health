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

  final List<Map<String, dynamic>> sampleData = [
    {
      'location': 'Zone A',
      'pH': 7.2,
      'turbidity': 2.1,
      'dissolved_oxygen': 8.5,
      'temperature': 25.0,
      'conductivity': 500,
      'status': 'Safe',
      'timestamp': '2025-11-02 08:00'
    },
    {
      'location': 'Zone B',
      'pH': 6.8,
      'turbidity': 3.5,
      'dissolved_oxygen': 7.2,
      'temperature': 22.0,
      'conductivity': 480,
      'status': 'Warning',
      'timestamp': '2025-11-02 09:00'
    },
    {
      'location': 'Zone C',
      'pH': 5.5,
      'turbidity': 8.2,
      'dissolved_oxygen': 4.1,
      'temperature': 28.0,
      'conductivity': 620,
      'status': 'Critical',
      'timestamp': '2025-11-02 10:00'
    },
  ];

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
            Text(
              '📊 Reports & Exports',
              style: AppTextStyles.heading2.copyWith(
                color: AppColors.charcoal,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Generate and download water quality reports',
              style: AppTextStyles.body.copyWith(
                color: AppColors.mediumGray,
              ),
            ),
            const SizedBox(height: 32),

          // Report Cards - Row 1
          Row(
            children: [
              _buildReportCard(
                icon: '📄',
                title: 'PDF Report',
                description: 'Professional PDF with charts',
                onTap: _generateAndPreviewPDF,
                color: AppColors.error.withOpacity(0.1),
                buttonColor: AppColors.error,
              ),
              const SizedBox(width: 16),
              _buildReportCard(
                icon: '📋',
                title: 'CSV Export',
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
              child: Text(
                icon,
                style: const TextStyle(fontSize: 32),
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
}
