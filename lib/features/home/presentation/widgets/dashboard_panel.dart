import 'package:flutter/material.dart';
import 'package:pure_health/core/constants/color_constants.dart';
import 'package:pure_health/core/theme/text_styles.dart';

class DashboardPanel extends StatelessWidget {
  final int totalStations;
  final int activeAlerts;
  final int safeCount;
  final int warningCount;
  final int criticalCount;

  const DashboardPanel({
    super.key,
    required this.totalStations,
    required this.activeAlerts,
    required this.safeCount,
    required this.warningCount,
    required this.criticalCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // System Status Section
        _buildSectionHeader('System Status', Icons.analytics_outlined),
        const SizedBox(height: 16),
        _buildStatRow(
          'Total Stations',
          totalStations.toString(),
          Icons.location_on,
          AppColors.primaryBlue,
        ),
        const SizedBox(height: 12),
        _buildStatRow(
          'Active Alerts',
          activeAlerts.toString(),
          Icons.notifications_active,
          activeAlerts > 0 ? AppColors.warning : AppColors.success,
        ),
        const SizedBox(height: 12),
        _buildStatRow(
          'Last Updated',
          'Just now',
          Icons.access_time,
          AppColors.mediumGray,
        ),
        
        const SizedBox(height: 20),
        Divider(height: 1, color: AppColors.darkCream.withOpacity(0.4)),
        const SizedBox(height: 20),
        
        // Status Distribution
        _buildSectionHeader('Status Distribution', Icons.pie_chart_outline),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatusBadge('Safe', safeCount, AppColors.success),
            _buildStatusBadge('Warning', warningCount, AppColors.warning),
            _buildStatusBadge('Critical', criticalCount, AppColors.error),
          ],
        ),
        
        const SizedBox(height: 24),
        Divider(height: 1, color: AppColors.darkCream.withOpacity(0.4)),
        const SizedBox(height: 20),
        
        // Map Legend
        _buildSectionHeader('Map Legend', Icons.map_outlined),
        const SizedBox(height: 16),
        _buildLegendItem('Safe', 'Within limits', AppColors.success, Icons.check_circle),
        const SizedBox(height: 12),
        _buildLegendItem('Warning', 'Approaching limits', AppColors.warning, Icons.warning),
        const SizedBox(height: 12),
        _buildLegendItem('Critical', 'Exceeds limits', AppColors.error, Icons.error),
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

  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.body.copyWith(
                color: AppColors.charcoal.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: AppTextStyles.heading4.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            shape: BoxShape.circle,
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              count.toString(),
              style: AppTextStyles.heading3.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.charcoal.withOpacity(0.7),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, String description, Color color, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.white, size: 14),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.charcoal,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              Text(
                description,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.charcoal.withOpacity(0.6),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
