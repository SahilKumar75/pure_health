import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/constants/color_constants.dart';
import '../../core/theme/text_styles.dart';
import 'trend_chart.dart';

class ParameterComparisonChart extends StatefulWidget {
  final List<WaterQualityDataPoint> data;
  final String title;
  final bool showThresholds;

  const ParameterComparisonChart({
    super.key,
    required this.data,
    this.title = 'Parameter Comparison',
    this.showThresholds = true,
  });

  @override
  State<ParameterComparisonChart> createState() => _ParameterComparisonChartState();
}

class _ParameterComparisonChartState extends State<ParameterComparisonChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return _buildEmptyState();
    }

    final averages = _calculateAverages();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          SizedBox(
            height: 300,
            child: BarChart(
              _buildBarChartData(averages),
              swapAnimationDuration: const Duration(milliseconds: 250),
            ),
          ),
          if (widget.showThresholds) ...[
            const SizedBox(height: 16),
            _buildThresholdLegend(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.primaryBlue,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Average values from ${widget.data.length} samples',
              style: AppTextStyles.body.copyWith(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildThresholdLegend() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.lightBlue.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: AppColors.primaryBlue,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'WHO/EPA Standard Ranges: pH (6.5-8.5), Turbidity (<5 NTU), DO (>5 mg/L), Temp (<30°C)',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No data available',
              style: AppTextStyles.body.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, double> _calculateAverages() {
    if (widget.data.isEmpty) return {};

    double totalPh = 0;
    double totalTurbidity = 0;
    double totalDO = 0;
    double totalTemp = 0;
    double totalConductivity = 0;

    for (var point in widget.data) {
      totalPh += point.ph;
      totalTurbidity += point.turbidity;
      totalDO += point.dissolvedOxygen;
      totalTemp += point.temperature;
      totalConductivity += point.conductivity;
    }

    int count = widget.data.length;

    return {
      'pH': totalPh / count,
      'Turbidity': totalTurbidity / count,
      'DO': totalDO / count,
      'Temperature': totalTemp / count,
      'Conductivity': totalConductivity / count,
    };
  }

  BarChartData _buildBarChartData(Map<String, double> averages) {
    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: 15,
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (group) => AppColors.primaryBlue.withOpacity(0.9),
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            String parameter;
            String value;
            String unit;

            switch (group.x.toInt()) {
              case 0:
                parameter = 'pH Level';
                value = averages['pH']!.toStringAsFixed(2);
                unit = '';
                break;
              case 1:
                parameter = 'Turbidity';
                value = averages['Turbidity']!.toStringAsFixed(1);
                unit = ' NTU';
                break;
              case 2:
                parameter = 'Dissolved Oxygen';
                value = averages['DO']!.toStringAsFixed(1);
                unit = ' mg/L';
                break;
              case 3:
                parameter = 'Temperature';
                value = averages['Temperature']!.toStringAsFixed(1);
                unit = '°C';
                break;
              case 4:
                parameter = 'Conductivity';
                value = averages['Conductivity']!.toStringAsFixed(0);
                unit = ' μS/cm';
                break;
              default:
                return null;
            }

            return BarTooltipItem(
              '$parameter\n$value$unit',
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            );
          },
        ),
        touchCallback: (FlTouchEvent event, barTouchResponse) {
          setState(() {
            if (!event.isInterestedForInteractions ||
                barTouchResponse == null ||
                barTouchResponse.spot == null) {
              _touchedIndex = -1;
              return;
            }
            _touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
          });
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (double value, TitleMeta meta) {
              const style = TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
              );
              Widget text;
              switch (value.toInt()) {
                case 0:
                  text = const Text('pH', style: style);
                  break;
                case 1:
                  text = const Text('Turbidity', style: style);
                  break;
                case 2:
                  text = const Text('DO', style: style);
                  break;
                case 3:
                  text = const Text('Temp', style: style);
                  break;
                case 4:
                  text = const Text('Cond', style: style);
                  break;
                default:
                  text = const Text('', style: style);
                  break;
              }
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: text,
              );
            },
            reservedSize: 38,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            interval: 3,
            getTitlesWidget: (double value, TitleMeta meta) {
              return Text(
                value.toInt().toString(),
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.grey[600],
                ),
              );
            },
          ),
        ),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 3,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey[200]!,
            strokeWidth: 1,
          );
        },
      ),
      borderData: FlBorderData(
        show: true,
        border: Border(
          left: BorderSide(color: Colors.grey[300]!),
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      barGroups: _buildBarGroups(averages),
    );
  }

  List<BarChartGroupData> _buildBarGroups(Map<String, double> averages) {
    return [
      _buildBarGroup(0, averages['pH']!, AppColors.chartBlue),
      _buildBarGroup(1, averages['Turbidity']!, AppColors.chartOrange),
      _buildBarGroup(2, averages['DO']!, AppColors.chartGreen),
      _buildBarGroup(3, averages['Temperature']! / 3, AppColors.chartRed), // Scaled
      _buildBarGroup(4, averages['Conductivity']! / 80, AppColors.chartPurple), // Scaled
    ];
  }

  BarChartGroupData _buildBarGroup(int x, double value, Color color) {
    final isTouched = x == _touchedIndex;
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: value,
          color: isTouched ? color : color.withOpacity(0.8),
          width: isTouched ? 28 : 24,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
          ),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 15,
            color: Colors.grey[100],
          ),
        ),
      ],
    );
  }
}
