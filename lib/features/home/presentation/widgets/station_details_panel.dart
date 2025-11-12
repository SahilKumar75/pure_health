import 'package:flutter/material.dart';
import 'package:pure_health/core/constants/color_constants.dart';
import 'package:pure_health/core/theme/text_styles.dart';
import 'package:pure_health/core/models/station_models.dart';
import 'package:pure_health/features/ai_analysis/presentation/pages/station_ai_analysis_page_with_sidebar.dart';

class StationDetailsPanel extends StatelessWidget {
  final String stationId;
  final WaterQualityStation station;
  final StationData stationData;
  final String Function(DateTime) getTimeAgo;

  const StationDetailsPanel({
    super.key,
    required this.stationId,
    required this.station,
    required this.stationData,
    required this.getTimeAgo,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Safe':
        return AppColors.success;
      case 'Warning':
        return AppColors.warning;
      case 'Critical':
        return AppColors.error;
      default:
        return AppColors.charcoal;
    }
  }

  double? _getParameterValue(String parameter) {
    final param = stationData.parameters[parameter];
    if (param == null) return null;
    
    // Handle nested object structure: {'value': 7.0, 'unit': 'pH'}
    if (param is Map<String, dynamic>) {
      final value = param['value'];
      if (value is num) {
        return value.toDouble();
      }
    }
    
    // Handle direct double value
    if (param is num) {
      return param.toDouble();
    }
    
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final status = stationData.status;
    final pH = _getParameterValue('pH');
    final turbidity = _getParameterValue('turbidity');
    final dissolvedOxygen = _getParameterValue('dissolvedOxygen');
    final temperature = _getParameterValue('temperature');
    final timestamp = DateTime.parse(stationData.timestamp);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Status Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getStatusColor(status).withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _getStatusColor(status),
              width: 1.5,
            ),
          ),
          child: Text(
            status,
            style: AppTextStyles.caption.copyWith(
              color: _getStatusColor(status),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Updated ${getTimeAgo(timestamp)}',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.mediumGray,
            fontSize: 12,
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Current Readings
        _buildSectionHeader('Current Readings', Icons.analytics),
        const SizedBox(height: 16),
        _buildReadingCard('pH Level', pH?.toStringAsFixed(2) ?? 'N/A', 'Neutral: 6.5-8.5', Icons.water_drop),
        const SizedBox(height: 12),
        _buildReadingCard('Turbidity', turbidity != null ? '${turbidity.toStringAsFixed(2)} NTU' : 'N/A', 'Max: 5 NTU', Icons.blur_on),
        const SizedBox(height: 12),
        _buildReadingCard('Dissolved Oxygen', dissolvedOxygen != null ? '${dissolvedOxygen.toStringAsFixed(2)} mg/L' : 'N/A', 'Min: 4 mg/L', Icons.air),
        const SizedBox(height: 12),
        _buildReadingCard('Temperature', temperature != null ? '${temperature.toStringAsFixed(1)}°C' : 'N/A', 'Normal: 20-30°C', Icons.thermostat),
        
        const SizedBox(height: 24),
        
        // AI Analysis Actions
        _buildSectionHeader('AI Analysis', Icons.psychology),
        const SizedBox(height: 12),
        Text(
          'Get detailed AI-powered analysis for this station',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.mediumGray,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 16),
        _buildAIAnalysisCard(
          'Quality Prediction',
          'Forecast water quality trends for the next 60 days',
          Icons.trending_up,
          AppColors.primaryBlue,
          () => _navigateToAIAnalysis(context, 'prediction'),
        ),
        const SizedBox(height: 12),
        _buildAIAnalysisCard(
          'Risk Assessment',
          'Identify contamination risks and safety factors',
          Icons.warning_amber_rounded,
          AppColors.warning,
          () => _navigateToAIAnalysis(context, 'risk'),
        ),
        const SizedBox(height: 12),
        _buildAIAnalysisCard(
          'Trend Analysis',
          'Analyze historical data patterns and changes',
          Icons.show_chart,
          AppColors.success,
          () => _navigateToAIAnalysis(context, 'trends'),
        ),
        const SizedBox(height: 12),
        _buildAIAnalysisCard(
          'Recommendations',
          'Get AI-powered treatment and monitoring advice',
          Icons.lightbulb_outline,
          AppColors.accentPink,
          () => _navigateToAIAnalysis(context, 'recommendations'),
        ),
        
        const SizedBox(height: 24),
        
        // Quick Insights (Real-time from live data)
        _buildSectionHeader('Live Insights', Icons.insights),
        const SizedBox(height: 16),
        _buildInsightItem('✓ Real-time monitoring active', AppColors.success),
        const SizedBox(height: 8),
        _buildInsightItem('📊 Updated ${getTimeAgo(timestamp)}', AppColors.primaryBlue),
        const SizedBox(height: 8),
        _buildInsightItem(
          status == 'Excellent' || status == 'Good' 
            ? '✓ All parameters within safe limits' 
            : '⚠ Some parameters need attention',
          status == 'Excellent' || status == 'Good' ? AppColors.success : AppColors.warning,
        ),
        
        const SizedBox(height: 24),
        
        // Actions
        _buildSectionHeader('Quick Actions', Icons.touch_app),
        const SizedBox(height: 16),
        _buildActionButton('Download Station Data', Icons.download, () {}),
        const SizedBox(height: 10),
        _buildActionButton('Set Custom Alert', Icons.notifications_active, () {}),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryBlue, size: 20),
        const SizedBox(width: 10),
        Text(
          title,
          style: AppTextStyles.heading4.copyWith(
            color: AppColors.primaryBlue,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildReadingCard(String label, String value, String range, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightCream,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.darkCream.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primaryBlue, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.mediumGray, fontSize: 12)),
                const SizedBox(height: 4),
                Text(value, style: AppTextStyles.heading4.copyWith(color: AppColors.charcoal, fontWeight: FontWeight.bold)),
                Text(range, style: AppTextStyles.caption.copyWith(color: AppColors.mediumGray, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(String text, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: AppTextStyles.body.copyWith(color: AppColors.charcoal, fontSize: 13)),
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primaryBlue.withOpacity(0.2), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primaryBlue, size: 18),
            const SizedBox(width: 10),
            Text(label, style: AppTextStyles.body.copyWith(color: AppColors.primaryBlue, fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildAIAnalysisCard(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.charcoal,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.mediumGray,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: color,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToAIAnalysis(BuildContext context, String analysisType) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StationAIAnalysisPageWithSidebar(
          stationId: stationId,
          station: station,
          analysisType: analysisType,
        ),
      ),
    );
  }
}
