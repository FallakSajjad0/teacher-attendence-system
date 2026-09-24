import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../utils/constants.dart';

class ApiResponse {
  final bool success;
  final String message;
  final dynamic data;
  final int statusCode;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    required this.statusCode,
  });
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;

  String? get token => _token;

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(AppConstants.tokenKey);
  }

  Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, token);
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userKey);
  }

  Map<String, String> get _headers {
    if (_token == null || _token!.isEmpty) {
      return ApiConfig.headers;
    }
    return ApiConfig.authHeaders(_token!);
  }

  Future<ApiResponse> _handleResponse(http.Response response) async {
    try {
      final body = jsonDecode(response.body);
      return ApiResponse(
        success: body['success'] ?? false,
        message: body['message'] ?? 'Request completed',
        data: body['data'],
        statusCode: response.statusCode,
      );
    } catch (_) {
      return ApiResponse(
        success: false,
        message: 'Failed to parse server response',
        statusCode: response.statusCode,
      );
    }
  }

  Future<ApiResponse> get(String endpoint) async {
    try {
      final response = await http
          .get(Uri.parse('${ApiConfig.baseUrl}$endpoint'), headers: _headers)
          .timeout(ApiConfig.timeout);
      return _handleResponse(response);
    } on SocketException {
      return ApiResponse(success: false, message: 'No internet connection', statusCode: 0);
    } catch (e) {
      return ApiResponse(success: false, message: 'Request failed: $e', statusCode: 0);
    }
  }

  Future<ApiResponse> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}$endpoint'),
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(ApiConfig.timeout);
      return _handleResponse(response);
    } on SocketException {
      return ApiResponse(success: false, message: 'No internet connection', statusCode: 0);
    } catch (e) {
      return ApiResponse(success: false, message: 'Request failed: $e', statusCode: 0);
    }
  }

  Future<ApiResponse> put(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http
          .put(
            Uri.parse('${ApiConfig.baseUrl}$endpoint'),
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(ApiConfig.timeout);
      return _handleResponse(response);
    } on SocketException {
      return ApiResponse(success: false, message: 'No internet connection', statusCode: 0);
    } catch (e) {
      return ApiResponse(success: false, message: 'Request failed: $e', statusCode: 0);
    }
  }

  Future<ApiResponse> delete(String endpoint) async {
    try {
      final response = await http
          .delete(Uri.parse('${ApiConfig.baseUrl}$endpoint'), headers: _headers)
          .timeout(ApiConfig.timeout);
      return _handleResponse(response);
    } on SocketException {
      return ApiResponse(success: false, message: 'No internet connection', statusCode: 0);
    } catch (e) {
      return ApiResponse(success: false, message: 'Request failed: $e', statusCode: 0);
    }
  }

  Future<ApiResponse> uploadFile(
    String endpoint,
    File file, {
    Map<String, String>? fields,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
      );
      request.headers.addAll({
        if (_token != null) 'Authorization': 'Bearer $_token',
      });
      if (fields != null) request.fields.addAll(fields);
      request.files.add(await http.MultipartFile.fromPath('photo', file.path));

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
      );
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } on SocketException {
      return ApiResponse(success: false, message: 'No internet connection', statusCode: 0);
    } catch (e) {
      return ApiResponse(success: false, message: 'Upload failed: $e', statusCode: 0);
    }
  }
}