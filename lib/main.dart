import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/catalog_provider.dart';
import 'presentation/providers/order_provider.dart';
import 'presentation/providers/notification_provider.dart';
import 'presentation/navigation/app_router.dart';

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
        ChangeNotifierProvider(create: (_) => CatalogProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MaterialApp(
        title: 'MoviCore',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: const Color(0xFF1565C0),
          useMaterial3: true,
        ),
        initialRoute: AppRouter.home,
        routes: AppRouter.routeMap,
      ),
    );
  }
}
