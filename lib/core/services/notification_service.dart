import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/alert_notification.dart';

/// Service for managing alert notifications and monitoring thresholds
class NotificationService extends ChangeNotifier {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final List<AlertNotification> _notifications = [];
  final StreamController<AlertNotification> _notificationStream = 
      StreamController<AlertNotification>.broadcast();

  // Thresholds (WHO/EPA standards)
  final Map<String, Map<String, double>> _thresholds = {
    'pH': {'min': 6.5, 'max': 8.5},
    'turbidity': {'max': 5.0}, // NTU
    'dissolvedOxygen': {'min': 5.0}, // mg/L
    'temperature': {'max': 30.0}, // °C
    'conductivity': {'max': 800.0}, // μS/cm
  };

  List<AlertNotification> get notifications => List.unmodifiable(_notifications);
  Stream<AlertNotification> get notificationStream => _notificationStream.stream;
  
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  int get unacknowledgedCriticalCount => _notifications
      .where((n) => n.severity == AlertSeverity.critical && !n.isAcknowledged)
      .length;

  /// Check water quality parameters and generate alerts
  Future<void> checkWaterQualityParameters(Map<String, dynamic> data) async {
    final location = data['location'] ?? 'Unknown';
    final timestamp = DateTime.now();

    // Check pH
    if (data['pH'] != null) {
      final pH = (data['pH'] as num).toDouble();
      if (pH < _thresholds['pH']!['min']! || pH > _thresholds['pH']!['max']!) {
        _addNotification(AlertNotification(
          id: '${DateTime.now().millisecondsSinceEpoch}_ph',
          title: 'pH Level ${pH < _thresholds['pH']!['min']! ? 'Too Low' : 'Too High'}',
          message: 'pH level is $pH at $location. Safe range: ${_thresholds['pH']!['min']}-${_thresholds['pH']!['max']}',
          severity: _getSeverity(pH, _thresholds['pH']!['min']!, _thresholds['pH']!['max']!),
          type: AlertType.phLevel,
          timestamp: timestamp,
          location: location,
          data: {'pH': pH},
        ));
      }
    }

    // Check turbidity
    if (data['turbidity'] != null) {
      final turbidity = (data['turbidity'] as num).toDouble();
      if (turbidity > _thresholds['turbidity']!['max']!) {
        _addNotification(AlertNotification(
          id: '${DateTime.now().millisecondsSinceEpoch}_turbidity',
          title: 'High Turbidity Detected',
          message: 'Turbidity is $turbidity NTU at $location. Maximum: ${_thresholds['turbidity']!['max']} NTU',
          severity: turbidity > _thresholds['turbidity']!['max']! * 1.5 
              ? AlertSeverity.critical 
              : AlertSeverity.warning,
          type: AlertType.turbidity,
          timestamp: timestamp,
          location: location,
          data: {'turbidity': turbidity},
        ));
      }
    }

    // Check dissolved oxygen
    if (data['dissolvedOxygen'] != null || data['dissolved_oxygen'] != null) {
      final dissolvedOxygen = ((data['dissolvedOxygen'] ?? data['dissolved_oxygen']) as num).toDouble();
      if (dissolvedOxygen < _thresholds['dissolvedOxygen']!['min']!) {
        _addNotification(AlertNotification(
          id: '${DateTime.now().millisecondsSinceEpoch}_do',
          title: 'Low Dissolved Oxygen',
          message: 'DO is $dissolvedOxygen mg/L at $location. Minimum: ${_thresholds['dissolvedOxygen']!['min']} mg/L',
          severity: dissolvedOxygen < _thresholds['dissolvedOxygen']!['min']! * 0.7 
              ? AlertSeverity.critical 
              : AlertSeverity.warning,
          type: AlertType.dissolvedOxygen,
          timestamp: timestamp,
          location: location,
          data: {'dissolvedOxygen': dissolvedOxygen},
        ));
      }
    }

    // Check temperature
    if (data['temperature'] != null) {
      final temperature = (data['temperature'] as num).toDouble();
      if (temperature > _thresholds['temperature']!['max']!) {
        _addNotification(AlertNotification(
          id: '${DateTime.now().millisecondsSinceEpoch}_temp',
          title: 'High Temperature',
          message: 'Temperature is $temperature°C at $location. Maximum: ${_thresholds['temperature']!['max']}°C',
          severity: AlertSeverity.warning,
          type: AlertType.temperature,
          timestamp: timestamp,
          location: location,
          data: {'temperature': temperature},
        ));
      }
    }

    notifyListeners();
  }

  AlertSeverity _getSeverity(double value, double min, double max) {
    final deviation = ((value - min).abs() / (max - min)) * 100;
    if (deviation > 30) return AlertSeverity.critical;
    if (deviation > 15) return AlertSeverity.warning;
    return AlertSeverity.info;
  }

  void _addNotification(AlertNotification notification) {
    _notifications.insert(0, notification); // Add to beginning
    _notificationStream.add(notification);
    notifyListeners();
  }

  /// Add a system notification
  void addSystemNotification({
    required String title,
    required String message,
    AlertSeverity severity = AlertSeverity.info,
  }) {
    _addNotification(AlertNotification(
      id: '${DateTime.now().millisecondsSinceEpoch}_system',
      title: title,
      message: message,
      severity: severity,
      type: AlertType.system,
      timestamp: DateTime.now(),
    ));
  }

  /// Mark notification as read
  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  /// Mark all notifications as read
  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    }
    notifyListeners();
  }

  /// Acknowledge critical notification
  void acknowledgeNotification(String notificationId, String acknowledgedBy) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(
        isAcknowledged: true,
        acknowledgedBy: acknowledgedBy,
        acknowledgedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  /// Clear all notifications
  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }

  /// Clear notifications older than specified days
  void clearOlderThan(int days) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    _notifications.removeWhere((n) => n.timestamp.isBefore(cutoffDate));
    notifyListeners();
  }

  /// Get notifications by severity
  List<AlertNotification> getNotificationsBySeverity(AlertSeverity severity) {
    return _notifications.where((n) => n.severity == severity).toList();
  }

  /// Get unacknowledged critical notifications
  List<AlertNotification> getUnacknowledgedCritical() {
    return _notifications
        .where((n) => n.severity == AlertSeverity.critical && !n.isAcknowledged)
        .toList();
  }

  @override
  void dispose() {
    _notificationStream.close();
    super.dispose();
  }
}
