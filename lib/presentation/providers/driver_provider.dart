import 'package:flutter/material.dart';
import '../../domain/model/driver.dart';
import '../../domain/repository/driver_repository.dart';
import '../../data/repository/driver_repository_impl.dart';

class DriverProvider extends ChangeNotifier {
  final DriverRepository _repo = DriverRepositoryImpl();

  bool _isLoading = false;
  List<Driver> _drivers = [];
  String? _error;
  String? _successMessage;

  bool get isLoading => _isLoading;
  List<Driver> get drivers => _drivers;
  String? get error => _error;
  String? get successMessage => _successMessage;

  void clearMessages() {
    _error = null;
    _successMessage = null;
    notifyListeners();
  }

  Future<void> loadDrivers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _drivers = await _repo.getDrivers();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createDriver(Driver driver) async {
    _isLoading = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _repo.createDriver(driver);
      _successMessage = 'Conductor creado exitosamente';
      await loadDrivers();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateDriver(Driver driver) async {
    _isLoading = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _repo.updateDriver(driver);
      _successMessage = 'Conductor actualizado exitosamente';
      await loadDrivers();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteDriver(int id) async {
    try {
      await _repo.deleteDriver(id);
      _successMessage = 'Conductor eliminado';
      await loadDrivers();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }
}
