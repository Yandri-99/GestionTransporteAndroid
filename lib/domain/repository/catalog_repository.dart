import '../model/product.dart';

abstract class CatalogRepository {
  Future<List<RouteModel>> getRoutes();
  Future<void> createRoute(RouteModel route);
  Future<void> updateRoute(RouteModel route);
  Future<void> deleteRoute(int id);
  Future<List<BusStop>> getRouteStops(int routeId);
  Future<List<RouteCoordinate>> getRouteCoordinates(int routeId);
  Future<List<BusStop>> getBusStops();
  Future<void> createStop(BusStop stop);
  Future<void> updateStop(BusStop stop);
  Future<void> deleteStop(int id);
  Future<List<Vehicle>> getVehicles();
  Future<List<Trip>> getTrips();
}
