import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _api = ApiService();

  Future<String?> getToken() async {
    return _api.token;
  }

  Future<User?> getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(AppConstants.userKey);
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  Future<void> _storeUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.userKey, jsonEncode(user.toJson()));
  }

  Future<Map<String, dynamic>> login(
    String email,
    String password, {
    String? fcmToken,
  }) async {
    final response = await _api.post('/auth/login', {
      'email': email,
      'password': password,
      if (fcmToken != null) 'fcmToken': fcmToken,
    });

    if (response.success && response.data != null) {
      final data = response.data as Map<String, dynamic>;
      final token = data['token'] as String;
      final user = User.fromJson(data['user'] as Map<String, dynamic>);

      await _api.setToken(token);
      await _storeUser(user);

      return {'success': true, 'user': user, 'token': token};
    }

    return {'success': false, 'message': response.message};
  }

  Future<User?> getProfile() async {
    final response = await _api.get('/auth/me');
    if (response.success && response.data != null) {
      final user = User.fromJson(response.data['user']);
      await _storeUser(user);
      return user;
    }
    return null;
  }

  Future<bool> updateFcmToken(String fcmToken) async {
    final response = await _api.put('/auth/fcm-token', {'fcmToken': fcmToken});
    return response.success;
  }

  Future<void> logout() async {
    await _api.clearToken();
  }
}