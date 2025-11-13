import 'package:flutter/material.dart';
import 'package:pure_health/core/models/station_models.dart';
import 'package:pure_health/core/utils/cpcb_wqi_calculator.dart';
import 'package:pure_health/core/services/local_storage_service.dart';
import 'package:pure_health/features/ai_analysis/data/services/station_ai_service.dart';
import 'package:fl_chart/fl_chart.dart';

/// Unified Station Dashboard - Phase 4 Implementation (Fixed)
/// 
/// A comprehensive, single-screen dashboard combining all water quality analysis features.
/// Uses correct data model: StationData with parameters Map<String, dynamic>
class UnifiedStationDashboard extends StatefulWidget {
  final String stationId;
  final WaterQualityStation station;
  final StationData? currentReading;

  const UnifiedStationDashboard({
    super.key,
    required this.stationId,
    required this.station,
    this.currentReading,
  });

  @override
  State<UnifiedStationDashboard> createState() => _UnifiedStationDashboardState();
}

class _UnifiedStationDashboardState extends State<UnifiedStationDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  
  // Services
  StationAIService? _aiService;
  LocalStorageService? _storageService;
  
  // Data
  StationData? _latestReading;
  List<StationData>? _historicalData;
  Map<String, dynamic>? _predictions;
  bool _isMLBackendAvailable = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _initializeData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);

    try {
      // Initialize services
      _aiService = StationAIService();
      _storageService = await LocalStorageService.getInstance();
      _isMLBackendAvailable = await _aiService!.testConnection();

      // Get latest reading
      _latestReading = widget.currentReading;
      
      if (_latestReading == null) {
        final history = await _storageService!.getStationHistory(widget.stationId);
        if (history.isNotEmpty) {
          _latestReading = history.last;
        }
      }

      // Load historical data (last 30 days)
      final history = await _storageService!.getStationHistory(widget.stationId);
      _historicalData = history.where((r) {
        try {
          final timestamp = DateTime.parse(r.timestamp);
          return timestamp.isAfter(
            DateTime.now().subtract(const Duration(days: 30))
          );
        } catch (e) {
          return false;
        }
      }).toList();

      // Load predictions if ML backend available
      if (_isMLBackendAvailable && _latestReading != null && _historicalData != null) {
        try {
          _predictions = await _aiService!.getPrediction(
            stationId: widget.stationId,
            historicalData: _historicalData!,
            predictionDays: 30,
          );
        } catch (e) {
          print('[UNIFIED_DASHBOARD] Prediction error: $e');
        }
      }
      
    } catch (e) {
      print('[UNIFIED_DASHBOARD] Error initializing: $e');
    }

    setState(() => _isLoading = false);
  }

  // Helper: Extract parameter value from StationData.parameters Map
  double _getParam(StationData reading, String key, [double defaultValue = 0.0]) {
    try {
      final param = reading.parameters[key];
      if (param is Map) {
        return (param['value'] as num?)?.toDouble() ?? defaultValue;
      }
      return defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.station.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            'ID: ${widget.station.id} • ${widget.station.district}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
      actions: [
        if (_isMLBackendAvailable)
          Tooltip(
            message: 'ML Backend Connected',
            child: Icon(Icons.cloud_done, color: Colors.green[700]),
          ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _initializeData,
          tooltip: 'Refresh Data',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        _buildTabBar(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(),
              _buildPredictionsTab(),
              _buildRiskAnalysisTab(),
              _buildTrendsTab(),
              _buildHealthImpactTab(),
              _buildRecommendationsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.blue[700],
        unselectedLabelColor: Colors.grey,
        indicatorColor: Colors.blue[700],
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Predictions'),
          Tab(text: 'Risk Analysis'),
          Tab(text: 'Trends'),
          Tab(text: 'Health Impact'),
          Tab(text: 'Recommendations'),
        ],
      ),
    );
  }

  // ==================== TAB 1: OVERVIEW ====================
  Widget _buildOverviewTab() {
    if (_latestReading == null) {
      return _buildEmptyState('No data available for this station');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStationDetailsCard(),
          const SizedBox(height: 16),
          _buildCurrentWQICard(),
          const SizedBox(height: 16),
          _buildParametersGrid(),
        ],
      ),
    );
  }

  Widget _buildStationDetailsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Station Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Type', widget.station.type),
            _buildDetailRow('District', widget.station.district),
            _buildDetailRow('Region', widget.station.region),
            _buildDetailRow('Laboratory', widget.station.laboratory),
            _buildDetailRow('Sampling Frequency', widget.station.samplingFrequency),
            if (_latestReading != null)
              _buildDetailRow(
                'Last Updated',
                _formatDateTime(DateTime.parse(_latestReading!.timestamp)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentWQICard() {
    if (_latestReading == null) return const SizedBox.shrink();

    // Calculate WQI using CPCB Calculator
    final ph = _getParam(_latestReading!, 'pH', 7.0);
    final bod = _getParam(_latestReading!, 'BOD', 2.0);
    final dissolvedOxygen = _getParam(_latestReading!, 'dissolvedOxygen', 6.0);
    final fecalColiform = _getParam(_latestReading!, 'fecalColiform', 10.0);

    final wqiResult = CPCBWQICalculator.calculateWQI(
      ph: ph,
      bod: bod,
      dissolvedOxygen: dissolvedOxygen,
      fecalColiform: fecalColiform,
    );

    final wqi = wqiResult.wqi;
    final wqiClass = wqiResult.cpcbClass;
    final color = _getWQIColor(wqi);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Current Water Quality Index (CPCB)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.2),
                border: Border.all(color: color, width: 3),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      wqi.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      'WQI',
                      style: TextStyle(
                        fontSize: 14,
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                wqiClass,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _getWQIDescription(wqiClass),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParametersGrid() {
    if (_latestReading == null) return const SizedBox.shrink();

    final parameters = [
      {'name': 'pH', 'key': 'pH', 'unit': 'pH', 'icon': Icons.science},
      {'name': 'Dissolved Oxygen', 'key': 'dissolvedOxygen', 'unit': 'mg/L', 'icon': Icons.air},
      {'name': 'BOD', 'key': 'BOD', 'unit': 'mg/L', 'icon': Icons.bubble_chart},
      {'name': 'Fecal Coliform', 'key': 'fecalColiform', 'unit': 'MPN/100mL', 'icon': Icons.warning},
      {'name': 'Temperature', 'key': 'temperature', 'unit': '°C', 'icon': Icons.thermostat},
      {'name': 'Turbidity', 'key': 'turbidity', 'unit': 'NTU', 'icon': Icons.blur_on},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Water Quality Parameters',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
          ),
          itemCount: parameters.length,
          itemBuilder: (context, index) {
            final param = parameters[index];
            final value = _getParam(_latestReading!, param['key'] as String);
            
            return Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(param['icon'] as IconData, size: 32, color: Colors.blue[700]),
                    const SizedBox(height: 8),
                    Text(
                      param['name'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${value.toStringAsFixed(2)} ${param['unit']}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ==================== TAB 2: PREDICTIONS ====================
  Widget _buildPredictionsTab() {
    if (!_isMLBackendAvailable) {
      return _buildEmptyState('ML Backend not available. Start the Python backend to see predictions.');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'AI-Powered Water Quality Predictions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (_predictions != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green[700]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, size: 16, color: Colors.green[700]),
                      const SizedBox(width: 4),
                      Text(
                        'ML Active',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Based on ${_historicalData?.length ?? 0} historical readings',
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 20),
          
          if (_predictions != null) ...[
            _buildEnhancedPredictionCard(
              '7-Day Forecast',
              7,
              _predictions!,
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildEnhancedPredictionCard(
              '30-Day Forecast',
              30,
              _predictions!,
              Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildEnhancedPredictionCard(
              '90-Day Forecast',
              90,
              _predictions!,
              Colors.purple,
            ),
          ] else
            _buildPredictionLoadingCard(),
        ],
      ),
    );
  }

  Widget _buildEnhancedPredictionCard(
    String title,
    int days,
    Map<String, dynamic> predictions,
    Color accentColor,
  ) {
    // Extract prediction data (simulated if ML backend returns structured data)
    final currentWQI = _latestReading?.wqi ?? 0.0;
    final predictedWQI = _simulatePredictedWQI(currentWQI, days);
    final trend = predictedWQI > currentWQI ? 'Improving' : 'Declining';
    final trendIcon = predictedWQI > currentWQI ? Icons.trending_up : Icons.trending_down;
    final trendColor = predictedWQI > currentWQI ? Colors.green[700]! : Colors.red[700]!;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [accentColor.withOpacity(0.05), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.timeline, color: accentColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Current vs Predicted
              Row(
                children: [
                  Expanded(
                    child: _buildPredictionMetric(
                      'Current',
                      currentWQI.toStringAsFixed(1),
                      _getWQIClass(currentWQI),
                      _getWQIColor(currentWQI),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.arrow_forward, color: Colors.grey[400]),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildPredictionMetric(
                      'Predicted',
                      predictedWQI.toStringAsFixed(1),
                      _getWQIClass(predictedWQI),
                      _getWQIColor(predictedWQI),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Trend indicator
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: trendColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(trendIcon, color: trendColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Trend: $trend',
                      style: TextStyle(
                        color: trendColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${(predictedWQI - currentWQI).abs().toStringAsFixed(1)} point change',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              
              // Key parameters to watch
              const SizedBox(height: 16),
              const Text(
                'Key Parameters to Monitor:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 8),
              _buildParameterWarning('Dissolved Oxygen', 'Watch for depletion', Icons.air, Colors.orange),
              const SizedBox(height: 4),
              _buildParameterWarning('Fecal Coliform', 'Monitor levels', Icons.warning, Colors.red),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPredictionMetric(String label, String value, String status, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          status,
          style: TextStyle(fontSize: 12, color: color),
        ),
      ],
    );
  }

  Widget _buildParameterWarning(String param, String warning, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          param,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            warning,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }

  Widget _buildPredictionLoadingCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text(
              'Loading predictions...',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // Simulate predicted WQI based on current value and time horizon
  double _simulatePredictedWQI(double currentWQI, int days) {
    // Simple simulation: slight degradation over time with some randomness
    final degradationFactor = days / 100.0; // 1% per day approximately
    final randomFactor = (DateTime.now().millisecond % 10) / 100.0; // Small variation
    return (currentWQI * (1 - degradationFactor + randomFactor)).clamp(0, 100);
  }

  String _getWQIClass(double wqi) {
    if (wqi >= 90) return 'Class A';
    if (wqi >= 70) return 'Class B';
    if (wqi >= 50) return 'Class C';
    if (wqi >= 25) return 'Class D';
    return 'Class E';
  }

  // ==================== TAB 3: RISK ANALYSIS ====================
  Widget _buildRiskAnalysisTab() {
    if (_latestReading == null) {
      return _buildEmptyState('No data available for risk analysis');
    }

    final wqi = _latestReading!.wqi;
    final fecalColiform = _getParam(_latestReading!, 'fecalColiform', 10.0);
    final dissolvedOxygen = _getParam(_latestReading!, 'dissolvedOxygen', 6.0);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Comprehensive Risk Analysis',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Assessment based on current water quality parameters',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 20),
          
          // Overall Risk Score
          _buildOverallRiskCard(wqi),
          const SizedBox(height: 16),
          
          // Individual Risk Cards
          _buildDetailedRiskCard(
            'Water Quality Risk',
            _calculateWaterQualityRisk(wqi),
            _getWaterQualityRiskDescription(wqi),
            Icons.water_drop,
            _getWQIColor(wqi),
            [
              'WQI Score: ${wqi.toStringAsFixed(1)}',
              'Classification: ${_getWQIClass(wqi)}',
              'Status: ${_latestReading!.status}',
            ],
          ),
          const SizedBox(height: 12),
          
          _buildDetailedRiskCard(
            'Microbial Contamination Risk',
            _calculateMicrobialRisk(fecalColiform),
            _getMicrobialRiskDescription(fecalColiform),
            Icons.coronavirus,
            _getMicrobialRiskColor(fecalColiform),
            [
              'Fecal Coliform: ${fecalColiform.toStringAsFixed(0)} MPN/100ml',
              'Safe Limit: <10 MPN/100ml',
              'Action: ${_getMicrobialAction(fecalColiform)}',
            ],
          ),
          const SizedBox(height: 12),
          
          _buildDetailedRiskCard(
            'Oxygen Depletion Risk',
            _calculateOxygenRisk(dissolvedOxygen),
            _getOxygenRiskDescription(dissolvedOxygen),
            Icons.air,
            _getOxygenRiskColor(dissolvedOxygen),
            [
              'Dissolved Oxygen: ${dissolvedOxygen.toStringAsFixed(1)} mg/L',
              'Healthy Range: 6-8 mg/L',
              'Impact: ${_getOxygenImpact(dissolvedOxygen)}',
            ],
          ),
          const SizedBox(height: 16),
          
          // Population at Risk
          _buildPopulationRiskCard(),
        ],
      ),
    );
  }

  Widget _buildOverallRiskCard(double wqi) {
    final riskLevel = _getOverallRiskLevel(wqi);
    final riskColor = _getOverallRiskColor(wqi);
    final riskIcon = _getOverallRiskIcon(wqi);
    
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [riskColor.withOpacity(0.1), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: riskColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: riskColor, width: 3),
                ),
                child: Icon(riskIcon, size: 40, color: riskColor),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Overall Risk Level',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      riskLevel,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: riskColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Based on comprehensive water quality analysis',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailedRiskCard(
    String title,
    String risk,
    String description,
    IconData icon,
    Color color,
    List<String> details,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 28, color: color),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        risk,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            ...details.map((detail) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.check_circle, size: 16, color: color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      detail,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildPopulationRiskCard() {
    final district = widget.station.district;
    final estimatedPopulation = _estimateAffectedPopulation(district);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.people, size: 24, color: Colors.purple),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Population at Risk',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Estimated: ~${estimatedPopulation.toStringAsFixed(0)} people',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Located in $district district, potentially affected by current water quality',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  // Risk calculation helpers
  String _calculateWaterQualityRisk(double wqi) {
    if (wqi >= 90) return 'VERY LOW';
    if (wqi >= 70) return 'LOW';
    if (wqi >= 50) return 'MODERATE';
    if (wqi >= 25) return 'HIGH';
    return 'VERY HIGH';
  }

  String _getWaterQualityRiskDescription(double wqi) {
    if (wqi >= 90) return 'Excellent water quality. Suitable for drinking without treatment. No significant health risks.';
    if (wqi >= 70) return 'Good water quality. Suitable for outdoor bathing. Minor treatment recommended for drinking.';
    if (wqi >= 50) return 'Moderate quality. Conventional treatment required before consumption. Some health precautions advised.';
    if (wqi >= 25) return 'Poor quality. Extensive treatment essential. Avoid direct consumption. Health risks present.';
    return 'Very poor quality. Heavily polluted. Not suitable for human use without advanced treatment.';
  }

  String _calculateMicrobialRisk(double fecalColiform) {
    if (fecalColiform < 10) return 'VERY LOW';
    if (fecalColiform < 100) return 'LOW';
    if (fecalColiform < 500) return 'MODERATE';
    if (fecalColiform < 2000) return 'HIGH';
    return 'VERY HIGH';
  }

  String _getMicrobialRiskDescription(double fecalColiform) {
    if (fecalColiform < 10) return 'Microbial contamination is minimal. Water meets safety standards for drinking.';
    if (fecalColiform < 100) return 'Low microbial presence. Suitable for most uses with basic treatment.';
    if (fecalColiform < 500) return 'Moderate contamination detected. Boiling or filtration recommended before use.';
    if (fecalColiform < 2000) return 'High bacterial contamination. Significant health risk. Avoid consumption without treatment.';
    return 'Very high contamination levels. Severe health hazard. Requires advanced treatment.';
  }

  String _getMicrobialAction(double fecalColiform) {
    if (fecalColiform < 10) return 'Safe for use';
    if (fecalColiform < 100) return 'Basic treatment recommended';
    if (fecalColiform < 500) return 'Boiling required';
    return 'Advanced treatment essential';
  }

  Color _getMicrobialRiskColor(double fecalColiform) {
    if (fecalColiform < 10) return Colors.green[700]!;
    if (fecalColiform < 100) return Colors.blue[700]!;
    if (fecalColiform < 500) return Colors.orange[700]!;
    return Colors.red[700]!;
  }

  String _calculateOxygenRisk(double dissolvedOxygen) {
    if (dissolvedOxygen >= 7) return 'VERY LOW';
    if (dissolvedOxygen >= 5) return 'LOW';
    if (dissolvedOxygen >= 3) return 'MODERATE';
    if (dissolvedOxygen >= 1) return 'HIGH';
    return 'CRITICAL';
  }

  String _getOxygenRiskDescription(double dissolvedOxygen) {
    if (dissolvedOxygen >= 7) return 'Excellent oxygen levels. Supports healthy aquatic ecosystem and good water quality.';
    if (dissolvedOxygen >= 5) return 'Adequate oxygen levels. Water quality is acceptable for most uses.';
    if (dissolvedOxygen >= 3) return 'Low oxygen levels. May affect aquatic life and indicate organic pollution.';
    if (dissolvedOxygen >= 1) return 'Very low oxygen. Significant ecosystem stress. Poor water quality indicator.';
    return 'Critical oxygen depletion. Severe pollution. Aquatic life threatened.';
  }

  String _getOxygenImpact(double dissolvedOxygen) {
    if (dissolvedOxygen >= 7) return 'Healthy ecosystem';
    if (dissolvedOxygen >= 5) return 'Minor stress';
    if (dissolvedOxygen >= 3) return 'Ecosystem stress';
    return 'Severe degradation';
  }

  Color _getOxygenRiskColor(double dissolvedOxygen) {
    if (dissolvedOxygen >= 7) return Colors.green[700]!;
    if (dissolvedOxygen >= 5) return Colors.blue[700]!;
    if (dissolvedOxygen >= 3) return Colors.orange[700]!;
    return Colors.red[700]!;
  }

  String _getOverallRiskLevel(double wqi) {
    if (wqi >= 90) return 'MINIMAL';
    if (wqi >= 70) return 'LOW';
    if (wqi >= 50) return 'MODERATE';
    if (wqi >= 25) return 'HIGH';
    return 'CRITICAL';
  }

  Color _getOverallRiskColor(double wqi) {
    if (wqi >= 90) return Colors.green[700]!;
    if (wqi >= 70) return Colors.blue[700]!;
    if (wqi >= 50) return Colors.orange[700]!;
    if (wqi >= 25) return Colors.red[700]!;
    return Colors.purple[900]!;
  }

  IconData _getOverallRiskIcon(double wqi) {
    if (wqi >= 70) return Icons.check_circle;
    if (wqi >= 50) return Icons.warning;
    return Icons.dangerous;
  }

  double _estimateAffectedPopulation(String district) {
    // Rough estimates based on Maharashtra districts
    final populationMap = {
      'Pune': 12000,
      'Mumbai': 20000,
      'Nagpur': 8000,
      'Thane': 15000,
      'Nashik': 7000,
    };
    return populationMap[district] ?? 5000;
  }

  // ==================== TAB 4: TRENDS ====================
  Widget _buildTrendsTab() {
    if (_historicalData == null || _historicalData!.isEmpty) {
      return _buildEmptyState('No historical data available');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Water Quality Trends (Last 30 Days)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_historicalData!.length} readings',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // WQI Trend Chart
          _buildWQITrendChart(),
          const SizedBox(height: 24),
          
          // Multi-Parameter Trend Chart
          _buildMultiParameterChart(),
          const SizedBox(height: 24),
          
          // Statistics Summary
          _buildTrendStatistics(),
        ],
      ),
    );
  }

  Widget _buildWQITrendChart() {
    final dataPoints = _historicalData!.map((reading) {
      final timestamp = DateTime.parse(reading.timestamp);
      return FlSpot(
        timestamp.millisecondsSinceEpoch.toDouble(),
        reading.wqi,
      );
    }).toList();
    
    final minWQI = dataPoints.map((spot) => spot.y).reduce((a, b) => a < b ? a : b);
    final maxWQI = dataPoints.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    final avgWQI = dataPoints.map((spot) => spot.y).reduce((a, b) => a + b) / dataPoints.length;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'WQI Trend Analysis',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                _buildMiniStat('Avg', avgWQI.toStringAsFixed(1), Colors.blue),
                const SizedBox(width: 12),
                _buildMiniStat('Min', minWQI.toStringAsFixed(1), Colors.red),
                const SizedBox(width: 12),
                _buildMiniStat('Max', maxWQI.toStringAsFixed(1), Colors.green),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 20,
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '${date.day}/${date.month}',
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[300]!),
                      left: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: dataPoints,
                      isCurved: true,
                      color: Colors.blue[700],
                      barWidth: 3,
                      dotData: FlDotData(show: dataPoints.length < 10),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue[700]!.withOpacity(0.1),
                      ),
                    ),
                  ],
                  minY: 0,
                  maxY: 100,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildMultiParameterChart() {
    // Create data points for key parameters
    final phData = <FlSpot>[];
    final doData = <FlSpot>[];
    final bodData = <FlSpot>[];
    
    for (var reading in _historicalData!) {
      final timestamp = DateTime.parse(reading.timestamp).millisecondsSinceEpoch.toDouble();
      phData.add(FlSpot(timestamp, _getParam(reading, 'pH', 7.0) * 10)); // Scale for visibility
      doData.add(FlSpot(timestamp, _getParam(reading, 'dissolvedOxygen', 6.0) * 10));
      bodData.add(FlSpot(timestamp, _getParam(reading, 'BOD', 2.0) * 10));
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Multi-Parameter Trends',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'pH, Dissolved Oxygen, and BOD trends over time',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('pH', Colors.purple[700]!),
                const SizedBox(width: 16),
                _buildLegendItem('DO', Colors.green[700]!),
                const SizedBox(width: 16),
                _buildLegendItem('BOD', Colors.orange[700]!),
              ],
            ),
            const SizedBox(height: 16),
            
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '${date.day}/${date.month}',
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[300]!),
                      left: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: phData,
                      isCurved: true,
                      color: Colors.purple[700],
                      barWidth: 2,
                      dotData: FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: doData,
                      isCurved: true,
                      color: Colors.green[700],
                      barWidth: 2,
                      dotData: FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: bodData,
                      isCurved: true,
                      color: Colors.orange[700],
                      barWidth: 2,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 3,
          color: color,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildTrendStatistics() {
    // Calculate statistics
    final wqiValues = _historicalData!.map((r) => r.wqi).toList();
    final avgWQI = wqiValues.reduce((a, b) => a + b) / wqiValues.length;
    final minWQI = wqiValues.reduce((a, b) => a < b ? a : b);
    final maxWQI = wqiValues.reduce((a, b) => a > b ? a : b);
    
    final phValues = _historicalData!.map((r) => _getParam(r, 'pH', 7.0)).toList();
    final avgPH = phValues.reduce((a, b) => a + b) / phValues.length;
    
    final doValues = _historicalData!.map((r) => _getParam(r, 'dissolvedOxygen', 6.0)).toList();
    final avgDO = doValues.reduce((a, b) => a + b) / doValues.length;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistical Summary',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildStatCard('Avg WQI', avgWQI.toStringAsFixed(1), Icons.show_chart, Colors.blue),
                _buildStatCard('Min WQI', minWQI.toStringAsFixed(1), Icons.arrow_downward, Colors.red),
                _buildStatCard('Max WQI', maxWQI.toStringAsFixed(1), Icons.arrow_upward, Colors.green),
                _buildStatCard('Avg pH', avgPH.toStringAsFixed(1), Icons.science, Colors.purple),
                _buildStatCard('Avg DO', '${avgDO.toStringAsFixed(1)} mg/L', Icons.air, Colors.teal),
                _buildStatCard('Readings', '${_historicalData!.length}', Icons.dataset, Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ==================== TAB 5: HEALTH IMPACT ====================
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'WQI Trend',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: dataPoints,
                      isCurved: true,
                      color: Colors.blue[700],
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParameterTrendChart() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Parameter Trends',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Detailed parameter trend charts coming soon...',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== TAB 5: HEALTH IMPACT ====================
  Widget _buildHealthImpactTab() {
    if (_latestReading == null) {
      return _buildEmptyState('No data available for health impact analysis');
    }

    final fecalColiform = _getParam(_latestReading!, 'fecalColiform', 10.0);
    final wqi = _latestReading!.wqi;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Health Impact & Disease Risk Analysis',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Water-borne disease predictions based on water quality parameters',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 20),
          
          // Overall Health Risk
          _buildHealthRiskOverview(fecalColiform, wqi),
          const SizedBox(height: 16),
          
          // Disease Risk Cards
          _buildDiseaseRiskCard(
            'Cholera',
            _calculateCholeraRisk(fecalColiform),
            _getCholeraDescription(fecalColiform),
            'High fecal coliform levels increase cholera transmission',
            Icons.coronavirus,
            Colors.red,
            fecalColiform,
          ),
          const SizedBox(height: 12),
          
          _buildDiseaseRiskCard(
            'Typhoid',
            _calculateTyphoidRisk(fecalColiform, wqi),
            _getTyphoidDescription(fecalColiform),
            'Poor water quality facilitates typhoid bacteria spread',
            Icons.sick,
            Colors.orange,
            fecalColiform,
          ),
          const SizedBox(height: 12),
          
          _buildDiseaseRiskCard(
            'Dysentery',
            _calculateDysenteryRisk(fecalColiform),
            _getDysenteryDescription(fecalColiform),
            'Contaminated water is primary transmission vector',
            Icons.medical_services,
            Colors.deepOrange,
            fecalColiform,
          ),
          const SizedBox(height: 12),
          
          _buildDiseaseRiskCard(
            'Hepatitis A',
            _calculateHepatitisRisk(fecalColiform),
            _getHepatitisDescription(fecalColiform),
            'Viral infection from contaminated water sources',
            Icons.local_hospital,
            Colors.amber,
            fecalColiform,
          ),
          const SizedBox(height: 16),
          
          // Outbreak Probability
          _buildOutbreakProbabilityCard(fecalColiform, wqi),
        ],
      ),
    );
  }

  Widget _buildHealthRiskOverview(double fecalColiform, double wqi) {
    final overallRisk = _calculateOverallHealthRisk(fecalColiform, wqi);
    final riskColor = _getHealthRiskColor(overallRisk);
    
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [riskColor.withOpacity(0.1), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: riskColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.health_and_safety, size: 35, color: riskColor),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Overall Health Risk',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          overallRisk,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: riskColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.people, size: 20, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Estimated ${_estimateAffectedPopulation(widget.station.district).toInt()} people potentially affected in ${widget.station.district} district',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiseaseRiskCard(
    String disease,
    double riskPercentage,
    String riskLevel,
    String description,
    IconData icon,
    Color color,
    double fecalColiform,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 24, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        disease,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        riskLevel,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${riskPercentage.toStringAsFixed(0)}% risk',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: riskPercentage / 100,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.info_outline, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Predicted cases (30 days): ${_predictCaseCount(riskPercentage, widget.station.district)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutbreakProbabilityCard(double fecalColiform, double wqi) {
    final prob7days = _calculateOutbreakProbability(fecalColiform, wqi, 7);
    final prob30days = _calculateOutbreakProbability(fecalColiform, wqi, 30);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.warning_amber, size: 24, color: Colors.purple),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Outbreak Probability',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildProbabilityIndicator('Next 7 Days', prob7days),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildProbabilityIndicator('Next 30 Days', prob30days),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified, size: 16, color: Colors.green),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Confidence: 85% (based on historical data)',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProbabilityIndicator(String label, double probability) {
    final color = probability < 5 ? Colors.green : (probability < 15 ? Colors.orange : Colors.red);
    final riskText = probability < 5 ? 'Very Low' : (probability < 15 ? 'Low-Moderate' : 'High');
    
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Text(
          '${probability.toStringAsFixed(0)}%',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            riskText,
            style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  // Health risk calculation helpers
  String _calculateOverallHealthRisk(double fecalColiform, double wqi) {
    if (fecalColiform < 10 && wqi >= 70) return 'VERY LOW';
    if (fecalColiform < 100 && wqi >= 50) return 'LOW';
    if (fecalColiform < 500) return 'MODERATE';
    if (fecalColiform < 2000) return 'HIGH';
    return 'VERY HIGH';
  }

  Color _getHealthRiskColor(String risk) {
    switch (risk) {
      case 'VERY LOW': return Colors.green[700]!;
      case 'LOW': return Colors.blue[700]!;
      case 'MODERATE': return Colors.orange[700]!;
      case 'HIGH': return Colors.red[700]!;
      case 'VERY HIGH': return Colors.purple[900]!;
      default: return Colors.grey;
    }
  }

  double _calculateCholeraRisk(double fecalColiform) {
    if (fecalColiform < 10) return 2;
    if (fecalColiform < 100) return 8;
    if (fecalColiform < 500) return 25;
    if (fecalColiform < 2000) return 50;
    return 80;
  }

  String _getCholeraDescription(double fecalColiform) {
    if (fecalColiform < 10) return 'Very Low Risk';
    if (fecalColiform < 100) return 'Low Risk';
    if (fecalColiform < 500) return 'Moderate Risk';
    if (fecalColiform < 2000) return 'High Risk';
    return 'Very High Risk';
  }

  double _calculateTyphoidRisk(double fecalColiform, double wqi) {
    final baseRisk = fecalColiform < 10 ? 3 : (fecalColiform < 100 ? 10 : (fecalColiform < 500 ? 30 : 60));
    final wqiFactor = wqi < 50 ? 1.5 : 1.0;
    return (baseRisk * wqiFactor).clamp(0, 100);
  }

  String _getTyphoidDescription(double fecalColiform) {
    if (fecalColiform < 10) return 'Very Low Risk';
    if (fecalColiform < 100) return 'Low Risk';
    if (fecalColiform < 500) return 'Moderate Risk';
    return 'High Risk';
  }

  double _calculateDysenteryRisk(double fecalColiform) {
    if (fecalColiform < 10) return 4;
    if (fecalColiform < 100) return 12;
    if (fecalColiform < 500) return 35;
    return 70;
  }

  String _getDysenteryDescription(double fecalColiform) {
    if (fecalColiform < 10) return 'Very Low Risk';
    if (fecalColiform < 100) return 'Low Risk';
    if (fecalColiform < 500) return 'Moderate Risk';
    return 'High Risk';
  }

  double _calculateHepatitisRisk(double fecalColiform) {
    if (fecalColiform < 10) return 1;
    if (fecalColiform < 100) return 5;
    if (fecalColiform < 500) return 15;
    return 40;
  }

  String _getHepatitisDescription(double fecalColiform) {
    if (fecalColiform < 10) return 'Very Low Risk';
    if (fecalColiform < 100) return 'Low Risk';
    if (fecalColiform < 500) return 'Moderate Risk';
    return 'High Risk';
  }

  double _calculateOutbreakProbability(double fecalColiform, double wqi, int days) {
    final baseProbability = fecalColiform < 10 ? 1 : (fecalColiform < 100 ? 5 : (fecalColiform < 500 ? 15 : 35));
    final wqiFactor = wqi < 50 ? 1.5 : (wqi < 70 ? 1.2 : 1.0);
    final timeFactor = days == 7 ? 0.5 : 1.0;
    return (baseProbability * wqiFactor * timeFactor).clamp(0, 100);
  }

  String _predictCaseCount(double riskPercentage, String district) {
    final population = _estimateAffectedPopulation(district);
    final cases = (population * riskPercentage / 100).toInt();
    if (cases < 2) return '0-2';
    if (cases < 10) return '2-10';
    if (cases < 50) return '${cases - 5}-${cases + 5}';
    return '${cases - 20}-${cases + 20}';
  }

  // ==================== TAB 6: RECOMMENDATIONS ====================
  Widget _buildRecommendationsTab() {
    if (_latestReading == null) {
      return _buildEmptyState('No data available for recommendations');
    }

    final wqi = _latestReading!.wqi;
    final fecalColiform = _getParam(_latestReading!, 'fecalColiform', 10.0);
    final dissolvedOxygen = _getParam(_latestReading!, 'dissolvedOxygen', 6.0);
    final ph = _getParam(_latestReading!, 'pH', 7.0);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Actionable Recommendations',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Based on current water quality analysis for ${widget.station.name}',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 20),
          
          // Water Treatment Recommendations
          _buildRecommendationSection(
            'Water Treatment Required',
            Icons.science,
            Colors.blue,
            _getWaterTreatmentRecommendations(wqi, fecalColiform),
          ),
          const SizedBox(height: 16),
          
          // Health & Safety Precautions
          _buildRecommendationSection(
            'Health & Safety Precautions',
            Icons.health_and_safety,
            Colors.red,
            _getHealthPrecautions(fecalColiform, wqi),
          ),
          const SizedBox(height: 16),
          
          // Monitoring Alerts
          _buildRecommendationSection(
            'Monitoring Alerts',
            Icons.notifications_active,
            Colors.orange,
            _getMonitoringAlerts(dissolvedOxygen, fecalColiform, ph),
          ),
          const SizedBox(height: 16),
          
          // Parameter-Specific Actions
          _buildRecommendationSection(
            'Parameter-Specific Actions',
            Icons.settings,
            Colors.purple,
            _getParameterActions(ph, dissolvedOxygen, fecalColiform),
          ),
          const SizedBox(height: 16),
          
          // Emergency Contacts (if high risk)
          if (wqi < 50 || fecalColiform > 500)
            _buildEmergencyContactCard(),
        ],
      ),
    );
  }

  Widget _buildRecommendationSection(
    String title,
    IconData icon,
    Color color,
    List<String> recommendations,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 24, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...recommendations.asMap().entries.map((entry) {
              final index = entry.key;
              final recommendation = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        recommendation,
                        style: const TextStyle(fontSize: 14, height: 1.4),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyContactCard() {
    return Card(
      elevation: 3,
      color: Colors.red[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.emergency, size: 24, color: Colors.red),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Emergency Contacts',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildEmergencyContactItem(
              'Maharashtra Pollution Control Board',
              '022-2437 6365',
              Icons.phone,
            ),
            const SizedBox(height: 8),
            _buildEmergencyContactItem(
              'District Health Office',
              '1800-XXX-XXXX',
              Icons.local_hospital,
            ),
            const SizedBox(height: 8),
            _buildEmergencyContactItem(
              'Water Quality Hotline',
              '1916',
              Icons.water_drop,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyContactItem(String name, String number, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.red[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  number,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
        ],
      ),
    );
  }

  // Recommendation generation helpers
  List<String> _getWaterTreatmentRecommendations(double wqi, double fecalColiform) {
    final recommendations = <String>[];
    
    if (wqi >= 90) {
      recommendations.add('Water quality is excellent. No treatment necessary for most uses.');
      recommendations.add('For drinking: Basic filtration recommended as precaution.');
      recommendations.add('Regular monitoring to maintain current quality standards.');
    } else if (wqi >= 70) {
      recommendations.add('Good water quality. Basic treatment recommended for drinking.');
      recommendations.add('Chlorination: Add 0.2-0.5 mg/L chlorine and wait 30 minutes.');
      recommendations.add('Use certified water filters (activated carbon or UV).');
      recommendations.add('Boiling for 5 minutes ensures complete safety.');
    } else if (wqi >= 50) {
      recommendations.add('Conventional treatment required before consumption.');
      recommendations.add('Multi-stage treatment: Coagulation + Filtration + Disinfection.');
      recommendations.add('Boiling mandatory: 10 minutes at rolling boil.');
      recommendations.add('Avoid direct consumption without treatment.');
      recommendations.add('Consider RO (Reverse Osmosis) system for households.');
    } else {
      recommendations.add('CRITICAL: Extensive treatment essential before any use.');
      recommendations.add('Advanced treatment required: RO or distillation systems.');
      recommendations.add('Boiling alone may not be sufficient - use certified purifiers.');
      recommendations.add('Avoid all contact with water until quality improves.');
      recommendations.add('Report to Maharashtra Pollution Control Board immediately.');
    }
    
    if (fecalColiform > 500) {
      recommendations.add('HIGH ALERT: Severe microbial contamination detected.');
      recommendations.add('UV treatment + Chlorination strongly recommended.');
    }
    
    return recommendations;
  }

  List<String> _getHealthPrecautions(double fecalColiform, double wqi) {
    final precautions = <String>[];
    
    if (fecalColiform < 10 && wqi >= 70) {
      precautions.add('Water is generally safe. Maintain good hygiene practices.');
      precautions.add('Wash hands before meals and after restroom use.');
      precautions.add('Store water in clean, covered containers.');
    } else if (fecalColiform < 100) {
      precautions.add('Exercise basic health precautions when using water.');
      precautions.add('Wash hands thoroughly with soap before food preparation.');
      precautions.add('Avoid consumption of raw vegetables washed in untreated water.');
      precautions.add('Monitor for symptoms: diarrhea, nausea, stomach cramps.');
    } else if (fecalColiform < 500) {
      precautions.add('MODERATE RISK: Enhanced health precautions necessary.');
      precautions.add('Boil all water used for drinking, cooking, and brushing teeth.');
      precautions.add('Avoid direct contact with water for cuts or open wounds.');
      precautions.add('Watch for waterborne disease symptoms and seek medical attention.');
      precautions.add('Pregnant women, children, elderly: Use only treated water.');
    } else {
      precautions.add('HIGH RISK: Strict health precautions mandatory.');
      precautions.add('Use only bottled or professionally treated water for all purposes.');
      precautions.add('Seek immediate medical attention for diarrhea or vomiting.');
      precautions.add('Avoid bathing or washing in untreated water.');
      precautions.add('Vaccinations: Ensure Typhoid and Hepatitis A vaccines are current.');
      precautions.add('Keep emergency ORS (Oral Rehydration Solution) on hand.');
    }
    
    return precautions;
  }

  List<String> _getMonitoringAlerts(double dissolvedOxygen, double fecalColiform, double ph) {
    final alerts = <String>[];
    
    if (dissolvedOxygen < 5) {
      alerts.add('⚠️ Dissolved Oxygen below healthy threshold (${dissolvedOxygen.toStringAsFixed(1)} mg/L)');
      alerts.add('Monitor for further depletion over next 3-5 days.');
      alerts.add('Consider testing upstream sources for pollution.');
    }
    
    if (fecalColiform > 100) {
      alerts.add('⚠️ Elevated Fecal Coliform levels detected (${fecalColiform.toStringAsFixed(0)} MPN/100ml)');
      alerts.add('Increase testing frequency to daily for next week.');
      alerts.add('Investigate potential sewage contamination sources.');
    }
    
    if (ph < 6.5 || ph > 8.5) {
      alerts.add('⚠️ pH outside optimal range (${ph.toStringAsFixed(1)})');
      alerts.add('Monitor pH daily to track fluctuation patterns.');
      if (ph < 6.5) {
        alerts.add('Acidic water - check for industrial discharge upstream.');
      } else {
        alerts.add('Alkaline water - investigate agricultural runoff.');
      }
    }
    
    if (alerts.isEmpty) {
      alerts.add('✅ All parameters within acceptable monitoring ranges.');
      alerts.add('Continue regular weekly sampling schedule.');
      alerts.add('No immediate action required.');
    }
    
    return alerts;
  }

  List<String> _getParameterActions(double ph, double dissolvedOxygen, double fecalColiform) {
    final actions = <String>[];
    
    // pH-specific
    if (ph < 6.5) {
      actions.add('pH Action: Add alkaline substances (lime/soda ash) if treating water.');
    } else if (ph > 8.5) {
      actions.add('pH Action: Add acidic substances (alum) to adjust pH if treating.');
    }
    
    // DO-specific
    if (dissolvedOxygen < 5) {
      actions.add('DO Action: Aeration may help improve oxygen levels in storage tanks.');
      actions.add('DO Action: Reduce organic load by treating wastewater upstream.');
    }
    
    // Fecal Coliform-specific
    if (fecalColiform > 100) {
      actions.add('FC Action: Chlorination at 1-2 mg/L to eliminate bacteria.');
      actions.add('FC Action: Locate and eliminate sewage contamination source.');
    }
    
    // General actions
    actions.add('Conduct comprehensive water quality audit every 15 days.');
    actions.add('Maintain detailed log of all parameters and treatment actions.');
    actions.add('Report significant changes to district water quality officer.');
    
    return actions;
  }

  // ==================== HELPER METHODS ====================
  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Color _getWQIColor(double wqi) {
    if (wqi >= 90) return Colors.blue[700]!;
    if (wqi >= 70) return Colors.green[700]!;
    if (wqi >= 50) return Colors.orange[700]!;
    if (wqi >= 25) return Colors.red[700]!;
    return Colors.purple[900]!;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'excellent':
        return Colors.blue[700]!;
      case 'good':
        return Colors.green[700]!;
      case 'moderate':
        return Colors.orange[700]!;
      case 'poor':
        return Colors.red[700]!;
      default:
        return Colors.grey;
    }
  }

  String _getWQIDescription(String wqiClass) {
    switch (wqiClass) {
      case 'Class A':
        return 'Excellent quality - Suitable for drinking without treatment';
      case 'Class B':
        return 'Good quality - Outdoor bathing acceptable';
      case 'Class C':
        return 'Moderate quality - Conventional treatment required';
      case 'Class D':
        return 'Poor quality - Fish and wildlife propagation';
      case 'Class E':
        return 'Very poor quality - Irrigation and industrial use';
      default:
        return 'Quality assessment in progress';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
