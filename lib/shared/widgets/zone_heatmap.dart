import 'package:flutter/material.dart';
import '../../core/constants/color_constants.dart';
import '../../core/theme/text_styles.dart';
import 'trend_chart.dart';

class ZoneHeatmap extends StatelessWidget {
  final List<WaterQualityDataPoint> data;
  final String title;
  final String selectedParameter;

  const ZoneHeatmap({
    super.key,
    required this.data,
    this.title = 'Zone Quality Heatmap',
    this.selectedParameter = 'overall',
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return _buildEmptyState();
    }

    final zoneData = _aggregateByZone();

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
          _buildHeatmapGrid(zoneData),
          const SizedBox(height: 16),
          _buildColorScale(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.heading3.copyWith(
            color: AppColors.primaryBlue,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Water quality distribution across monitoring zones',
          style: AppTextStyles.body.copyWith(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
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
              Icons.grid_on,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No zone data available',
              style: AppTextStyles.body.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeatmapGrid(Map<String, ZoneMetrics> zoneData) {
    final zones = zoneData.keys.toList()..sort();

    return Column(
      children: zones.map((zone) {
        final metrics = zoneData[zone]!;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildZoneRow(zone, metrics),
        );
      }).toList(),
    );
  }

  Widget _buildZoneRow(String zone, ZoneMetrics metrics) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            zone,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primaryBlue,
            ),
          ),
        ),
        Expanded(
          child: Row(
            children: [
              _buildParameterCell('pH', metrics.avgPh, 6.5, 8.5),
              _buildParameterCell('Turb', metrics.avgTurbidity, 0, 5),
              _buildParameterCell('DO', metrics.avgDO, 5, 15),
              _buildParameterCell('Temp', metrics.avgTemp, 0, 30),
              _buildParameterCell('Cond', metrics.avgConductivity, 0, 800, scaleFactor: 1),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getOverallQualityColor(metrics.overallQuality),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '${metrics.sampleCount}',
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildParameterCell(
    String label,
    double value,
    double minThreshold,
    double maxThreshold, {
    double scaleFactor = 1,
  }) {
    final displayValue = value / scaleFactor;
    final color = _getParameterColor(displayValue, minThreshold, maxThreshold);

    return Expanded(
      child: Tooltip(
        message: '$label: ${displayValue.toStringAsFixed(1)}',
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          height: 50,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 9,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  displayValue.toStringAsFixed(1),
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorScale() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Text(
            'Quality Scale:',
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(width: 12),
          _buildScaleItem('Excellent', AppColors.success),
          _buildScaleItem('Good', AppColors.chartGreen.withOpacity(0.7)),
          _buildScaleItem('Fair', AppColors.warning),
          _buildScaleItem('Poor', AppColors.chartOrange),
          _buildScaleItem('Critical', AppColors.error),
        ],
      ),
    );
  }

  Widget _buildScaleItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Color _getParameterColor(double value, double minThreshold, double maxThreshold) {
    // For parameters where higher is better (like DO)
    if (minThreshold > 0 && maxThreshold > minThreshold * 2) {
      if (value >= minThreshold * 1.5) return AppColors.success;
      if (value >= minThreshold * 1.2) return AppColors.chartGreen.withOpacity(0.7);
      if (value >= minThreshold) return AppColors.warning;
      if (value >= minThreshold * 0.7) return AppColors.chartOrange;
      return AppColors.error;
    }

    // For parameters with optimal range (like pH)
    if (minThreshold > 0 && maxThreshold > minThreshold) {
      final midPoint = (minThreshold + maxThreshold) / 2;
      final range = maxThreshold - minThreshold;
      
      if (value >= minThreshold && value <= maxThreshold) {
        final deviation = (value - midPoint).abs() / range;
        if (deviation < 0.15) return AppColors.success;
        if (deviation < 0.3) return AppColors.chartGreen.withOpacity(0.7);
        return AppColors.warning;
      }
      
      final outOfRange = value < minThreshold 
          ? (minThreshold - value) / minThreshold
          : (value - maxThreshold) / maxThreshold;
      
      if (outOfRange < 0.2) return AppColors.chartOrange;
      return AppColors.error;
    }

    // For parameters where lower is better (like turbidity)
    if (value <= maxThreshold * 0.5) return AppColors.success;
    if (value <= maxThreshold * 0.8) return AppColors.chartGreen.withOpacity(0.7);
    if (value <= maxThreshold) return AppColors.warning;
    if (value <= maxThreshold * 1.3) return AppColors.chartOrange;
    return AppColors.error;
  }

  Color _getOverallQualityColor(double quality) {
    if (quality >= 90) return AppColors.success;
    if (quality >= 75) return AppColors.chartGreen.withOpacity(0.7);
    if (quality >= 60) return AppColors.warning;
    if (quality >= 40) return AppColors.chartOrange;
    return AppColors.error;
  }

  Map<String, ZoneMetrics> _aggregateByZone() {
    Map<String, List<WaterQualityDataPoint>> zoneGroups = {};

    for (var point in data) {
      if (!zoneGroups.containsKey(point.location)) {
        zoneGroups[point.location] = [];
      }
      zoneGroups[point.location]!.add(point);
    }

    Map<String, ZoneMetrics> result = {};

    for (var entry in zoneGroups.entries) {
      final points = entry.value;
      final metrics = ZoneMetrics(
        avgPh: points.map((p) => p.ph).reduce((a, b) => a + b) / points.length,
        avgTurbidity: points.map((p) => p.turbidity).reduce((a, b) => a + b) / points.length,
        avgDO: points.map((p) => p.dissolvedOxygen).reduce((a, b) => a + b) / points.length,
        avgTemp: points.map((p) => p.temperature).reduce((a, b) => a + b) / points.length,
        avgConductivity: points.map((p) => p.conductivity).reduce((a, b) => a + b) / points.length,
        sampleCount: points.length,
      );

      result[entry.key] = metrics;
    }

    return result;
  }
}

class ZoneMetrics {
  final double avgPh;
  final double avgTurbidity;
  final double avgDO;
  final double avgTemp;
  final double avgConductivity;
  final int sampleCount;

  ZoneMetrics({
    required this.avgPh,
    required this.avgTurbidity,
    required this.avgDO,
    required this.avgTemp,
    required this.avgConductivity,
    required this.sampleCount,
  });

  double get overallQuality {
    // Calculate quality score based on parameter compliance
    double score = 100.0;

    // pH score (optimal: 6.5-8.5)
    if (avgPh < 6.5 || avgPh > 8.5) {
      score -= 20;
    } else if (avgPh < 7.0 || avgPh > 8.0) {
      score -= 10;
    }

    // Turbidity score (optimal: < 5 NTU)
    if (avgTurbidity > 5) {
      score -= 20;
    } else if (avgTurbidity > 3) {
      score -= 10;
    }

    // DO score (optimal: > 5 mg/L)
    if (avgDO < 5) {
      score -= 20;
    } else if (avgDO < 6) {
      score -= 10;
    }

    // Temperature score (optimal: < 30°C)
    if (avgTemp > 30) {
      score -= 20;
    } else if (avgTemp > 27) {
      score -= 10;
    }

    // Conductivity score (optimal: < 800 μS/cm)
    if (avgConductivity > 800) {
      score -= 20;
    } else if (avgConductivity > 600) {
      score -= 10;
    }

    return score.clamp(0, 100);
  }
}
