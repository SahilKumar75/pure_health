import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pure_health/core/constants/color_constants.dart';
import 'package:pure_health/core/theme/text_styles.dart';
import 'package:pure_health/core/services/local_storage_service.dart';
import 'package:pure_health/features/ml_analysis/data/services/historical_data_service.dart';
import 'package:pure_health/features/ai_analysis/data/services/station_ai_service.dart';
import 'package:pure_health/features/ai_analysis/data/services/historical_disease_data_service.dart';
import 'package:pure_health/features/ai_analysis/data/models/disease_risk_model.dart';
import 'package:pure_health/features/ai_analysis/presentation/widgets/time_range_selector.dart';
import 'package:pure_health/features/ai_analysis/presentation/widgets/prediction_horizon_selector.dart';
import 'package:pure_health/features/ai_analysis/presentation/widgets/disease_risk_card.dart';
import 'package:pure_health/features/ai_analysis/presentation/widgets/outbreak_alert_card.dart';
import 'package:pure_health/core/models/station_models.dart';
import 'package:pure_health/shared/widgets/custom_sidebar.dart';
import 'package:fl_chart/fl_chart.dart';

class StationAIAnalysisPageWithSidebar extends StatefulWidget {
  final String stationId;
  final WaterQualityStation station;
  final String analysisType; // 'prediction', 'risk', 'trends', 'recommendations'

  const StationAIAnalysisPageWithSidebar({
    super.key,
    required this.stationId,
    required this.station,
    required this.analysisType,
  });

  @override
  State<StationAIAnalysisPageWithSidebar> createState() => _StationAIAnalysisPageWithSidebarState();
}

class _StationAIAnalysisPageWithSidebarState extends State<StationAIAnalysisPageWithSidebar> {
  int _selectedIndex = 3; // AI Analysis index in sidebar
  bool _isLoading = false;
  bool _isAnalyzing = false;
  DateTime? _startDate;
  DateTime? _endDate;
  int _predictionHorizonDays = 30; // Default 30 days prediction
  Map<String, dynamic>? _analysisResult;
  List<StationData>? _filteredData;
  HistoricalDataService? _historicalService;
  StationAIService? _aiService;
  bool _isMLBackendAvailable = false;
  
  // Disease data
  final _diseaseService = HistoricalDiseaseDataService();
  List<StationDataWithDisease>? _diseaseData;
  StationDataWithDisease? _latestDiseaseReading;
  Map<String, List<int>>? _diseaseRiskTrends;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    setState(() => _isLoading = true);

    try {
      _historicalService = await HistoricalDataService.create();
      
      // Initialize AI service and test connection
      _aiService = StationAIService();
      _isMLBackendAvailable = await _aiService!.testConnection();
      
      if (_isMLBackendAvailable) {
        print('[AI_ANALYSIS] ✅ ML Backend connected');
      } else {
        print('[AI_ANALYSIS] ⚠️  ML Backend unavailable, using local data only');
      }
      
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
      // Load water quality data
      final storage = await LocalStorageService.getInstance();
      final data = await storage.getStationReadingsInRange(
        widget.stationId,
        startDate: _startDate!,
        endDate: _endDate!,
      );

      // Load disease data for the same period
      final diseaseData = await _diseaseService.loadStationDataForDateRange(
        widget.stationId,
        _startDate!,
        _endDate!,
      );
      
      final latestDisease = await _diseaseService.getLatestReading(widget.stationId);
      
      final diseaseTrends = await _diseaseService.getDiseaseRiskTrends(
        widget.stationId,
        _startDate!,
        _endDate!,
      );

      setState(() {
        _filteredData = data;
        _diseaseData = diseaseData;
        _latestDiseaseReading = latestDisease;
        _diseaseRiskTrends = diseaseTrends;
      });
    } catch (e) {
      print('[STATION_AI_ANALYSIS] Error loading data: $e');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _performAnalysis() async {
    if (_filteredData == null || _filteredData!.isEmpty) {
      _showError('No data available for the selected time range');
      return;
    }

    setState(() => _isAnalyzing = true);

    try {
      Map<String, dynamic> result;

      // Try ML backend first, fallback to local if unavailable
      if (_isMLBackendAvailable && _aiService != null) {
        print('[AI_ANALYSIS] Using ML Backend for ${widget.analysisType}');
        
        try {
          switch (widget.analysisType) {
            case 'prediction':
              final mlResult = await _aiService!.getPrediction(
                stationId: widget.stationId,
                historicalData: _filteredData!,
                predictionDays: _predictionHorizonDays,
              );
              result = _formatMLPredictionResult(mlResult);
              break;
              
            case 'risk':
              final mlResult = await _aiService!.getRiskAssessment(
                stationId: widget.stationId,
                historicalData: _filteredData!,
              );
              result = _formatMLRiskResult(mlResult);
              break;
              
            case 'trends':
              final mlResult = await _aiService!.getTrendAnalysis(
                stationId: widget.stationId,
                historicalData: _filteredData!,
              );
              result = _formatMLTrendResult(mlResult);
              break;
              
            case 'recommendations':
              final mlResult = await _aiService!.getRecommendations(
                stationId: widget.stationId,
                historicalData: _filteredData!,
              );
              result = _formatMLRecommendationResult(mlResult);
              break;
              
            default:
              throw Exception('Unknown analysis type');
          }
        } catch (mlError) {
          print('[AI_ANALYSIS] ML Backend error, using fallback: $mlError');
          result = await _getFallbackResult();
        }
      } else {
        print('[AI_ANALYSIS] ML Backend unavailable, using local data');
        result = await _getFallbackResult();
      }

      setState(() {
        _analysisResult = result;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isMLBackendAvailable 
              ? 'Analysis completed successfully!' 
              : 'Analysis completed (offline mode)'),
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
      backgroundColor: AppColors.darkBg,
      body: Row(
        children: [
          CustomSidebar(
            selectedIndex: _selectedIndex,
            onItemSelected: (index) {
              setState(() => _selectedIndex = index);
              if (index != 3) {
                Navigator.pop(context);
              }
            },
          ),
          Expanded(
            child: Column(
              children: [
                // Header with back button
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.darkBg3,
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.borderLight,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: AppColors.lightText),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getAnalysisTitle(),
                            style: AppTextStyles.heading3.copyWith(
                              color: AppColors.lightText,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.station.name,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.mediumText,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Center(
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 1200),
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

                                  // Prediction Horizon Selector (only for prediction analysis)
                                  if (widget.analysisType == 'prediction') ...[
                                    PredictionHorizonSelector(
                                      selectedDays: _predictionHorizonDays,
                                      onDaysSelected: (days) {
                                        setState(() {
                                          _predictionHorizonDays = days;
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 24),
                                  ],

                                  // Data Summary
                                  if (_filteredData != null) ...[
                                    _buildDataSummaryCard(),
                                    const SizedBox(height: 24),
                                  ],

                                  // Disease Outbreak Alert (if high risk)
                                  if (_latestDiseaseReading != null &&
                                      (_latestDiseaseReading!.outbreakProbability.level == 'high' ||
                                       _latestDiseaseReading!.outbreakProbability.level == 'medium')) ...[
                                    OutbreakAlertCard(
                                      outbreakProbability: _latestDiseaseReading!.outbreakProbability,
                                    ),
                                    const SizedBox(height: 24),
                                  ],

                                  // Analysis Button
                                  _buildAnalysisButton(),

                                  const SizedBox(height: 24),

                                  // Analysis Results
                                  if (_analysisResult != null) ...[
                                    _buildAnalysisResults(),
                                    const SizedBox(height: 24),
                                  ],

                                  // Comprehensive Water Quality & Disease Section
                                  if (_filteredData != null && _filteredData!.isNotEmpty) ...[
                                    _buildComprehensiveAnalysisSection(),
                                  ],
                                ],
                              ),
                            ),
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

  Widget _buildStationInfoCard() {
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
              Icon(Icons.location_on, color: AppColors.accentPink, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.station.name,
                      style: AppTextStyles.heading4.copyWith(
                        color: AppColors.lightText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${widget.station.district} • ${widget.station.type}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.mediumText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: AppColors.borderLight),
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
        Icon(icon, color: AppColors.mediumText, size: 16),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.mediumText,
            fontSize: 13,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.lightText,
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
              Icon(Icons.assessment, color: AppColors.accentPink, size: 24),
              const SizedBox(width: 12),
              Text(
                'Data Summary',
                style: AppTextStyles.heading4.copyWith(
                  color: AppColors.lightText,
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
                  AppColors.accentPink,
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
        color: AppColors.darkBg2,
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
    final isEnabled = _filteredData != null && _filteredData!.isNotEmpty && !_isAnalyzing;

    return Column(
      children: [
        // ML Backend Status Indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _isMLBackendAvailable 
                ? AppColors.success.withOpacity(0.1) 
                : AppColors.warning.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isMLBackendAvailable 
                  ? AppColors.success.withOpacity(0.3) 
                  : AppColors.warning.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _isMLBackendAvailable ? AppColors.success : AppColors.warning,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _isMLBackendAvailable ? 'ML Backend Connected' : 'Offline Mode (Local Data)',
                style: AppTextStyles.caption.copyWith(
                  color: _isMLBackendAvailable ? AppColors.success : AppColors.warning,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Analysis Button
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: isEnabled ? _performAnalysis : null,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: isEnabled ? AppColors.accentPink : AppColors.dimText,
              borderRadius: BorderRadius.circular(12),
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
        ),
      ],
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
        color: AppColors.darkBg3,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.success.withOpacity(0.3),
          width: 1,
        ),
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
                  color: AppColors.lightText,
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
    final predictionHorizon = _analysisResult!['predictionHorizon'] as int?;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Prediction Horizon Info (if available)
        if (predictionHorizon != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.accentPink.withOpacity(0.2),
                  AppColors.accentPink.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.accentPink.withOpacity(0.4),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.accentPink,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.trending_up,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Prediction Horizon',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.mediumText,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$predictionHorizon days ahead',
                        style: AppTextStyles.heading4.copyWith(
                          color: AppColors.lightText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Predictions until ${_formatDate(DateTime.now().add(Duration(days: predictionHorizon)))}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.mediumText,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        
        _buildResultRow('Total Data Points', '${_analysisResult!['dataPoints']}'),
        _buildResultRow('Average WQI', (stats['avgWqi'] as double).toStringAsFixed(2)),
        _buildResultRow('Min WQI', (stats['minWqi'] as double).toStringAsFixed(2)),
        _buildResultRow('Max WQI', (stats['maxWqi'] as double).toStringAsFixed(2)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.accentPink.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.accentPink.withOpacity(0.3),
            ),
          ),
          child: Text(
            '✓ Time series data is ready for ML prediction models',
            style: AppTextStyles.body.copyWith(
              color: AppColors.accentPink,
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

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  // ============================================
  // ML BACKEND RESULT FORMATTERS
  // ============================================

  Map<String, dynamic> _formatMLPredictionResult(Map<String, dynamic> mlResult) {
    final predictions = mlResult['predictions'] as Map<String, dynamic>? ?? {};
    
    // Calculate statistics from filtered data
    final wqiValues = _filteredData!.map((d) => d.wqi).toList();
    final avgWqi = wqiValues.reduce((a, b) => a + b) / wqiValues.length;
    final minWqi = wqiValues.reduce((a, b) => a < b ? a : b);
    final maxWqi = wqiValues.reduce((a, b) => a > b ? a : b);

    return {
      'hasData': true,
      'dataPoints': _filteredData!.length,
      'predictionHorizon': _predictionHorizonDays,
      'predictionEndDate': DateTime.now().add(Duration(days: _predictionHorizonDays)).toIso8601String(),
      'statistics': {
        'avgWqi': avgWqi,
        'minWqi': minWqi,
        'maxWqi': maxWqi,
      },
      'predictions': predictions,
      'mlBackend': true,
    };
  }

  Map<String, dynamic> _formatMLRiskResult(Map<String, dynamic> mlResult) {
    final riskData = mlResult['risk_assessment'] as Map<String, dynamic>? ?? {};
    
    return {
      'hasData': true,
      'totalReadings': _filteredData!.length,
      'riskLevel': riskData['overall_risk'] ?? 'Unknown',
      'riskScore': riskData['risk_score'] ?? 0.0,
      'riskFactors': riskData['risk_factors'] ?? [],
      'mlBackend': true,
    };
  }

  Map<String, dynamic> _formatMLTrendResult(Map<String, dynamic> mlResult) {
    final trendsData = mlResult['trends'] as Map<String, dynamic>? ?? {};
    
    return {
      'hasData': true,
      'dataPoints': _filteredData!.length,
      'trends': trendsData,
      'anomalies': trendsData['anomalies'] ?? [],
      'mlBackend': true,
    };
  }

  Map<String, dynamic> _formatMLRecommendationResult(Map<String, dynamic> mlResult) {
    final recommendations = mlResult['recommendations'] as Map<String, dynamic>? ?? {};
    
    return {
      'hasData': true,
      'dataPoints': _filteredData!.length,
      'recommendations': recommendations['actions'] ?? [],
      'priority': recommendations['priority'] ?? 'medium',
      'mlBackend': true,
    };
  }

  Future<Map<String, dynamic>> _getFallbackResult() async {
    // Use historical data service as fallback
    switch (widget.analysisType) {
      case 'prediction':
        final result = await _historicalService!.getMLPredictionData(widget.stationId);
        result['predictionHorizon'] = _predictionHorizonDays;
        result['predictionEndDate'] = DateTime.now().add(Duration(days: _predictionHorizonDays)).toIso8601String();
        result['mlBackend'] = false;
        return result;
      case 'risk':
        final result = await _historicalService!.getRiskAssessmentData(widget.stationId);
        result['mlBackend'] = false;
        return result;
      case 'trends':
        final result = await _historicalService!.getTrendAnalysisData(widget.stationId);
        result['mlBackend'] = false;
        return result;
      case 'recommendations':
        final result = await _historicalService!.exportDataForML(widget.stationId);
        result['mlBackend'] = false;
        return result;
      default:
        return {'hasData': false, 'message': 'Unknown analysis type', 'mlBackend': false};
    }
  }

  // NEW: Comprehensive Analysis Section showing Water Quality + Disease Data
  Widget _buildComprehensiveAnalysisSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section Header
        Text(
          'Comprehensive Water Quality & Health Analysis',
          style: AppTextStyles.heading3.copyWith(
            color: AppColors.lightText,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _diseaseData != null && _diseaseData!.isNotEmpty
              ? 'Complete overview of water quality parameters and associated disease outbreak risks'
              : 'Comprehensive water quality analysis for this station',
          style: AppTextStyles.body.copyWith(
            color: AppColors.mediumText,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 24),

        // Water Quality Trends
        _buildWaterQualityTrendsCard(),
        const SizedBox(height: 24),

        // Disease Risk Analysis (if available)
        if (_diseaseData != null && _diseaseData!.isNotEmpty) ...[
          _buildDiseaseRiskAnalysisCard(),
          const SizedBox(height: 24),
        ] else if (_diseaseData != null && _diseaseData!.isEmpty) ...[
          // Show info card when station is not in sample disease data
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.accentBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.accentBlue.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.accentBlue, size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Disease Data Not Available for This Station',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.lightText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'The disease outbreak sample dataset currently includes 50 Surface Water (SW) stations. Groundwater and other station types show water quality analysis only. To view disease predictions, try Surface Water stations like MH-PUN-SW-001 through MH-PUN-SW-007.',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.mediumText,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Environmental Factors
        if (_latestDiseaseReading != null) ...[
          _buildEnvironmentalFactorsCard(),
          const SizedBox(height: 24),
        ],

        // Disease Risk Trends (if available)
        if (_diseaseRiskTrends != null && _diseaseRiskTrends!.isNotEmpty) ...[
          _buildDiseaseRiskTrendsCard(),
          const SizedBox(height: 24),
        ],

        // Key Insights
        _buildKeyInsightsCard(),
      ],
    );
  }

  Widget _buildWaterQualityTrendsCard() {
    if (_filteredData == null || _filteredData!.isEmpty) {
      return const SizedBox.shrink();
    }

    // Calculate averages and trends
    double avgPH = 0, avgTurbidity = 0, avgTDS = 0, avgColiform = 0;
    int count = _filteredData!.length;

    for (var reading in _filteredData!) {
      avgPH += _extractParameterValue(reading.parameters, 'ph');
      avgTurbidity += _extractParameterValue(reading.parameters, 'turbidity');
      avgTDS += _extractParameterValue(reading.parameters, 'tds');
      avgColiform += _extractParameterValue(reading.parameters, 'total_coliform');
    }

    avgPH /= count;
    avgTurbidity /= count;
    avgTDS /= count;
    avgColiform /= count;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkBg3,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.water_drop, color: AppColors.accentBlue, size: 24),
              const SizedBox(width: 12),
              Text(
                'Water Quality Parameters',
                style: AppTextStyles.heading4.copyWith(
                  color: AppColors.lightText,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accentBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_filteredData!.length} readings',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.accentBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Parameter Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildParameterTile('pH Level', avgPH.toStringAsFixed(2), 
                _getpHStatus(avgPH), Icons.science),
              _buildParameterTile('Turbidity', '${avgTurbidity.toStringAsFixed(1)} NTU', 
                _getTurbidityStatus(avgTurbidity), Icons.visibility_off),
              _buildParameterTile('TDS', '${avgTDS.toStringAsFixed(0)} mg/L', 
                _getTDSStatus(avgTDS), Icons.straighten),
              _buildParameterTile('Total Coliform', '${avgColiform.toStringAsFixed(0)} MPN/100ml', 
                _getColiformStatus(avgColiform), Icons.bug_report),
            ],
          ),

          const SizedBox(height: 16),

          // Water Quality Class
          if (_latestDiseaseReading != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getWQIColor(_latestDiseaseReading!.wqi).withOpacity(0.2),
                    _getWQIColor(_latestDiseaseReading!.wqi).withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getWQIColor(_latestDiseaseReading!.wqi).withOpacity(0.4),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getWQIIcon(_latestDiseaseReading!.wqi),
                    color: _getWQIColor(_latestDiseaseReading!.wqi),
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Water Quality Index',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.mediumText,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              _latestDiseaseReading!.wqi.toStringAsFixed(1),
                              style: AppTextStyles.heading3.copyWith(
                                color: _getWQIColor(_latestDiseaseReading!.wqi),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getWQIColor(_latestDiseaseReading!.wqi).withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _latestDiseaseReading!.waterQualityClass,
                                style: AppTextStyles.caption.copyWith(
                                  color: _getWQIColor(_latestDiseaseReading!.wqi),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _latestDiseaseReading!.status.toUpperCase(),
                    style: AppTextStyles.caption.copyWith(
                      color: _getWQIColor(_latestDiseaseReading!.wqi),
                      fontWeight: FontWeight.bold,
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

  Widget _buildParameterTile(String label, String value, String status, IconData icon) {
    final statusColor = status == 'Good' ? AppColors.success : 
                       status == 'Moderate' ? AppColors.warning : AppColors.error;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: statusColor, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.mediumText,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.body.copyWith(
              color: AppColors.lightText,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              status,
              style: AppTextStyles.caption.copyWith(
                color: statusColor,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiseaseRiskAnalysisCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkBg3,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.coronavirus, color: AppColors.error, size: 24),
              const SizedBox(width: 12),
              Text(
                'Disease Outbreak Risk Assessment',
                style: AppTextStyles.heading4.copyWith(
                  color: AppColors.lightText,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_latestDiseaseReading != null) ...[
            // Current Outbreak Probability
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getOutbreakColor(_latestDiseaseReading!.outbreakProbability.level).withOpacity(0.2),
                    _getOutbreakColor(_latestDiseaseReading!.outbreakProbability.level).withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getOutbreakColor(_latestDiseaseReading!.outbreakProbability.level).withOpacity(0.4),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getOutbreakIcon(_latestDiseaseReading!.outbreakProbability.level),
                    color: _getOutbreakColor(_latestDiseaseReading!.outbreakProbability.level),
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Outbreak Probability',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.mediumText,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _latestDiseaseReading!.outbreakProbability.displayLevel,
                          style: AppTextStyles.heading3.copyWith(
                            color: _getOutbreakColor(_latestDiseaseReading!.outbreakProbability.level),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _getOutbreakColor(_latestDiseaseReading!.outbreakProbability.level),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_latestDiseaseReading!.outbreakProbability.score}%',
                      style: AppTextStyles.body.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Individual Disease Risks
            Text(
              'Disease Risk Breakdown',
              style: AppTextStyles.body.copyWith(
                color: AppColors.mediumText,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),

            // Disease Risk Cards
            ..._latestDiseaseReading!.diseaseRisks.map((risk) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: DiseaseRiskCard(diseaseRisk: risk),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildEnvironmentalFactorsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkBg3,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.eco, color: AppColors.success, size: 24),
              const SizedBox(width: 12),
              Text(
                'Environmental Factors',
                style: AppTextStyles.heading4.copyWith(
                  color: AppColors.lightText,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildEnvironmentalFactor(
            'Stagnation Index',
            _latestDiseaseReading!.stagnationIndex,
            Icons.water,
            'Water stagnation level (breeding ground for vectors)',
          ),
          const SizedBox(height: 12),
          _buildEnvironmentalFactor(
            'Rainfall Index',
            _latestDiseaseReading!.rainfallIndex,
            Icons.water_drop,
            'Rainfall impact on water quality',
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.accentBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.wb_sunny, size: 20, color: AppColors.accentBlue),
                const SizedBox(width: 8),
                Text(
                  'Season: ${_latestDiseaseReading!.season}',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.lightText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnvironmentalFactor(String label, double value, IconData icon, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppColors.accentBlue),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.body.copyWith(
                color: AppColors.lightText,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 12,
            backgroundColor: AppColors.darkBg,
            valueColor: AlwaysStoppedAnimation<Color>(_getIndexColor(value)),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${(value * 100).toStringAsFixed(0)}% - $description',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.mediumText,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildDiseaseRiskTrendsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkBg3,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: AppColors.accentPink, size: 24),
              const SizedBox(width: 12),
              Text(
                'Disease Risk Trends',
                style: AppTextStyles.heading4.copyWith(
                  color: AppColors.lightText,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Show trend bars for each disease
          ..._diseaseRiskTrends!.entries.map((entry) {
            if (entry.value.isEmpty) return const SizedBox.shrink();
            
            final avgRisk = entry.value.reduce((a, b) => a + b) / entry.value.length;
            final maxRisk = entry.value.reduce((a, b) => a > b ? a : b);
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDiseaseName(entry.key),
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.lightText,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        'Avg: ${avgRisk.toStringAsFixed(0)} | Max: $maxRisk',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.mediumText,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: avgRisk / 100,
                      minHeight: 8,
                      backgroundColor: AppColors.darkBg,
                      valueColor: AlwaysStoppedAnimation<Color>(_getDiseaseRiskColor(avgRisk.toInt())),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildKeyInsightsCard() {
    final insights = <String>[];

    // Add water quality insights
    if (_filteredData != null && _filteredData!.isNotEmpty) {
      final avgColiform = _filteredData!
          .map((r) => _extractParameterValue(r.parameters, 'total_coliform'))
          .reduce((a, b) => a + b) / _filteredData!.length;
      if (avgColiform > 500) {
        insights.add('⚠️ High coliform contamination detected - indicates fecal pollution');
      }

      final avgpH = _filteredData!
          .map((r) => _extractParameterValue(r.parameters, 'ph'))
          .reduce((a, b) => a + b) / _filteredData!.length;
      if (avgpH < 6.5 || avgpH > 8.5) {
        insights.add('⚠️ pH levels outside safe range - may affect disinfection effectiveness');
      }
    }

    // Add disease insights
    if (_latestDiseaseReading != null) {
      if (_latestDiseaseReading!.outbreakProbability.level == 'high') {
        insights.add('🚨 HIGH OUTBREAK RISK - Immediate intervention recommended');
      }

      final highRiskDiseases = _latestDiseaseReading!.diseaseRisks
          .where((r) => r.riskScore >= 60)
          .length;
      if (highRiskDiseases > 0) {
        insights.add('⚠️ $highRiskDiseases disease(s) at high risk - enhanced monitoring needed');
      }

      if (_latestDiseaseReading!.stagnationIndex > 0.7) {
        insights.add('🦟 High water stagnation - increased vector breeding risk');
      }
    }

    // If no issues, add positive insight
    if (insights.isEmpty) {
      insights.add('✅ Water quality and disease risks within acceptable ranges');
      insights.add('👍 Continue regular monitoring and maintenance');
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkBg3,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: AppColors.warning, size: 24),
              const SizedBox(width: 12),
              Text(
                'Key Insights & Recommendations',
                style: AppTextStyles.heading4.copyWith(
                  color: AppColors.lightText,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          ...insights.map((insight) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      color: AppColors.accentPink,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      insight,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.lightText,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // Helper methods for status determination
  String _getpHStatus(double pH) {
    if (pH >= 6.5 && pH <= 8.5) return 'Good';
    if (pH >= 6.0 && pH <= 9.0) return 'Moderate';
    return 'Poor';
  }

  String _getTurbidityStatus(double turbidity) {
    if (turbidity <= 5) return 'Good';
    if (turbidity <= 25) return 'Moderate';
    return 'Poor';
  }

  String _getTDSStatus(double tds) {
    if (tds <= 500) return 'Good';
    if (tds <= 1000) return 'Moderate';
    return 'Poor';
  }

  String _getColiformStatus(double coliform) {
    if (coliform <= 50) return 'Good';
    if (coliform <= 500) return 'Moderate';
    return 'Poor';
  }

  Color _getWQIColor(double wqi) {
    if (wqi >= 75) return AppColors.success;
    if (wqi >= 50) return AppColors.warning;
    return AppColors.error;
  }

  IconData _getWQIIcon(double wqi) {
    if (wqi >= 75) return Icons.check_circle;
    if (wqi >= 50) return Icons.warning;
    return Icons.error;
  }

  Color _getOutbreakColor(String level) {
    switch (level) {
      case 'very_low':
        return AppColors.success;
      case 'low':
        return AppColors.success.withOpacity(0.7);
      case 'medium':
        return AppColors.warning;
      case 'high':
        return AppColors.error;
      default:
        return AppColors.mediumText;
    }
  }

  IconData _getOutbreakIcon(String level) {
    switch (level) {
      case 'very_low':
      case 'low':
        return Icons.check_circle;
      case 'medium':
        return Icons.warning;
      case 'high':
        return Icons.error;
      default:
        return Icons.info;
    }
  }

  Color _getDiseaseRiskColor(int score) {
    if (score >= 80) return AppColors.error;
    if (score >= 60) return Colors.orange;
    if (score >= 40) return AppColors.warning;
    if (score >= 20) return AppColors.success.withOpacity(0.7);
    return AppColors.success;
  }

  Color _getIndexColor(double value) {
    if (value >= 0.8) return AppColors.error;
    if (value >= 0.6) return Colors.orange;
    if (value >= 0.4) return AppColors.warning;
    if (value >= 0.2) return AppColors.success.withOpacity(0.7);
    return AppColors.success;
  }

  String _formatDiseaseName(String disease) {
    return disease
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  // Helper method to safely extract parameter values from nested or flat structures
  double _extractParameterValue(Map<String, dynamic> parameters, String key) {
    final param = parameters[key];
    if (param == null) return 0;
    
    // Handle nested structure: {value: 7.5, unit: "pH", status: "normal"}
    if (param is Map<String, dynamic>) {
      final value = param['value'];
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0;
    }
    
    // Handle direct numeric value
    if (param is num) return param.toDouble();
    
    // Handle string numeric value
    if (param is String) return double.tryParse(param) ?? 0;
    
    return 0;
  }
}
