# MoviCore - Transporte Público Inteligente

Aplicación móvil Flutter para consulta de rutas y gestión de incidencias del transporte público urbano. Consume la API REST **QuitoMove Smart Mobility** (Django).

## Requisitos

- Flutter SDK ^3.12.0
- Dart SDK ^3.12.0
- Dispositivo Android (API 21+) o emulador

## Instalación

```bash
# Clonar el repositorio
git clone https://github.com/Yandri-99/GestionTransporteAndroid.git
cd GestionTransporteAndroid

# Obtener dependencias
flutter pub get

# Ejecutar en dispositivo/emulador
flutter run
```

## Configuración

### URL de la API

Editar `lib/config/api_config.dart`:

```dart
class ApiConfig {
  static const String baseUrl = 'http://10.0.2.2:8000';  // Emulador Android
  // static const String baseUrl = 'http://192.168.x.x:8000';  // Dispositivo físico (WiFi)
}
```

| Escenario | URL |
|-----------|-----|
| Emulador Android | `http://10.0.2.2:8000` |
| Dispositivo físico (USB/WiFi) | `http://<IP-local-PC>:8000` |
| iOS Simulator | `http://localhost:8000` |

### Backend (Django)

El backend debe estar corriendo en `http://localhost:8000`:

```bash
cd backend
pip install -r requirements.txt
python manage.py migrate
python manage.py seed_demo
python manage.py runserver 0.0.0.0:8000
```

## Credenciales de prueba

| Rol | Usuario | Contraseña |
|-----|---------|------------|
| Administrador | `admin` | `admin123` |
| Usuario | `usuario1` | *(preguntar al creador del backend)* |
| Conductor | `conductor1` | *(preguntar al creador del backend)* |

## Funcionalidades

### Públicas (sin autenticación)
- Ver rutas disponibles
- Detalle de ruta con paradas y coordenadas

### Usuarios autenticados
- Reportar incidencias en rutas
- Ver notificaciones

### Administradores
- Panel de administración con indicadores
- Gestionar incidencias (listar, resolver)
- Acceso a todas las funcionalidades

## Estructura del proyecto

```
lib/
├── config/          # Configuración (URL base)
├── models/          # Modelos de datos (User, Route, Incident, Notification)
├── services/        # Servicios HTTP (Dio, Auth, Transport)
├── providers/       # State management (Provider)
├── screens/         # Pantallas (public, auth, admin, notifications)
└── widgets/         # Componentes reutilizables
```

## Stack técnico

- **Flutter** + **Dart** (frontend móvil)
- **Provider** (state management)
- **Dio** (HTTP client con interceptors)
- **flutter_secure_storage** (persistencia de tokens JWT)
- **Django 6.0** + **DRF 3.17** (backend)
- **PostgreSQL** / **SQLite** (base de datos)
- **SimpleJWT** (autenticación)

## API

Documentación completa disponible en `/api/docs/swagger/` del backend.

### Endpoints principales

- `POST /api/auth/login/` - Inicio de sesión
- `POST /api/auth/register/` - Registro
- `GET /api/auth/me/` - Perfil del usuario
- `GET /api/public/routes/` - Rutas públicas
- `GET /api/public/routes/{id}/stops/` - Paradas de ruta
- `GET /api/public/routes/{id}/coordinates/` - Coordenadas de ruta
- `GET /api/incidents/incidents/` - Listar incidencias
- `POST /api/incidents/incidents/` - Crear incidencia
- `PATCH /api/incidents/incidents/{id}/resolve/` - Resolver incidencia
- `GET /api/notifications/notifications/` - Notificaciones

## Entregable

- Código fuente completo en GitHub
- Video demo (3-5 min)
- Capturas: home, login, admin dashboard, listado API, formulario con éxito, restricción de roles
