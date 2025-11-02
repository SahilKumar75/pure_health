import 'package:flutter/material.dart';
import 'package:pure_health/core/theme/government_theme.dart';
import 'package:pure_health/core/theme/text_styles.dart';

/// Compliance monitoring widget for water quality standards
class ComplianceMonitor extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const ComplianceMonitor({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final metrics = _calculateMetrics();

    return GovernmentCard(
      title: 'Compliance Status',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverallStatus(metrics),
          const SizedBox(height: 24),
          _buildParameterCompliance(metrics),
          const SizedBox(height: 24),
          _buildRecommendations(metrics),
        ],
      ),
    );
  }

  Map<String, dynamic> _calculateMetrics() {
    if (data.isEmpty) {
      return {
        'overall_compliant': false,
        'pH_compliant': false,
        'turbidity_compliant': false,
        'do_compliant': false,
        'pH_avg': 0.0,
        'turbidity_avg': 0.0,
        'do_avg': 0.0,
        'safe_count': 0,
        'warning_count': 0,
        'critical_count': 0,
      };
    }

    double pHSum = 0, turbSum = 0, doSum = 0;
    int pHCount = 0, turbCount = 0, doCount = 0;
    int safeCount = 0, warningCount = 0, criticalCount = 0;

    for (var record in data) {
      // pH
      if (record['pH'] != null) {
        pHSum += (record['pH'] as num).toDouble();
        pHCount++;
      }
      
      // Turbidity
      if (record['turbidity'] != null) {
        turbSum += (record['turbidity'] as num).toDouble();
        turbCount++;
      }
      
      // Dissolved Oxygen
      if (record['dissolved_oxygen'] != null) {
        doSum += (record['dissolved_oxygen'] as num).toDouble();
        doCount++;
      }

      // Status counts
      final status = record['status']?.toString().toLowerCase() ?? '';
      if (status == 'safe') safeCount++;
      else if (status == 'warning') warningCount++;
      else if (status == 'critical') criticalCount++;
    }

    final pHAvg = pHCount > 0 ? pHSum / pHCount : 0.0;
    final turbAvg = turbCount > 0 ? turbSum / turbCount : 0.0;
    final doAvg = doCount > 0 ? doSum / doCount : 0.0;

    final pHCompliant = pHAvg >= 6.5 && pHAvg <= 8.5;
    final turbCompliant = turbAvg < 5.0;
    final doCompliant = doAvg > 5.0;

    return {
      'overall_compliant': pHCompliant && turbCompliant && doCompliant,
      'pH_compliant': pHCompliant,
      'turbidity_compliant': turbCompliant,
      'do_compliant': doCompliant,
      'pH_avg': pHAvg,
      'turbidity_avg': turbAvg,
      'do_avg': doAvg,
      'safe_count': safeCount,
      'warning_count': warningCount,
      'critical_count': criticalCount,
      'total_records': data.length,
    };
  }

  Widget _buildOverallStatus(Map<String, dynamic> metrics) {
    final isCompliant = metrics['overall_compliant'] as bool;
    final safePercentage = metrics['total_records'] > 0
        ? (metrics['safe_count'] / metrics['total_records'] * 100)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isCompliant
            ? GovernmentTheme.statusGreen.withOpacity(0.1)
            : GovernmentTheme.statusRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCompliant
              ? GovernmentTheme.statusGreen
              : GovernmentTheme.statusRed,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isCompliant ? Icons.check_circle : Icons.warning,
            color: isCompliant
                ? GovernmentTheme.statusGreen
                : GovernmentTheme.statusRed,
            size: 48,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCompliant
                      ? 'COMPLIANT'
                      : 'NON-COMPLIANT',
                  style: AppTextStyles.heading3.copyWith(
                    color: isCompliant
                        ? GovernmentTheme.statusGreen
                        : GovernmentTheme.statusRed,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${safePercentage.toStringAsFixed(1)}% of records meet safety standards',
                  style: AppTextStyles.body.copyWith(
                    color: GovernmentTheme.governmentGray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParameterCompliance(Map<String, dynamic> metrics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Parameter Compliance',
          style: AppTextStyles.heading4.copyWith(
            color: GovernmentTheme.governmentBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        _buildComplianceRow(
          'pH Level',
          metrics['pH_avg'].toStringAsFixed(2),
          '6.5 - 8.5',
          metrics['pH_compliant'] as bool,
        ),
        const Divider(height: 24),
        _buildComplianceRow(
          'Turbidity',
          '${metrics['turbidity_avg'].toStringAsFixed(2)} NTU',
          '< 5.0 NTU',
          metrics['turbidity_compliant'] as bool,
        ),
        const Divider(height: 24),
        _buildComplianceRow(
          'Dissolved Oxygen',
          '${metrics['do_avg'].toStringAsFixed(2)} mg/L',
          '> 5.0 mg/L',
          metrics['do_compliant'] as bool,
        ),
      ],
    );
  }

  Widget _buildComplianceRow(
    String parameter,
    String value,
    String standard,
    bool compliant,
  ) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                parameter,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: GovernmentTheme.governmentBlue,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Standard: $standard',
                style: AppTextStyles.bodySmall.copyWith(
                  color: GovernmentTheme.governmentGray,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: GovernmentTheme.governmentBlue,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        StatusBadge(
          status: compliant ? 'COMPLIANT' : 'NON-COMPLIANT',
          isCompact: true,
        ),
      ],
    );
  }

  Widget _buildRecommendations(Map<String, dynamic> metrics) {
    final recommendations = <String>[];

    if (!(metrics['pH_compliant'] as bool)) {
      recommendations.add('pH levels require adjustment - implement water treatment protocols');
    }

    if (!(metrics['turbidity_compliant'] as bool)) {
      recommendations.add('Turbidity exceeds safe limits - enhance filtration systems');
    }

    if (!(metrics['do_compliant'] as bool)) {
      recommendations.add('Dissolved oxygen below recommended levels - increase aeration');
    }

    if (recommendations.isEmpty) {
      recommendations.add('All parameters within safe limits - continue regular monitoring');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recommendations',
          style: AppTextStyles.heading4.copyWith(
            color: GovernmentTheme.governmentBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...recommendations.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
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
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    entry.value,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: GovernmentTheme.governmentGray,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
