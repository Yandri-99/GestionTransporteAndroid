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
  List<BusStop> _allStops = [];
  List<Vehicle> _vehicles = [];
  List<Trip> _trips = [];
  List<RouteCoordinate> _coordinates = [];
  String? _error;
  String? _successMessage;
  final Map<int, int> _stopsCountMap = {};
  final Map<int, List<RouteCoordinate>> _routeCoordinatesMap = {};

  bool get isLoading => _isLoading;
  List<RouteModel> get routes => _routes;
  RouteModel? get selectedRoute => _selectedRoute;
  List<BusStop> get stops => _stops;
  List<BusStop> get allStops => _allStops;
  List<Vehicle> get vehicles => _vehicles;
  List<Trip> get trips => _trips;
  List<RouteCoordinate> get coordinates => _coordinates;
  String? get error => _error;
  String? get successMessage => _successMessage;
  Map<int, int> get stopsCountMap => _stopsCountMap;
  Map<int, List<RouteCoordinate>> get routeCoordinatesMap => _routeCoordinatesMap;

  void clearMessages() {
    _error = null;
    _successMessage = null;
    notifyListeners();
  }

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

  Future<void> loadAllStops() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allStops = await _repo.getBusStops();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadVehicles() async {
    try {
      _vehicles = await _repo.getVehicles();
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    }
  }

  Future<bool> createRoute(RouteModel route) async {
    _isLoading = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _repo.createRoute(route);
      _successMessage = 'Ruta creada exitosamente';
      await loadRoutes();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateRoute(RouteModel route) async {
    _isLoading = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _repo.updateRoute(route);
      _successMessage = 'Ruta actualizada exitosamente';
      await loadRoutes();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteRoute(int id) async {
    try {
      await _repo.deleteRoute(id);
      _successMessage = 'Ruta eliminada';
      await loadRoutes();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  Future<bool> createStop(BusStop stop) async {
    _isLoading = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _repo.createStop(stop);
      _successMessage = 'Parada creada exitosamente';
      await loadAllStops();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateStop(BusStop stop) async {
    _isLoading = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _repo.updateStop(stop);
      _successMessage = 'Parada actualizada exitosamente';
      await loadAllStops();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteStop(int id) async {
    try {
      await _repo.deleteStop(id);
      _successMessage = 'Parada eliminada';
      await loadAllStops();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  void clearDetail() {
    _selectedRoute = null;
    _stops = [];
    _coordinates = [];
  }

  Future<void> loadStopsCount(int routeId) async {
    if (_stopsCountMap.containsKey(routeId)) return;
    try {
      final stops = await _repo.getRouteStops(routeId);
      _stopsCountMap[routeId] = stops.length;
      notifyListeners();
    } catch (_) {
      _stopsCountMap[routeId] = 0;
    }
  }

  Future<void> loadRouteCoordinatesForMap(int routeId) async {
    if (_routeCoordinatesMap.containsKey(routeId)) return;
    try {
      final coords = await _repo.getRouteCoordinates(routeId);
      _routeCoordinatesMap[routeId] = coords;
      notifyListeners();
    } catch (_) {
      _routeCoordinatesMap[routeId] = [];
    }
  }

  Future<void> loadTrips() async {
    try {
      _trips = await _repo.getTrips();
      notifyListeners();
    } catch (e) {
      _trips = [];
      notifyListeners();
    }
  }
}
