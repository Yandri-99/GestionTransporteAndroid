import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../../data/remote/api/dio_client.dart';

@pragma('vm:entry-point')
Future<void> _onBackgroundMessage(RemoteMessage message) async {}

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._();
  factory PushNotificationService() => _instance;
  PushNotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final DioClient _api = DioClient();

  String? _token;
  String? get token => _token;

  GlobalKey<NavigatorState>? _navigatorKey;

  void setNavigatorKey(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
  }

  /// Llama esto al arrancar la app (antes del login).
  /// Solo pide permisos y configura los listeners de mensajes.
  /// NO registra el token en el backend (todavía no hay sesión).
  Future<void> initialize() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      _token = await _messaging.getToken();
      debugPrint('📲 [FCM] Token obtenido: $_token');

      // Refresco automático: si hay sesión activa, se re-registra
      _messaging.onTokenRefresh.listen((newToken) {
        _token = newToken;
        debugPrint('🔄 [FCM] Token refrescado: $newToken');
        _sendTokenToBackend(newToken);
      });
    }

    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);
    FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _onMessageOpenedApp(initialMessage);
    }
  }

  /// Llama esto DESPUÉS de un login exitoso o al restaurar sesión.
  /// Registra el token FCM en el backend con el JWT activo.
  Future<void> registerTokenForUser() async {
    // Si aún no tenemos token, intentamos obtenerlo
    _token ??= await _messaging.getToken();
    debugPrint('📤 [FCM] Registrando token para usuario autenticado...');
    await _sendTokenToBackend(_token);
  }

  void _onForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    if (_navigatorKey?.currentContext != null) {
      final scaffold = ScaffoldMessenger.of(_navigatorKey!.currentContext!);
      scaffold.showSnackBar(SnackBar(
        content: Row(
          children: [
            const Icon(Icons.notifications_active, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notification.title ?? '',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  if (notification.body != null)
                    Text(notification.body!,
                        style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFC62828),
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  void _onMessageOpenedApp(RemoteMessage message) {
    final data = message.data;
    if (data.containsKey('incident_id')) {
      _navigatorKey?.currentState?.pushNamed('/incident_map');
    }
  }

  Future<void> _sendTokenToBackend(String? token) async {
    if (token == null) return;
    try {
      final response = await _api.post('/api/notifications/fcm-tokens/', data: {
        'token': token,
        'platform': 'android',
      });
      debugPrint('✅ [FCM] Token enviado al backend: ${response.statusCode}');
    } catch (e) {
      debugPrint('❌ [FCM] Error enviando token: $e');
    }
  }
}
