import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/profile_provider.dart';
import '../../../theme/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ProfileProvider>();
    final theme = Theme.of(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (prov.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(prov.error!), backgroundColor: AppColors.error),
        );
        prov.clearMessages();
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: prov.isLoading && prov.profile == null
          ? const Center(child: CircularProgressIndicator())
          : prov.profile == null
              ? const Center(child: Text('No se pudo cargar el perfil'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 55,
                        backgroundColor: AppColors.primary.withAlpha(20),
                        backgroundImage: prov.profile!.avatar != null
                            ? NetworkImage(prov.profile!.avatar!)
                            : null,
                        child: prov.profile!.avatar == null
                            ? Text(
                                prov.initials,
                                style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary),
                              )
                            : null,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${prov.profile!.firstName} ${prov.profile!.lastName}'
                                    .trim()
                                    .isNotEmpty
                            ? '${prov.profile!.firstName} ${prov.profile!.lastName}'
                            : prov.profile!.username,
                        style: theme.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '@${prov.profile!.username}',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 24),
                      _buildInfoCard(
                        theme,
                        'Datos de Cuenta',
                        Icons.person,
                        AppColors.primary,
                        [
                          _infoRow('Nombre de usuario', prov.profile!.username),
                          _infoRow('Nombre', prov.profile!.firstName),
                          _infoRow('Apellidos', prov.profile!.lastName),
                          _infoRow('Correo', prov.profile!.email),
                          _infoRow('Teléfono', prov.profile!.phone),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInfoCard(
                        theme,
                        'Dirección',
                        Icons.home,
                        AppColors.secondary,
                        [
                          _infoRow('Dirección', prov.profile!.address),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInfoCard(
                        theme,
                        'Contacto de Emergencia',
                        Icons.emergency,
                        AppColors.error,
                        [
                          _infoRow(
                              'Nombre del contacto', prov.profile!.emergencyContact),
                          _infoRow('Teléfono de emergencia',
                              prov.profile!.emergencyPhone),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoCard(ThemeData theme, String title, IconData icon,
      Color color, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 10),
                Text(title,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 2),
          Text(
            value.isNotEmpty ? value : '—',
            style: const TextStyle(fontSize: 15),
          ),
        ],
      ),
    );
  }
}
