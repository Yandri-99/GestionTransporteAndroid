import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/catalog_provider.dart';
import '../../../domain/model/product.dart';
import '../../../theme/app_colors.dart';

class AdminRoutesScreen extends StatefulWidget {
  const AdminRoutesScreen({super.key});

  @override
  State<AdminRoutesScreen> createState() => _AdminRoutesScreenState();
}

class _AdminRoutesScreenState extends State<AdminRoutesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CatalogProvider>().loadRoutes();
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
        title: const Text('Gestionar Rutas'),
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
    if (provider.isLoading && provider.routes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.routes.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.route, size: 44, color: AppColors.primary.withAlpha(180)),
            ),
            const SizedBox(height: 16),
            Text('No hay rutas', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Crea una nueva ruta con el botón +', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadRoutes(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        itemCount: provider.routes.length,
        itemBuilder: (context, index) {
          final route = provider.routes[index];
          return _RouteCard(
            route: route,
            onEdit: () => _showForm(context, route),
            onDelete: () => _confirmDelete(context, provider, route),
          );
        },
      ),
    );
  }

  void _showForm(BuildContext context, RouteModel? route) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _RouteFormScreen(route: route),
      ),
    );
  }

  void _confirmDelete(BuildContext context, CatalogProvider provider, RouteModel route) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar ruta'),
        content: Text('Eliminar la ruta "${route.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              provider.deleteRoute(route.id);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

class _RouteCard extends StatelessWidget {
  final RouteModel route;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RouteCard({required this.route, required this.onEdit, required this.onDelete});

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
                color: AppColors.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.route, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(route.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('Código: ${route.code}', style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13)),
                  if (route.description.isNotEmpty)
                    Text(route.description, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12)),
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

class _RouteFormScreen extends StatefulWidget {
  final RouteModel? route;
  const _RouteFormScreen({this.route});

  @override
  State<_RouteFormScreen> createState() => _RouteFormScreenState();
}

class _RouteFormScreenState extends State<_RouteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  bool _isEditing = false;

  String? _selectedCode;
  String? _selectedCompany;

  static const _codeOptions = {
    'RT-ECO': 'Ecovía',
    'RT-TRO': 'Trolebús',
    'RT-ME1': 'Metrovía 1',
    'RT-ME2': 'Metrovía 2',
    'RT-SUR': 'Corredor Sur',
    'RT-NOR': 'Corredor Norte',
    'RT-CHO': 'Corredor Chilibulo',
    'RT-LOS': 'Corredor Los Chillos',
    'RT-INT': 'Intermodal',
  };

  static const _companyOptions = [
    'Metro de Quito',
    'Electricidad de Quito',
    'Transporte Público Quito',
    'Cooperativa de Transporte',
    'Transportes Amazonas',
    'Empresa Pública de Transporte',
  ];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.route != null;
    _selectedCode = widget.route?.code;
    _nameCtrl = TextEditingController(text: widget.route?.name ?? '');
    _descCtrl = TextEditingController(text: widget.route?.description ?? '');
    _selectedCompany = widget.route?.companyName.isNotEmpty == true
        ? widget.route!.companyName
        : null;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<CatalogProvider>();
    final route = RouteModel(
      id: widget.route?.id ?? 0,
      code: _selectedCode ?? '',
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      companyName: _selectedCompany ?? '',
    );

    final future = _isEditing ? provider.updateRoute(route) : provider.createRoute(route);
    future.then((success) {
      if (mounted && success) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CatalogProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Editar Ruta' : 'Crear Ruta')),
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
                              color: AppColors.primary.withAlpha(20),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.route, color: AppColors.primary, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Text(_isEditing ? 'Editar Ruta' : 'Nueva Ruta', style: theme.textTheme.titleLarge),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Completa los datos de la ruta', style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Código', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedCode,
                decoration: const InputDecoration(
                  hintText: 'Seleccionar código',
                  prefixIcon: Icon(Icons.tag),
                ),
                items: _codeOptions.entries.map((e) {
                  return DropdownMenuItem(
                    value: e.key,
                    child: Text('${e.key} — ${e.value}'),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _selectedCode = v),
                validator: (v) => v == null ? 'Selecciona un código' : null,
              ),
              const SizedBox(height: 16),
              Text('Nombre', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  hintText: 'Ej: Ecovía',
                  prefixIcon: Icon(Icons.text_fields),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              Text('Descripción', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(
                  hintText: 'Descripción de la ruta...',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Text('Empresa', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedCompany,
                decoration: const InputDecoration(
                  hintText: 'Seleccionar empresa',
                  prefixIcon: Icon(Icons.business_outlined),
                ),
                items: _companyOptions.map((c) {
                  return DropdownMenuItem(value: c, child: Text(c));
                }).toList(),
                onChanged: (v) => setState(() => _selectedCompany = v),
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
                  label: Text(provider.isLoading ? 'Guardando...' : (_isEditing ? 'Guardar cambios' : 'Crear ruta')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
