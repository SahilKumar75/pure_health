import 'package:flutter/material.dart';
import 'package:pure_health/core/constants/color_constants.dart';
import 'package:pure_health/core/theme/text_styles.dart';
import 'package:pure_health/core/models/station_models.dart';

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

  @override
  Widget build(BuildContext context) {
    final status = stationData.status;
    final pH = stationData.parameters['pH'] as double?;
    final turbidity = stationData.parameters['turbidity'] as double?;
    final dissolvedOxygen = stationData.parameters['dissolvedOxygen'] as double?;
    final temperature = stationData.parameters['temperature'] as double?;
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
        
        // AI Predictions
        _buildSectionHeader('AI Predictions', Icons.trending_up),
        const SizedBox(height: 16),
        _buildPredictionCard('Next 7 Days', 'Quality expected to remain ${status.toLowerCase()}', Icons.calendar_today),
        const SizedBox(height: 12),
        _buildPredictionCard('Risk Level', 'Low contamination risk', Icons.shield),
        
        const SizedBox(height: 24),
        
        // Quick Insights
        _buildSectionHeader('Key Insights', Icons.lightbulb_outline),
        const SizedBox(height: 16),
        _buildInsightItem('✓ All parameters within safe limits', AppColors.success),
        const SizedBox(height: 8),
        _buildInsightItem('↗ Slight pH increase trend observed', AppColors.warning),
        const SizedBox(height: 8),
        _buildInsightItem('→ Regular monitoring recommended', AppColors.primaryBlue),
        
        const SizedBox(height: 24),
        
        // Actions
        _buildSectionHeader('Available Actions', Icons.touch_app),
        const SizedBox(height: 16),
        _buildActionButton('View Full Report', Icons.description, () {}),
        const SizedBox(height: 10),
        _buildActionButton('Export Data', Icons.download, () {}),
        const SizedBox(height: 10),
        _buildActionButton('Set Alert', Icons.notifications, () {}),
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

  Widget _buildPredictionCard(String title, String description, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.success, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.body.copyWith(color: AppColors.charcoal, fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 2),
                Text(description, style: AppTextStyles.caption.copyWith(color: AppColors.mediumGray, fontSize: 12)),
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
}
