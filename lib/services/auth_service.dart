import 'package:dio/dio.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _api.post('/api/auth/login/', data: {
        'username': username,
        'password': password,
      });

      await _api.saveTokens(response.data['access'], response.data['refresh']);
      return response.data;
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? _parseError(e.response?.data);
      throw Exception(msg);
    }
  }

  Future<void> register(
      String username, String email, String password) async {
    try {
      await _api.post('/api/auth/register/', data: {
        'username': username,
        'email': email,
        'password': password,
      });
    } on DioException catch (e) {
      throw Exception(_parseError(e.response?.data));
    }
  }

  Future<User> getMe() async {
    try {
      final response = await _api.get('/api/auth/me/');
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_parseError(e.response?.data));
    }
  }

  Future<void> logout() async {
    await _api.clearTokens();
  }

  Future<bool> isLoggedIn() async {
    final token = await _api.getAccessToken();
    return token != null;
  }

  String _parseError(dynamic data) {
    if (data == null) return 'Error de conexión';
    if (data is Map && data.containsKey('message')) return data['message'];
    if (data is Map && data.containsKey('errors')) {
      final errors = data['errors'] as Map;
      return errors.values.expand((e) => e as List).join('\n');
    }
    return 'Error desconocido';
  }
}
