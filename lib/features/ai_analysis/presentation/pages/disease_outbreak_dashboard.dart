import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/models/disease_risk_model.dart';
import '../../data/services/historical_disease_data_service.dart';
import '../widgets/disease_risk_card.dart';
import '../widgets/outbreak_alert_card.dart';

/// Disease Outbreak Dashboard for a station
class DiseaseOutbreakDashboard extends StatefulWidget {
  final String stationId;
  final String stationName;

  const DiseaseOutbreakDashboard({
    super.key,
    required this.stationId,
    required this.stationName,
  });

  @override
  State<DiseaseOutbreakDashboard> createState() => _DiseaseOutbreakDashboardState();
}

class _DiseaseOutbreakDashboardState extends State<DiseaseOutbreakDashboard> {
  final _diseaseService = HistoricalDiseaseDataService();
  
  bool _isLoading = true;
  String? _error;
  
  StationDataWithDisease? _latestReading;
  Map<String, List<int>>? _diseaseRiskTrends;
  Map<String, Map<String, double>>? _seasonalPatterns;
  
  int _selectedTimeRange = 30; // days

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: _selectedTimeRange));

      final results = await Future.wait([
        _diseaseService.getLatestReading(widget.stationId),
        _diseaseService.getDiseaseRiskTrends(widget.stationId, startDate, endDate),
        _diseaseService.getSeasonalDiseasePatterns(widget.stationId),
      ]);

      setState(() {
        _latestReading = results[0] as StationDataWithDisease?;
        _diseaseRiskTrends = results[1] as Map<String, List<int>>;
        _seasonalPatterns = results[2] as Map<String, Map<String, double>>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Disease Outbreak Dashboard'),
            Text(
              widget.stationName,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _latestReading == null
                  ? const Center(child: Text('No data available'))
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      child: ListView(
                        padding: const EdgeInsets.all(8),
                        children: [
                          // Time Range Selector
                          _buildTimeRangeSelector(),
                          const SizedBox(height: 16),

                          // Current Outbreak Alert
                          OutbreakAlertCard(
                            outbreakProbability: _latestReading!.outbreakProbability,
                            onDetailsPressed: () {
                              // TODO: Navigate to detailed analysis
                            },
                          ),
                          const SizedBox(height: 16),

                          // Current Disease Risks
                          _buildSectionHeader('Current Disease Risks'),
                          ..._latestReading!.diseaseRisks
                              .map((risk) => DiseaseRiskCard(diseaseRisk: risk))
                              .toList(),
                          const SizedBox(height: 16),

                          // Trend Chart
                          if (_diseaseRiskTrends != null) ...[
                            _buildSectionHeader('Risk Trends (Last $_selectedTimeRange days)'),
                            _buildTrendChart(),
                            const SizedBox(height: 16),
                          ],

                          // Seasonal Patterns
                          if (_seasonalPatterns != null) ...[
                            _buildSectionHeader('Seasonal Disease Patterns'),
                            _buildSeasonalPatternsChart(),
                            const SizedBox(height: 16),
                          ],

                          // Environmental Factors
                          _buildSectionHeader('Environmental Factors'),
                          _buildEnvironmentalFactors(),
                          const SizedBox(height: 16),

                          // Water Quality Summary
                          _buildSectionHeader('Water Quality Summary'),
                          _buildWaterQualitySummary(),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Time Range',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [7, 14, 30, 60, 90].map((days) {
                final isSelected = _selectedTimeRange == days;
                return ChoiceChip(
                  label: Text('$days days'),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedTimeRange = days;
                      });
                      _loadData();
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTrendChart() {
    if (_diseaseRiskTrends == null || _diseaseRiskTrends!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 300,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: true),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        'D${value.toInt()}',
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: true),
              lineBarsData: _createLineChartData(),
              minY: 0,
              maxY: 100,
            ),
          ),
        ),
      ),
    );
  }

  List<LineChartBarData> _createLineChartData() {
    final colors = [
      Colors.red,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.green,
      Colors.blue,
      Colors.teal,
    ];

    int colorIndex = 0;
    return _diseaseRiskTrends!.entries.map((entry) {
      final color = colors[colorIndex % colors.length];
      colorIndex++;

      return LineChartBarData(
        spots: List.generate(
          entry.value.length,
          (index) => FlSpot(index.toDouble(), entry.value[index].toDouble()),
        ),
        isCurved: true,
        color: color,
        barWidth: 2,
        dotData: const FlDotData(show: false),
      );
    }).toList();
  }

  Widget _buildSeasonalPatternsChart() {
    if (_seasonalPatterns == null || _seasonalPatterns!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: _seasonalPatterns!.entries.map((seasonEntry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  seasonEntry.key,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...seasonEntry.value.entries.map((diseaseEntry) {
                  final avgScore = diseaseEntry.value;
                  final color = _getRiskColor(avgScore.toInt());
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            _formatDiseaseName(diseaseEntry.key),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: avgScore / 100,
                              minHeight: 8,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(color),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          avgScore.toStringAsFixed(0),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const Divider(),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEnvironmentalFactors() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildFactorRow(
              'Stagnation Index',
              _latestReading!.stagnationIndex,
              Icons.water,
              'Water stagnation level (breeding ground for vectors)',
            ),
            const SizedBox(height: 12),
            _buildFactorRow(
              'Rainfall Index',
              _latestReading!.rainfallIndex,
              Icons.water_drop,
              'Rainfall impact on water quality',
            ),
            const SizedBox(height: 12),
            _buildFactorRow(
              'Season',
              null,
              Icons.wb_sunny,
              _latestReading!.season,
              seasonText: _latestReading!.season,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFactorRow(
    String label,
    double? value,
    IconData icon,
    String description, {
    String? seasonText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.blue),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (value != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 12,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getIndexColor(value),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${(value * 100).toStringAsFixed(0)}% - $description',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
        ] else if (seasonText != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              seasonText,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.blue,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildWaterQualitySummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Water Quality Index',
                      style: TextStyle(fontSize: 12),
                    ),
                    Text(
                      _latestReading!.wqi.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: _getWQIColor(_latestReading!.wqi),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _getWQIColor(_latestReading!.wqi).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _latestReading!.waterQualityClass,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _getWQIColor(_latestReading!.wqi),
                        ),
                      ),
                      Text(
                        _latestReading!.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          color: _getWQIColor(_latestReading!.wqi),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Key Parameters',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildKeyParameter('pH', _latestReading!.waterQualityParams['ph']),
            _buildKeyParameter('Turbidity', _latestReading!.waterQualityParams['turbidity'], unit: 'NTU'),
            _buildKeyParameter('Total Coliform', _latestReading!.waterQualityParams['totalColiform'], unit: 'MPN/100ml'),
            _buildKeyParameter('Dissolved Oxygen', _latestReading!.waterQualityParams['dissolvedOxygen'], unit: 'mg/L'),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyParameter(String label, dynamic value, {String unit = ''}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
          Text(
            '${value is double ? value.toStringAsFixed(2) : value} $unit',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRiskColor(int score) {
    if (score >= 80) return Colors.red.shade700;
    if (score >= 60) return Colors.orange.shade700;
    if (score >= 40) return Colors.yellow.shade700;
    if (score >= 20) return Colors.lightGreen;
    return Colors.green;
  }

  Color _getIndexColor(double value) {
    if (value >= 0.8) return Colors.red;
    if (value >= 0.6) return Colors.orange;
    if (value >= 0.4) return Colors.yellow;
    if (value >= 0.2) return Colors.lightGreen;
    return Colors.green;
  }

  Color _getWQIColor(double wqi) {
    if (wqi >= 75) return Colors.green;
    if (wqi >= 50) return Colors.lightGreen;
    if (wqi >= 25) return Colors.orange;
    return Colors.red;
  }

  String _formatDiseaseName(String disease) {
    return disease
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
