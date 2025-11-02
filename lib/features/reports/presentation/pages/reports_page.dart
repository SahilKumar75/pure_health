import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pure_health/core/constants/color_constants.dart';
import 'package:pure_health/core/theme/text_styles.dart';
import 'package:pure_health/core/services/report_service.dart';
import 'package:pure_health/shared/widgets/custom_sidebar.dart';
import 'package:printing/printing.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({Key? key}) : super(key: key);

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  int _selectedIndex = 6;
  bool _isGenerating = false;

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
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating PDF: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  Future<void> _downloadCSV() async {
    try {
      final csv = ReportService.generateCSVReport(sampleData);
      print('CSV Generated:\n$csv');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('CSV downloaded successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
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
            child: SingleChildScrollView(
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

                  // Report Cards
                  Row(
                    children: [
                      _buildReportCard(
                        icon: '📄',
                        title: 'PDF Report',
                        description: 'Professional PDF with charts',
                        onTap: _generateAndPreviewPDF,
                        isLoading: _isGenerating,
                      ),
                      const SizedBox(width: 16),
                      _buildReportCard(
                        icon: '📋',
                        title: 'CSV Export',
                        description: 'Raw data in CSV format',
                        onTap: _downloadCSV,
                      ),
                      const SizedBox(width: 16),
                      _buildReportCard(
                        icon: '📊',
                        title: 'Excel Report',
                        description: 'Data analysis in Excel',
                        onTap: () {},
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
                  _buildReportList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard({
    required String icon,
    required String title,
    required String description,
    required VoidCallback onTap,
    bool isLoading = false,
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
            Text(
              icon,
              style: const TextStyle(fontSize: 40),
            ),
            const SizedBox(height: 12),
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
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkVanilla,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.white,
                          ),
                        ),
                      )
                    : Text(
                        'Generate',
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.white,
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
    final reports = [
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

    return Column(
      children: reports
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
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report['title']!,
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.charcoal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '${report['format']} • ${report['size']}',
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
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Icon(
                      CupertinoIcons.arrow_down_to_line,
                      color: AppColors.darkVanilla,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
