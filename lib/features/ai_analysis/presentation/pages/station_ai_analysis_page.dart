import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pure_health/core/constants/color_constants.dart';
import 'package:pure_health/core/theme/text_styles.dart';
import 'package:pure_health/core/services/local_storage_service.dart';
import 'package:pure_health/features/ml_analysis/data/services/historical_data_service.dart';
import 'package:pure_health/ml/repositories/ml_repository.dart';
import 'package:pure_health/features/ai_analysis/presentation/widgets/time_range_selector.dart';
import 'package:pure_health/core/models/station_models.dart';

class StationAIAnalysisPage extends StatefulWidget {
  final String stationId;
  final WaterQualityStation station;
  final String analysisType; // 'prediction', 'risk', 'trends', 'recommendations'

  const StationAIAnalysisPage({
    super.key,
    required this.stationId,
    required this.station,
    required this.analysisType,
  });

  @override
  State<StationAIAnalysisPage> createState() => _StationAIAnalysisPageState();
}

class _StationAIAnalysisPageState extends State<StationAIAnalysisPage> {
  bool _isLoading = false;
  bool _isAnalyzing = false;
  DateTime? _startDate;
  DateTime? _endDate;
  Map<String, dynamic>? _analysisResult;
  List<StationData>? _filteredData;
  HistoricalDataService? _historicalService;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    setState(() => _isLoading = true);

    try {
      _historicalService = await HistoricalDataService.create();
      
      // Load initial data (last 30 days by default)
      final end = DateTime.now();
      final start = end.subtract(const Duration(days: 30));
      
      setState(() {
        _startDate = start;
        _endDate = end;
      });

      await _loadHistoricalData();
    } catch (e) {
      print('[STATION_AI_ANALYSIS] Error initializing: $e');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _loadHistoricalData() async {
    if (_historicalService == null || _startDate == null || _endDate == null) return;

    setState(() => _isLoading = true);

    try {
      final storage = await LocalStorageService.getInstance();
      final data = await storage.getStationReadingsInRange(
        widget.stationId,
        startDate: _startDate!,
        endDate: _endDate!,
      );

      setState(() {
        _filteredData = data;
      });
    } catch (e) {
      print('[STATION_AI_ANALYSIS] Error loading data: $e');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _performAnalysis() async {
    if (_historicalService == null) {
      _showError('Service not initialized');
      return;
    }

    setState(() => _isAnalyzing = true);

    try {
      Map<String, dynamic> result;

      switch (widget.analysisType) {
        case 'prediction':
          result = await _historicalService!.getMLPredictionData(widget.stationId);
          // If we don't have historical data locally, call ML repository fallback
          if (result['hasData'] != true) {
            final ml = MLRepository();
            try {
              final pred = await ml.getWaterQualityPrediction({'stationId': widget.stationId});
              // Convert into shape the UI expects (minimal)
              result = {
                'hasData': true,
                'dataPoints': 0,
                'statistics': {
                  'avgWqi': pred.predictedValue,
                  'minWqi': pred.predictedValue,
                  'maxWqi': pred.predictedValue,
                },
                'message': 'Prediction (fallback) available',
                'prediction': pred.toJson(),
              };
            } catch (e) {
              // keep original result (no data)
              print('[STATION_AI_ANALYSIS] ML fallback failed: $e');
            }
          }
          break;
        case 'risk':
          result = await _historicalService!.getRiskAssessmentData(widget.stationId);
          break;
        case 'trends':
          result = await _historicalService!.getTrendAnalysisData(widget.stationId);
          break;
        case 'recommendations':
          result = await _historicalService!.exportDataForML(widget.stationId);
          break;
        default:
          result = await _historicalService!.getMLPredictionData(widget.stationId);
      }

      setState(() {
        _analysisResult = result;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Analysis completed successfully!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      _showError('Analysis failed: ${e.toString()}');
    }

    setState(() => _isAnalyzing = false);
  }

  void _showError(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getAnalysisTitle(),
              style: AppTextStyles.heading4.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.station.name,
              style: AppTextStyles.caption.copyWith(
                color: Colors.white.withOpacity(0.9),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Station Info Card
                  _buildStationInfoCard(),
                  const SizedBox(height: 24),

                  // Time Range Selector
                  TimeRangeSelectorWidget(
                    startDate: _startDate,
                    endDate: _endDate,
                    onRangeSelected: (start, end) {
                      setState(() {
                        _startDate = start;
                        _endDate = end;
                      });
                      _loadHistoricalData();
                    },
                    onClear: () {
                      setState(() {
                        _startDate = null;
                        _endDate = null;
                        _filteredData = null;
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  // Data Summary
                  if (_filteredData != null) ...[
                    _buildDataSummaryCard(),
                    const SizedBox(height: 24),
                  ],

                  // Analysis Button
                  _buildAnalysisButton(),

                  const SizedBox(height: 24),

                  // Analysis Results
                  if (_analysisResult != null) ...[
                    _buildAnalysisResults(),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildStationInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryBlue,
            AppColors.primaryBlue.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.station.name,
                      style: AppTextStyles.heading4.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${widget.station.district} • ${widget.station.type}',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.white.withOpacity(0.3)),
          const SizedBox(height: 12),
          _buildInfoRow('Station ID', widget.stationId, Icons.tag),
          const SizedBox(height: 8),
          _buildInfoRow('Region', widget.station.region, Icons.map),
          const SizedBox(height: 8),
          _buildInfoRow('Monitoring', widget.station.monitoringType, Icons.sensors),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.8), size: 16),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: AppTextStyles.caption.copyWith(
            color: Colors.white.withOpacity(0.9),
            fontSize: 13,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.caption.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDataSummaryCard() {
    final dataCount = _filteredData?.length ?? 0;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.lightCream,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.darkCream.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assessment, color: AppColors.primaryBlue, size: 24),
              const SizedBox(width: 12),
              Text(
                'Data Summary',
                style: AppTextStyles.heading4.copyWith(
                  color: AppColors.charcoal,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Readings',
                  dataCount.toString(),
                  Icons.analytics,
                  AppColors.primaryBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryItem(
                  'Time Range',
                  '${(_endDate?.difference(_startDate ?? DateTime.now()).inDays ?? 0)} days',
                  Icons.date_range,
                  AppColors.success,
                ),
              ),
            ],
          ),
          if (dataCount > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.success, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ready for AI analysis',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (dataCount == 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: AppColors.warning, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'No data available for selected time range',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.heading3.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.mediumGray,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisButton() {
    // Allow forcing prediction even without filtered historical data by enabling
    // the button when the analysis type is 'prediction'. For other types
    // require filtered data.
    final isEnabled = !_isAnalyzing && (
      widget.analysisType == 'prediction' ||
      (_filteredData != null && _filteredData!.isNotEmpty)
    );

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: isEnabled ? _performAnalysis : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: isEnabled ? AppColors.primaryBlue : AppColors.mediumGray,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isAnalyzing)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            else
              Icon(
                _getAnalysisIcon(),
                color: Colors.white,
                size: 24,
              ),
            const SizedBox(width: 12),
            Text(
              _isAnalyzing ? 'Analyzing...' : 'Perform ${_getAnalysisTitle()}',
              style: AppTextStyles.button.copyWith(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisResults() {
    if (_analysisResult == null || _analysisResult!['hasData'] != true) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.warning.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.warning.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.warning),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _analysisResult?['message'] ?? 'No analysis results available',
                style: AppTextStyles.body.copyWith(color: AppColors.warning),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.success.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.success, size: 28),
              const SizedBox(width: 12),
              Text(
                'Analysis Results',
                style: AppTextStyles.heading3.copyWith(
                  color: AppColors.charcoal,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildResultsContent(),
        ],
      ),
    );
  }

  Widget _buildResultsContent() {
    switch (widget.analysisType) {
      case 'prediction':
        return _buildPredictionResults();
      case 'risk':
        return _buildRiskResults();
      case 'trends':
        return _buildTrendResults();
      case 'recommendations':
        return _buildRecommendationResults();
      default:
        return const SizedBox();
    }
  }

  Widget _buildPredictionResults() {
    final stats = _analysisResult!['statistics'] as Map<String, dynamic>;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildResultRow('Total Data Points', '${_analysisResult!['dataPoints']}'),
        _buildResultRow('Average WQI', (stats['avgWqi'] as double).toStringAsFixed(2)),
        _buildResultRow('Min WQI', (stats['minWqi'] as double).toStringAsFixed(2)),
        _buildResultRow('Max WQI', (stats['maxWqi'] as double).toStringAsFixed(2)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '✓ Time series data is ready for ML prediction models',
            style: AppTextStyles.body.copyWith(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRiskResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildResultRow('Risk Level', _analysisResult!['riskLevel'] ?? 'Unknown'),
        _buildResultRow('Total Readings', '${_analysisResult!['totalReadings']}'),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _getRiskColor(_analysisResult!['riskLevel']).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Risk assessment completed based on ${_analysisResult!['totalReadings']} readings',
            style: AppTextStyles.body.copyWith(
              color: _getRiskColor(_analysisResult!['riskLevel']),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrendResults() {
    final trends = _analysisResult!['trends'] as Map<String, dynamic>;
    final wqiTrend = trends['wqi'] as Map<String, dynamic>;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildResultRow('WQI Trend', wqiTrend['direction'] ?? 'stable'),
        _buildResultRow('Anomalies Detected', '${(_analysisResult!['anomalies'] as List).length}'),
        _buildResultRow('Data Points Analyzed', '${_analysisResult!['dataPoints']}'),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _getTrendColor(wqiTrend['direction']).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Trend analysis shows water quality is ${wqiTrend['direction']}',
            style: AppTextStyles.body.copyWith(
              color: _getTrendColor(wqiTrend['direction']),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildResultRow('Data Points Exported', '${_analysisResult!['dataPoints']}'),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '✓ Data exported and ready for ML recommendation engine',
            style: AppTextStyles.body.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.body.copyWith(
              color: AppColors.mediumGray,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.body.copyWith(
              color: AppColors.charcoal,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _getAnalysisTitle() {
    switch (widget.analysisType) {
      case 'prediction':
        return 'Quality Prediction';
      case 'risk':
        return 'Risk Assessment';
      case 'trends':
        return 'Trend Analysis';
      case 'recommendations':
        return 'Recommendations';
      default:
        return 'AI Analysis';
    }
  }

  IconData _getAnalysisIcon() {
    switch (widget.analysisType) {
      case 'prediction':
        return Icons.trending_up;
      case 'risk':
        return Icons.warning_amber_rounded;
      case 'trends':
        return Icons.show_chart;
      case 'recommendations':
        return Icons.lightbulb_outline;
      default:
        return Icons.psychology;
    }
  }

  Color _getRiskColor(String? riskLevel) {
    switch (riskLevel?.toLowerCase()) {
      case 'high':
        return AppColors.error;
      case 'medium':
        return AppColors.warning;
      case 'low':
        return AppColors.success;
      default:
        return AppColors.mediumGray;
    }
  }

  Color _getTrendColor(String? direction) {
    switch (direction?.toLowerCase()) {
      case 'improving':
        return AppColors.success;
      case 'declining':
        return AppColors.error;
      case 'stable':
        return AppColors.primaryBlue;
      default:
        return AppColors.mediumGray;
    }
  }
}
