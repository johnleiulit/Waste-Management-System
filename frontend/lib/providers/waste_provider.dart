import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../services/api_services.dart';

class WasteProvider extends ChangeNotifier {
  final _api = ApiService();

  bool _loading = false;
  String? _error;
  List<Map<String, dynamic>> _logs = [];

  int _totalLogs = 0;
  int _currentPage = 1;

  // Getters
  bool get isLoading => _loading;
  String? get error => _error;
  List<Map<String, dynamic>> get logs => _logs;
  int get totalLogs => _totalLogs;
  int get currentPage => _currentPage;

  // -------------------------------
  // Fetch MY Logs
  // -------------------------------
  Future<void> fetchMyLogs() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _api.get('/api/waste');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _logs = List<Map<String, dynamic>>.from(data['data']['logs'] ?? []);
      } else {
        _error = 'Failed to load logs';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // -------------------------------
  // Create Log
  // -------------------------------
  Future<bool> createLog({
    required String wasteType,
    required String category,
    required double amount,
    DateTime? dateLogged,
  }) async {
    try {
      final res = await _api.post(
        '/api/waste',
        body: {
          'wasteType': wasteType,
          'category': category,
          'amount': amount,
          if (dateLogged != null) 'dateLogged': dateLogged.toIso8601String(),
        },
      );

      if (res.statusCode == 201) {
        await fetchMyLogs(); // Refresh list
        return true;
      }

      final data = jsonDecode(res.body);
      _error = data['message'] ?? 'Failed to create log';
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // -------------------------------
  // Fetch ALL Logs (Admin)
  // -------------------------------
  Future<void> fetchAllLogs({
    int page = 1,
    int limit = 10,
    String? category,
    String? wasteType,
    String? userId,
    String? from,
    String? to,
    String? searchQuery,
  }) async {
    _loading = true;
    _error = null;
    _currentPage = page;
    notifyListeners();

    try {
      final query = <String, dynamic>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (category != null && category.isNotEmpty) query['category'] = category;
      if (wasteType != null && wasteType.isNotEmpty)
        query['wasteType'] = wasteType;
      if (userId != null && userId.isNotEmpty) query['userId'] = userId;
      if (from != null && from.isNotEmpty) query['from'] = from;
      if (to != null && to.isNotEmpty) query['to'] = to;
      if (searchQuery != null && searchQuery.isNotEmpty)
        query['q'] = searchQuery;

      final res = await _api.get('/api/waste', query: query);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _logs = List<Map<String, dynamic>>.from(data['data']['logs'] ?? []);
        _totalLogs = data['data']['total'] ?? 0;
      } else {
        _error = 'Failed to load logs';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // -------------------------------
  // Delete Log
  // -------------------------------
  Future<bool> deleteLog(String logId) async {
    try {
      final res = await _api.delete('/api/waste/$logId');

      if (res.statusCode == 200) {
        await fetchMyLogs(); // optional refresh
        return true;
      }

      final data = jsonDecode(res.body);
      _error = data['message'] ?? 'Failed to delete log';
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // -------------------------------
  // Update Log
  // -------------------------------
  Future<bool> updateLog({
    required String logId,
    required String wasteType,
    required String category,
    required double amount,
    DateTime? dateLogged,
  }) async {
    try {
      final res = await _api.put(
        '/api/waste/$logId',
        body: {
          'wasteType': wasteType,
          'category': category,
          'amount': amount,
          if (dateLogged != null) 'dateLogged': dateLogged.toIso8601String(),
        },
      );
      if (kDebugMode) {
      print('Update Log Response: ${res.statusCode}');
      print('Body: ${res.body}');
      }

      if (res.statusCode == 200) {
        await fetchMyLogs(); // Refresh list
        return true;
      }

      final data = jsonDecode(res.body);
      _error = data['message'] ?? 'Failed to update log';
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
