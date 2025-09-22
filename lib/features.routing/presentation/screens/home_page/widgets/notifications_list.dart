import 'package:flutter/material.dart';
import 'package:flutter_valhalla/features/routing/presentation/utils/date_formatter.dart';

class NotificationsList extends StatefulWidget {
  final String userId;
  final dynamic db;
  const NotificationsList({super.key, required this.userId, required this.db});

  @override
  State<NotificationsList> createState() => _NotificationsListState();
}

class _NotificationsListState extends State<NotificationsList> {
  late List<Map<String, dynamic>> _notifications;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    _notifications = List<Map<String, dynamic>>.from(widget.db.getNotificationsForUser(widget.userId));
    _notifications.sort((a, b) {
      final dateA = DateTime.tryParse(a['createdAt'] ?? '') ?? DateTime(2000);
      final dateB = DateTime.tryParse(b['createdAt'] ?? '') ?? DateTime(2000);
      return dateB.compareTo(dateA);
    });
  }

  void _markAsRead(String notifId) {
    widget.db.markNotificationAsRead(notifId);
    setState(() {
      _loadNotifications();
    });
  }

  void _deleteNotification(String notifId) {
    widget.db.deleteNotification(notifId);
    setState(() {
      _loadNotifications();
    });
  }

  void _clearAllNotifications() {
    widget.db.clearNotificationsForUser(widget.userId);
    setState(() {
      _loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: _notifications.isEmpty ? null : _clearAllNotifications,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Очистить'),
              ),
            ],
          ),
        ),
        Expanded(
          child: _notifications.isEmpty
              ? const Center(child: Text('Нет уведомлений'))
              : ListView.builder(
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notif = _notifications[index];
                    return Dismissible(
                      key: Key(notif['id']),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        color: Colors.red,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) {
                        _deleteNotification(notif['id']);
                      },
                      
                      child: GestureDetector(
                        onTap: () {
                          if (!notif['isRead']) {
                            _markAsRead(notif['id']);
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                          decoration: BoxDecoration(
                            color: notif['isRead'] ? Colors.grey.shade100 : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
                            title: Text(
                              notif['title'] ?? '',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: notif['isRead'] ? Colors.black87 : Colors.black,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notif['body'] ?? '',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  formatDate(notif['createdAt']),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                            trailing: notif['isRead']
                                ? const Icon(Icons.done, color: Colors.green, size: 24)
                                : const Icon(Icons.mark_email_unread, color: Colors.blue, size: 24),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
