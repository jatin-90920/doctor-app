import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:intl/intl.dart';

enum NotificationType {
  info,
  success,
  warning,
  error,
  reminder,
  appointment,
  treatment,
  patient,
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? data;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.data,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRead,
    Map<String, dynamic>? data,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
    );
  }
}

class NotificationWidget extends StatelessWidget {
  final List<NotificationItem> notifications;
  final Function(NotificationItem)? onNotificationTap;
  final Function(NotificationItem)? onNotificationDismiss;
  final Function()? onMarkAllAsRead;
  final Function()? onClearAll;

  const NotificationWidget({
    super.key,
    required this.notifications,
    this.onNotificationTap,
    this.onNotificationDismiss,
    this.onMarkAllAsRead,
    this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    final unreadCount = notifications.where((n) => !n.isRead).length;

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  MdiIcons.bell,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Notifications',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (unreadCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      unreadCount.toString(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onError,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                if (notifications.isNotEmpty) ...[
                  if (unreadCount > 0)
                    TextButton(
                      onPressed: onMarkAllAsRead,
                      child: const Text('Mark All Read'),
                    ),
                  PopupMenuButton<String>(
                    icon: Icon(MdiIcons.dotsVertical),
                    onSelected: (value) {
                      switch (value) {
                        case 'clear_all':
                          onClearAll?.call();
                          break;
                        case 'mark_all_read':
                          onMarkAllAsRead?.call();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      if (unreadCount > 0)
                        const PopupMenuItem(
                          value: 'mark_all_read',
                          child: Text('Mark All as Read'),
                        ),
                      const PopupMenuItem(
                        value: 'clear_all',
                        child: Text('Clear All'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1),
          if (notifications.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      MdiIcons.bellOff,
                      size: 48,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No notifications',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return NotificationTile(
                  notification: notification,
                  onTap: () => onNotificationTap?.call(notification),
                  onDismiss: () => onNotificationDismiss?.call(notification),
                );
              },
            ),
        ],
      ),
    );
  }
}

class NotificationTile extends StatelessWidget {
  final NotificationItem notification;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const NotificationTile({
    super.key,
    required this.notification,
    this.onTap,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss?.call(),
      background: Container(
        color: Theme.of(context).colorScheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: Icon(
          MdiIcons.delete,
          color: Theme.of(context).colorScheme.onError,
        ),
      ),
      child: ListTile(
        leading: _buildNotificationIcon(context),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              _formatTimestamp(notification.timestamp),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        trailing: notification.isRead
            ? null
            : Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(BuildContext context) {
    IconData iconData;
    Color iconColor;

    switch (notification.type) {
      case NotificationType.info:
        iconData = MdiIcons.information;
        iconColor = Theme.of(context).colorScheme.primary;
        break;
      case NotificationType.success:
        iconData = MdiIcons.checkCircle;
        iconColor = Colors.green;
        break;
      case NotificationType.warning:
        iconData = MdiIcons.alert;
        iconColor = Colors.orange;
        break;
      case NotificationType.error:
        iconData = MdiIcons.alertCircle;
        iconColor = Theme.of(context).colorScheme.error;
        break;
      case NotificationType.reminder:
        iconData = MdiIcons.clockAlert;
        iconColor = Colors.blue;
        break;
      case NotificationType.appointment:
        iconData = MdiIcons.calendar;
        iconColor = Colors.purple;
        break;
      case NotificationType.treatment:
        iconData = MdiIcons.stethoscope;
        iconColor = Colors.teal;
        break;
      case NotificationType.patient:
        iconData = MdiIcons.account;
        iconColor = Colors.indigo;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 20,
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM dd').format(timestamp);
    }
  }
}

class NotificationBadge extends StatelessWidget {
  final int count;
  final Widget child;
  final Color? badgeColor;
  final Color? textColor;

  const NotificationBadge({
    super.key,
    required this.count,
    required this.child,
    this.badgeColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (count > 0)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: badgeColor ?? Theme.of(context).colorScheme.error,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.surface,
                  width: 2,
                ),
              ),
              constraints: const BoxConstraints(
                minWidth: 20,
                minHeight: 20,
              ),
              child: Text(
                count > 99 ? '99+' : count.toString(),
                style: TextStyle(
                  color: textColor ?? Theme.of(context).colorScheme.onError,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

class NotificationService extends ChangeNotifier {
  final List<NotificationItem> _notifications = [];

  List<NotificationItem> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void addNotification(NotificationItem notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    }
    notifyListeners();
  }

  void removeNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    notifyListeners();
  }

  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }

  // Helper methods for creating common notifications
  void notifyPatientAdded(String patientName) {
    addNotification(NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'New Patient Added',
      message: 'Patient $patientName has been successfully registered.',
      type: NotificationType.patient,
      timestamp: DateTime.now(),
    ));
  }

  void notifyTreatmentCompleted(String patientName) {
    addNotification(NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Treatment Completed',
      message: 'Treatment for $patientName has been recorded.',
      type: NotificationType.treatment,
      timestamp: DateTime.now(),
    ));
  }

  void notifyAppointmentReminder(String patientName, DateTime appointmentTime) {
    addNotification(NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Appointment Reminder',
      message: 'Upcoming appointment with $patientName at ${DateFormat('HH:mm').format(appointmentTime)}.',
      type: NotificationType.reminder,
      timestamp: DateTime.now(),
    ));
  }

  void notifyError(String title, String message) {
    addNotification(NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      type: NotificationType.error,
      timestamp: DateTime.now(),
    ));
  }

  void notifySuccess(String title, String message) {
    addNotification(NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      type: NotificationType.success,
      timestamp: DateTime.now(),
    ));
  }
}

