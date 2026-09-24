import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../services/socket_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final NotificationService _notificationService = NotificationService();
  final SocketService _socketService = SocketService();

  User? _user;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;

  AuthProvider() {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await ApiService().loadToken();
    final storedUser = await _authService.getStoredUser();

    if (storedUser != null) {
      _user = storedUser;
      _isAuthenticated = true;
      notifyListeners();

      // Refresh profile in background
      try {
        final freshUser = await _authService.getProfile();
        if (freshUser != null) {
          _user = freshUser;
          notifyListeners();
        }
      } catch (_) {}

      final token = await _authService.getToken();
      if (token != null) {
        _socketService.connect(token);
      }
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      String? fcmToken;
      try {
        fcmToken = await _notificationService.getFcmToken();
      } catch (_) {}

      final result = await _authService.login(email, password, fcmToken: fcmToken);

      if (result['success'] == true) {
        _user = result['user'] as User;
        _isAuthenticated = true;
        _isLoading = false;

        final token = await _authService.getToken();
        if (token != null) {
          _socketService.connect(token);
        }

        notifyListeners();
        return true;
      } else {
        _error = result['message'] ?? 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Login error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _socketService.disconnect();
    _user = null;
    _isAuthenticated = false;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}