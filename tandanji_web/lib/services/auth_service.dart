import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  final ApiService _api = ApiService();
  
  String? _userId;
  String? _username;
  String? _token;
  bool _isLoading = true;

  String? get userId => _userId;
  String? get username => _username;
  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;

  AuthService() {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('user_id');
    _username = prefs.getString('username');
    _token = prefs.getString('token');
    
    if (_token != null) {
      _api.setToken(_token);
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _api.register(
        username: username,
        email: email,
        password: password,
      );

      print('Register response: $response');

      _userId = response['user_id'];
      _username = response['name'] ?? response['username'] ?? username;
      _token = response['token'] ?? 'no_token';
      
      _api.setToken(_token);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', _userId!);
      await prefs.setString('username', _username!);
      await prefs.setString('token', _token!);

      notifyListeners();
    } catch (e) {
      print('Register error in auth_service: $e');
      rethrow;
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _api.login(
        email: email,
        password: password,
      );

      print('Auth service received: $response');

      _userId = response['user_id'];
      _username = response['name'] ?? response['username'] ?? 'User';
      _token = response['token'] ?? 'no_token';
      
      _api.setToken(_token);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', _userId!);
      await prefs.setString('username', _username!);
      await prefs.setString('token', _token!);

      notifyListeners();
    } catch (e) {
      print('Login error in auth_service: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    _userId = null;
    _username = null;
    _token = null;
    
    _api.setToken(null);

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    notifyListeners();
  }

  ApiService get api => _api;
}