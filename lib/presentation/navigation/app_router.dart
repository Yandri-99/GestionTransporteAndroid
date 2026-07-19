import 'package:flutter/material.dart';
import '../screens/public/splash_screen.dart';
import '../screens/public/onboarding_screen.dart';
import '../screens/public/welcome_screen.dart';
import '../screens/public/home_screen.dart';
import '../screens/public/routes_screen.dart';
import '../screens/public/route_detail_screen.dart';
import '../screens/public/route_map_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/admin/admin_home_screen.dart';
import '../screens/admin/incidents_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../widgets/auth_guard.dart';

class AppRouter {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String welcome = '/welcome';
  static const String home = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String routesPath = '/routes';
  static const String routeDetail = '/route_detail';
  static const String routeMapPath = '/route_map';
  static const String admin = '/admin';
  static const String incidents = '/incidents';
  static const String createIncident = '/create_incident';
  static const String notifications = '/notifications';

  static Map<String, WidgetBuilder> get routeMap {
    return {
      splash: (context) => const SplashScreen(),
      onboarding: (context) => const OnboardingScreen(),
      welcome: (context) => const WelcomeScreen(),
      home: (context) => const HomeScreen(),
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      routesPath: (context) => const RoutesScreen(),
      routeDetail: (context) => const RouteDetailScreen(),
      routeMapPath: (context) => const RouteMapScreen(),
      admin: (context) =>
          const AuthGuard(requireAdmin: true, child: AdminHomeScreen()),
      incidents: (context) => const AuthGuard(child: IncidentsScreen()),
      createIncident: (context) =>
          const AuthGuard(child: CreateIncidentScreen()),
      notifications: (context) => const AuthGuard(child: NotificationsScreen()),
    };
  }
}
