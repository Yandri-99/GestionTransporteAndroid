import 'package:flutter/material.dart';
import '../../domain/model/auth_models.dart';
import '../../domain/repository/auth_repository.dart';
import '../../data/repository/auth_repository_impl.dart';
import '../../core/services/analytics_service.dart';
import '../../core/services/push_notification_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepo = AuthRepositoryImpl();

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

    final hasToken = await _authRepo.isLoggedIn();
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
      _user = await _authRepo.getMe();
      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();
      // Registrar token FCM ahora que hay sesión activa
      PushNotificationService().registerTokenForUser();
    } catch (e) {
      await _authRepo.logout();
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
      _user = await _authRepo.login(username, password);
      _isLoggedIn = true;
      _isLoading = false;
      AnalyticsService().logLogin('password');
      AnalyticsService().setUserRole(_user?.isAdmin == true ? 'admin' : 'user');
      // Registrar token FCM con el JWT recién obtenido
      PushNotificationService().registerTokenForUser();
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  Future<bool> register(String username, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authRepo.register(username, email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    AnalyticsService().logLogout();
    await _authRepo.logout();
    _isLoggedIn = false;
    _user = null;
    _error = null;
    notifyListeners();
  }

  Future<String?> requestPasswordReset(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _authRepo.requestPasswordReset(email);
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      final msg = e.toString().replaceFirst('Exception: ', '');
      _error = msg;
      notifyListeners();
      return msg;
    }
  }

  Future<String?> confirmPasswordReset(String uid, String token, String newPassword, String newPassword2) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _authRepo.confirmPasswordReset(uid, token, newPassword, newPassword2);
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      final msg = e.toString().replaceFirst('Exception: ', '');
      _error = msg;
      notifyListeners();
      return msg;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
