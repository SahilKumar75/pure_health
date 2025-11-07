import 'package:flutter/material.dart';
import 'package:pure_health/core/constants/color_constants.dart';
import 'package:pure_health/core/theme/text_styles.dart';

class DashboardPanel extends StatelessWidget {
  final int totalStations;
  final int activeAlerts;
  final int safeCount;
  final int warningCount;
  final int criticalCount;
  final String? selectedDistrict;
  final String? selectedType;
  final List<String> availableDistricts;
  final Function(String?) onDistrictChanged;
  final Function(String?) onTypeChanged;
  final VoidCallback onClearFilters;

  const DashboardPanel({
    super.key,
    required this.totalStations,
    required this.activeAlerts,
    required this.safeCount,
    required this.warningCount,
    required this.criticalCount,
    required this.selectedDistrict,
    required this.selectedType,
    required this.availableDistricts,
    required this.onDistrictChanged,
    required this.onTypeChanged,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filters Section
        _buildSectionHeader('Filters', Icons.filter_list),
        const SizedBox(height: 16),
        
        // District filter - Fixed focus traversal issue
        Container(
          decoration: BoxDecoration(
            color: AppColors.lightCream,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.darkCream.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: ExcludeFocus(
              child: DropdownButton<String?>(
                isExpanded: true,
                value: selectedDistrict,
                hint: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'All Districts',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.mediumGray,
                    ),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                borderRadius: BorderRadius.circular(12),
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text('All Districts', style: AppTextStyles.body),
                  ),
                  ...availableDistricts.map((district) => DropdownMenuItem<String?>(
                    value: district,
                    child: Text(district, style: AppTextStyles.body),
                  )),
                ],
                onChanged: onDistrictChanged,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Type filter - Fixed focus traversal issue
        Container(
          decoration: BoxDecoration(
            color: AppColors.lightCream,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.darkCream.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: ExcludeFocus(
              child: DropdownButton<String?>(
                isExpanded: true,
                value: selectedType,
                hint: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'All Types',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.mediumGray,
                    ),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                borderRadius: BorderRadius.circular(12),
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text('All Types', style: AppTextStyles.body),
                  ),
                  DropdownMenuItem<String?>(
                    value: 'Surface Water',
                    child: Text('Surface Water', style: AppTextStyles.body),
                  ),
                  DropdownMenuItem<String?>(
                    value: 'Groundwater',
                    child: Text('Groundwater', style: AppTextStyles.body),
                  ),
                ],
                onChanged: onTypeChanged,
              ),
            ),
          ),
        ),
        
        // Clear filters button
        if (selectedDistrict != null || selectedType != null) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onClearFilters,
              icon: const Icon(Icons.clear, size: 18),
              label: const Text('Clear Filters'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightCream,
                foregroundColor: AppColors.primaryBlue,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: AppColors.primaryBlue.withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
        ],
        
        const SizedBox(height: 20),
        Divider(height: 1, color: AppColors.darkCream.withOpacity(0.4)),
        const SizedBox(height: 20),
        
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
