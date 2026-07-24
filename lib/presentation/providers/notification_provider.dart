import 'package:flutter/material.dart';
import '../../data/remote/api/dio_client.dart';

class NotificationModel {
  final int id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final String createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    this.type = 'system',
    this.isRead = false,
    this.createdAt = '',
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'system',
      isRead: json['is_read'] ?? false,
      createdAt: json['created_at'] ?? '',
    );
  }
}

class NotificationProvider extends ChangeNotifier {
  final DioClient _api = DioClient();

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
      final response = await _api.get('/api/notifications/notifications/');
      final data = response.data;
      final items = (data is Map ? (data['results'] ?? data['value'] ?? []) : data) as List;
      _notifications = items.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> markAsRead(int id) async {
    await _api.patch('/api/notifications/notifications/$id/read/');
    await loadNotifications();
  }

  Future<void> markAllAsRead() async {
    await _api.put('/api/notifications/notifications/read_all/');
    await loadNotifications();
  }

  Future<void> deleteNotification(int id) async {
    try {
      await _api.delete('/api/notifications/notifications/$id/');
      _notifications.removeWhere((n) => n.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  Future<void> deleteAllNotifications() async {
    try {
      for (final n in List.from(_notifications)) {
        await _api.delete('/api/notifications/notifications/${n.id}/');
      }
      _notifications.clear();
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }
}
