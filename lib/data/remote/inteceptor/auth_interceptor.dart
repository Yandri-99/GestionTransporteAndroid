import 'package:dio/dio.dart';
import '../../local/secure_storage.dart';
import '../../../core/config/app_config.dart';
class AuthInterceptor extends Interceptor {
  final Dio _dio;
  final SecureStorage _storage = SecureStorage();

  AuthInterceptor(this._dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        final retryResponse = await _retry(err.requestOptions);
        handler.resolve(retryResponse);
        return;
      }
      await _storage.clearAll();
    }
    handler.next(err);
  }

  Future<bool> _tryRefreshToken() async {
    try {
      final refresh = await _storage.getRefreshToken();
      if (refresh == null) return false;

      final response = await Dio().post(
        '${AppConfig.baseUrl}/api/auth/refresh/',
        data: {'refresh': refresh},
      );

      if (response.statusCode == 200) {
        await _storage.saveAccessToken(response.data['access']);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<Response> _retry(RequestOptions requestOptions) async {
    final token = await _storage.getAccessToken();
    final options = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        'Authorization': 'Bearer $token',
      },
    );
    return _dio.request(requestOptions.path,
        data: requestOptions.data,
        queryParameters: requestOptions.queryParameters,
        options: options);
  }
}
