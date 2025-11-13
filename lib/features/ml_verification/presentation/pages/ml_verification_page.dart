import 'package:flutter/material.dart';
import 'package:pure_health/ml/repositories/ml_repository.dart';
import 'package:pure_health/core/constants/color_constants.dart';
import 'package:pure_health/core/theme/text_styles.dart';
import 'dart:convert';

/// ML Model Verification & Testing Page
/// Shows exactly what data, models, and predictions are being used
class MLVerificationPage extends StatefulWidget {
  const MLVerificationPage({super.key});

  @override
  State<MLVerificationPage> createState() => _MLVerificationPageState();
}

class _MLVerificationPageState extends State<MLVerificationPage> {
  final MLRepository _mlRepo = MLRepository();
  
  bool _isLoading = false;
  Map<String, dynamic>? _modelInfo;
  Map<String, dynamic>? _trainingData;
  Map<String, dynamic>? _predictionResult;
  Map<String, dynamic>? _testInput;
  
  @override
  void initState() {
    super.initState();
    _loadModelInfo();
  }

  Future<void> _loadModelInfo() async {
    setState(() => _isLoading = true);
    
    try {
      // Get comprehensive model information
      final info = await _mlRepo.getModelInformation();
      final training = await _mlRepo.getTrainingDataInfo();
      
      setState(() {
        _modelInfo = info;
        _trainingData = training;
      });
    } catch (e) {
      _showError('Failed to load model info: $e');
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _runTestPrediction() async {
    setState(() => _isLoading = true);
    
    try {
      // Create test input with known values
      _testInput = {
        'stationId': 'TEST_STATION_001',
        'timestamp': DateTime.now().toIso8601String(),
        'parameters': {
          'pH': 7.5,
          'dissolvedOxygen': 6.8,
          'turbidity': 15.0,
          'temperature': 25.0,
          'conductivity': 450.0,
          'bod': 3.2,
          'tds': 300.0,
        },
      };
      
      // Get prediction with full details
      final prediction = await _mlRepo.getDetailedPrediction(_testInput!);
      
      setState(() {
        _predictionResult = prediction;
      });
      
      _showSuccess('Prediction completed!');
    } catch (e) {
      _showError('Prediction failed: $e');
    }
    
    setState(() => _isLoading = false);
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
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
        title: const Text(
          'ML Model Verification',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadModelInfo,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildWarningBanner(),
                  const SizedBox(height: 24),
                  _buildModelInfoSection(),
                  const SizedBox(height: 24),
                  _buildTrainingDataSection(),
                  const SizedBox(height: 24),
                  _buildTestSection(),
                  const SizedBox(height: 24),
                  if (_predictionResult != null) _buildPredictionResultSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildWarningBanner() {
    final isMocked = _modelInfo?['isMocked'] ?? true;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isMocked ? Colors.orange[50] : Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMocked ? Colors.orange : Colors.green,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isMocked ? Icons.warning_amber : Icons.check_circle,
            color: isMocked ? Colors.orange : Colors.green,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isMocked ? '⚠️ MOCK MODE ACTIVE' : '✅ REAL ML MODEL',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isMocked ? Colors.orange[800] : Colors.green[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isMocked
                      ? 'Currently using simulated predictions. Real ML model not loaded.'
                      : 'Using trained ML model with real predictions.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModelInfoSection() {
    return _buildSection(
      title: '🤖 Model Information',
      icon: Icons.psychology,
      child: _modelInfo == null
          ? const Text('No model information available')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Model Type', _modelInfo!['modelType'] ?? 'Unknown'),
                _buildInfoRow('Version', _modelInfo!['version'] ?? 'N/A'),
                _buildInfoRow('Framework', _modelInfo!['framework'] ?? 'N/A'),
                _buildInfoRow('Status', _modelInfo!['status'] ?? 'Unknown'),
                _buildInfoRow('Last Updated', _modelInfo!['lastUpdated'] ?? 'Never'),
                const Divider(height: 24),
                _buildInfoRow('Model Path', _modelInfo!['modelPath'] ?? 'Not specified', mono: true),
                _buildInfoRow('Input Features', '${_modelInfo!['inputFeatures'] ?? 0}'),
                _buildInfoRow('Output Classes', '${_modelInfo!['outputClasses'] ?? 0}'),
                const SizedBox(height: 16),
                if (_modelInfo!['isMocked'] == true) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: Colors.red[700], size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'This is a MOCK model returning hardcoded predictions for demonstration purposes.',
                            style: TextStyle(
                              color: Colors.red[700],
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

  Widget _buildTrainingDataSection() {
    return _buildSection(
      title: '📊 Training Data Information',
      icon: Icons.dataset,
      child: _trainingData == null
          ? const Text('No training data information available')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Dataset Name', _trainingData!['datasetName'] ?? 'Unknown'),
                _buildInfoRow('Total Samples', '${_trainingData!['totalSamples'] ?? 0}'),
                _buildInfoRow('Training Samples', '${_trainingData!['trainingSamples'] ?? 0}'),
                _buildInfoRow('Validation Samples', '${_trainingData!['validationSamples'] ?? 0}'),
                _buildInfoRow('Test Samples', '${_trainingData!['testSamples'] ?? 0}'),
                const Divider(height: 24),
                _buildInfoRow('Date Range', _trainingData!['dateRange'] ?? 'Not specified'),
                _buildInfoRow('Data Source', _trainingData!['dataSource'] ?? 'Unknown'),
                _buildInfoRow('Features Used', '${(_trainingData!['features'] as List?)?.length ?? 0}'),
                const SizedBox(height: 16),
                if (_trainingData!['features'] != null) ...[
                  const Text(
                    'Features in Model:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (_trainingData!['features'] as List)
                        .map((feature) => Chip(
                              label: Text(
                                feature.toString(),
                                style: const TextStyle(fontSize: 12),
                              ),
                              backgroundColor: Colors.blue[50],
                            ))
                        .toList(),
                  ),
                ],
                const SizedBox(height: 16),
                if (_trainingData!['isMocked'] == true) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange[700], size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'No actual training data was used. This is simulated information.',
                            style: TextStyle(
                              color: Colors.orange[700],
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

  Widget _buildTestSection() {
    return _buildSection(
      title: '🧪 Test Prediction',
      icon: Icons.science,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Run a test prediction with sample water quality parameters to verify the model:',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _runTestPrediction,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Run Test Prediction'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (_testInput != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Test Input:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    const JsonEncoder.withIndent('  ').convert(_testInput),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
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

  Widget _buildPredictionResultSection() {
    return _buildSection(
      title: '📈 Prediction Result',
      icon: Icons.trending_up,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status indicator
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _predictionResult!['isMocked'] == true
                  ? Colors.orange[50]
                  : Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _predictionResult!['isMocked'] == true
                    ? Colors.orange
                    : Colors.green,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _predictionResult!['isMocked'] == true
                      ? Icons.warning
                      : Icons.check_circle,
                  color: _predictionResult!['isMocked'] == true
                      ? Colors.orange[700]
                      : Colors.green[700],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _predictionResult!['isMocked'] == true
                        ? 'Mock Prediction (Hardcoded)'
                        : 'Real ML Prediction',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _predictionResult!['isMocked'] == true
                          ? Colors.orange[700]
                          : Colors.green[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Prediction values
          _buildInfoRow('Predicted WQI', '${_predictionResult!['predictedValue'] ?? 'N/A'}'),
          _buildInfoRow('Status', _predictionResult!['status'] ?? 'Unknown'),
          _buildInfoRow('Confidence', '${(_predictionResult!['confidence'] ?? 0) * 100}%'),
          _buildInfoRow('Model Used', _predictionResult!['modelUsed'] ?? 'Unknown'),
          _buildInfoRow('Timestamp', _predictionResult!['timestamp'] ?? 'N/A'),
          
          const Divider(height: 24),
          
          // Full JSON response
          const Text(
            'Full Response:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                const JsonEncoder.withIndent('  ').convert(_predictionResult),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryBlue, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: AppTextStyles.heading4.copyWith(
                  color: AppColors.charcoal,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool mono = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: AppColors.charcoal,
                fontWeight: FontWeight.bold,
                fontFamily: mono ? 'monospace' : null,
                fontSize: mono ? 12 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
