import 'package:flutter/material.dart';
import 'package:pure_health/ml/models/chat_model.dart';
import 'package:pure_health/ml/models/water_quality_model.dart';
import 'package:pure_health/ml/repositories/ml_repository.dart';

/// Local chat message model for UI display
class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? confidence;
  final Map<String, dynamic>? metadata;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.confidence,
    this.metadata,
  });
}

class ChatProvider extends ChangeNotifier {
  final MLRepository _mlRepository;

  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _error;
  bool _isConnected = true;

  ChatProvider(this._mlRepository) {
    _initializeChat();
  }

  // Getters
  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isConnected => _isConnected;

  void _initializeChat() {
    // Add welcome message
    _messages.add(
      ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text:
            'Hello! I\'m your PureHealth Government AI Assistant. I can help you analyze water quality data, process uploaded files, and generate reports. How can I help you today?',
        isUser: false,
        timestamp: DateTime.now(),
        confidence: '1.0',
      ),
    );
  }

  /// Send a chat message and get AI response
  Future<void> sendMessage(ChatRequest request) async {
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      // Add user message
      final userMsg = ChatMessage(
        id: request.message.hashCode.toString(),
        text: request.message,
        isUser: true,
        timestamp: DateTime.now(),
      );
      _messages.add(userMsg);
      notifyListeners();

      // Get AI response from ML repository
      final response = await _mlRepository.sendChatMessage(request);

      // Add AI response
      final aiMsg = ChatMessage(
        id: response.id,
        text: response.response,
        isUser: false,
        timestamp: DateTime.now(),
        confidence: response.confidence.toString(),
        metadata: {
          'intent': response.intent,
          'entities': response.entities,
        },
      );
      _messages.add(aiMsg);
      _isConnected = true;
    } catch (e) {
      _error = e.toString();
      _isConnected = false;

      // Add error message
      final errorMsg = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: 'Sorry, I encountered an error: ${e.toString()}',
        isUser: false,
        timestamp: DateTime.now(),
        confidence: '0.0',
      );
      _messages.add(errorMsg);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Analyze uploaded water quality files
  Future<void> analyzeUploadedFiles(
    List<String> fileNames,
    String fileContent,
  ) async {
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      // Add user message about files
      final userMsg = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: 'Please analyze these water quality files: ${fileNames.join(', ')}',
        isUser: true,
        timestamp: DateTime.now(),
        metadata: {
          'fileNames': fileNames,
          'fileCount': fileNames.length,
        },
      );
      _messages.add(userMsg);
      notifyListeners();

      // Send file analysis request to backend
      final response = await _mlRepository.analyzeFile(
  fileName: fileNames.join(', '),
  content: fileContent,
);

      // Extract analysis data
      final analysis = response['analysis'] as Map<String, dynamic>;

      // Create AI response with analysis
      final aiMsg = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: _formatFileAnalysisResponse(analysis, fileNames),
        isUser: false,
        timestamp: DateTime.now(),
        confidence: '0.95',
        metadata: {
          'analysis': analysis,
          'fileNames': fileNames,
          'type': 'file_analysis',
        },
      );
      _messages.add(aiMsg);
      _isConnected = true;
    } catch (e) {
      _error = e.toString();
      _isConnected = false;

      final errorMsg = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: 'Error analyzing files: $e',
        isUser: false,
        timestamp: DateTime.now(),
        confidence: '0.0',
      );
      _messages.add(errorMsg);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Format file analysis response
  String _formatFileAnalysisResponse(
    Map<String, dynamic> analysis,
    List<String> fileNames,
  ) {
    final totalRecords = analysis['totalRecords'] ?? 0;
    final locations = (analysis['locations'] as List?)?.join(', ') ?? 'Unknown';
    final avgPH = (analysis['avgPH'] as num?)?.toStringAsFixed(2) ?? '0.00';
    final avgTurbidity =
        (analysis['avgTurbidity'] as num?)?.toStringAsFixed(2) ?? '0.00';
    final safeCount = analysis['safeCount'] ?? 0;
    final warningCount = analysis['warningCount'] ?? 0;
    final criticalCount = analysis['criticalCount'] ?? 0;

    return '''📊 **Water Quality Analysis Report**

**Files Analyzed:** ${fileNames.join(', ')}
**Total Records:** $totalRecords
**Locations:** $locations

**Key Metrics:**
• Average pH: $avgPH
• Average Turbidity: $avgTurbidity NTU

**Status Distribution:**
✅ Safe: $safeCount records
⚠️ Warning: $warningCount records
❌ Critical: $criticalCount records

**Recommendations:**
${_generateAnalysisRecommendations(double.parse(avgPH), double.parse(avgTurbidity), criticalCount)}''';
  }

  /// Generate recommendations based on analysis
  String _generateAnalysisRecommendations(
    double avgPH,
    double avgTurbidity,
    int criticalCount,
  ) {
    List<String> recs = [];

    if (avgPH < 6.5 || avgPH > 8.5) {
      recs.add('• Adjust pH levels to safe range (6.5-8.5)');
    } else {
      recs.add('• pH levels are within safe range');
    }

    if (avgTurbidity > 5) {
      recs.add('• Increase filtration - turbidity exceeds safe limits');
    } else {
      recs.add('• Turbidity levels are acceptable');
    }

    if (criticalCount > 0) {
      recs.add('• URGENT: Address critical zones immediately');
      recs.add('• Implement emergency treatment protocols');
    } else if (avgTurbidity > 3) {
      recs.add('• Monitor turbidity levels closely');
    }

    return recs.join('\n');
  }

  /// Predict water quality based on parameters
  Future<void> predictWaterQuality(Map<String, dynamic> params) async {
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      // Create water quality data from parameters
      final data = WaterQualityData(
        pH: (params['pH'] as num).toDouble(),
        turbidity: (params['turbidity'] as num).toDouble(),
        dissolved_oxygen: (params['dissolved_oxygen'] as num).toDouble(),
        temperature: (params['temperature'] as num).toDouble(),
        conductivity: (params['conductivity'] as num).toDouble(),
        timestamp: DateTime.now(),
        location: params['location'] as String? ?? 'Unknown',
      );

      // Get prediction from ML repository
      final prediction = await _mlRepository.getWaterQualityPrediction(data);

      // Create and add response message
      final message = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: _formatPredictionResponse(prediction),
        isUser: false,
        timestamp: DateTime.now(),
        confidence: prediction.confidence.toString(),
        metadata: {
          'parameter': prediction.parameter,
          'value': prediction.predictedValue,
          'recommendations': prediction.recommendations,
          'type': 'prediction',
        },
      );
      _messages.add(message);
      _isConnected = true;
    } catch (e) {
      _error = e.toString();
      _isConnected = false;

      final errorMsg = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: 'Error analyzing water quality: $e',
        isUser: false,
        timestamp: DateTime.now(),
        confidence: '0.0',
      );
      _messages.add(errorMsg);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Format prediction response
  String _formatPredictionResponse(WaterQualityPrediction prediction) {
    final statusEmoji = prediction.status == 'Safe'
        ? '✅'
        : prediction.status == 'Warning'
            ? '⚠️'
            : '❌';

    return '''$statusEmoji **Water Quality Analysis**

**Parameter:** ${prediction.parameter}
**Score:** ${prediction.predictedValue.toStringAsFixed(1)}/100
**Status:** ${prediction.status}
**Confidence:** ${(prediction.confidence * 100).toStringAsFixed(1)}%

**Recommendations:**
${prediction.recommendations.map((r) => '• $r').join('\n')}''';
  }

  /// Generate report from chat history
  Future<void> generateReport({
    required String title,
    required String format,
  }) async {
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      // Create report data
      final reportData = {
        'title': title,
        'format': format,
        'messages': _messages
            .map((m) => {
                  'text': m.text,
                  'isUser': m.isUser,
                  'timestamp': m.timestamp.toIso8601String(),
                  'confidence': m.confidence,
                })
            .toList(),
        'totalMessages': _messages.length,
        'generatedAt': DateTime.now().toIso8601String(),
        'summary': _generateReportSummary(),
      };

      // Send to backend for report generation
      await _mlRepository.generateReport(
  title: title,
  format: format,
  messages: _messages
      .map((m) => {
            'text': m.text,
            'isUser': m.isUser,
            'timestamp': m.timestamp.toIso8601String(),
            'confidence': m.confidence,
          })
      .toList(),
);

      print('✅ Report generated: $title ($format)');

      // Add system message about report
      _messages.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text:
              '📄 Report "$title" has been generated successfully in $format format.',
          isUser: false,
          timestamp: DateTime.now(),
          confidence: '1.0',
          metadata: {
            'type': 'report_generated',
            'title': title,
            'format': format,
          },
        ),
      );
    } catch (e) {
      _error = e.toString();
      print('❌ Error generating report: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Generate report summary
  String _generateReportSummary() {
    int userMessages = _messages.where((m) => m.isUser).length;
    int aiMessages = _messages.where((m) => !m.isUser).length;

    return 'Conversation Summary: $userMessages user messages, $aiMessages AI responses. '
        'Topics covered: water quality analysis, file processing, predictions, and recommendations.';
  }

  /// Export chat as CSV
  Future<void> exportAsCSV() async {
    try {
      final header = 'Text,User,Timestamp,Confidence\n';
      final rows = _messages
          .map((m) =>
              '"${m.text.replaceAll('"', '""')}","${m.isUser}","${m.timestamp.toIso8601String()}","${m.confidence ?? 'N/A'}"')
          .join('\n');

      final csv = header + rows;
      print('✅ CSV Export:\n$csv');

      // In production, save to file or download
    } catch (e) {
      print('❌ Error exporting CSV: $e');
    }
  }

  /// Export chat as PDF
  Future<void> exportAsPDF() async {
    try {
      print('🔄 Generating PDF with ${_messages.length} messages...');

      // In production, use pdf package to generate PDF
      final pdfContent = '''=== PureHealth Chat Export ===
Generated: ${DateTime.now().toIso8601String()}
Total Messages: ${_messages.length}

${_messages.map((m) => '${m.isUser ? 'USER' : 'AI'}: ${m.text}').join('\n\n')}''';

      print('✅ PDF ready:\n$pdfContent');
    } catch (e) {
      print('❌ Error exporting PDF: $e');
    }
  }

  /// Clear entire chat history
  void clearChat() {
    _messages.clear();
    _initializeChat();
    notifyListeners();
  }

  /// Get chat statistics
  Map<String, dynamic> getChatStatistics() {
    return {
      'totalMessages': _messages.length,
      'userMessages': _messages.where((m) => m.isUser).length,
      'aiMessages': _messages.where((m) => !m.isUser).length,
      'averageConfidence': _messages
              .where((m) => m.confidence != null)
              .map((m) => double.tryParse(m.confidence ?? '0') ?? 0)
              .fold<double>(0, (a, b) => a + b) /
          (_messages.where((m) => m.confidence != null).length == 0
              ? 1
              : _messages.where((m) => m.confidence != null).length),
    };
  }

  /// Get messages with specific type
  List<ChatMessage> getMessagesByType(String type) {
    return _messages
        .where((m) => m.metadata?['type'] == type)
        .toList();
  }
}
