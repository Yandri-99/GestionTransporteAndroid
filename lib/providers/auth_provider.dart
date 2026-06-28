import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = true;
  bool _isLoggedIn = false;
  User? _user;
  String? _error;

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  User? get user => _user;
  String? get error => _error;
  bool get isAdmin => _user?.isAdmin ?? false;

  Future<void> checkSession() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final hasToken = await _authService.isLoggedIn();
    if (hasToken) {
      await loadUser();
    } else {
      _isLoading = false;
      _isLoggedIn = false;
      notifyListeners();
    }
  }

  Future<void> loadUser() async {
    try {
      _user = await _authService.getMe();
      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      await _authService.logout();
      _isLoggedIn = false;
      _isLoading = false;
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  Future<void> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.login(username, password);
      await loadUser();
    } catch (e) {
      _isLoading = false;
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _isLoggedIn = false;
    _user = null;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
