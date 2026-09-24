import 'package:flutter/foundation.dart';
import '../models/class_model.dart';
import '../services/api_service.dart';

class ClassProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<ClassModel> _classes = [];
  List<ClassModel> _todayClasses = [];
  bool _isLoading = false;
  String? _error;

  List<ClassModel> get classes => _classes;
  List<ClassModel> get todayClasses => _todayClasses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchClasses({String? teacherId, bool refresh = false}) async {
    if (_isLoading && !refresh) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final endpoint = teacherId != null
          ? '/classes?teacherId=$teacherId&limit=100'
          : '/classes?limit=100';

      final response = await _api.get(endpoint);

      if (response.success && response.data != null) {
        final list = (response.data['classes'] as List)
            .map((e) => ClassModel.fromJson(e))
            .toList();
        _classes = list;
      } else {
        _error = response.message;
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchTodayClasses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.get('/classes/today');

      if (response.success && response.data != null) {
        _todayClasses = (response.data['classes'] as List)
            .map((e) => ClassModel.fromJson(e))
            .toList();
      } else {
        _error = response.message;
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<ClassModel?> getClassById(String id) async {
    try {
      final response = await _api.get('/classes/$id');
      if (response.success && response.data != null) {
        return ClassModel.fromJson(response.data['class']);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> createClass(Map<String, dynamic> data) async {
    try {
      final response = await _api.post('/classes', data);
      if (response.success) {
        await fetchClasses(refresh: true);
        return true;
      }
      _error = response.message;
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<bool> updateClass(String id, Map<String, dynamic> data) async {
    try {
      final response = await _api.put('/classes/$id', data);
      if (response.success) {
        await fetchClasses(refresh: true);
        return true;
      }
      _error = response.message;
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }
}