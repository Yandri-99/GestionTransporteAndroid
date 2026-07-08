import 'package:flutter/material.dart';
import '../../domain/model/order.dart';

class CartProvider extends ChangeNotifier {
  final List<Incident> _draftIncidents = [];
  String? _error;

  List<Incident> get draftIncidents => _draftIncidents;
  String? get error => _error;

  void addDraft(Incident incident) {
    _draftIncidents.add(incident);
    notifyListeners();
  }

  void removeDraft(int index) {
    _draftIncidents.removeAt(index);
    notifyListeners();
  }

  void clearDrafts() {
    _draftIncidents.clear();
    notifyListeners();
  }
}
