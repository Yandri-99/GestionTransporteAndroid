import 'package:flutter/material.dart';
import '../../domain/model/order.dart';
import '../../domain/repository/order_repository.dart';
import '../../data/repository/order_repository_impl.dart';

class OrderProvider extends ChangeNotifier {
  final OrderRepository _repo = OrderRepositoryImpl();

  bool _isLoading = false;
  List<Incident> _incidents = [];
  String? _error;
  String? _successMessage;

  bool get isLoading => _isLoading;
  List<Incident> get incidents => _incidents;
  String? get error => _error;
  String? get successMessage => _successMessage;

  Future<void> loadIncidents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _incidents = await _repo.getIncidents();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> createIncident(Incident incident) async {
    _isLoading = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _repo.createIncident(incident);
      _successMessage = 'Incidencia reportada exitosamente';
      await loadIncidents();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resolveIncident(int id) async {
    try {
      await _repo.resolveIncident(id);
      _successMessage = 'Incidencia resuelta';
      await loadIncidents();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  Future<void> deleteIncident(int id) async {
    try {
      await _repo.deleteIncident(id);
      _successMessage = 'Incidencia eliminada';
      await loadIncidents();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  void clearMessages() {
    _error = null;
    _successMessage = null;
    notifyListeners();
  }
}
