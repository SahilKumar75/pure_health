import 'package:flutter/material.dart';
import 'package:pure_health/core/constants/color_constants.dart';
import 'package:pure_health/core/theme/text_styles.dart';
import 'package:pure_health/ml/repositories/ml_repository.dart';

class CustomAlert extends StatefulWidget {
  final String title;
  final String message;
  final String? severity;
  final VoidCallback? onDismiss;

  const CustomAlert({
    super.key,
    required this.title,
    required this.message,
    this.severity,
    this.onDismiss,
  });

  @override
  State<CustomAlert> createState() => _CustomAlertState();
}

class _CustomAlertState extends State<CustomAlert> {
  late final MLRepository _mlRepository;

  @override
  void initState() {
    super.initState();
    _mlRepository = MLRepository();
  }

  Future<void> _analyzeSentiment() async {
    try {
      final result = await _mlRepository.classifyAlertSentiment(widget.message);
      debugPrint('Sentiment: $result');
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Color _getSeverityColor() {
    switch (widget.severity?.toLowerCase()) {
      case 'critical':
        return AppColors.error;
      case 'warning':
        return AppColors.warning;
      case 'info':
        return AppColors.info;
      default:
        return AppColors.success;
    }
  }

  IconData _getSeverityIcon() {
    switch (widget.severity?.toLowerCase()) {
      case 'critical':
        return Icons.error;
      case 'warning':
        return Icons.warning_amber;
      case 'info':
        return Icons.info;
      default:
        return Icons.check_circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getSeverityColor().withValues(alpha: 0.1),
        border: Border.all(
          color: _getSeverityColor().withValues(alpha: 0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            _getSeverityIcon(),
            color: _getSeverityColor(),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.lightText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.message,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.mediumText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () async {
              await _analyzeSentiment();
              widget.onDismiss?.call();
            },
            child: Icon(
              Icons.close,
              color: AppColors.mediumText,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
