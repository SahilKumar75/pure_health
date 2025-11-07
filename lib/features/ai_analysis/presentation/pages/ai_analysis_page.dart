import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:pure_health/core/constants/color_constants.dart';
import 'package:pure_health/core/theme/text_styles.dart';
import 'package:pure_health/core/theme/government_theme.dart';
import 'package:pure_health/shared/widgets/custom_sidebar.dart';
import 'package:pure_health/shared/widgets/toast_notification.dart';
import '../viewmodel/ai_analysis_viewmodel.dart';
import '../widgets/file_upload_section.dart';
import '../widgets/location_selector.dart';
import '../widgets/analysis_report_view.dart';

class AIAnalysisPage extends StatefulWidget {
  const AIAnalysisPage({super.key});

  @override
  State<AIAnalysisPage> createState() => _AIAnalysisPageState();
}

class _AIAnalysisPageState extends State<AIAnalysisPage> {
  int _selectedIndex = 2; // AI Analysis index in sidebar (moved to priority position)

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AIAnalysisViewModel(),
      child: Scaffold(
        backgroundColor: AppColors.darkBg,
        body: Row(
          children: [
            CustomSidebar(
              selectedIndex: _selectedIndex,
              onItemSelected: (index) {
                setState(() => _selectedIndex = index);
              },
            ),
            Expanded(
              child: Consumer<AIAnalysisViewModel>(
                builder: (context, viewModel, _) {
                  return viewModel.hasReport
                      ? AnalysisReportView(
                          report: viewModel.currentReport!,
                          onNewAnalysis: () => _clearAnalysis(context, viewModel),
                          onGeneratePDF: () => _generatePDFReport(context, viewModel),
                          onSaveReport: () => _saveReport(context, viewModel),
                          isLoading: viewModel.isLoading,
                        )
                      : _buildUploadSection(context, viewModel);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildUploadSection(BuildContext context, AIAnalysisViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // File Upload Section
              FileUploadSection(
                onUpload: () => _uploadFile(context, viewModel),
                fileName: viewModel.fileName,
                recordCount: viewModel.recordCount,
                isLoading: viewModel.isLoading,
              ),
              
              const SizedBox(height: 24),
              
              // Location Selector
              if (viewModel.hasUploadedFile) ...[
                LocationSelector(
                  selectedLocation: viewModel.selectedLocation,
                  onLocationSelected: (location) {
                    viewModel.selectLocation(location);
                  },
                  onClearLocation: () {
                    viewModel.clearLocation();
                  },
                ),
                
                const SizedBox(height: 32),
                
                // Generate Analysis Button
                Center(
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: viewModel.isAnalyzing
                        ? null
                        : () => _generateAnalysis(context, viewModel),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: viewModel.isAnalyzing
                            ? AppColors.dimText
                            : AppColors.accentPink,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (viewModel.isAnalyzing)
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          else
                            Icon(
                              CupertinoIcons.chart_bar_alt_fill,
                              color: Colors.white,
                              size: 20,
                            ),
                          const SizedBox(width: 12),
                          Text(
                            viewModel.isAnalyzing
                                ? 'Analyzing...'
                                : 'Generate Comprehensive Analysis',
                            style: AppTextStyles.button.copyWith(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              
              const SizedBox(height: 48),
              
              // Info Cards
              _buildInfoCards(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCards() {
    final features = [
      {
        'icon': CupertinoIcons.chart_bar_alt_fill,
        'title': '60-Day Predictions',
        'description': 'AI-powered forecasts for water quality parameters for the next 2 months',
      },
      {
        'icon': CupertinoIcons.exclamationmark_triangle_fill,
        'title': 'Risk Assessment',
        'description': 'Comprehensive contamination risk scoring and health impact analysis',
      },
      {
        'icon': CupertinoIcons.arrow_up_right_circle_fill,
        'title': 'Trend Analysis',
        'description': 'Historical patterns, anomaly detection, and seasonal trend identification',
      },
      {
        'icon': CupertinoIcons.lightbulb_fill,
        'title': 'Smart Recommendations',
        'description': 'Actionable treatment, monitoring, infrastructure, and policy suggestions',
      },
      {
        'icon': CupertinoIcons.doc_text_fill,
        'title': 'PDF Report Generation',
        'description': 'Professional reports with MPCB compliance and government branding',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What You\'ll Get',
          style: AppTextStyles.heading3.copyWith(
            color: AppColors.lightText,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: features.map((feature) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.darkBg3,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.borderLight,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        feature['icon'] as IconData,
                        color: GovernmentTheme.governmentBlue,
                        size: 32,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        feature['title'] as String,
                        style: AppTextStyles.heading4.copyWith(
                          color: AppColors.lightText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        feature['description'] as String,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.mediumText,
                          height: 1.5,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _uploadFile(BuildContext context, AIAnalysisViewModel viewModel) async {
    try {
      await viewModel.uploadFile();
      if (mounted) {
        ToastNotification.success(
          context,
          'File uploaded successfully: ${viewModel.fileName}',
        );
      }
    } catch (e) {
      if (mounted) {
        ToastNotification.error(context, 'Upload failed: ${e.toString()}');
      }
    }
  }

  Future<void> _generateAnalysis(BuildContext context, AIAnalysisViewModel viewModel) async {
    try {
      await viewModel.generateAnalysis();
      if (mounted) {
        ToastNotification.success(
          context,
          'Analysis completed successfully!',
        );
      }
    } catch (e) {
      if (mounted) {
        ToastNotification.error(context, 'Analysis failed: ${e.toString()}');
      }
    }
  }

  Future<void> _saveReport(BuildContext context, AIAnalysisViewModel viewModel) async {
    try {
      await viewModel.saveReport();
      if (mounted) {
        ToastNotification.success(
          context,
          'Report saved to history!',
        );
      }
    } catch (e) {
      if (mounted) {
        ToastNotification.error(context, 'Save failed: ${e.toString()}');
      }
    }
  }

  Future<void> _generatePDFReport(BuildContext context, AIAnalysisViewModel viewModel) async {
    try {
      final result = await viewModel.generatePDFReport();
      
      if (mounted) {
        // Get the download URL for the generated report
        viewModel.getReportDownloadUrl(result['filename']);
        
        ToastNotification.success(
          context,
          'PDF Report generated successfully! Check your Downloads folder.',
        );
        
        // The backend handles the file download automatically
        // You can add url_launcher here if you want to open the PDF
      }
    } catch (e) {
      if (mounted) {
        ToastNotification.error(context, 'PDF generation failed: ${e.toString()}');
      }
    }
  }

  void _clearAnalysis(BuildContext context, AIAnalysisViewModel viewModel) {
    viewModel.clearAnalysis();
    ToastNotification.info(context, 'Ready for new analysis');
  }
}
