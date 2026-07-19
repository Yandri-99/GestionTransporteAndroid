import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_message.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        actions: [
          if (provider.unreadCount > 0)
            TextButton(
              onPressed: () => provider.markAllAsRead(),
              child: const Text('Leer todas'),
            ),
        ],
      ),
      body: _buildBody(provider, theme),
    );
  }

  Widget _buildBody(NotificationProvider provider, ThemeData theme) {
    if (provider.isLoading) return const LoadingIndicator();
    if (provider.error != null) {
      return ErrorMessage(
        message: provider.error!,
        onRetry: () => provider.loadNotifications(),
      );
    }
    if (provider.notifications.isEmpty) {
      return const Center(child: Text('No tienes notificaciones'));
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadNotifications(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.notifications.length,
        itemBuilder: (context, index) {
          final notif = provider.notifications[index];
          final icon = switch (notif.type) {
            'incident' => Icons.report,
            'warning' => Icons.warning_amber,
            _ => Icons.notifications,
          };
          final iconColor = switch (notif.type) {
            'incident' => theme.colorScheme.error,
            'warning' => Colors.orange,
            _ => theme.colorScheme.primary,
          };

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            elevation: notif.isRead ? 0 : 2,
            child: ListTile(
              leading: Icon(icon, color: iconColor),
              title: Text(
                notif.title,
                style: TextStyle(
                  fontWeight: notif.isRead
                      ? FontWeight.normal
                      : FontWeight.bold,
                ),
              ),
              subtitle: Text(notif.message),
              trailing: notif.isRead
                  ? null
                  : Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                    ),
              onTap: () => provider.markAsRead(notif.id),
            ),
          );
        },
      ),
    );
  }
}
