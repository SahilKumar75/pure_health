import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pure_health/core/constants/color_constants.dart';
import 'package:pure_health/core/theme/text_styles.dart';

class WaterQualityCharts {
  /// 📈 pH Trend Chart (Line Chart)
  static Widget buildPHTrendChart(List<Map<String, dynamic>> data) {
    if (data.isEmpty) {
      return _buildEmptyChart('No pH data available');
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.darkCream.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📊 pH Levels Trend',
            style: AppTextStyles.heading4.copyWith(
              color: AppColors.charcoal,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Last 24 hours',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.mediumGray,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 0.5,
                  verticalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppColors.darkCream.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: AppColors.darkCream.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          'H${value.toInt()}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.mediumGray,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toStringAsFixed(1)}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.mediumGray,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: AppColors.darkCream.withOpacity(0.2),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: _generatePHSpots(data),
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.darkVanilla,
                        AppColors.darkVanilla.withOpacity(0.5),
                      ],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: AppColors.darkVanilla,
                          strokeWidth: 2,
                          strokeColor: AppColors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.darkVanilla.withOpacity(0.2),
                          AppColors.darkVanilla.withOpacity(0.01),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                minY: 6.0,
                maxY: 8.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildChartLegend('Safe Range: 6.5 - 8.5 pH'),
        ],
      ),
    );
  }

  /// 📊 Turbidity Comparison Chart (Bar Chart)
  static Widget buildTurbidityChart(List<Map<String, dynamic>> data) {
    if (data.isEmpty) {
      return _buildEmptyChart('No turbidity data available');
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.darkCream.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🌊 Turbidity by Location',
            style: AppTextStyles.heading4.copyWith(
              color: AppColors.charcoal,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Turbidity Levels (NTU)',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.mediumGray,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 10,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    fitInsideHorizontally: true,
                    fitInsideVertically: true,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final location = _getLocationName(groupIndex);
                      return BarTooltipItem(
                        '$location\n${rod.toY.toStringAsFixed(2)} NTU',
                        TextStyle(
                          color: AppColors.white,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppColors.darkCream.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _getLocationName(value.toInt()),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.charcoal,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.mediumGray,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: AppColors.darkCream.withOpacity(0.2),
                  ),
                ),
                barGroups: _generateTurbidityBars(data),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildChartLegend('Safe Limit: < 5 NTU'),
        ],
      ),
    );
  }

  /// 🥧 Status Distribution Pie Chart
  static Widget buildStatusPieChart(Map<String, int> statusCounts) {
    final total = statusCounts.values.fold<int>(0, (a, b) => a + b);
    if (total == 0) {
      return _buildEmptyChart('No status data available');
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.darkCream.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📈 Water Quality Status Distribution',
            style: AppTextStyles.heading4.copyWith(
              color: AppColors.charcoal,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Overall quality breakdown',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.mediumGray,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 250,
                  child: PieChart(
                    PieChartData(
                      sections: _generatePieSections(statusCounts),
                      centerSpaceRadius: 50,
                      sectionsSpace: 2,
                      pieTouchData: PieTouchData(
                        enabled: true,
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {},
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegendItem('Safe', statusCounts['Safe'] ?? 0,
                        AppColors.success),
                    const SizedBox(height: 12),
                    _buildLegendItem('Warning', statusCounts['Warning'] ?? 0,
                        AppColors.warning),
                    const SizedBox(height: 12),
                    _buildLegendItem('Critical', statusCounts['Critical'] ?? 0,
                        AppColors.error),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 📍 Location-based Status Widget
  static Widget buildLocationStatus(List<Map<String, dynamic>> locations) {
    if (locations.isEmpty) {
      return _buildEmptyChart('No location data available');
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.darkCream.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📍 Location Status Overview',
            style: AppTextStyles.heading4.copyWith(
              color: AppColors.charcoal,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          ...locations.asMap().entries.map((entry) {
            final index = entry.key;
            final loc = entry.value;
            final status = loc['status'] as String?;
            final statusColor = status == 'Safe'
                ? AppColors.success
                : status == 'Warning'
                    ? AppColors.warning
                    : AppColors.error;
            final statusIcon = status == 'Safe'
                ? '✅'
                : status == 'Warning'
                    ? '⚠️'
                    : '❌';

            return Padding(
              padding: EdgeInsets.only(
                bottom: index < locations.length - 1 ? 12 : 0,
              ),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: statusColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc['location'] ?? 'Unknown',
                          style: AppTextStyles.button.copyWith(
                            color: AppColors.charcoal,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'pH: ${(loc['pH'] as num?)?.toStringAsFixed(1) ?? 'N/A'} | Turbidity: ${(loc['turbidity'] as num?)?.toStringAsFixed(1) ?? 'N/A'} NTU',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.mediumGray,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor),
                      ),
                      child: Text(
                        '$statusIcon ${status ?? 'Unknown'}',
                        style: AppTextStyles.buttonSmall.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  /// 📊 Temperature & Conductivity Combo Chart
  static Widget buildTemperatureConductivityChart(
    List<Map<String, dynamic>> data,
  ) {
    if (data.isEmpty) {
      return _buildEmptyChart('No temperature/conductivity data available');
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.darkCream.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🌡️ Temperature & Conductivity',
            style: AppTextStyles.heading4.copyWith(
              color: AppColors.charcoal,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSimpleStat(
                  'Avg Temperature',
                  '${(_getAverageValue(data, "temperature")).toStringAsFixed(1)}°C',
                  AppColors.warning,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSimpleStat(
                  'Avg Conductivity',
                  '${(_getAverageValue(data, "conductivity")).toStringAsFixed(0)} µS/cm',
                  AppColors.darkVanilla,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============= HELPER METHODS =============

  static List<FlSpot> _generatePHSpots(List<Map<String, dynamic>> data) {
    return List.generate(
      data.length,
      (index) => FlSpot(
        index.toDouble(),
        (data[index]['pH'] as num?)?.toDouble() ?? 7.0,
      ),
    );
  }

  static List<BarChartGroupData> _generateTurbidityBars(
    List<Map<String, dynamic>> data,
  ) {
    return List.generate(
      data.length,
      (index) {
        final turbidity = (data[index]['turbidity'] as num?)?.toDouble() ?? 0;
        final color = turbidity > 5
            ? AppColors.error
            : turbidity > 3
                ? AppColors.warning
                : AppColors.success;

        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: turbidity,
              color: color,
              width: 16,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        );
      },
    );
  }

  static List<PieChartSectionData> _generatePieSections(
    Map<String, int> counts,
  ) {
    return [
      PieChartSectionData(
        value: (counts['Safe'] ?? 0).toDouble(),
        title: '${counts['Safe'] ?? 0}',
        color: AppColors.success,
        radius: 100,
        titleStyle: AppTextStyles.buttonSmall.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
      PieChartSectionData(
        value: (counts['Warning'] ?? 0).toDouble(),
        title: '${counts['Warning'] ?? 0}',
        color: AppColors.warning,
        radius: 100,
        titleStyle: AppTextStyles.buttonSmall.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
      PieChartSectionData(
        value: (counts['Critical'] ?? 0).toDouble(),
        title: '${counts['Critical'] ?? 0}',
        color: AppColors.error,
        radius: 100,
        titleStyle: AppTextStyles.buttonSmall.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    ];
  }

  static String _getLocationName(int index) {
    final locations = ['Zone A', 'Zone B', 'Zone C', 'Zone D', 'Zone E'];
    return locations.asMap().containsKey(index) ? locations[index] : 'Zone ${index + 1}';
  }

  static Widget _buildLegendItem(String label, int count, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.charcoal,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$count records',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.mediumGray,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _buildChartLegend(String text) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.darkVanilla.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.darkVanilla.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.darkVanilla,
        ),
      ),
    );
  }

  static Widget _buildSimpleStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.mediumGray,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.heading4.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildEmptyChart(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.darkCream.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          message,
          style: AppTextStyles.body.copyWith(
            color: AppColors.mediumGray,
          ),
        ),
      ),
    );
  }

  static double _getAverageValue(List<Map<String, dynamic>> data, String key) {
    if (data.isEmpty) return 0;
    final total = data.fold<double>(
      0,
      (sum, item) => sum + ((item[key] as num?)?.toDouble() ?? 0),
    );
    return total / data.length;
  }
}
