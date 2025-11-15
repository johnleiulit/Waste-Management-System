import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../services/api_services.dart';

class ReportsProvider extends ChangeNotifier {
  final _api = ApiService();
  bool _loading = false;
  String? _error;
  List<Map<String, dynamic>> _breakdown = [];
  double _grandTotal = 0;

  bool get isLoading => _loading;
  String? get error => _error;
  List<Map<String, dynamic>> get breakdown => _breakdown;
  double get grandTotal => _grandTotal;

  Future<void> fetchReports({
    String? category,
    String? from,
    String? to,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final query = <String, dynamic>{};
      if (category != null && category.isNotEmpty && category != 'All') {
        query['category'] = category;
      }
      if (from != null && from.isNotEmpty) {
        query['from'] = from;
      }
      if (to != null && to.isNotEmpty) {
        query['to'] = to;
      }

      final res = await _api.get('/api/reports', query: query);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _breakdown = List<Map<String, dynamic>>.from(
          data['data']['breakdown'] ?? [],
        );
        _grandTotal = (data['data']['grandTotal'] ?? 0).toDouble();
      } else {
        _error = 'Failed to load reports';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}