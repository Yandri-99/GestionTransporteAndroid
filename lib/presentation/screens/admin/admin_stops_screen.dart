import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/catalog_provider.dart';
import '../../../domain/model/product.dart';
import '../../../theme/app_colors.dart';

class AdminStopsScreen extends StatefulWidget {
  const AdminStopsScreen({super.key});

  @override
  State<AdminStopsScreen> createState() => _AdminStopsScreenState();
}

class _AdminStopsScreenState extends State<AdminStopsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CatalogProvider>().loadAllStops();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CatalogProvider>();

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
        title: const Text('Gestionar Paradas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
            onPressed: () => _showForm(context, null),
          ),
        ],
      ),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(CatalogProvider provider) {
    if (provider.isLoading && provider.allStops.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.allStops.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: AppColors.tertiary.withAlpha(15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.location_on_outlined, size: 44, color: AppColors.tertiary.withAlpha(180)),
            ),
            const SizedBox(height: 16),
            Text('No hay paradas', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Crea una nueva parada con el botón +', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadAllStops(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        itemCount: provider.allStops.length,
        itemBuilder: (context, index) {
          final stop = provider.allStops[index];
          return _StopCard(
            stop: stop,
            onEdit: () => _showForm(context, stop),
            onDelete: () => _confirmDelete(context, provider, stop),
          );
        },
      ),
    );
  }

  void _showForm(BuildContext context, BusStop? stop) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _StopFormScreen(stop: stop)),
    );
  }

  void _confirmDelete(BuildContext context, CatalogProvider provider, BusStop stop) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar parada'),
        content: Text('Eliminar la parada "${stop.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              provider.deleteStop(stop.id);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

class _StopCard extends StatelessWidget {
  final BusStop stop;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _StopCard({required this.stop, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: AppColors.tertiary.withAlpha(20),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.location_on_outlined, color: AppColors.tertiary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(stop.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('Código: ${stop.code}', style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13)),
                  Text('${stop.latitude.toStringAsFixed(4)}, ${stop.longitude.toStringAsFixed(4)}',
                      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12)),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  color: AppColors.primary,
                  onPressed: onEdit,
                  tooltip: 'Editar',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: AppColors.error,
                  onPressed: onDelete,
                  tooltip: 'Eliminar',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StopFormScreen extends StatefulWidget {
  final BusStop? stop;
  const _StopFormScreen({this.stop});

  @override
  State<_StopFormScreen> createState() => _StopFormScreenState();
}

class _StopFormScreenState extends State<_StopFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _latCtrl;
  late final TextEditingController _lngCtrl;
  late final TextEditingController _orderCtrl;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.stop != null;
    _codeCtrl = TextEditingController(text: widget.stop?.code ?? '');
    _nameCtrl = TextEditingController(text: widget.stop?.name ?? '');
    _latCtrl = TextEditingController(text: widget.stop?.latitude.toString() ?? '');
    _lngCtrl = TextEditingController(text: widget.stop?.longitude.toString() ?? '');
    _orderCtrl = TextEditingController(text: widget.stop?.stopOrder.toString() ?? '0');
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    _orderCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<CatalogProvider>();
    final stop = BusStop(
      id: widget.stop?.id ?? 0,
      code: _codeCtrl.text.trim(),
      name: _nameCtrl.text.trim(),
      latitude: double.tryParse(_latCtrl.text) ?? 0,
      longitude: double.tryParse(_lngCtrl.text) ?? 0,
      stopOrder: int.tryParse(_orderCtrl.text) ?? 0,
    );

    final future = _isEditing ? provider.updateStop(stop) : provider.createStop(stop);
    future.then((success) {
      if (mounted && success) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CatalogProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Editar Parada' : 'Crear Parada')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Form(
          key: _formKey,
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
                              color: AppColors.tertiary.withAlpha(20),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.location_on_outlined, color: AppColors.tertiary, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Text(_isEditing ? 'Editar Parada' : 'Nueva Parada', style: theme.textTheme.titleLarge),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Completa los datos de la parada', style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Código', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              TextFormField(
                controller: _codeCtrl,
                decoration: const InputDecoration(
                  hintText: 'Ej: PAR-001',
                  prefixIcon: Icon(Icons.tag),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              Text('Nombre', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  hintText: 'Ej: Terminal Carcelén',
                  prefixIcon: Icon(Icons.text_fields),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              Text('Ubicación', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Latitud',
                        prefixIcon: Icon(Icons.explore_outlined, size: 20),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lngCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Longitud',
                        prefixIcon: Icon(Icons.explore_outlined, size: 20),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Orden', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              TextFormField(
                controller: _orderCtrl,
                decoration: const InputDecoration(
                  hintText: '0',
                  prefixIcon: Icon(Icons.sort),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: provider.isLoading ? null : _submit,
                  icon: provider.isLoading
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                      : Icon(_isEditing ? Icons.save : Icons.add),
                  label: Text(provider.isLoading ? 'Guardando...' : (_isEditing ? 'Guardar cambios' : 'Crear parada')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
