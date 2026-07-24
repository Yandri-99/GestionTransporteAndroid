import 'package:flutter/material.dart';
import '../../domain/model/driver_assignment.dart';
import '../../domain/repository/driver_assignment_repository.dart';
import '../../data/repository/driver_assignment_repository_impl.dart';

class DriverAssignmentProvider extends ChangeNotifier {
  final DriverAssignmentRepository _repo = DriverAssignmentRepositoryImpl();

  bool _isLoading = false;
  List<DriverAssignment> _assignments = [];
  String? _error;
  String? _successMessage;

  bool get isLoading => _isLoading;
  List<DriverAssignment> get assignments => _assignments;
  String? get error => _error;
  String? get successMessage => _successMessage;

  void clearMessages() {
    _error = null;
    _successMessage = null;
    notifyListeners();
  }

  Future<void> loadAssignments() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _assignments = await _repo.getAssignments();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createAssignment(DriverAssignment assignment) async {
    _isLoading = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _repo.createAssignment(assignment);
      _successMessage = 'Asignación creada exitosamente';
      await loadAssignments();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateAssignment(DriverAssignment assignment) async {
    _isLoading = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _repo.updateAssignment(assignment);
      _successMessage = 'Asignación actualizada exitosamente';
      await loadAssignments();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteAssignment(int id) async {
    try {
      await _repo.deleteAssignment(id);
      _successMessage = 'Asignación eliminada';
      await loadAssignments();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }
}
