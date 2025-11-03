import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:pure_health/core/services/notification_service.dart';
import 'package:pure_health/core/constants/color_constants.dart';
import 'package:pure_health/core/theme/text_styles.dart';
import 'package:pure_health/shared/widgets/notification_panel.dart';

/// Notification bell icon with badge showing unread count
class NotificationBell extends StatelessWidget {
  final VoidCallback? onTap;

  const NotificationBell({
    Key? key,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationService>(
      builder: (context, notificationService, child) {
        final unreadCount = notificationService.unreadCount;
        final criticalCount = notificationService.unacknowledgedCriticalCount;

        return Stack(
          children: [
            IconButton(
              icon: Icon(
                criticalCount > 0 
                    ? CupertinoIcons.bell_fill
                    : CupertinoIcons.bell,
                color: criticalCount > 0 
                    ? AppColors.error 
                    : AppColors.charcoal,
              ),
              onPressed: onTap ?? () => _showNotificationPanel(context),
            ),
            if (unreadCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: criticalCount > 0 
                        ? AppColors.error 
                        : AppColors.accentPink,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Center(
                    child: Text(
                      unreadCount > 99 ? '99+' : unreadCount.toString(),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void _showNotificationPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.mediumGray.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Notification panel
            const Expanded(
              child: SingleChildScrollView(
                child: NotificationPanel(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
