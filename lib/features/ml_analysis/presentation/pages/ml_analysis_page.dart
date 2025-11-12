import 'package:flutter/material.dart';
import 'package:pure_health/core/constants/color_constants.dart';
import 'package:pure_health/core/theme/text_styles.dart';
import 'package:pure_health/core/services/local_storage_service.dart';
import 'package:pure_health/features/ml_analysis/data/services/historical_data_service.dart';

class MLAnalysisPage extends StatefulWidget {
  final String? stationId;
  final String? analysisType;

  const MLAnalysisPage({
    super.key,
    this.stationId,
    this.analysisType,
  });

  @override
  State<MLAnalysisPage> createState() => _MLAnalysisPageState();
}

class _MLAnalysisPageState extends State<MLAnalysisPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _analysisData;
  Map<String, dynamic>? _storageInfo;
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
      final storage = await LocalStorageService.getInstance();
      _storageInfo = await storage.getStorageInfo();

      if (widget.stationId != null) {
        await _loadAnalysisData();
      }
    } catch (e) {
      print('[ML_ANALYSIS] Error initializing: $e');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _loadAnalysisData() async {
    if (_historicalService == null || widget.stationId == null) return;

    try {
      Map<String, dynamic> data;

      switch (widget.analysisType) {
        case 'prediction':
          data = await _historicalService!.getMLPredictionData(widget.stationId!);
          break;
        case 'risk':
          data = await _historicalService!.getRiskAssessmentData(widget.stationId!);
          break;
        case 'trends':
          data = await _historicalService!.getTrendAnalysisData(widget.stationId!);
          break;
        default:
          data = await _historicalService!.getMLPredictionData(widget.stationId!);
      }

      setState(() {
        _analysisData = data;
      });
    } catch (e) {
      print('[ML_ANALYSIS] Error loading analysis data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: Text(
          'ML/AI Analysis',
          style: AppTextStyles.heading3.copyWith(color: AppColors.white),
        ),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Storage Information
                  _buildStorageInfoCard(),
                  const SizedBox(height: 24),

                  // Analysis Data
                  if (_analysisData != null) ...[
                    _buildAnalysisCard(),
                    const SizedBox(height: 24),
                  ],

                  // Quick Actions
                  _buildQuickActionsCard(),
                  const SizedBox(height: 24),

                  // Export Options
                  _buildExportCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildStorageInfoCard() {
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
              Icon(Icons.storage, color: AppColors.white, size: 28),
              const SizedBox(width: 12),
              Text(
                'Stored Data',
                style: AppTextStyles.heading3.copyWith(color: AppColors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            'Total Stations',
            '${_storageInfo?['totalStations'] ?? 0}',
            Icons.location_on,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Total Readings',
            '${_storageInfo?['totalReadings'] ?? 0}',
            Icons.analytics,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Last Update',
            _formatLastUpdate(_storageInfo?['lastUpdate']),
            Icons.access_time,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.white.withOpacity(0.8), size: 18),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: AppTextStyles.body.copyWith(
            color: AppColors.white.withOpacity(0.9),
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.body.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisCard() {
    final hasData = _analysisData?['hasData'] == true;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.lightCream,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkCream.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analysis Results',
            style: AppTextStyles.heading4.copyWith(
              color: AppColors.charcoal,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (!hasData)
            Text(
              _analysisData?['message'] ?? 'No data available',
              style: AppTextStyles.body.copyWith(color: AppColors.mediumGray),
            )
          else ...[
            Text(
              'Station ID: ${_analysisData?['stationId']}',
              style: AppTextStyles.body.copyWith(color: AppColors.charcoal),
            ),
            const SizedBox(height: 8),
            Text(
              'Data Points: ${_analysisData?['dataPoints'] ?? 0}',
              style: AppTextStyles.body.copyWith(color: AppColors.charcoal),
            ),
            const SizedBox(height: 16),
            Text(
              '✓ Ready for ML/AI Analysis',
              style: AppTextStyles.body.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkCream.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: AppTextStyles.heading4.copyWith(
              color: AppColors.charcoal,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildActionButton(
            'View All Stored Data',
            Icons.list_alt,
            () => _showAllStoredData(),
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            'Clear Storage',
            Icons.delete_outline,
            () => _clearStorage(),
            color: AppColors.error,
          ),
        ],
      ),
    );
  }

  Widget _buildExportCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.lightCream,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkCream.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Export Data',
            style: AppTextStyles.heading4.copyWith(
              color: AppColors.charcoal,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Export stored data for external ML processing',
            style: AppTextStyles.caption.copyWith(color: AppColors.mediumGray),
          ),
          const SizedBox(height: 16),
          _buildActionButton(
            'Export to JSON',
            Icons.file_download,
            () => _exportData(),
            color: AppColors.primaryBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onPressed, {Color? color}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: (color ?? AppColors.primaryBlue).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: (color ?? AppColors.primaryBlue).withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color ?? AppColors.primaryBlue, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.body.copyWith(
                  color: color ?? AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: color ?? AppColors.primaryBlue,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  String _formatLastUpdate(DateTime? dateTime) {
    if (dateTime == null) return 'Never';
    
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }

  Future<void> _showAllStoredData() async {
    final storage = await LocalStorageService.getInstance();
    final allHistory = await storage.getAllStationsHistory();
    
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Stored Data Overview'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Total Stations: ${allHistory.length}'),
              const SizedBox(height: 12),
              ...allHistory.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '${entry.key}: ${entry.value.length} readings',
                    style: const TextStyle(fontSize: 13),
                  ),
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearStorage() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text(
          'This will permanently delete all stored simulation data. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final storage = await LocalStorageService.getInstance();
      await storage.clearAllHistory();
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All stored data cleared'),
          backgroundColor: Colors.green,
        ),
      );
      
      _initializeServices();
    }
  }

  Future<void> _exportData() async {
    if (widget.stationId == null || _historicalService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No station selected')),
      );
      return;
    }

    final exportData = await _historicalService!.exportDataForML(widget.stationId!);
    
    if (!mounted) return;
    
    if (exportData['success'] == true) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Export Successful'),
          content: Text(
            'Exported ${exportData['dataPoints']} data points for station ${exportData['stationId']}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(exportData['message'] ?? 'Export failed')),
      );
    }
  }
}
