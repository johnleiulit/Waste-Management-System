import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../services/api_services.dart';

class DashboardProvider extends ChangeNotifier {
  final _api = ApiService();
  bool _loading = false;
  Map<String, dynamic>? _stats;
  String? _error;

  bool get isLoading => _loading;
  Map<String, dynamic>? get stats => _stats;
  String? get error => _error;

  Future<void> fetchStats() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await _api.get('/api/reports/dashboard');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _stats = data['data'];
      } else {
        _error = 'Failed to load stats';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}