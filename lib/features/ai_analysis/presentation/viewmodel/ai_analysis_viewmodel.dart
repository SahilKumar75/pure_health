import 'package:flutter/material.dart';
import '../../data/models/analysis_report.dart';
import '../../data/models/water_body_location.dart';
import '../../data/services/ai_analysis_service.dart';
import '../../data/water_bodies_maharashtra.dart';

class AIAnalysisViewModel extends ChangeNotifier {
  final AIAnalysisService _service;

  bool _isLoading = false;
  bool _isAnalyzing = false;
  String? _error;
  
  // File data
  Map<String, dynamic>? _uploadedFileData;
  String? _fileName;
  int? _recordCount;
  
  // Location
  WaterBodyLocation? _selectedLocation;
  
  // Analysis report
  AnalysisReport? _currentReport;
  
  // Saved reports
  List<AnalysisReport> _savedReports = [];

  AIAnalysisViewModel({AIAnalysisService? service})
      : _service = service ?? AIAnalysisService();

  // Getters
  bool get isLoading => _isLoading;
  bool get isAnalyzing => _isAnalyzing;
  String? get error => _error;
  Map<String, dynamic>? get uploadedFileData => _uploadedFileData;
  String? get fileName => _fileName;
  int? get recordCount => _recordCount;
  WaterBodyLocation? get selectedLocation => _selectedLocation;
  AnalysisReport? get currentReport => _currentReport;
  List<AnalysisReport> get savedReports => _savedReports;
  bool get hasUploadedFile => _uploadedFileData != null;
  bool get hasReport => _currentReport != null;

  /// Upload file
  Future<void> uploadFile() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await _service.uploadFile();
      
      _uploadedFileData = result['file_data'];
      _fileName = result['file_name'];
      _recordCount = result['record_count'];
      
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Select water body location
  void selectLocation(WaterBodyLocation location) {
    _selectedLocation = location;
    notifyListeners();
  }

  /// Clear location selection
  void clearLocation() {
    _selectedLocation = null;
    notifyListeners();
  }

  /// Generate comprehensive analysis
  Future<void> generateAnalysis() async {
    if (_uploadedFileData == null) {
      _error = 'Please upload a file first';
      notifyListeners();
      return;
    }

    try {
      _isAnalyzing = true;
      _error = null;
      notifyListeners();

      _currentReport = await _service.generateReport(
        fileData: _uploadedFileData!,
        location: _selectedLocation,
      );
      
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  /// Save current report to history
  Future<void> saveReport() async {
    if (_currentReport == null) {
      _error = 'No report to save';
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _service.saveReportToHistory(_currentReport!);
      await loadSavedReports();
      
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load saved reports
  Future<void> loadSavedReports() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _savedReports = await _service.getSavedReports();
      
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load a saved report
  void loadReport(AnalysisReport report) {
    _currentReport = report;
    _selectedLocation = report.location;
    notifyListeners();
  }

  /// Delete a report
  Future<void> deleteReport(String reportId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _service.deleteReport(reportId);
      await loadSavedReports();
      
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear current analysis
  void clearAnalysis() {
    _currentReport = null;
    _uploadedFileData = null;
    _fileName = null;
    _recordCount = null;
    _selectedLocation = null;
    _error = null;
    notifyListeners();
  }

  /// Get all Maharashtra water bodies
  List<WaterBodyLocation> getAllWaterBodies() {
    return MaharashtraWaterBodies.allWaterBodies;
  }

  /// Search water bodies
  List<WaterBodyLocation> searchWaterBodies(String query) {
    return MaharashtraWaterBodies.searchByName(query);
  }

  /// Get water bodies by district
  List<WaterBodyLocation> getWaterBodiesByDistrict(String district) {
    return MaharashtraWaterBodies.getByDistrict(district);
  }

  /// Get water bodies by type
  List<WaterBodyLocation> getWaterBodiesByType(String type) {
    return MaharashtraWaterBodies.getByType(type);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
