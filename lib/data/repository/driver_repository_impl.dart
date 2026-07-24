import 'package:dio/dio.dart';
import '../../domain/model/driver.dart';
import '../../domain/repository/driver_repository.dart';
import '../../core/error/api_exception.dart';
import '../remote/api/dio_client.dart';
import '../remote/dto/driver_dto.dart';

class DriverRepositoryImpl implements DriverRepository {
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
  Future<List<Driver>> getDrivers() async {
    try {
      final response = await _api.get('/api/operations/drivers/');
      final dtos = _extractResults(response.data, DriverDto.fromJson);
      return dtos.map((d) => Driver(
        id: d.id, userId: d.userId, userFullName: d.userFullName,
        userUsername: d.userUsername, licenseNumber: d.licenseNumber,
        licenseType: d.licenseType, hireDate: d.hireDate,
        experienceYears: d.experienceYears, observations: d.observations,
        isAvailable: d.isAvailable, isActive: d.isActive,
      )).toList();
    } on DioException catch (e) {
      throw ApiException(_parseError(e.response?.data), statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<void> createDriver(Driver driver) async {
    try {
      await _api.post('/api/operations/drivers/', data: driver.toJson());
    } on DioException catch (e) {
      throw ApiException(_parseError(e.response?.data), statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<void> updateDriver(Driver driver) async {
    try {
      await _api.put('/api/operations/drivers/${driver.id}/', data: driver.toJson());
    } on DioException catch (e) {
      throw ApiException(_parseError(e.response?.data), statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<void> deleteDriver(int id) async {
    try {
      await _api.delete('/api/operations/drivers/$id/');
    } on DioException catch (e) {
      throw ApiException(_parseError(e.response?.data), statusCode: e.response?.statusCode);
    }
  }
}
