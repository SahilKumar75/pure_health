import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:pure_health/core/models/alert_notification.dart';
import 'package:pure_health/core/services/notification_service.dart';
import 'package:pure_health/core/constants/color_constants.dart';
import 'package:pure_health/core/theme/text_styles.dart';
import 'package:pure_health/core/theme/government_theme.dart';

/// Notification panel widget showing alerts and warnings
class NotificationPanel extends StatelessWidget {
  final bool showOnlyUnread;
  final int? maxItems;

  const NotificationPanel({
    Key? key,
    this.showOnlyUnread = false,
    this.maxItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationService>(
      builder: (context, notificationService, child) {
        var notifications = showOnlyUnread
            ? notificationService.notifications.where((n) => !n.isRead).toList()
            : notificationService.notifications;

        if (maxItems != null && notifications.length > maxItems!) {
          notifications = notifications.sublist(0, maxItems!);
        }

        if (notifications.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.bell,
                        color: AppColors.accentPink,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Alerts & Notifications',
                        style: AppTextStyles.heading4.copyWith(
                          color: AppColors.charcoal,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  if (notifications.isNotEmpty)
                    TextButton(
                      onPressed: () => notificationService.markAllAsRead(),
                      child: Text(
                        'Mark all read',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.accentPink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Notification list
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: AppColors.darkCream.withOpacity(0.2),
              ),
              itemBuilder: (context, index) {
                return _buildNotificationItem(
                  context,
                  notifications[index],
                  notificationService,
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            CupertinoIcons.check_mark_circled,
            size: 48,
            color: AppColors.success,
          ),
          const SizedBox(height: 16),
          Text(
            'No new alerts',
            style: AppTextStyles.heading4.copyWith(
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'All water quality parameters are within safe limits',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.mediumGray,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context,
    AlertNotification notification,
    NotificationService service,
  ) {
    final severityColor = _getSeverityColor(notification.severity);
    
    return InkWell(
      onTap: () {
        if (!notification.isRead) {
          service.markAsRead(notification.id);
        }
        _showNotificationDetails(context, notification, service);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        color: notification.isRead 
            ? Colors.transparent 
            : severityColor.withOpacity(0.05),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: severityColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  _getIconForType(notification.type),
                  size: 20,
                  color: severityColor,
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.charcoal,
                            fontWeight: notification.isRead 
                                ? FontWeight.w500 
                                : FontWeight.w700,
                          ),
                        ),
                      ),
                      _buildSeverityBadge(notification.severity),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.mediumGray,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (notification.location != null) ...[
                        Icon(
                          CupertinoIcons.location_solid,
                          size: 12,
                          color: AppColors.mediumGray,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          notification.location!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.mediumGray,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Icon(
                        CupertinoIcons.time,
                        size: 12,
                        color: AppColors.mediumGray,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getTimeAgo(notification.timestamp),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.mediumGray,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Unread indicator
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: severityColor,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeverityBadge(AlertSeverity severity) {
    final color = _getSeverityColor(severity);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        severity.displayName.toUpperCase(),
        style: AppTextStyles.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 10,
        ),
      ),
    );
  }

  Color _getSeverityColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return AppColors.error;
      case AlertSeverity.warning:
        return AppColors.warning;
      case AlertSeverity.info:
        return GovernmentTheme.governmentBlue;
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _showNotificationDetails(
    BuildContext context,
    AlertNotification notification,
    NotificationService service,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _getIconForType(notification.type),
              color: _getSeverityColor(notification.severity),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                notification.title,
                style: AppTextStyles.heading4,
              ),
            ),
            _buildSeverityBadge(notification.severity),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.message,
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 16),
            if (notification.location != null)
              _buildDetailRow('Location', notification.location!),
            _buildDetailRow('Time', notification.timestamp.toString()),
            _buildDetailRow('Type', notification.type.displayName),
            if (notification.isAcknowledged) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Acknowledged',
                      style: AppTextStyles.buttonSmall.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'By ${notification.acknowledgedBy} at ${notification.acknowledgedAt}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.mediumGray,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (notification.severity == AlertSeverity.critical && 
              !notification.isAcknowledged)
            TextButton(
              onPressed: () {
                service.acknowledgeNotification(
                  notification.id,
                  'Government Officer', // Replace with actual user
                );
                Navigator.of(context).pop();
              },
              child: const Text('Acknowledge'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.mediumGray,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.charcoal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(AlertType type) {
    switch (type) {
      case AlertType.phLevel:
        return Icons.science_outlined;
      case AlertType.turbidity:
        return Icons.water_drop_outlined;
      case AlertType.dissolvedOxygen:
        return Icons.air;
      case AlertType.temperature:
        return Icons.thermostat_outlined;
      case AlertType.conductivity:
        return Icons.electric_bolt_outlined;
      case AlertType.system:
        return Icons.settings_outlined;
      case AlertType.compliance:
        return Icons.check_circle_outline;
    }
  }
}
