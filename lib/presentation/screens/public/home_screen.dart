import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../../theme/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 360;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: isSmall ? 200 : 260,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.headerGradientStart, AppColors.headerGradientEnd],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(24, isSmall ? 40 : 60, 24, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 40, height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withAlpha(30),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.directions_bus, color: Colors.white, size: 24),
                                ),
                                const SizedBox(width: 12),
                                const Text('MoviCore',
                                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                              ],
                            ),
                            Row(
                              children: [
                                if (auth.isLoggedIn)
                                  IconButton(
                                    icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                                    onPressed: () => Navigator.pushNamed(context, '/notifications'),
                                  ),
                                if (auth.isLoggedIn)
                                  IconButton(
                                    icon: const Icon(Icons.logout, color: Colors.white),
                                    onPressed: () => _confirmLogout(context),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text('Transporte Público',
                            style: TextStyle(fontSize: isSmall ? 24 : 32, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 4),
                        Text('Inteligente', style: TextStyle(fontSize: isSmall ? 16 : 20, color: Colors.white70)),
                        const SizedBox(height: 8),
                        Row(
                          children: List.generate(3, (i) => Container(
                            width: i == 0 ? 24 : 8, height: 8,
                            margin: const EdgeInsets.only(right: 4),
                            decoration: BoxDecoration(
                              color: i == 0 ? AppColors.secondary : Colors.white38,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          )),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(
                children: [
                  _FeatureCard(
                    icon: Icons.route,
                    iconColor: AppColors.primary,
                    title: 'Explora las rutas de Quito',
                    subtitle: 'Descubre todas las rutas de transporte público disponibles en la ciudad.',
                    buttonLabel: 'Ver Rutas Disponibles',
                    buttonType: 'primary',
                    onPressed: () => Navigator.pushNamed(context, '/routes'),
                  ),
                  const SizedBox(height: 16),
                  if (auth.isLoggedIn)
                    _FeatureCard(
                      icon: Icons.report_outlined,
                      iconColor: AppColors.secondary,
                      title: 'Reportar Incidencia',
                      subtitle: 'Ayuda a mejorar el servicio reportando incidencias en las rutas.',
                      buttonLabel: 'Reportar Incidencia',
                      buttonType: 'outlined',
                      onPressed: () => Navigator.pushNamed(context, '/incidents'),
                    ),
                  if (!auth.isLoggedIn)
                    _LoginPrompt(onPressed: () => Navigator.pushNamed(context, '/login')),
                  if (auth.isAdmin) ...[
                    const SizedBox(height: 16),
                    _FeatureCard(
                      icon: Icons.dashboard_outlined,
                      iconColor: AppColors.tertiary,
                      title: 'Panel de Administración',
                      subtitle: 'Gestiona usuarios, incidencias y monitorea el sistema.',
                      buttonLabel: 'Ir al Panel Admin',
                      buttonType: 'tonal',
                      onPressed: () => Navigator.pushNamed(context, '/admin'),
                    ),
                  ],
                ],
              ),
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

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final String buttonType;
  final VoidCallback onPressed;

  const _FeatureCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.buttonType,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [iconColor.withAlpha(15), iconColor.withAlpha(5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: iconColor.withAlpha(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 28),
              const SizedBox(width: 12),
              Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge)),
            ],
          ),
          const SizedBox(height: 8),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: switch (buttonType) {
              'outlined' => OutlinedButton.icon(
                  onPressed: onPressed, icon: const Icon(Icons.flag_outlined), label: Text(buttonLabel)),
              'tonal' => FilledButton.tonalIcon(
                  onPressed: onPressed, icon: const Icon(Icons.shield_outlined), label: Text(buttonLabel)),
              _ => ElevatedButton.icon(
                  onPressed: onPressed, icon: const Icon(Icons.map_outlined), label: Text(buttonLabel)),
            },
          ),
        ],
      ),
    );
  }
}

class _LoginPrompt extends StatelessWidget {
  final VoidCallback onPressed;
  const _LoginPrompt({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline.withAlpha(40)),
      ),
      child: Column(
        children: [
          Icon(Icons.person_outline, size: 48, color: AppColors.onSurfaceVariant),
          const SizedBox(height: 12),
          Text('Inicia sesión para reportar incidencias',
              style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.login),
              label: const Text('Iniciar Sesión'),
            ),
          ),
        ],
      ),
    );
  }
}
