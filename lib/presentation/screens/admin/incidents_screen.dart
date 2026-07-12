import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../../domain/model/order.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_message.dart';
import '../../../theme/app_colors.dart';

class IncidentsScreen extends StatefulWidget {
  const IncidentsScreen({super.key});

  @override
  State<IncidentsScreen> createState() => _IncidentsScreenState();
}

class _IncidentsScreenState extends State<IncidentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadIncidents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderProvider>();
    final isAdmin = context.watch<AuthProvider>().isAdmin;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (provider.successMessage != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.successMessage!), backgroundColor: AppColors.success),
        );
        provider.clearMessages();
      }
      if (provider.error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.error!), backgroundColor: AppColors.error),
        );
        provider.clearMessages();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Incidencias'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/create_incident'),
          ),
        ],
      ),
      body: _buildBody(provider, isAdmin),
    );
  }

  Widget _buildBody(OrderProvider provider, bool isAdmin) {
    if (provider.isLoading) return const LoadingIndicator();
    if (provider.error != null) {
      return ErrorMessage(
        message: provider.error!,
        onRetry: () => provider.loadIncidents(),
      );
    }

    if (provider.incidents.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: AppColors.success.withAlpha(15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_circle, size: 44, color: AppColors.success.withAlpha(180)),
            ),
            const SizedBox(height: 16),
            Text('No hay incidencias', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Todo está en orden', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: provider.incidents.length,
      itemBuilder: (context, index) {
        final incident = provider.incidents[index];
        return _IncidentCard(
          incident: incident,
          isAdmin: isAdmin,
          onResolve: () => provider.resolveIncident(incident.id),
          onDelete: () => _confirmDelete(context, provider, incident),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, OrderProvider provider, Incident incident) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar incidencia'),
        content: Text('¿Eliminar "${incident.incidentTypeName}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () { Navigator.pop(ctx); provider.deleteIncident(incident.id); },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

class _IncidentCard extends StatelessWidget {
  final Incident incident;
  final bool isAdmin;
  final VoidCallback onResolve;
  final VoidCallback onDelete;

  const _IncidentCard({
    required this.incident,
    required this.isAdmin,
    required this.onResolve,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final severityColor = switch (incident.severity) {
      'high' => AppColors.error,
      'medium' => AppColors.warning,
      _ => AppColors.primary,
    };
    final isResolved = incident.status == 'resolved';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isResolved ? AppColors.success.withAlpha(30) : severityColor.withAlpha(30)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                          color: (isResolved ? AppColors.success : severityColor).withAlpha(20),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isResolved ? Icons.check_circle : Icons.report,
                          color: isResolved ? AppColors.success : severityColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(incident.incidentTypeName, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text(incident.createdAt, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: severityColor.withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(incident.severity.toUpperCase(),
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: severityColor)),
                  ),
                ],
              ),
              if (incident.description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(incident.description, style: theme.textTheme.bodyLarge),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: (isResolved ? AppColors.success : severityColor).withAlpha(15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isResolved ? 'RESUELTA' : 'ABIERTA',
                      style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w600,
                        color: isResolved ? AppColors.success : severityColor,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      if (!isResolved && isAdmin)
                        FilledButton.tonal(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.success.withAlpha(30),
                            foregroundColor: AppColors.success,
                          ),
                          onPressed: onResolve,
                          child: const Text('Resolver', style: TextStyle(fontSize: 13)),
                        ),
                      if (isAdmin) ...[
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 36, height: 36,
                          child: IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20),
                            color: AppColors.error,
                            onPressed: onDelete,
                            tooltip: 'Eliminar',
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CreateIncidentScreen extends StatefulWidget {
  const CreateIncidentScreen({super.key});

  @override
  State<CreateIncidentScreen> createState() => _CreateIncidentScreenState();
}

class _CreateIncidentScreenState extends State<CreateIncidentScreen> {
  final _descCtrl = TextEditingController();
  final _latCtrl = TextEditingController(text: '-0.1694');
  final _lngCtrl = TextEditingController(text: '-78.4779');
  String _severity = 'medium';
  int _incidentTypeId = 1;
  final _types = {1: 'Accidente', 2: 'Falla Mecánica', 3: 'Retraso'};

  @override
  void dispose() {
    _descCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final incident = Incident(
      id: 0,
      tripId: 1,
      incidentTypeId: _incidentTypeId,
      description: _descCtrl.text.trim(),
      severity: _severity,
      latitude: double.tryParse(_latCtrl.text) ?? 0,
      longitude: double.tryParse(_lngCtrl.text) ?? 0,
    );
    if (!mounted) return;
    context.read<OrderProvider>().createIncident(incident).then((_) {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Reportar Incidencia')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withAlpha(20),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.report, color: AppColors.secondary, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Text('Nueva Incidencia', style: theme.textTheme.titleLarge),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Reporta una incidencia en la ruta', style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Tipo de Incidencia', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _types.entries.map((e) {
                final selected = _incidentTypeId == e.key;
                return ChoiceChip(
                  label: Text(e.value, style: const TextStyle(color: Colors.black87)),
                  selected: selected,
                  selectedColor: AppColors.primary.withAlpha(30),
                  onSelected: (_) => setState(() => _incidentTypeId = e.key),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Text('Tipo de gravedad', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: ['low', 'medium', 'high'].map((s) {
                final selected = _severity == s;
                final label = s[0].toUpperCase() + s.substring(1);
                final color = s == 'high' ? AppColors.error : (s == 'medium' ? AppColors.warning : AppColors.primary);
                return ChoiceChip(
                  label: Text(label, style: const TextStyle(color: Colors.black87)),
                  selected: selected,
                  selectedColor: color.withAlpha(30),
                  onSelected: (_) => setState(() => _severity = s),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Text('Descripción', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            TextField(
              controller: _descCtrl,
              decoration: const InputDecoration(
                hintText: 'Describe la incidencia...',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 20),
            Text('Ubicación', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _latCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Latitud',
                      prefixIcon: Icon(Icons.explore_outlined, size: 20),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _lngCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Longitud',
                      prefixIcon: Icon(Icons.explore_outlined, size: 20),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _descCtrl.text.isNotEmpty && !provider.isLoading ? _submit : null,
                icon: provider.isLoading
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                    : const Icon(Icons.send),
                label: Text(provider.isLoading ? 'Enviando...' : 'Reportar Incidencia'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
