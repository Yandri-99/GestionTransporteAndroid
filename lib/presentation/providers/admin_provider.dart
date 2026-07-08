import 'package:flutter/material.dart';
import '../../domain/model/auth_models.dart';
import '../../domain/repository/admin_repository.dart';
import '../../data/repository/admin_repository_impl.dart';

class AdminProvider extends ChangeNotifier {
  final AdminRepository _repo = AdminRepositoryImpl();

  bool _isLoading = false;
  List<User> _users = [];
  String? _error;

  bool get isLoading => _isLoading;
  List<User> get users => _users;
  String? get error => _error;

  Future<void> loadUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _users = await _repo.getUsers();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteUser(int id) async {
    try {
      await _repo.deleteUser(id);
      await loadUsers();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }
}
