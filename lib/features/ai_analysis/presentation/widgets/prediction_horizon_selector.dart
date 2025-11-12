import 'package:flutter/material.dart';
import 'package:pure_health/core/constants/color_constants.dart';
import 'package:pure_health/core/theme/text_styles.dart';

class PredictionHorizonSelector extends StatelessWidget {
  final int selectedDays;
  final Function(int days) onDaysSelected;

  const PredictionHorizonSelector({
    super.key,
    required this.selectedDays,
    required this.onDaysSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkBg3,
        borderRadius: BorderRadius.circular(16),
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
                Icons.timeline,
                color: AppColors.accentPink,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Prediction Horizon',
                style: AppTextStyles.heading4.copyWith(
                  color: AppColors.lightText,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'How many days ahead do you want to predict?',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.mediumText,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          
          // Quick Options
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildQuickOption(context, 7, '7 Days'),
              _buildQuickOption(context, 14, '2 Weeks'),
              _buildQuickOption(context, 30, '1 Month'),
              _buildQuickOption(context, 60, '2 Months'),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Slider for custom selection
          Row(
            children: [
              Icon(
                Icons.tune,
                color: AppColors.mediumText,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Custom: $selectedDays days',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.lightText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: AppColors.accentPink,
                        inactiveTrackColor: AppColors.borderLight,
                        thumbColor: AppColors.accentPink,
                        overlayColor: AppColors.accentPink.withOpacity(0.2),
                        trackHeight: 4,
                      ),
                      child: Slider(
                        value: selectedDays.toDouble(),
                        min: 1,
                        max: 60,
                        divisions: 59,
                        label: '$selectedDays days',
                        onChanged: (value) {
                          onDaysSelected(value.toInt());
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Info message
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.accentPink.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.accentPink.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.accentPink,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Predictions are based on historical patterns. Accuracy decreases for longer horizons.',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.lightText,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickOption(BuildContext context, int days, String label) {
    final isSelected = selectedDays == days;
    
    return InkWell(
      onTap: () => onDaysSelected(days),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.accentPink 
              : AppColors.darkBg2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? AppColors.accentPink 
                : AppColors.borderLight,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: isSelected 
                ? Colors.white 
                : AppColors.lightText,
            fontWeight: isSelected 
                ? FontWeight.w600 
                : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
