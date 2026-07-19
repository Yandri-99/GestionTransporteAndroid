import 'package:dio/dio.dart';
import '../../domain/model/product.dart';
import '../../domain/repository/catalog_repository.dart';
import '../../core/error/api_exception.dart';
import '../remote/api/dio_client.dart';
import '../remote/dto/route_dto.dart';
import '../local/cache_service.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  final DioClient _api = DioClient();
  final CacheService _cache = CacheService();

  List<T> _extractResults<T>(
    dynamic data,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (data is! Map) {
      return (data as List)
          .map((e) => fromJson(e as Map<String, dynamic>))
          .toList();
    }
    final items = data['results'] ?? data['value'] ?? data as List;
    return (items as List)
        .map((e) => fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<RouteModel>> getRoutes() async {
    try {
      final response = await _api.get('/api/public/routes/');
      final dtos = _extractResults(response.data, RouteDto.fromJson);
      final routes = dtos
          .map(
            (d) => RouteModel(
              id: d.id,
              code: d.code,
              name: d.name,
              description: d.description,
              companyName: d.companyName,
            ),
          )
          .toList();
      await _cache.put(
        CacheService.routesKey,
        routes.map((r) => r.toJson()).toList(),
      );
      return routes;
    } on DioException catch (_) {
      final cached = await _cache.get(CacheService.routesKey);
      if (cached != null) {
        return (cached as List)
            .map((e) => RouteModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw ApiException('Sin conexión y sin datos en caché');
    }
  }

  @override
  Future<List<BusStop>> getRouteStops(int routeId) async {
    try {
      final response = await _api.get('/api/public/routes/$routeId/stops/');
      final dtos = _extractResults(response.data, BusStopDto.fromJson);
      final stops = dtos
          .map(
            (d) => BusStop(
              id: d.id,
              code: d.code,
              name: d.name,
              latitude: d.latitude,
              longitude: d.longitude,
              stopOrder: d.stopOrder,
            ),
          )
          .toList();
      await _cache.put(
        '${CacheService.stopsPrefix}$routeId',
        stops.map((s) => s.toJson()).toList(),
      );
      return stops;
    } on DioException catch (_) {
      final cached = await _cache.get('${CacheService.stopsPrefix}$routeId');
      if (cached != null) {
        return (cached as List)
            .map((e) => BusStop.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw ApiException('Sin conexión y sin datos en caché');
    }
  }

  @override
  Future<List<RouteCoordinate>> getRouteCoordinates(int routeId) async {
    try {
      final response = await _api.get(
        '/api/public/routes/$routeId/coordinates/',
      );
      final dtos = _extractResults(response.data, RouteCoordinateDto.fromJson);
      final coords = dtos
          .map(
            (d) => RouteCoordinate(
              id: d.id,
              latitude: d.latitude,
              longitude: d.longitude,
              order: d.order,
            ),
          )
          .toList();
      await _cache.put(
        '${CacheService.coordinatesPrefix}$routeId',
        coords.map((c) => c.toJson()).toList(),
      );
      return coords;
    } on DioException catch (_) {
      final cached = await _cache.get(
        '${CacheService.coordinatesPrefix}$routeId',
      );
      if (cached != null) {
        return (cached as List)
            .map((e) => RouteCoordinate.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw ApiException('Sin conexión y sin datos en caché');
    }
  }

  @override
  Future<List<BusStop>> getBusStops() async {
    try {
      final response = await _api.get('/api/public/bus-stops/');
      final dtos = _extractResults(response.data, BusStopDto.fromJson);
      return dtos
          .map(
            (d) => BusStop(
              id: d.id,
              code: d.code,
              name: d.name,
              latitude: d.latitude,
              longitude: d.longitude,
              stopOrder: d.stopOrder,
            ),
          )
          .toList();
    } on DioException catch (e) {
      throw ApiException(
        'Error al cargar paradas: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
