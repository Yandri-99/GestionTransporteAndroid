import '../model/product.dart';

abstract class CatalogRepository {
  Future<List<RouteModel>> getRoutes();
  Future<List<BusStop>> getRouteStops(int routeId);
  Future<List<RouteCoordinate>> getRouteCoordinates(int routeId);
  Future<List<BusStop>> getBusStops();
}
