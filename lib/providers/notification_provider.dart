import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/transport_service.dart';

class NotificationProvider extends ChangeNotifier {
  final TransportService _service = TransportService();

  bool _isLoading = false;
  List<NotificationModel> _notifications = [];
  String? _error;

  bool get isLoading => _isLoading;
  List<NotificationModel> get notifications => _notifications;
  String? get error => _error;
  int get unreadCount =>
      _notifications.where((n) => !n.isRead).length;

  Future<void> loadNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notifications = await _service.getNotifications();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> markAsRead(int id) async {
    await _service.markNotificationAsRead(id);
    await loadNotifications();
  }

  Future<void> markAllAsRead() async {
    await _service.markAllNotificationsAsRead();
    await loadNotifications();
  }
}
