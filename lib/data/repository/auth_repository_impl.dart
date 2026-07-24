import 'package:dio/dio.dart';
import '../../domain/model/auth_models.dart';
import '../../domain/repository/auth_repository.dart';
import '../../core/error/api_exception.dart';
import '../remote/api/dio_client.dart';
import '../local/secure_storage.dart';
import '../remote/dto/auth_dto.dart';

class AuthRepositoryImpl implements AuthRepository {
  final DioClient _api = DioClient();
  final SecureStorage _storage = SecureStorage();

  @override
  Future<User> login(String username, String password) async {
    try {
      final dto = LoginRequestDto(username: username, password: password);
      final response = await _api.post('/api/auth/login/', data: dto.toJson());
      final loginDto = LoginResponseDto.fromJson(response.data);
      await _storage.saveTokens(loginDto.access, loginDto.refresh);
      return await getMe();
    } on DioException catch (e) {
      throw ApiException(_parseError(e.response?.data), statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<void> register(String username, String email, String password) async {
    try {
      final dto = RegisterRequestDto(username: username, email: email, password: password);
      await _api.post('/api/auth/register/', data: dto.toJson());
    } on DioException catch (e) {
      throw ApiException(_parseError(e.response?.data), statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<User> getMe() async {
    try {
      final response = await _api.get('/api/auth/me/');
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(_parseError(e.response?.data), statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<void> logout() async {
    await _storage.clearAll();
  }

  @override
  Future<bool> isLoggedIn() async {
    return await _storage.hasToken();
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    try {
      final dto = PasswordResetRequestDto(email: email);
      await _api.post('/api/auth/password-reset/', data: dto.toJson());
    } on DioException catch (e) {
      throw ApiException(_parseError(e.response?.data), statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<void> confirmPasswordReset(String uid, String token, String newPassword, String newPassword2) async {
    try {
      final dto = PasswordResetConfirmDto(
        uid: uid,
        token: token,
        newPassword: newPassword,
        newPassword2: newPassword2,
      );
      await _api.post('/api/auth/password-reset/confirm/', data: dto.toJson());
    } on DioException catch (e) {
      throw ApiException(_parseError(e.response?.data), statusCode: e.response?.statusCode);
    }
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
