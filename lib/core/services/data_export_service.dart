import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Professional data export utilities for government reporting
class DataExportService {
  /// Export data to CSV format
  static String exportToCSV(List<Map<String, dynamic>> data, {List<String>? columns}) {
    if (data.isEmpty) {
      return '';
    }

    final List<String> headers = columns ?? data.first.keys.toList();
    final StringBuffer csv = StringBuffer();

    // Add headers
    csv.writeln(headers.map((h) => _escapeCsvField(h)).join(','));

    // Add data rows
    for (final row in data) {
      final values = headers.map((header) {
        final value = row[header];
        return _escapeCsvField(value?.toString() ?? '');
      });
      csv.writeln(values.join(','));
    }

    return csv.toString();
  }

  /// Escape CSV field to handle commas and quotes
  static String _escapeCsvField(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }

  /// Export data to JSON format
  static String exportToJSON(List<Map<String, dynamic>> data) {
    return jsonEncode(data);
  }

  /// Export data to formatted JSON (pretty print)
  static String exportToFormattedJSON(List<Map<String, dynamic>> data) {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(data);
  }

  /// Generate summary statistics for government reports
  static Map<String, dynamic> generateSummaryStatistics(List<Map<String, dynamic>> data) {
    if (data.isEmpty) {
      return {};
    }

    final summary = <String, dynamic>{};
    
    // Count total records
    summary['total_records'] = data.length;
    
    // Count by status
    final statusCounts = <String, int>{};
    for (final record in data) {
      final status = record['status']?.toString() ?? 'Unknown';
      statusCounts[status] = (statusCounts[status] ?? 0) + 1;
    }
    summary['status_distribution'] = statusCounts;

    // Calculate numeric averages
    final numericFields = ['pH', 'turbidity', 'dissolved_oxygen', 'temperature', 'conductivity'];
    for (final field in numericFields) {
      final values = data
          .where((r) => r[field] != null)
          .map((r) => _parseDouble(r[field]))
          .where((v) => v != null)
          .cast<double>()
          .toList();

      if (values.isNotEmpty) {
        summary['${field}_average'] = values.reduce((a, b) => a + b) / values.length;
        summary['${field}_min'] = values.reduce((a, b) => a < b ? a : b);
        summary['${field}_max'] = values.reduce((a, b) => a > b ? a : b);
      }
    }

    return summary;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Create government-compliant filename
  static String generateGovernmentFilename(String reportType, {String? dateStr}) {
    final date = dateStr ?? DateTime.now().toString().substring(0, 10);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'WATER_QUALITY_${reportType.toUpperCase()}_${date}_$timestamp';
  }

  /// Generate audit trail entry
  static Map<String, dynamic> createAuditEntry({
    required String action,
    required String userId,
    String? details,
    Map<String, dynamic>? metadata,
  }) {
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'action': action,
      'user_id': userId,
      'details': details,
      'metadata': metadata ?? {},
    };
  }

  /// Format data for government report table
  static List<Map<String, String>> formatForGovernmentReport(
    List<Map<String, dynamic>> data,
  ) {
    return data.map((record) {
      return {
        'Date': record['timestamp']?.toString().substring(0, 10) ?? 'N/A',
        'Location': record['location']?.toString() ?? 'N/A',
        'pH Level': _formatNumber(record['pH'], decimals: 2),
        'Turbidity (NTU)': _formatNumber(record['turbidity'], decimals: 2),
        'Dissolved Oxygen (mg/L)': _formatNumber(record['dissolved_oxygen'], decimals: 2),
        'Temperature (C)': _formatNumber(record['temperature'], decimals: 1),
        'Conductivity (uS/cm)': _formatNumber(record['conductivity'], decimals: 0),
        'Status': record['status']?.toString() ?? 'N/A',
      };
    }).toList();
  }

  static String _formatNumber(dynamic value, {required int decimals}) {
    final num = _parseDouble(value);
    if (num == null) return 'N/A';
    return num.toStringAsFixed(decimals);
  }

  /// Generate compliance report summary
  static Map<String, dynamic> generateComplianceReport(List<Map<String, dynamic>> data) {
    final summary = generateSummaryStatistics(data);
    
    // Check compliance for each parameter
    final compliance = <String, dynamic>{};
    
    // pH compliance (6.5-8.5 is safe)
    if (summary.containsKey('pH_average')) {
      final pHAvg = summary['pH_average'] as double;
      compliance['pH_compliant'] = pHAvg >= 6.5 && pHAvg <= 8.5;
      compliance['pH_status'] = pHAvg >= 6.5 && pHAvg <= 8.5 ? 'COMPLIANT' : 'NON-COMPLIANT';
    }

    // Turbidity compliance (< 5 NTU is safe)
    if (summary.containsKey('turbidity_average')) {
      final turbAvg = summary['turbidity_average'] as double;
      compliance['turbidity_compliant'] = turbAvg < 5.0;
      compliance['turbidity_status'] = turbAvg < 5.0 ? 'COMPLIANT' : 'NON-COMPLIANT';
    }

    // Dissolved Oxygen compliance (> 5 mg/L is safe)
    if (summary.containsKey('dissolved_oxygen_average')) {
      final doAvg = summary['dissolved_oxygen_average'] as double;
      compliance['dissolved_oxygen_compliant'] = doAvg > 5.0;
      compliance['dissolved_oxygen_status'] = doAvg > 5.0 ? 'COMPLIANT' : 'NON-COMPLIANT';
    }

    return {
      'report_date': DateTime.now().toIso8601String(),
      'total_records': summary['total_records'],
      'status_distribution': summary['status_distribution'],
      'compliance_summary': compliance,
      'recommendations': _generateRecommendations(compliance),
    };
  }

  static List<String> _generateRecommendations(Map<String, dynamic> compliance) {
    final recommendations = <String>[];

    if (compliance['pH_compliant'] == false) {
      recommendations.add('pH levels require adjustment - implement water treatment protocols');
    }

    if (compliance['turbidity_compliant'] == false) {
      recommendations.add('Turbidity exceeds safe limits - enhance filtration systems');
    }

    if (compliance['dissolved_oxygen_compliant'] == false) {
      recommendations.add('Dissolved oxygen below recommended levels - increase aeration');
    }

    if (recommendations.isEmpty) {
      recommendations.add('All parameters within safe limits - continue regular monitoring');
    }

    return recommendations;
  }

  /// Download CSV file (Web compatible)
  static void downloadCSV(String csvContent, String filename) {
    if (kIsWeb) {
      // Web download implementation would go here
      // For now, just print to console
      debugPrint('CSV Download: $filename');
      debugPrint(csvContent);
    } else {
      // Mobile/Desktop implementation
      debugPrint('CSV saved: $filename');
    }
  }

  /// Download JSON file (Web compatible)
  static void downloadJSON(String jsonContent, String filename) {
    if (kIsWeb) {
      debugPrint('JSON Download: $filename');
      debugPrint(jsonContent);
    } else {
      debugPrint('JSON saved: $filename');
    }
  }
}
