import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/routes_provider.dart';
import 'providers/incident_provider.dart';
import 'providers/notification_provider.dart';
import 'screens/public/home_screen.dart';
import 'screens/public/routes_screen.dart';
import 'screens/public/route_detail_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/admin/admin_home_screen.dart';
import 'screens/admin/incidents_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'widgets/auth_guard.dart';

void main() {
  runApp(const MoviCoreApp());
}

class MoviCoreApp extends StatelessWidget {
  const MoviCoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..checkSession()),
        ChangeNotifierProvider(create: (_) => RoutesProvider()),
        ChangeNotifierProvider(create: (_) => IncidentProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MaterialApp(
        title: 'MoviCore',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: const Color(0xFF1565C0),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/routes': (context) => const RoutesScreen(),
          '/route_detail': (context) => const RouteDetailScreen(),
          '/admin': (context) => const AuthGuard(requireAdmin: true, child: AdminHomeScreen()),
          '/incidents': (context) => const AuthGuard(child: IncidentsScreen()),
          '/create_incident': (context) => const AuthGuard(child: CreateIncidentScreen()),
          '/notifications': (context) => const AuthGuard(child: NotificationsScreen()),
        },
      ),
    );
  }
}
