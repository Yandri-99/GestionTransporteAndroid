import 'package:flutter/material.dart';
import '../../domain/model/user_profile.dart';
import '../../data/repository/profile_repository.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _repo = ProfileRepository();

  bool _isLoading = false;
  UserProfile? _profile;
  String? _error;
  String? _successMessage;

  bool get isLoading => _isLoading;
  UserProfile? get profile => _profile;
  String? get error => _error;
  String? get successMessage => _successMessage;

  void clearMessages() {
    _error = null;
    _successMessage = null;
    notifyListeners();
  }

  String get initials {
    if (_profile == null) return '?';
    final first = _profile!.firstName.isNotEmpty ? _profile!.firstName[0] : '';
    final last = _profile!.lastName.isNotEmpty ? _profile!.lastName[0] : '';
    return '$first$last'.toUpperCase();
  }

  Future<void> loadProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await _repo.getProfile();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateProfile(UserProfile profile) async {
    _isLoading = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _repo.updateMe(profile);
      await _repo.updateProfileDetails(profile);
      _successMessage = 'Perfil actualizado exitosamente';
      await loadProfile();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    _isLoading = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _repo.changePassword(oldPassword: oldPassword, newPassword: newPassword);
      _successMessage = 'Contraseña actualizada exitosamente';
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }
}
