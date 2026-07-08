import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';

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
        backgroundColor: theme.colorScheme.primaryContainer,
        foregroundColor: theme.colorScheme.onPrimaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => auth.logout(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bienvenido, ${auth.user?.fullName ?? ''}',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Chip(
              avatar: const Icon(Icons.admin_panel_settings, size: 18),
              label: const Text('Administrador'),
            ),
            const SizedBox(height: 24),
            Text('Indicadores del Sistema',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _KpiCard(title: 'Viajes Hoy', value: '1', icon: Icons.directions_bus, theme: theme)),
                const SizedBox(width: 12),
                Expanded(child: _KpiCard(title: 'Vehículos', value: '2', icon: Icons.local_shipping, theme: theme)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _KpiCard(title: 'Incidencias', value: '$openIncidents', icon: Icons.report, theme: theme)),
                const SizedBox(width: 12),
                Expanded(child: _KpiCard(title: 'Puntualidad', value: '0%', icon: Icons.timeline, theme: theme)),
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
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final ThemeData theme;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(height: 8),
            Text(value, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            Text(title, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
