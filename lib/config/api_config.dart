class ApiConfig {
  // Cambia aquí según dónde esté corriendo el backend:

  // Local (USB/ADB reverse): adb reverse tcp:8000 tcp:8000
  static const String baseUrl = 'http://localhost:8000';

  // Producción (DigitalOcean - prender VM primero)
  // static const String baseUrl = 'https://tanqueno-produccion.uaeftt-ute.site';
}
