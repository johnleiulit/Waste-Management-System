import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_services.dart';

class AuthService {
  final _api = ApiService();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await _api.post('/api/auth/login', auth: false, body: {
      'email': email,
      'password': password,
    });
    final data = jsonDecode(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300 && data['success'] == true) {
      await _persistSession(data['data']['token'], data['data']['user']);
      return data['data'];
    }
    throw Exception(data['message'] ?? 'Login failed');
  }

  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    final res = await _api.post('/api/auth/register', auth: false, body: {
      'username': username,
      'email': email,
      'password': password,
    });
    final data = jsonDecode(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300 && data['success'] == true) {
      await _persistSession(data['data']['token'], data['data']['user']);
      return data['data'];
    }
    throw Exception(data['message'] ?? 'Register failed');
  }

  Future<Map<String, dynamic>?> me() async {
    final res = await _api.get('/api/auth/me');
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['data'];
    }
    return null;
  }

  Future<void> _persistSession(String token, Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('user', jsonEncode(user));
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
  }

  Future<Map<String, dynamic>?> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userStr = prefs.getString('user');
    if (token != null && userStr != null) {
      return {'token': token, 'user': jsonDecode(userStr)};
    }
    return null;
  }
}