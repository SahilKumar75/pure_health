import 'package:flutter/material.dart';
import '../../data/models/disease_risk_model.dart';

/// Widget to display outbreak probability alert
class OutbreakAlertCard extends StatelessWidget {
  final OutbreakProbability outbreakProbability;
  final VoidCallback? onDetailsPressed;

  const OutbreakAlertCard({
    super.key,
    required this.outbreakProbability,
    this.onDetailsPressed,
  });

  Color _getLevelColor(String level) {
    switch (level) {
      case 'very_low':
        return Colors.green;
      case 'low':
        return Colors.lightGreen;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getLevelIcon(String level) {
    switch (level) {
      case 'very_low':
        return Icons.check_circle;
      case 'low':
        return Icons.info;
      case 'medium':
        return Icons.warning;
      case 'high':
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  String _getMessage(String level) {
    switch (level) {
      case 'very_low':
        return 'Water quality is good. No significant outbreak risk detected.';
      case 'low':
        return 'Minor concerns. Continue monitoring water quality.';
      case 'medium':
        return 'Moderate risk detected. Take preventive measures.';
      case 'high':
        return 'HIGH RISK! Immediate action required to prevent outbreak.';
      default:
        return 'Unknown risk level';
    }
  }

  @override
  Widget build(BuildContext context) {
    final levelColor = _getLevelColor(outbreakProbability.level);
    final levelIcon = _getLevelIcon(outbreakProbability.level);
    final message = _getMessage(outbreakProbability.level);

    return Card(
      elevation: outbreakProbability.level == 'high' ? 8 : 4,
      color: levelColor.withOpacity(0.05),
      margin: const EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: levelColor.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Icon and Level
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: levelColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      levelIcon,
                      color: levelColor,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Outbreak Probability',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          outbreakProbability.displayLevel,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: levelColor,
                              ),
                        ),
                      ],
                    ),
                  ),
                  // Score Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: levelColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${outbreakProbability.score}%',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: outbreakProbability.score / 100,
                  minHeight: 12,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(levelColor),
                ),
              ),

              const SizedBox(height: 16),

              // Message
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: levelColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: levelColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        message,
                        style: TextStyle(
                          fontSize: 13,
                          color: levelColor.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // High Risk Diseases Section
              if (outbreakProbability.highRiskDiseases.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'High Risk Diseases (${outbreakProbability.diseaseCount})',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: outbreakProbability.highRiskDiseases.map((disease) {
                    return Chip(
                      label: Text(
                        _formatDiseaseName(disease),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      backgroundColor: levelColor.withOpacity(0.2),
                      avatar: Icon(
                        Icons.coronavirus,
                        color: levelColor,
                        size: 16,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    );
                  }).toList(),
                ),
              ],

              // Action Button
              if (onDetailsPressed != null) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onDetailsPressed,
                    icon: const Icon(Icons.analytics),
                    label: const Text('View Detailed Analysis'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: levelColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDiseaseName(String disease) {
    return disease
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
