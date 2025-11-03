import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pure_health/core/constants/color_constants.dart';
import 'package:pure_health/core/theme/text_styles.dart';
import 'package:pure_health/core/theme/government_theme.dart';
import '../../data/models/analysis_report.dart';
import 'package:intl/intl.dart';

class AnalysisReportView extends StatefulWidget {
  final AnalysisReport report;

  const AnalysisReportView({
    super.key,
    required this.report,
  });

  @override
  State<AnalysisReportView> createState() => _AnalysisReportViewState();
}

class _AnalysisReportViewState extends State<AnalysisReportView> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Report Header
              _buildReportHeader(),
              
              const SizedBox(height: 24),
              
              // Tabs
              _buildTabs(),
              
              const SizedBox(height: 24),
              
              // Tab Content
              _buildTabContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.darkBg3,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Analysis Report',
                  style: AppTextStyles.heading2.copyWith(
                    color: AppColors.lightText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.doc_text_fill,
                      color: AppColors.mediumText,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.report.fileName,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.mediumText,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      CupertinoIcons.time,
                      color: AppColors.mediumText,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat('MMM dd, yyyy HH:mm')
                          .format(widget.report.timestamp),
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.mediumText,
                      ),
                    ),
                  ],
                ),
                if (widget.report.location != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.map_pin_ellipse,
                        color: AppColors.mediumText,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.report.location!.name,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.mediumText,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    final tabs = [
      {'label': 'Overview', 'icon': CupertinoIcons.chart_pie_fill},
      {'label': 'Predictions', 'icon': CupertinoIcons.graph_circle},
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
        return _buildOverviewTab();
      case 1:
        return _buildPredictionsTab();
      case 2:
        return _buildRiskAssessmentTab();
      case 3:
        return _buildTrendsTab();
      case 4:
        return _buildRecommendationsTab();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildOverviewTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildOverviewCard(
                icon: CupertinoIcons.graph_circle,
                title: 'Prediction Period',
                value: '2 Months',
                subtitle: '${DateFormat('MMM dd').format(widget.report.predictionStartDate)} - '
                    '${DateFormat('MMM dd, yyyy').format(widget.report.predictionEndDate)}',
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildOverviewCard(
                icon: CupertinoIcons.exclamationmark_shield_fill,
                title: 'Risk Level',
                value: widget.report.riskAssessment.overallRiskLevel.toUpperCase(),
                subtitle: 'Score: ${widget.report.riskAssessment.riskScore.toStringAsFixed(1)}/100',
                color: _getRiskColor(widget.report.riskAssessment.overallRiskLevel),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildOverviewCard(
                icon: CupertinoIcons.arrow_up_right,
                title: 'Overall Trend',
                value: widget.report.trendAnalysis.overallTrend.toUpperCase(),
                subtitle: 'Water quality status',
                color: _getTrendColor(widget.report.trendAnalysis.overallTrend),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildOverviewCard(
                icon: CupertinoIcons.list_bullet,
                title: 'Recommendations',
                value: '${widget.report.recommendations.length}',
                subtitle: 'Action items identified',
                color: Colors.purple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        
        // Location Map (if location exists)
        if (widget.report.location != null)
          _buildLocationSection(),
      ],
    );
  }

  Widget _buildOverviewCard({
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
              Text(
                title,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.mediumText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.lightText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.dimText,
            ),
          ),
        ],
      ),
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
              // Map Placeholder
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.darkBg2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.borderLight,
                    width: 1,
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.map_fill,
                            color: AppColors.mediumText,
                            size: 48,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Map View',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.mediumText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: GovernmentTheme.governmentBlue,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          CupertinoIcons.location_fill,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
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

  Widget _buildPredictionsTab() {
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
          Text(
            '2-Month Predictions',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.lightText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Forecast from ${DateFormat('MMM dd').format(widget.report.predictionStartDate)} to '
            '${DateFormat('MMM dd, yyyy').format(widget.report.predictionEndDate)}',
            style: AppTextStyles.body.copyWith(
              color: AppColors.mediumText,
            ),
          ),
          const SizedBox(height: 24),
          
          // Predictions content
          Text(
            'Detailed predictions will be displayed here with charts and parameter forecasts.',
            style: AppTextStyles.body.copyWith(
              color: AppColors.mediumText,
            ),
          ),
        ],
      ),
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
