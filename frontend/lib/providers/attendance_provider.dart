import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/attendance.dart';
import '../services/api_service.dart';

class AttendanceProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<Attendance> _myAttendance = [];
  List<Attendance> _pendingVerifications = [];
  Map<String, dynamic>? _dashboardStats;
  bool _isLoading = false;
  String? _error;
  Attendance? _currentAttendance;

  List<Attendance> get myAttendance => _myAttendance;
  List<Attendance> get pendingVerifications => _pendingVerifications;
  Map<String, dynamic>? get dashboardStats => _dashboardStats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Attendance? get currentAttendance => _currentAttendance;

  Future<Map<String, dynamic>> respondAvailability(
    String attendanceId,
    bool isAvailable,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.post('/attendance/availability', {
        'attendanceId': attendanceId,
        'isAvailable': isAvailable,
      });

      _isLoading = false;
      notifyListeners();

      return {
        'success': response.success,
        'message': response.message,
        'data': response.data,
      };
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': _error};
    }
  }

  Future<Map<String, dynamic>> confirmArrival({
    required String attendanceId,
    required double latitude,
    required double longitude,
    double? accuracy,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.post('/attendance/arrival', {
        'attendanceId': attendanceId,
        'latitude': latitude,
        'longitude': longitude,
        if (accuracy != null) 'accuracy': accuracy,
      });

      if (response.success && response.data != null) {
        _currentAttendance = Attendance.fromJson(response.data['attendance']);
      }

      _isLoading = false;
      notifyListeners();

      return {
        'success': response.success,
        'message': response.message,
        'data': response.data,
      };
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': _error};
    }
  }

  Future<Map<String, dynamic>> submitEvidence({
    required String attendanceId,
    required File photo,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.uploadFile(
        '/attendance/evidence',
        photo,
        fields: {'attendanceId': attendanceId},
      );

      _isLoading = false;
      notifyListeners();

      return {
        'success': response.success,
        'message': response.message,
        'data': response.data,
      };
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': _error};
    }
  }

  Future<void> fetchMyAttendance() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _api.get('/attendance/my?limit=50');
      if (response.success && response.data != null) {
        _myAttendance = (response.data['records'] as List)
            .map((e) => Attendance.fromJson(e))
            .toList();
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchPendingVerifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _api.get('/attendance/pending-verifications');
      if (response.success && response.data != null) {
        _pendingVerifications = (response.data['records'] as List)
            .map((e) => Attendance.fromJson(e))
            .toList();
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> verifyAttendance({
    required String attendanceId,
    required String verificationStatus,
    String? notes,
  }) async {
    try {
      final response = await _api.post('/attendance/verify', {
        'attendanceId': attendanceId,
        'verificationStatus': verificationStatus,
        if (notes != null) 'notes': notes,
      });

      if (response.success) {
        await fetchPendingVerifications();
        return true;
      }
      _error = response.message;
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<void> fetchDashboardStats() async {
    try {
      final response = await _api.get('/attendance/dashboard/stats');
      if (response.success && response.data != null) {
        _dashboardStats = response.data as Map<String, dynamic>;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<List<Attendance>> getAttendanceByClass(String classId) async {
    try {
      final response = await _api.get('/attendance/class/$classId');
      if (response.success && response.data != null) {
        return (response.data['records'] as List)
            .map((e) => Attendance.fromJson(e))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}