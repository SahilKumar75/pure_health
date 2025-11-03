/// Alert notification model for water quality monitoring
class AlertNotification {
  final String id;
  final String title;
  final String message;
  final AlertSeverity severity;
  final AlertType type;
  final DateTime timestamp;
  final String? location;
  final Map<String, dynamic>? data;
  bool isRead;
  bool isAcknowledged;
  String? acknowledgedBy;
  DateTime? acknowledgedAt;

  AlertNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.severity,
    required this.type,
    required this.timestamp,
    this.location,
    this.data,
    this.isRead = false,
    this.isAcknowledged = false,
    this.acknowledgedBy,
    this.acknowledgedAt,
  });

  AlertNotification copyWith({
    bool? isRead,
    bool? isAcknowledged,
    String? acknowledgedBy,
    DateTime? acknowledgedAt,
  }) {
    return AlertNotification(
      id: id,
      title: title,
      message: message,
      severity: severity,
      type: type,
      timestamp: timestamp,
      location: location,
      data: data,
      isRead: isRead ?? this.isRead,
      isAcknowledged: isAcknowledged ?? this.isAcknowledged,
      acknowledgedBy: acknowledgedBy ?? this.acknowledgedBy,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
    );
  }
}

enum AlertSeverity {
  critical, // Immediate action required
  warning,  // Attention needed
  info,     // Informational only
}

enum AlertType {
  phLevel,
  turbidity,
  dissolvedOxygen,
  temperature,
  conductivity,
  system,
  compliance,
}

extension AlertSeverityExtension on AlertSeverity {
  String get displayName {
    switch (this) {
      case AlertSeverity.critical:
        return 'Critical';
      case AlertSeverity.warning:
        return 'Warning';
      case AlertSeverity.info:
        return 'Info';
    }
  }
}

extension AlertTypeExtension on AlertType {
  String get displayName {
    switch (this) {
      case AlertType.phLevel:
        return 'pH Level';
      case AlertType.turbidity:
        return 'Turbidity';
      case AlertType.dissolvedOxygen:
        return 'Dissolved Oxygen';
      case AlertType.temperature:
        return 'Temperature';
      case AlertType.conductivity:
        return 'Conductivity';
      case AlertType.system:
        return 'System';
      case AlertType.compliance:
        return 'Compliance';
    }
  }

  String get iconName {
    switch (this) {
      case AlertType.phLevel:
        return 'science';
      case AlertType.turbidity:
        return 'water_drop';
      case AlertType.dissolvedOxygen:
        return 'air';
      case AlertType.temperature:
        return 'thermostat';
      case AlertType.conductivity:
        return 'electric_bolt';
      case AlertType.system:
        return 'settings';
      case AlertType.compliance:
        return 'check_circle';
    }
  }
}
