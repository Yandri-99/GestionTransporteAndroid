import 'package:dio/dio.dart';
import '../../domain/model/driver_assignment.dart';
import '../../domain/repository/driver_assignment_repository.dart';
import '../../core/error/api_exception.dart';
import '../remote/api/dio_client.dart';
import '../remote/dto/driver_assignment_dto.dart';

class DriverAssignmentRepositoryImpl implements DriverAssignmentRepository {
  final DioClient _api = DioClient();

  List<T> _extractResults<T>(dynamic data, T Function(Map<String, dynamic>) fromJson) {
    if (data is! Map) return (data as List).map((e) => fromJson(e as Map<String, dynamic>)).toList();
    final items = data['results'] ?? data['value'] ?? data as List;
    return (items as List).map((e) => fromJson(e as Map<String, dynamic>)).toList();
  }

  String _parseError(dynamic data) {
    if (data == null) return 'Sin respuesta del servidor';
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

  @override
  Future<List<DriverAssignment>> getAssignments() async {
    try {
      final response = await _api.get('/api/operations/driver-assignments/');
      final dtos = _extractResults(response.data, DriverAssignmentDto.fromJson);
      return dtos.map((d) => DriverAssignment(
        id: d.id, driverId: d.driverId, driverName: d.driverName,
        routeId: d.routeId, routeName: d.routeName,
        vehicleId: d.vehicleId, vehiclePlate: d.vehiclePlate,
        assignmentDate: d.assignmentDate,
        isActive: d.isActive, notes: d.notes,
      )).toList();
    } on DioException catch (e) {
      throw ApiException(_parseError(e.response?.data), statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<void> createAssignment(DriverAssignment assignment) async {
    try {
      await _api.post('/api/operations/driver-assignments/', data: assignment.toJson());
    } on DioException catch (e) {
      throw ApiException(_parseError(e.response?.data), statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<void> updateAssignment(DriverAssignment assignment) async {
    try {
      await _api.put('/api/operations/driver-assignments/${assignment.id}/', data: assignment.toJson());
    } on DioException catch (e) {
      throw ApiException(_parseError(e.response?.data), statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<void> deleteAssignment(int id) async {
    try {
      await _api.delete('/api/operations/driver-assignments/$id/');
    } on DioException catch (e) {
      throw ApiException(_parseError(e.response?.data), statusCode: e.response?.statusCode);
    }
  }
}
