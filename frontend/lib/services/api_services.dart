import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constant.dart';

class ApiService {
  final String _base = apiBaseUrl;

  Future<Map<String, String>> _headers({bool withAuth = true}) async {
    final headers = {'Content-Type': 'application/json'};
    if (!withAuth) return headers;
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) headers['Authorization'] = 'Bearer $token';
    return headers;
  }

  Uri _url(String path, [Map<String, dynamic>? query]) =>
      Uri.parse('$_base$path').replace(queryParameters: query);

  Future<http.Response> get(String path, {Map<String, dynamic>? query, bool auth = true}) async {
    return http.get(_url(path, query), headers: await _headers(withAuth: auth));
  }
  Future<http.Response> delete(String path, {bool auth = true}) async {
     return http.delete(_url(path), headers: await _headers(withAuth: auth));
   }

  Future<http.Response> post(String path, {Object? body, bool auth = true}) async {
    return http.post(_url(path), headers: await _headers(withAuth: auth), body: jsonEncode(body));
  }

  Future<http.Response> put(String path, {Object? body, bool auth = true}) async {
    return http.put(_url(path), headers: await _headers(withAuth: auth), body: jsonEncode(body));
  }
}