import 'package:flutter/material.dart';
import '../../domain/model/product.dart';
import '../../domain/repository/catalog_repository.dart';
import '../../data/repository/catalog_repository_impl.dart';

class CatalogProvider extends ChangeNotifier {
  final CatalogRepository _repo = CatalogRepositoryImpl();

  bool _isLoading = false;
  List<RouteModel> _routes = [];
  RouteModel? _selectedRoute;
  List<BusStop> _stops = [];
  List<RouteCoordinate> _coordinates = [];
  String? _error;

  bool get isLoading => _isLoading;
  List<RouteModel> get routes => _routes;
  RouteModel? get selectedRoute => _selectedRoute;
  List<BusStop> get stops => _stops;
  List<RouteCoordinate> get coordinates => _coordinates;
  String? get error => _error;

  Future<void> loadRoutes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _routes = await _repo.getRoutes();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadRouteDetail(int routeId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repo.getRoutes(),
        _repo.getRouteStops(routeId),
        _repo.getRouteCoordinates(routeId),
      ]);

      _selectedRoute = (results[0] as List<RouteModel>)
          .firstWhere((r) => r.id == routeId);
      _stops = results[1] as List<BusStop>;
      _coordinates = results[2] as List<RouteCoordinate>;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    }
    _isLoading = false;
    notifyListeners();
  }

  void clearDetail() {
    _selectedRoute = null;
    _stops = [];
    _coordinates = [];
  }
}
