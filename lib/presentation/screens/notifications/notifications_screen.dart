import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_message.dart';
import '../../../theme/app_colors.dart';

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
          if (provider.notifications.isNotEmpty) ...[
            if (provider.unreadCount > 0)
              TextButton(
                onPressed: () => provider.markAllAsRead(),
                child: const Text('Leer todas'),
              ),
            TextButton(
              onPressed: () => _confirmDeleteAll(context, provider),
              child: const Text('Borrar todas', style: TextStyle(color: AppColors.error)),
            ),
          ],
        ],
      ),
      body: _buildBody(provider, theme),
    );
  }

  void _confirmDeleteAll(BuildContext context, NotificationProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Borrar todas'),
        content: const Text('¿Eliminar todas las notificaciones?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              provider.deleteAllNotifications();
            },
            child: const Text('Borrar'),
          ),
        ],
      ),
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
                  fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold,
                ),
              ),
              subtitle: Text(notif.message),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!notif.isRead)
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    color: AppColors.error,
                    onPressed: () => provider.deleteNotification(notif.id),
                  ),
                ],
              ),
              onTap: () => provider.markAsRead(notif.id),
            ),
          );
        },
      ),
    );
  }
}
