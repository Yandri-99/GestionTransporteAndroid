import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../../theme/app_colors.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final incidents = context.watch<OrderProvider>();
    final theme = Theme.of(context);

    final openIncidents = incidents.incidents.where((i) => i.status != 'resolved').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.primary.withAlpha(20),
                        child: Icon(Icons.admin_panel_settings, color: AppColors.primary, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Bienvenido', style: theme.textTheme.bodyMedium),
                          Text(auth.user?.fullName ?? '', style: theme.textTheme.titleLarge),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shield, size: 16, color: AppColors.primary),
                        SizedBox(width: 6),
                        Text('Administrador', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.primary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Indicadores del Sistema', style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _KpiCard(
                title: 'Viajes Hoy',
                value: '1',
                icon: Icons.directions_bus,
                color: AppColors.primary,
              )),
              const SizedBox(width: 12),
              Expanded(child: _KpiCard(
                title: 'Vehículos',
                value: '4',
                icon: Icons.local_shipping,
                color: AppColors.tertiary,
              )),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _KpiCard(
                title: 'Incidencias',
                value: '$openIncidents',
                icon: Icons.report,
                color: AppColors.secondary,
              )),
              const SizedBox(width: 12),
              Expanded(child: _KpiCard(
                title: 'Rutas',
                value: '4',
                icon: Icons.route,
                color: const Color(0xFFE65100),
              )),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/incidents'),
              icon: const Icon(Icons.report),
              label: const Text('Gestionar Incidencias'),
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> _confirmLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sí, cerrar sesión')),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      final auth = context.read<AuthProvider>();
      await auth.logout();
      if (context.mounted) Navigator.pushReplacementNamed(context, '/welcome');
    }
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: color.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 12),
            Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            )),
            const SizedBox(height: 4),
            Text(title, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
