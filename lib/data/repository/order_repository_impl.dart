import 'package:dio/dio.dart';
import '../../domain/model/order.dart';
import '../../domain/repository/order_repository.dart';
import '../../core/error/api_exception.dart';
import '../remote/api/dio_client.dart';
import '../remote/dto/order_dto.dart';

class OrderRepositoryImpl implements OrderRepository {
  final DioClient _api = DioClient();

  List<T> _extractResults<T>(dynamic data, T Function(Map<String, dynamic>) fromJson) {
    if (data is! Map) return (data as List).map((e) => fromJson(e as Map<String, dynamic>)).toList();
    final items = data['results'] ?? data['value'] ?? data as List;
    return (items as List).map((e) => fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<Incident>> getIncidents({String? status, String? severity}) async {
    try {
      final params = <String, dynamic>{};
      if (status != null) params['status'] = status;
      if (severity != null) params['severity'] = severity;

      final response = await _api.get('/api/incidents/incidents/', params: params);
      final dtos = _extractResults(response.data, IncidentDto.fromJson);
      return dtos.map((d) => Incident(
        id: d.id, tripId: d.tripId, vehicleId: d.vehicleId, driverId: d.driverId,
        incidentTypeId: d.incidentTypeId,
        incidentTypeName: d.incidentTypeName, description: d.description,
        severity: d.severity, status: d.status,
        latitude: d.latitude, longitude: d.longitude,
        createdAt: d.createdAt,
      )).toList();
    } on DioException catch (e) {
      throw ApiException('Error al cargar incidentes: ${e.message}', statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<void> createIncident(Incident incident) async {
    try {
      final dto = IncidentDto(
        id: 0, tripId: incident.tripId,
        vehicleId: incident.vehicleId, driverId: incident.driverId,
        incidentTypeId: incident.incidentTypeId,
        description: incident.description, severity: incident.severity,
        latitude: incident.latitude, longitude: incident.longitude,
      );
      await _api.post('/api/incidents/incidents/', data: dto.toJson());
    } on DioException catch (e) {
      throw ApiException(_parseError(e.response?.data), statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<void> resolveIncident(int id) async {
    try {
      await _api.patch('/api/incidents/incidents/$id/resolve/');
    } on DioException catch (e) {
      throw ApiException(_parseError(e.response?.data), statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<void> deleteIncident(int id) async {
    try {
      await _api.delete('/api/incidents/incidents/$id/');
    } on DioException catch (e) {
      throw ApiException(_parseError(e.response?.data), statusCode: e.response?.statusCode);
    }
  }

  String _parseError(dynamic data) {
    if (data == null) return 'Error de conexión';
    if (data is String) return data.isNotEmpty ? data : 'Respuesta vacía';
    if (data is Map) {
      if (data.containsKey('errors') && data['errors'] is Map) {
        final errors = data['errors'] as Map;
        final messages = <String>[];
        errors.forEach((key, value) {
          if (value is List) {
            messages.addAll(value.map((e) => '$key: $e'));
          } else {
            messages.add('$key: $value');
          }
        });
        return messages.isNotEmpty ? messages.join('\n') : data.toString();
      }
      if (data.containsKey('detail')) return data['detail'].toString();
      if (data.containsKey('message')) return data['message'];
      return data.toString();
    }
    return data.toString();
  }
}
