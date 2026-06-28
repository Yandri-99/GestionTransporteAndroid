import 'package:flutter/material.dart';
import '../models/incident.dart';
import '../services/transport_service.dart';

class IncidentProvider extends ChangeNotifier {
  final TransportService _service = TransportService();

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
      _incidents = await _service.getIncidents();
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
      await _service.createIncident(incident);
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
      await _service.resolveIncident(id);
      _successMessage = 'Incidencia resuelta';
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
