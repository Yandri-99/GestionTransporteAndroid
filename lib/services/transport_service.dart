import 'package:dio/dio.dart';
import '../models/route_model.dart';
import '../models/incident.dart';
import '../models/notification_model.dart';
import 'api_service.dart';

class TransportService {
  final ApiService _api = ApiService();

  List<T> _extractResults<T>(dynamic data, T Function(Map<String, dynamic>) fromJson) {
    if (data is! Map) return (data as List).map((e) => fromJson(e as Map<String, dynamic>)).toList();
    final items = data['results'] ?? data['value'] ?? data as List;
    return (items as List).map((e) => fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<RouteModel>> getPublicRoutes() async {
    try {
      final response = await _api.get('/api/public/routes/');
      return _extractResults(response.data, RouteModel.fromJson);
    } on DioException catch (e) {
      throw Exception('Error al cargar rutas: ${e.message}');
    }
  }

  Future<List<BusStop>> getRouteStops(int routeId) async {
    try {
      final response = await _api.get('/api/public/routes/$routeId/stops/');
      return _extractResults(response.data, BusStop.fromJson);
    } on DioException catch (e) {
      throw Exception('Error al cargar paradas: ${e.message}');
    }
  }

  Future<List<RouteCoordinate>> getRouteCoordinates(int routeId) async {
    try {
      final response =
          await _api.get('/api/public/routes/$routeId/coordinates/');
      return _extractResults(response.data, RouteCoordinate.fromJson);
    } on DioException catch (e) {
      throw Exception('Error al cargar coordenadas: ${e.message}');
    }
  }

  Future<List<BusStop>> getPublicBusStops() async {
    try {
      final response = await _api.get('/api/public/bus-stops/');
      return _extractResults(response.data, BusStop.fromJson);
    } on DioException catch (e) {
      throw Exception('Error al cargar paradas: ${e.message}');
    }
  }

  Future<List<Incident>> getIncidents({String? status, String? severity}) async {
    try {
      final params = <String, dynamic>{};
      if (status != null) params['status'] = status;
      if (severity != null) params['severity'] = severity;

      final response = await _api.get('/api/incidents/incidents/', params: params);
      return _extractResults(response.data, Incident.fromJson);
    } on DioException catch (e) {
      throw Exception('Error al cargar incidentes: ${e.message}');
    }
  }

  Future<void> createIncident(Incident incident) async {
    try {
      await _api.post('/api/incidents/incidents/', data: incident.toJson());
    } on DioException catch (e) {
      throw Exception(_parseError(e.response?.data));
    }
  }

  Future<void> resolveIncident(int id) async {
    try {
      await _api.patch('/api/incidents/incidents/$id/resolve/');
    } on DioException catch (e) {
      throw Exception(_parseError(e.response?.data));
    }
  }

  Future<void> deleteIncident(int id) async {
    try {
      await _api.delete('/api/incidents/incidents/$id/');
    } on DioException catch (e) {
      throw Exception(_parseError(e.response?.data));
    }
  }

  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await _api.get('/api/notifications/notifications/');
      return _extractResults(response.data, NotificationModel.fromJson);
    } on DioException catch (e) {
      throw Exception('Error al cargar notificaciones: ${e.message}');
    }
  }

  Future<void> markNotificationAsRead(int id) async {
    await _api.patch('/api/notifications/notifications/$id/read/');
  }

  Future<void> markAllNotificationsAsRead() async {
    await _api.put('/api/notifications/notifications/read_all/');
  }

  String _parseError(dynamic data) {
    if (data == null) return 'Error de conexión';
    if (data is Map && data.containsKey('message')) return data['message'];
    return 'Error desconocido';
  }
}
