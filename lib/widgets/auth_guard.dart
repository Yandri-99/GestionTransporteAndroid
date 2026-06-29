import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;
  final bool requireAdmin;

  const AuthGuard({super.key, required this.child, this.requireAdmin = false});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!auth.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return const SizedBox.shrink();
    }

    if (requireAdmin && !auth.isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Acceso denegado: se requieren permisos de administrador')),
        );
        Navigator.pushReplacementNamed(context, '/');
      });
      return const SizedBox.shrink();
    }

    return child;
  }
}
