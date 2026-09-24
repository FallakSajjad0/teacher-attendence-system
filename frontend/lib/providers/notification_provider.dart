import 'package:flutter/foundation.dart';
import '../models/notification.dart';
import '../services/api_service.dart';

class NotificationProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<AppNotification> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;

  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchNotifications({bool unreadOnly = false}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final endpoint = unreadOnly
          ? '/notifications?unreadOnly=true&limit=50'
          : '/notifications?limit=50';

      final response = await _api.get(endpoint);
      if (response.success && response.data != null) {
        _notifications = (response.data['notifications'] as List)
            .map((e) => AppNotification.fromJson(e))
            .toList();
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchUnreadCount() async {
    try {
      final response = await _api.get('/notifications/unread-count');
      if (response.success && response.data != null) {
        _unreadCount = response.data['count'] ?? 0;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final response = await _api.put('/notifications/$notificationId/read', {});
      if (response.success) {
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          await fetchNotifications();
        }
        await fetchUnreadCount();
      }
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    try {
      final response = await _api.put('/notifications/read-all', {});
      if (response.success) {
        await fetchNotifications();
        _unreadCount = 0;
        notifyListeners();
      }
    } catch (_) {}
  }

  void addNotification(AppNotification notification) {
    _notifications.insert(0, notification);
    _unreadCount++;
    notifyListeners();
  }
}