import 'package:device/config/app_colors.dart';
import 'package:device/models/notification_models.dart';
import 'package:device/services/notification_service.dart';
import 'package:device/services/firebase_service.dart';
import 'package:device/events/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:device/l10n/app_localizations.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final NotificationService _notificationService = NotificationService();
  final FirebaseService _firebaseService = FirebaseService();
  List<NotificationItem> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();

    EventBus.instance.addListener(
      EventKeys.notificationReceived,
      _onNotificationReceived,
    );

    EventBus.instance.addListener(
      EventKeys.notificationCountChanged,
      _onNotificationCountChanged,
    );
  }

  @override
  void dispose() {
    // Remove event listeners
    EventBus.instance.removeListener(
      EventKeys.notificationReceived,
      _onNotificationReceived,
    );

    EventBus.instance.removeListener(
      EventKeys.notificationCountChanged,
      _onNotificationCountChanged,
    );

    super.dispose();
  }

  void _onNotificationReceived(NotificationItem notification) {
    if (mounted) {
      _loadNotifications();
    }
  }

  void _onNotificationCountChanged(int count) {
    if (mounted) {
      _loadNotifications();
    }
  }

  void _loadNotifications() {
    if (!mounted) return;
    setState(() {
      // Merge notifications from both services
      final localNotifications = _notificationService.notifications;
      final firebaseNotifications = _firebaseService.notifications;

      // Combine and sort by timestamp (most recent first)
      _notifications = [...localNotifications, ...firebaseNotifications]
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    });
  }

  void _markAllAsRead() {
    // Mark all as read in both services
    _notificationService.markAllAsRead();
    _firebaseService.markAllAsRead();
    _loadNotifications();
  }

  void _clearAll() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearAllNotifications),
        content: Text(l10n.clearAllNotificationsConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              // Clear notifications from both services
              _notificationService.clearAllNotifications();
              _firebaseService.clearAllNotifications();
              Navigator.pop(context);
              _loadNotifications();
            },
            child: Text(
              l10n.clearAll,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    final l10n = AppLocalizations.of(context)!;

    if (difference.inMinutes < 1) {
      return l10n.justNow;
    } else if (difference.inHours < 1) {
      return l10n.minutesAgo(difference.inMinutes);
    } else if (difference.inDays < 1) {
      return l10n.hoursAgo(difference.inHours);
    } else if (difference.inDays < 7) {
      return l10n.daysAgo(difference.inDays);
    } else {
      return DateFormat('MMM d, yyyy').format(timestamp);
    }
  }

  IconData _getNotificationIcon(Map<String, dynamic>? payload) {
    if (payload == null) return Icons.notifications;

    if (payload['level'] == 'severe') {
      return Icons.warning_amber_rounded;
    } else if (payload['level'] == 'notice') {
      return Icons.sms;
    }

    return Icons.notifications;
  }

  Color _getNotificationColor(Map<String, dynamic>? payload) {
    if (payload == null) return AppColors.primaryColor;

    if (payload['level'] == 'severe') {
      return Colors.red;
    } else if (payload['level'] == 'notice') {
      return Colors.green;
    }

    return AppColors.primaryColor;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const FaIcon(
            FontAwesomeIcons.chevronLeft,
            color: Colors.black,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.notifications,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_notifications.isNotEmpty)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.black, size: 20),
              onSelected: (value) {
                if (value == 'mark_all_read') {
                  _markAllAsRead();
                } else if (value == 'clear_all') {
                  _clearAll();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'mark_all_read',
                  child: Row(
                    children: [
                      const Icon(Icons.done_all, size: 18),
                      const SizedBox(width: 8),
                      Text(l10n.markAllAsRead),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'clear_all',
                  child: Row(
                    children: [
                      const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                      const SizedBox(width: 8),
                      Text(l10n.clearAll, style: const TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noNotificationsYet,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.youllSeeNotificationsHere,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                final icon = _getNotificationIcon(notification.payload);
                final color = _getNotificationColor(notification.payload);

                return Container(
                  key: ValueKey('notification_${notification.id}'), // Unique key to prevent duplicates
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: notification.isRead
                        ? Colors.white
                        : AppColors.primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: notification.isRead
                          ? Colors.grey[200]!
                          : AppColors.primaryColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: InkWell(
                    onTap: () {
                      // Mark as read in both services (only one will have the ID)
                      _notificationService.markAsRead(notification.id);
                      _firebaseService.markAsRead(notification.id);
                      _loadNotifications();
                      // TODO: Handle navigation based on payload
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Icon
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              icon,
                              color: color,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title
                                Text(
                                  notification.title,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: notification.isRead
                                        ? FontWeight.w500
                                        : FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // Body
                                Text(
                                  notification.body,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Timestamp and red point on right top
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _formatTimestamp(notification.timestamp),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                  if (!notification.isRead) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primaryColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
