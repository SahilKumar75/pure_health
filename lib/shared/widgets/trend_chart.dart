import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/color_constants.dart';
import '../../core/theme/text_styles.dart';

class TrendChart extends StatefulWidget {
  final List<WaterQualityDataPoint> data;
  final String title;
  final List<String> selectedParameters;
  final DateTimeRange? dateRange;

  const TrendChart({
    super.key,
    required this.data,
    required this.title,
    this.selectedParameters = const ['pH', 'Turbidity', 'DO'],
    this.dateRange,
  });

  @override
  State<TrendChart> createState() => _TrendChartState();
}

class _TrendChartState extends State<TrendChart> {
  @override
  Widget build(BuildContext context) {
    final filteredData = _filterDataByDateRange();
    
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
          _buildLegend(),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: filteredData.isEmpty
                ? _buildEmptyState()
                : LineChart(_buildLineChartData(filteredData)),
          ),
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
              '${widget.data.length} data points',
              style: AppTextStyles.body.copyWith(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        if (widget.dateRange != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${DateFormat('MMM dd').format(widget.dateRange!.start)} - ${DateFormat('MMM dd').format(widget.dateRange!.end)}',
              style: AppTextStyles.body.copyWith(
                color: AppColors.primaryBlue,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 20,
      runSpacing: 8,
      children: [
        if (widget.selectedParameters.contains('pH'))
          _buildLegendItem('pH Level', AppColors.chartBlue),
        if (widget.selectedParameters.contains('Turbidity'))
          _buildLegendItem('Turbidity', AppColors.chartOrange),
        if (widget.selectedParameters.contains('DO'))
          _buildLegendItem('Dissolved Oxygen', AppColors.chartGreen),
        if (widget.selectedParameters.contains('Temperature'))
          _buildLegendItem('Temperature', AppColors.chartRed),
        if (widget.selectedParameters.contains('Conductivity'))
          _buildLegendItem('Conductivity', AppColors.chartPurple),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.body.copyWith(
            fontSize: 12,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.show_chart,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No data available for selected range',
            style: AppTextStyles.body.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  List<WaterQualityDataPoint> _filterDataByDateRange() {
    if (widget.dateRange == null) return widget.data;
    
    return widget.data.where((point) {
      final date = point.timestamp;
      return date.isAfter(widget.dateRange!.start.subtract(const Duration(days: 1))) &&
          date.isBefore(widget.dateRange!.end.add(const Duration(days: 1)));
    }).toList();
  }

  LineChartData _buildLineChartData(List<WaterQualityDataPoint> data) {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey[200]!,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Colors.grey[200]!,
            strokeWidth: 1,
          );
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
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, meta) {
              if (value.toInt() < 0 || value.toInt() >= data.length) {
                return const SizedBox();
              }
              final date = data[value.toInt()].timestamp;
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  DateFormat('MM/dd').format(date),
                  style: AppTextStyles.body.copyWith(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 2,
            reservedSize: 42,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toStringAsFixed(1),
                style: AppTextStyles.body.copyWith(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      minX: 0,
      maxX: (data.length - 1).toDouble(),
      minY: 0,
      maxY: 14,
      lineBarsData: _buildLineBars(data),
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) => AppColors.primaryBlue.withOpacity(0.9),
          getTooltipItems: (List<LineBarSpot> touchedSpots) {
            return touchedSpots.map((LineBarSpot touchedSpot) {
              final dataPoint = data[touchedSpot.x.toInt()];
              String parameterName = '';
              String value = '';
              
              if (touchedSpot.barIndex == 0 && widget.selectedParameters.contains('pH')) {
                parameterName = 'pH';
                value = dataPoint.ph.toStringAsFixed(2);
              } else if (touchedSpot.barIndex == 1 && widget.selectedParameters.contains('Turbidity')) {
                parameterName = 'Turbidity';
                value = '${dataPoint.turbidity.toStringAsFixed(1)} NTU';
              } else if (touchedSpot.barIndex == 2 && widget.selectedParameters.contains('DO')) {
                parameterName = 'DO';
                value = '${dataPoint.dissolvedOxygen.toStringAsFixed(1)} mg/L';
              } else if (touchedSpot.barIndex == 3 && widget.selectedParameters.contains('Temperature')) {
                parameterName = 'Temp';
                value = '${dataPoint.temperature.toStringAsFixed(1)}°C';
              } else if (touchedSpot.barIndex == 4 && widget.selectedParameters.contains('Conductivity')) {
                parameterName = 'Cond';
                value = '${(dataPoint.conductivity / 100).toStringAsFixed(1)}×100 μS/cm';
              }
              
              return LineTooltipItem(
                '$parameterName: $value\n${DateFormat('MMM dd, HH:mm').format(dataPoint.timestamp)}',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            }).toList();
          },
        ),
        handleBuiltInTouches: true,
      ),
    );
  }

  List<LineChartBarData> _buildLineBars(List<WaterQualityDataPoint> data) {
    List<LineChartBarData> bars = [];

    if (widget.selectedParameters.contains('pH')) {
      bars.add(_buildLineBar(
        data,
        (point) => point.ph,
        AppColors.chartBlue,
      ));
    }

    if (widget.selectedParameters.contains('Turbidity')) {
      bars.add(_buildLineBar(
        data,
        (point) => point.turbidity,
        AppColors.chartOrange,
      ));
    }

    if (widget.selectedParameters.contains('DO')) {
      bars.add(_buildLineBar(
        data,
        (point) => point.dissolvedOxygen,
        AppColors.chartGreen,
      ));
    }

    if (widget.selectedParameters.contains('Temperature')) {
      bars.add(_buildLineBar(
        data,
        (point) => point.temperature / 3, // Scale down for visibility
        AppColors.chartRed,
      ));
    }

    if (widget.selectedParameters.contains('Conductivity')) {
      bars.add(_buildLineBar(
        data,
        (point) => point.conductivity / 100, // Scale down for visibility
        AppColors.chartPurple,
      ));
    }

    return bars;
  }

  LineChartBarData _buildLineBar(
    List<WaterQualityDataPoint> data,
    double Function(WaterQualityDataPoint) getValue,
    Color color,
  ) {
    return LineChartBarData(
      spots: List.generate(
        data.length,
        (index) => FlSpot(index.toDouble(), getValue(data[index])),
      ),
      isCurved: true,
      color: color,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 4,
            color: color,
            strokeWidth: 2,
            strokeColor: Colors.white,
          );
        },
      ),
      belowBarData: BarAreaData(
        show: true,
        color: color.withOpacity(0.1),
      ),
    );
  }
}

class WaterQualityDataPoint {
  final DateTime timestamp;
  final double ph;
  final double turbidity;
  final double dissolvedOxygen;
  final double temperature;
  final double conductivity;
  final String location;

  WaterQualityDataPoint({
    required this.timestamp,
    required this.ph,
    required this.turbidity,
    required this.dissolvedOxygen,
    required this.temperature,
    required this.conductivity,
    required this.location,
  });
}
