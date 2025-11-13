import 'package:flutter/material.dart';
import '../../data/models/disease_risk_model.dart';

/// Widget to display disease risk information
class DiseaseRiskCard extends StatelessWidget {
  final DiseaseRisk diseaseRisk;
  final VoidCallback? onTap;

  const DiseaseRiskCard({
    super.key,
    required this.diseaseRisk,
    this.onTap,
  });

  Color _getRiskColor(int score) {
    if (score >= 80) return Colors.red.shade700;
    if (score >= 60) return Colors.orange.shade700;
    if (score >= 40) return Colors.yellow.shade700;
    if (score >= 20) return Colors.lightGreen;
    return Colors.green;
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'waterborne':
        return Icons.water_drop;
      case 'vector_borne':
        return Icons.bug_report;
      case 'water_washed':
        return Icons.clean_hands;
      default:
        return Icons.health_and_safety;
    }
  }

  @override
  Widget build(BuildContext context) {
    final riskColor = _getRiskColor(diseaseRisk.riskScore);
    final categoryIcon = _getCategoryIcon(diseaseRisk.category);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Category Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: riskColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  categoryIcon,
                  color: riskColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),

              // Disease Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      diseaseRisk.displayName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: riskColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            diseaseRisk.riskLevel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: riskColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          diseaseRisk.category.replaceAll('_', ' ').toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Risk Score
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${diseaseRisk.riskScore}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: riskColor,
                    ),
                  ),
                  Text(
                    'Risk Score',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 8),

              // Progress Indicator
              SizedBox(
                width: 40,
                height: 40,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: diseaseRisk.riskScore / 100,
                      strokeWidth: 4,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(riskColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
