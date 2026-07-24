import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/driver_provider.dart';
import '../../providers/auth_provider.dart';
import '../../../domain/model/driver.dart';
import '../../../theme/app_colors.dart';

class AdminDriversScreen extends StatefulWidget {
  const AdminDriversScreen({super.key});

  @override
  State<AdminDriversScreen> createState() => _AdminDriversScreenState();
}

class _AdminDriversScreenState extends State<AdminDriversScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DriverProvider>().loadDrivers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DriverProvider>();

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
        title: const Text('Gestionar Conductores'),
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

  Widget _buildBody(DriverProvider provider) {
    if (provider.isLoading && provider.drivers.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.drivers.isEmpty) {
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
              child: Icon(Icons.person, size: 44, color: AppColors.primary.withAlpha(180)),
            ),
            const SizedBox(height: 16),
            Text('No hay conductores', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Crea un nuevo conductor con el botón +', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadDrivers(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        itemCount: provider.drivers.length,
        itemBuilder: (context, index) {
          final driver = provider.drivers[index];
          return _DriverCard(
            driver: driver,
            onEdit: () => _showForm(context, driver),
            onDelete: () => _confirmDelete(context, provider, driver),
          );
        },
      ),
    );
  }

  void _showForm(BuildContext context, Driver? driver) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _DriverFormScreen(driver: driver)),
    );
  }

  void _confirmDelete(BuildContext context, DriverProvider provider, Driver driver) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar conductor'),
        content: Text('Eliminar a "${driver.displayName}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              provider.deleteDriver(driver.id);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

class _DriverCard extends StatelessWidget {
  final Driver driver;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _DriverCard({required this.driver, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = driver.isActive ? AppColors.success : AppColors.error;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primary.withAlpha(20),
              child: Text(
                driver.displayName.isNotEmpty ? driver.displayName[0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(driver.displayName, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('Licencia: ${driver.licenseNumber}', style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13)),
                  if (driver.licenseType.isNotEmpty)
                    Text('Tipo: ${driver.licenseType}', style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12)),
                  if (driver.hireDate.isNotEmpty)
                    Text('Contratado: ${driver.hireDate}', style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12)),
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    driver.isActive ? 'ACTIVO' : 'INACTIVO',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor),
                  ),
                ),
                const SizedBox(height: 8),
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
          ],
        ),
      ),
    );
  }
}

class _DriverFormScreen extends StatefulWidget {
  final Driver? driver;
  const _DriverFormScreen({this.driver});

  @override
  State<_DriverFormScreen> createState() => _DriverFormScreenState();
}

class _DriverFormScreenState extends State<_DriverFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _userIdCtrl;
  late final TextEditingController _licenseCtrl;
  String? _licenseType;
  late final TextEditingController _hireDateCtrl;
  late final TextEditingController _yearsExpCtrl;
  late final TextEditingController _observationsCtrl;
  bool _isActive = true;
  bool _isAvailable = true;
  bool _isEditing = false;

  static const _licenseTypes = [
    ('A', 'Tipo A (Automóvil)'),
    ('B', 'Tipo B (Camioneta)'),
    ('C', 'Tipo C (Bus)'),
    ('D', 'Tipo D (Camión)'),
    ('E', 'Tipo E (Pesado)'),
  ];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.driver != null;
    final authUser = context.read<AuthProvider>().user;
    final existingId = widget.driver?.userId != null && widget.driver!.userId > 0 ? widget.driver!.userId.toString() : '';
    _userIdCtrl = TextEditingController(text: existingId.isNotEmpty ? existingId : (authUser?.id.toString() ?? ''));
    _licenseCtrl = TextEditingController(text: widget.driver?.licenseNumber ?? '');
    final rawType = widget.driver?.licenseType ?? '';
    if (rawType.length == 1 && 'ABCDE'.contains(rawType)) {
      _licenseType = rawType;
    } else if (rawType.isNotEmpty) {
      final match = _licenseTypes.where((t) => t.$1 == rawType || t.$2 == rawType);
      _licenseType = match.isNotEmpty ? match.first.$1 : rawType;
    } else {
      _licenseType = null;
    }
    _hireDateCtrl = TextEditingController(text: widget.driver?.hireDate ?? '');
    _yearsExpCtrl = TextEditingController(text: widget.driver != null ? widget.driver!.experienceYears.toString() : '0');
    _observationsCtrl = TextEditingController(text: widget.driver?.observations ?? '');
    _isActive = widget.driver?.isActive ?? true;
    _isAvailable = widget.driver?.isAvailable ?? true;
  }

  @override
  void dispose() {
    _userIdCtrl.dispose();
    _licenseCtrl.dispose();
    _hireDateCtrl.dispose();
    _yearsExpCtrl.dispose();
    _observationsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _hireDateCtrl.text.isNotEmpty
          ? DateTime.tryParse(_hireDateCtrl.text) ?? now
          : now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _hireDateCtrl.text = picked.toIso8601String().split('T')[0]);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<DriverProvider>();
    final driver = Driver(
      id: widget.driver?.id ?? 0,
      userId: int.tryParse(_userIdCtrl.text) ?? 0,
      licenseNumber: _licenseCtrl.text.trim(),
      licenseType: _licenseType ?? '',
      hireDate: _hireDateCtrl.text.trim(),
      experienceYears: int.tryParse(_yearsExpCtrl.text) ?? 0,
      observations: _observationsCtrl.text.trim(),
      isAvailable: _isAvailable,
      isActive: _isActive,
    );

    final future = _isEditing ? provider.updateDriver(driver) : provider.createDriver(driver);
    future.then((success) {
      if (mounted && success) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DriverProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Editar Conductor' : 'Crear Conductor')),
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
                            child: const Icon(Icons.person, color: AppColors.primary, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Text(_isEditing ? 'Editar Conductor' : 'Nuevo Conductor', style: theme.textTheme.titleLarge),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Completa los datos del conductor', style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('ID de Usuario', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              TextFormField(
                controller: _userIdCtrl,
                decoration: const InputDecoration(
                  hintText: 'Ej: 17',
                  prefixIcon: Icon(Icons.account_circle_outlined),
                  helperText: 'Busca el ID en Django Admin > Usuarios',
                  helperMaxLines: 2,
                ),
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              Text('Número de Licencia', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              TextFormField(
                controller: _licenseCtrl,
                decoration: const InputDecoration(
                  hintText: 'Ej: LIC-001234',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              Text('Tipo de Licencia', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _licenseType,
                decoration: const InputDecoration(
                  hintText: 'Seleccionar tipo',
                  prefixIcon: Icon(Icons.card_membership_outlined),
                ),
                items: _licenseTypes.map((t) {
                  return DropdownMenuItem(value: t.$1, child: Text(t.$2));
                }).toList(),
                onChanged: (v) => setState(() => _licenseType = v),
              ),
              const SizedBox(height: 16),
              Text('Fecha de contratación', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              TextFormField(
                controller: _hireDateCtrl,
                decoration: const InputDecoration(
                  hintText: 'Seleccionar fecha',
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                ),
                readOnly: true,
                onTap: _pickDate,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              Text('Años de experiencia', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              TextFormField(
                controller: _yearsExpCtrl,
                decoration: const InputDecoration(
                  hintText: '0',
                  prefixIcon: Icon(Icons.work_outline),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              Text('Observaciones', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              TextFormField(
                controller: _observationsCtrl,
                decoration: const InputDecoration(
                  hintText: 'Notas adicionales...',
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text('Disponible', style: theme.textTheme.titleMedium),
                  const SizedBox(width: 12),
                  Switch(
                    value: _isAvailable,
                    onChanged: (v) => setState(() => _isAvailable = v),
                    activeThumbColor: AppColors.primary,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('Activo', style: theme.textTheme.titleMedium),
                  const SizedBox(width: 12),
                  Switch(
                    value: _isActive,
                    onChanged: (v) => setState(() => _isActive = v),
                    activeThumbColor: AppColors.success,
                  ),
                ],
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
                  label: Text(provider.isLoading ? 'Guardando...' : (_isEditing ? 'Guardar cambios' : 'Crear conductor')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
