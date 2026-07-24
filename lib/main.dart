import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/services/analytics_service.dart';
import 'core/services/push_notification_service.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/catalog_provider.dart';
import 'presentation/providers/order_provider.dart';
import 'presentation/providers/notification_provider.dart';
import 'presentation/providers/driver_provider.dart';
import 'presentation/providers/driver_assignment_provider.dart';
import 'presentation/providers/profile_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/navigation/app_router.dart';
import 'theme/app_theme.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Configurar navigator key y pedir permisos de notificación
  PushNotificationService().setNavigatorKey(navigatorKey);
  await PushNotificationService().initialize();

  runApp(const MoviCoreApp());
}

class MoviCoreApp extends StatelessWidget {
  const MoviCoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CatalogProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => DriverProvider()),
        ChangeNotifierProvider(create: (_) => DriverAssignmentProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProv, _) {
          return MaterialApp(
            title: 'MoviCore',
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeProv.themeMode,
            initialRoute: AppRouter.splash,
            routes: AppRouter.routeMap,
            navigatorObservers: [AnalyticsService().observer],
            builder: (context, child) {
              return GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: child,
              );
            },
          );
        },
      ),
    );
  }
}
