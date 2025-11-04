import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pure_health/core/constants/color_constants.dart';
import 'package:pure_health/core/theme/text_styles.dart';
import 'package:pure_health/core/theme/government_theme.dart';
import '../../data/models/analysis_report.dart';
import 'package:intl/intl.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class AnalysisReportView extends StatefulWidget {
  final AnalysisReport report;
  final VoidCallback onNewAnalysis;
  final VoidCallback onGeneratePDF;
  final VoidCallback onSaveReport;
  final bool isLoading;

  const AnalysisReportView({
    super.key,
    required this.report,
    required this.onNewAnalysis,
    required this.onGeneratePDF,
    required this.onSaveReport,
    this.isLoading = false,
  });

  @override
  State<AnalysisReportView> createState() => _AnalysisReportViewState();
}

class _AnalysisReportViewState extends State<AnalysisReportView> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Compact Action Bar
        _buildActionBar(context),
        
        // Main Content with Tabs
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tabs
                    _buildTabs(),
                    
                    const SizedBox(height: 24),
                    
                    // Tab Content
                    _buildTabContent(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.darkBg2,
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // File Info
          Expanded(
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.doc_text_fill,
                  color: GovernmentTheme.governmentBlue,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.report.fileName,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.lightText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (widget.report.location != null) ...[
                  const SizedBox(width: 16),
                  Icon(
                    CupertinoIcons.map_pin_ellipse,
                    color: AppColors.mediumText,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.report.location!.name,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.mediumText,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Action Buttons
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: widget.isLoading ? null : widget.onSaveReport,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: GovernmentTheme.governmentBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.floppy_disk,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Save',
                    style: AppTextStyles.button.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: widget.isLoading ? null : widget.onGeneratePDF,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.accentPink,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.doc_text_fill,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'PDF',
                    style: AppTextStyles.button.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: widget.onNewAnalysis,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.darkBg3,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.borderLight,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.arrow_clockwise,
                    color: AppColors.lightText,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'New',
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.lightText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    final tabs = [
      {'label': 'Data & Predictions', 'icon': CupertinoIcons.chart_bar_square_fill},
      {'label': 'Risk Assessment', 'icon': CupertinoIcons.exclamationmark_triangle_fill},
      {'label': 'Trends', 'icon': CupertinoIcons.chart_bar_alt_fill},
      {'label': 'Recommendations', 'icon': CupertinoIcons.lightbulb_fill},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = _selectedTab == index;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () => setState(() => _selectedTab = index),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? GovernmentTheme.governmentBlue
                      : AppColors.darkBg3,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? GovernmentTheme.governmentBlue
                        : AppColors.borderLight,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      tabs[index]['icon'] as IconData,
                      color: isSelected ? Colors.white : AppColors.mediumText,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      tabs[index]['label'] as String,
                      style: AppTextStyles.button.copyWith(
                        color: isSelected ? Colors.white : AppColors.lightText,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildDataAndPredictionsTab();
      case 1:
        return _buildRiskAssessmentTab();
      case 2:
        return _buildTrendsTab();
      case 3:
        return _buildRecommendationsTab();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDataAndPredictionsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hero Section - Predictions Showcase
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                GovernmentTheme.governmentBlue.withOpacity(0.2),
                Colors.purple.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: GovernmentTheme.governmentBlue.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: GovernmentTheme.governmentBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      CupertinoIcons.chart_bar_square_fill,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '60-Day Water Quality Forecast',
                          style: AppTextStyles.heading2.copyWith(
                            color: AppColors.lightText,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'AI-powered predictions from ${DateFormat('MMM dd').format(widget.report.predictionStartDate)} to ${DateFormat('MMM dd, yyyy').format(widget.report.predictionEndDate)}',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.mediumText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Quick Stats Row
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: CupertinoIcons.exclamationmark_shield_fill,
                title: 'Risk Level',
                value: widget.report.riskAssessment.overallRiskLevel.toUpperCase(),
                subtitle: 'Score: ${widget.report.riskAssessment.riskScore.toStringAsFixed(1)}/100',
                color: _getRiskColor(widget.report.riskAssessment.overallRiskLevel),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                icon: CupertinoIcons.arrow_up_right,
                title: 'Overall Trend',
                value: widget.report.trendAnalysis.overallTrend.toUpperCase(),
                subtitle: 'Water quality status',
                color: _getTrendColor(widget.report.trendAnalysis.overallTrend),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                icon: CupertinoIcons.list_bullet,
                title: 'Actions',
                value: '${widget.report.recommendations.length}',
                subtitle: 'Recommendations',
                color: Colors.purple,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Uploaded Data Section
        _buildUploadedDataSection(),
        
        const SizedBox(height: 24),
        
        // Predictions by Parameter
        _buildPredictionsByParameter(),
        
        const SizedBox(height: 24),
        
        // Location Map (if location exists)
        if (widget.report.location != null)
          _buildLocationSection(),
      ],
    );
  }
  
  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
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
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.mediumText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.lightText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.mediumText,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildUploadedDataSection() {
    if (widget.report.rawData == null || widget.report.rawData!.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: const EdgeInsets.all(24),
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
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.chart_bar_fill,
                color: Colors.blue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Uploaded Data Summary',
                style: AppTextStyles.heading3.copyWith(
                  color: AppColors.lightText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDataSummaryGrid(),
        ],
      ),
    );
  }
  
  Widget _buildDataSummaryGrid() {
    // Extract key parameters from rawData
    final rawData = widget.report.rawData!;
    final parameters = <String, dynamic>{};
    
    // Common water quality parameters to display
    final displayParams = ['pH', 'Turbidity', 'DO', 'BOD', 'Temperature', 'Conductivity', 'Nitrate', 'Fecal_Coliform'];
    
    for (final param in displayParams) {
      if (rawData.containsKey(param)) {
        parameters[param] = rawData[param];
      }
    }
    
    if (parameters.isEmpty) {
      return Text(
        'No parameter data available',
        style: AppTextStyles.body.copyWith(
          color: AppColors.mediumText,
        ),
      );
    }
    
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: parameters.entries.map((entry) {
        return Container(
          width: (MediaQuery.of(context).size.width - 200) / 4 - 20,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.darkBg2,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.borderLight,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.key,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.mediumText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                entry.value.toString(),
                style: AppTextStyles.heading3.copyWith(
                  color: AppColors.lightText,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildPredictionsByParameter() {
    final predictions = widget.report.predictions;
    
    return Container(
      padding: const EdgeInsets.all(24),
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
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.graph_circle_fill,
                color: Colors.green,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Parameter Predictions',
                style: AppTextStyles.heading3.copyWith(
                  color: AppColors.lightText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPredictionsGrid(predictions),
        ],
      ),
    );
  }
  
  Widget _buildPredictionsGrid(Map<String, dynamic> predictions) {
    if (predictions.isEmpty) {
      return Text(
        'No prediction data available',
        style: AppTextStyles.body.copyWith(
          color: AppColors.mediumText,
        ),
      );
    }
    
    return Column(
      children: predictions.entries.map((entry) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.darkBg2,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.borderLight,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.key,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.lightText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              if (entry.value is Map) _buildPredictionDetails(entry.value as Map<String, dynamic>)
              else Text(
                entry.value.toString(),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.mediumText,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildPredictionDetails(Map<String, dynamic> details) {
    return Wrap(
      spacing: 24,
      runSpacing: 8,
      children: details.entries.take(6).map((entry) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${entry.key}: ',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.mediumText,
              ),
            ),
            Text(
              entry.value.toString(),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.lightText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }



  Widget _buildLocationSection() {
    final location = widget.report.location!;
    
    return Container(
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
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.map_pin_ellipse,
                color: GovernmentTheme.governmentBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Water Body Location',
                style: AppTextStyles.heading4.copyWith(
                  color: AppColors.lightText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location.name,
                      style: AppTextStyles.heading3.copyWith(
                        color: AppColors.lightText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(CupertinoIcons.tag, 'Type', location.type.toUpperCase()),
                    _buildInfoRow(CupertinoIcons.building_2_fill, 'District', location.district),
                    _buildInfoRow(CupertinoIcons.map, 'Region', location.region),
                    _buildInfoRow(
                      CupertinoIcons.location,
                      'Coordinates',
                      'Lat: ${location.latitude.toStringAsFixed(4)}, '
                          'Lng: ${location.longitude.toStringAsFixed(4)}',
                    ),
                  ],
                ),
              ),
              // Actual Map
              Container(
                width: 300,
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.borderLight,
                    width: 1,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: _buildMapWidget(location.latitude, location.longitude),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, color: AppColors.mediumText, size: 14),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.mediumText,
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.lightText,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMapWidget(double latitude, double longitude) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(latitude, longitude),
        initialZoom: 12.0,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.purehealth.app',
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: LatLng(latitude, longitude),
              width: 40,
              height: 40,
              child: Icon(
                CupertinoIcons.location_solid,
                color: GovernmentTheme.governmentBlue,
                size: 40,
                shadows: const [
                  Shadow(
                    color: Colors.black54,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }



  Widget _buildRiskAssessmentTab() {
    final riskAssessment = widget.report.riskAssessment;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Overall Risk
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _getRiskColor(riskAssessment.overallRiskLevel).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getRiskColor(riskAssessment.overallRiskLevel).withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _getRiskColor(riskAssessment.overallRiskLevel),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  CupertinoIcons.exclamationmark_shield_fill,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overall Risk: ${riskAssessment.overallRiskLevel.toUpperCase()}',
                      style: AppTextStyles.heading2.copyWith(
                        color: AppColors.lightText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Risk Score: ${riskAssessment.riskScore.toStringAsFixed(1)}/100',
                      style: AppTextStyles.heading4.copyWith(
                        color: AppColors.mediumText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Risk Summary
        Container(
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
            children: [
              Text(
                'Summary',
                style: AppTextStyles.heading4.copyWith(
                  color: AppColors.lightText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                riskAssessment.summary,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.mediumText,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Risk Factors
        ...riskAssessment.riskFactors.map((factor) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildRiskFactorCard(factor),
        )),
      ],
    );
  }

  Widget _buildRiskFactorCard(RiskFactor factor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkBg3,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getRiskColor(factor.level).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _getRiskColor(factor.level).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              CupertinoIcons.drop_fill,
              color: _getRiskColor(factor.level),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  factor.parameter,
                  style: AppTextStyles.heading4.copyWith(
                    color: AppColors.lightText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  factor.description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.mediumText,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Current: ${factor.currentValue}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.mediumText,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Threshold: ${factor.thresholdValue}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.mediumText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getRiskColor(factor.level).withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              factor.level.toUpperCase(),
              style: AppTextStyles.buttonSmall.copyWith(
                color: _getRiskColor(factor.level),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendsTab() {
    final trendAnalysis = widget.report.trendAnalysis;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Overall Trend
        Container(
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
            children: [
              Row(
                children: [
                  Icon(
                    _getTrendIcon(trendAnalysis.overallTrend),
                    color: _getTrendColor(trendAnalysis.overallTrend),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Overall Trend: ${trendAnalysis.overallTrend.toUpperCase()}',
                    style: AppTextStyles.heading3.copyWith(
                      color: AppColors.lightText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                trendAnalysis.summary,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.mediumText,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Parameter Trends
        ...trendAnalysis.parameterTrends.entries.map((entry) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildTrendCard(entry.key, entry.value),
        )),
      ],
    );
  }

  Widget _buildTrendCard(String parameter, TrendData trend) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        children: [
          Row(
            children: [
              Icon(
                _getTrendIcon(trend.direction),
                color: _getTrendColor(trend.direction),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                parameter,
                style: AppTextStyles.heading4.copyWith(
                  color: AppColors.lightText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getTrendColor(trend.direction).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${trend.changePercentage >= 0 ? '+' : ''}${trend.changePercentage.toStringAsFixed(1)}%',
                  style: AppTextStyles.buttonSmall.copyWith(
                    color: _getTrendColor(trend.direction),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Trend: ${trend.direction.toUpperCase()}',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.mediumText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsTab() {
    final recommendations = widget.report.recommendations;
    
    // Group by priority
    final highPriority = recommendations.where((r) => r.priority == 'high').toList();
    final mediumPriority = recommendations.where((r) => r.priority == 'medium').toList();
    final lowPriority = recommendations.where((r) => r.priority == 'low').toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (highPriority.isNotEmpty) ...[
          _buildPrioritySection('High Priority', highPriority, Colors.red),
          const SizedBox(height: 16),
        ],
        if (mediumPriority.isNotEmpty) ...[
          _buildPrioritySection('Medium Priority', mediumPriority, Colors.orange),
          const SizedBox(height: 16),
        ],
        if (lowPriority.isNotEmpty) ...[
          _buildPrioritySection('Low Priority', lowPriority, Colors.blue),
        ],
      ],
    );
  }

  Widget _buildPrioritySection(String title, List<Recommendation> recommendations, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                CupertinoIcons.flag_fill,
                color: color,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.lightText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...recommendations.map((rec) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildRecommendationCard(rec, color),
        )),
      ],
    );
  }

  Widget _buildRecommendationCard(Recommendation recommendation, Color priorityColor) {
    final categoryIcons = {
      'treatment': CupertinoIcons.drop_fill,
      'monitoring': CupertinoIcons.eye_fill,
      'policy': CupertinoIcons.doc_text_fill,
      'infrastructure': CupertinoIcons.building_2_fill,
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkBg3,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: priorityColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: GovernmentTheme.governmentBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  categoryIcons[recommendation.category] ?? CupertinoIcons.lightbulb_fill,
                  color: GovernmentTheme.governmentBlue,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  recommendation.title,
                  style: AppTextStyles.heading4.copyWith(
                    color: AppColors.lightText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.darkBg2,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  recommendation.timeframe.toUpperCase(),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.mediumText,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            recommendation.description,
            style: AppTextStyles.body.copyWith(
              color: AppColors.mediumText,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Action Items:',
            style: AppTextStyles.buttonSmall.copyWith(
              color: AppColors.lightText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...recommendation.actionItems.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: GovernmentTheme.governmentBlue,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.mediumText,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Color _getRiskColor(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'critical':
        return Colors.red.shade700;
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getTrendColor(String trend) {
    switch (trend.toLowerCase()) {
      case 'improving':
      case 'stable':
        return Colors.green;
      case 'declining':
      case 'decreasing':
        return Colors.red;
      case 'increasing':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getTrendIcon(String trend) {
    switch (trend.toLowerCase()) {
      case 'improving':
      case 'increasing':
        return CupertinoIcons.arrow_up_right;
      case 'declining':
      case 'decreasing':
        return CupertinoIcons.arrow_down_right;
      case 'stable':
        return CupertinoIcons.arrow_right;
      default:
        return CupertinoIcons.minus;
    }
  }
}
