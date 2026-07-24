import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Acerca de')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(60),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.directions_bus, color: Colors.white, size: 48),
              ),
            ),
            const SizedBox(height: 16),
            Text('MoviCore', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Transporte Público Inteligente',
                style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.primary)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('Versión 1.0.0', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 32),

            _buildSection(
              context,
              icon: Icons.info_outline,
              title: 'Descripción',
              isDark: isDark,
              child: Text(
                'MoviCore es una aplicación móvil diseñada para mejorar la experiencia '
                'del transporte público en la ciudad de Quito, Ecuador. Permite a los '
                'usuarios consultar rutas, monitorear incidencias en tiempo real y '
                'gestionar el sistema de transporte de manera eficiente.',
                style: theme.textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 16),

            _buildSection(
              context,
              icon: Icons.group,
              title: 'Equipo de Desarrollo',
              isDark: isDark,
              child: Column(
                children: [
                  _TeamMember(name: 'Yandri Llumiquinga', role: 'Desarrollador', icon: Icons.code),
                  const Divider(height: 20),
                  _TeamMember(name: 'Edison Tanqueño', role: 'Desarrollador', icon: Icons.code),
                  const Divider(height: 20),
                  _TeamMember(name: 'Alexander Calo', role: 'Desarrollador', icon: Icons.code),
                ],
              ),
            ),
            const SizedBox(height: 16),

            _buildSection(
              context,
              icon: Icons.build,
              title: 'Tecnologías',
              isDark: isDark,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _TechChip(label: 'Flutter', icon: Icons.phone_android),
                  _TechChip(label: 'Django REST', icon: Icons.storage),
                  _TechChip(label: 'PostgreSQL', icon: Icons.cloud),
                  _TechChip(label: 'Provider', icon: Icons.notifications),
                  _TechChip(label: 'Dio', icon: Icons.sync),
                  _TechChip(label: 'Flutter Map', icon: Icons.map),
                ],
              ),
            ),
            const SizedBox(height: 16),

            _buildSection(
              context,
              icon: Icons.star_outline,
              title: 'Características',
              isDark: isDark,
              child: Column(
                children: [
                  _FeatureItem(text: 'Consulta de rutas en tiempo real'),
                  _FeatureItem(text: 'Mapa interactivo con paradas'),
                  _FeatureItem(text: 'Reporte y seguimiento de incidencias'),
                  _FeatureItem(text: 'Gestión administrativa completa'),
                  _FeatureItem(text: 'Tema claro y oscuro'),
                  _FeatureItem(text: 'Permisos de ubicación'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            _buildSection(
              context,
              icon: Icons.school,
              title: 'Proyecto Académico',
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Materia: Programación - Seminario', style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  Text('Paralelo: Noche', style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  Text('Instituto: UTE', style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  Text('Fecha: Julio 2026', style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
            const SizedBox(height: 32),

            Text(
              'Hecho con Flutter y Django',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
            ),
            const SizedBox(height: 8),
            Icon(Icons.favorite, color: AppColors.secondary, size: 16),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required IconData icon, required String title, required bool isDark, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceContainer : AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkOutline.withAlpha(60) : AppColors.outline.withAlpha(40),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _TeamMember extends StatelessWidget {
  final String name;
  final String role;
  final IconData icon;

  const _TeamMember({required this.name, required this.role, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.primary.withAlpha(20),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              Text(role, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
        ),
      ],
    );
  }
}

class _TechChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _TechChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withAlpha(30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primary)),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String text;
  const _FeatureItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: AppColors.success),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
