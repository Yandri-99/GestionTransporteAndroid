import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../../domain/model/order.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_message.dart';

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
          SnackBar(content: Text(provider.successMessage!), backgroundColor: Colors.green),
        );
        provider.clearMessages();
      }
      if (provider.error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.error!), backgroundColor: Colors.red),
        );
        provider.clearMessages();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Incidencias'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
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
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text('No hay incidencias'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
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
        title: const Text('Eliminar incidencia'),
        content: Text('¿Eliminar "${incident.incidentTypeName}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(onPressed: () { Navigator.pop(ctx); provider.deleteIncident(incident.id); }, child: const Text('Eliminar')),
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
      'high' => theme.colorScheme.error,
      'medium' => theme.colorScheme.tertiary,
      _ => theme.colorScheme.primary,
    };

    return Card(
      color: incident.status == 'resolved'
          ? theme.colorScheme.surfaceContainerHighest
          : null,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Icon(Icons.report, color: severityColor),
                  const SizedBox(width: 8),
                  Text(incident.incidentTypeName,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                ]),
                Chip(
                  label: Text(incident.severity.toUpperCase(),
                      style: const TextStyle(fontSize: 11)),
                  backgroundColor: severityColor.withAlpha(50),
                ),
              ],
            ),
            if (incident.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(incident.description),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(incident.status.replaceAll('_', ' ').toUpperCase(),
                    style: TextStyle(
                      color: incident.status == 'resolved' ? Colors.grey : severityColor,
                      fontSize: 12,
                    )),
                Row(
                  children: [
                    if (incident.status != 'resolved' && isAdmin)
                      FilledButton.tonal(
                        onPressed: onResolve,
                        child: const Text('Resolver'),
                      ),
                    if (isAdmin) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        color: theme.colorScheme.error,
                        onPressed: onDelete,
                        tooltip: 'Eliminar',
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
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

    return Scaffold(
      appBar: AppBar(title: const Text('Reportar Incidencia')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Reportar una incidencia en la ruta'),
            const SizedBox(height: 16),
            const Text('Tipo de Incidencia'),
            const SizedBox(height: 8),
            Row(
              children: _types.entries.map((e) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(e.value),
                    selected: _incidentTypeId == e.key,
                    onSelected: (_) => setState(() => _incidentTypeId = e.key),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('Severidad'),
            const SizedBox(height: 8),
            Row(
              children: ['low', 'medium', 'high'].map((s) {
                final first = s[0].toUpperCase() + s.substring(1);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(first),
                    selected: _severity == s,
                    onSelected: (_) => setState(() => _severity = s),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descCtrl,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _latCtrl,
                    decoration: const InputDecoration(labelText: 'Latitud', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _lngCtrl,
                    decoration: const InputDecoration(labelText: 'Longitud', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            if (provider.error != null) ...[
              const SizedBox(height: 8),
              Text(provider.error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _descCtrl.text.isNotEmpty && !provider.isLoading ? _submit : null,
                child: provider.isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Reportar Incidencia'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
