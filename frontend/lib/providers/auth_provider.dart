import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final _auth = AuthService();
  Map<String, dynamic>? _user;
  bool _loading = false;

  Map<String, dynamic>? get user => _user;
  bool get isLoading => _loading;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _user?['role'] == 'admin';

  Future<void> loadSession() async {
    _loading = true; notifyListeners();
    final session = await _auth.loadSession();
    if (session != null) {
      _user = session['user'];
      // Optionally verify token by calling /me
      try {
        final me = await _auth.me();
        if (me != null) _user = me['user'];
      } catch (_) {}
    }
    _loading = false; notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _loading = true; notifyListeners();
    try {
      final data = await _auth.login(email, password);
      _user = data['user'];
    } finally {
      _loading = false; notifyListeners();
    }
  }

  Future<void> register(String username, String email, String password) async {
    _loading = true; notifyListeners();
    try {
      final data = await _auth.register(username, email, password);
      _user = data['user'];
    } finally {
      _loading = false; notifyListeners();
    }
  }

  Future<void> logout() async {
    await _auth.logout();
    _user = null;
    notifyListeners();
  }
}