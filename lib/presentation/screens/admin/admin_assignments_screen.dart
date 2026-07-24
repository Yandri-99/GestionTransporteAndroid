import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/driver_assignment_provider.dart';
import '../../providers/driver_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../../domain/model/driver_assignment.dart';
import '../../../theme/app_colors.dart';

class AdminAssignmentsScreen extends StatefulWidget {
  const AdminAssignmentsScreen({super.key});

  @override
  State<AdminAssignmentsScreen> createState() => _AdminAssignmentsScreenState();
}

class _AdminAssignmentsScreenState extends State<AdminAssignmentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final assignmentProv = context.read<DriverAssignmentProvider>();
      final driverProv = context.read<DriverProvider>();
      final catalogProv = context.read<CatalogProvider>();
      assignmentProv.loadAssignments();
      driverProv.loadDrivers();
      catalogProv.loadRoutes();
      catalogProv.loadVehicles();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DriverAssignmentProvider>();

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
        title: const Text('Asignaciones de Rutas'),
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

  Widget _buildBody(DriverAssignmentProvider provider) {
    if (provider.isLoading && provider.assignments.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.assignments.isEmpty) {
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
              child: Icon(Icons.link, size: 44, color: AppColors.primary.withAlpha(180)),
            ),
            const SizedBox(height: 16),
            Text('No hay asignaciones', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Asigna una ruta a un conductor con el botón +', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadAssignments(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        itemCount: provider.assignments.length,
        itemBuilder: (context, index) {
          final assignment = provider.assignments[index];
          return _AssignmentCard(
            assignment: assignment,
            onEdit: () => _showForm(context, assignment),
            onDelete: () => _confirmDelete(context, provider, assignment),
          );
        },
      ),
    );
  }

  void _showForm(BuildContext context, DriverAssignment? assignment) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _AssignmentFormScreen(assignment: assignment)),
    );
  }

  void _confirmDelete(BuildContext context, DriverAssignmentProvider provider, DriverAssignment assignment) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar asignación'),
        content: const Text('¿Estás seguro de eliminar esta asignación?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              provider.deleteAssignment(assignment.id);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  final DriverAssignment assignment;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AssignmentCard({required this.assignment, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = assignment.isActive ? AppColors.success : AppColors.error;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.link, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(assignment.driverName.isNotEmpty ? assignment.driverName : 'Conductor #${assignment.driverId}',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.route, size: 14, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(assignment.routeName.isNotEmpty ? assignment.routeName : 'Ruta #${assignment.routeId}',
                              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    assignment.isActive ? 'ACTIVA' : 'INACTIVA',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor),
                  ),
                ),
              ],
            ),
            if (assignment.assignmentDate.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text('Asignado: ${assignment.assignmentDate}',
                      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ],
            if (assignment.vehiclePlate.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.directions_bus_outlined, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text('Vehículo: ${assignment.vehiclePlate}',
                      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ],
            if (assignment.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(assignment.notes, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12)),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
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

class _AssignmentFormScreen extends StatefulWidget {
  final DriverAssignment? assignment;
  const _AssignmentFormScreen({this.assignment});

  @override
  State<_AssignmentFormScreen> createState() => _AssignmentFormScreenState();
}

class _AssignmentFormScreenState extends State<_AssignmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedDriverId;
  int? _selectedRouteId;
  int? _selectedVehicleId;
  late final TextEditingController _assignmentDateCtrl;
  late final TextEditingController _notesCtrl;
  bool _isActive = true;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.assignment != null;
    _selectedDriverId = widget.assignment?.driverId;
    _selectedRouteId = widget.assignment?.routeId;
    _selectedVehicleId = widget.assignment?.vehicleId != null && widget.assignment!.vehicleId > 0 ? widget.assignment!.vehicleId : null;
    _assignmentDateCtrl = TextEditingController(text: widget.assignment?.assignmentDate ?? '');
    _notesCtrl = TextEditingController(text: widget.assignment?.notes ?? '');
    _isActive = widget.assignment?.isActive ?? true;
  }

  @override
  void dispose() {
    _assignmentDateCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _assignmentDateCtrl.text.isNotEmpty ? DateTime.tryParse(_assignmentDateCtrl.text) ?? now : now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _assignmentDateCtrl.text = picked.toIso8601String().split('T')[0]);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<DriverAssignmentProvider>();
    final assignment = DriverAssignment(
      id: widget.assignment?.id ?? 0,
      driverId: _selectedDriverId ?? 0,
      routeId: _selectedRouteId ?? 0,
      vehicleId: _selectedVehicleId ?? 0,
      assignmentDate: _assignmentDateCtrl.text.trim(),
      notes: _notesCtrl.text.trim(),
      isActive: _isActive,
    );

    final future = _isEditing ? provider.updateAssignment(assignment) : provider.createAssignment(assignment);
    future.then((success) {
      if (mounted && success) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DriverAssignmentProvider>();
    final drivers = context.watch<DriverProvider>().drivers;
    final routes = context.watch<CatalogProvider>().routes;
    final vehicles = context.watch<CatalogProvider>().vehicles;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Editar Asignación' : 'Nueva Asignación')),
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
                            child: const Icon(Icons.link, color: AppColors.primary, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Text(_isEditing ? 'Editar Asignación' : 'Nueva Asignación', style: theme.textTheme.titleLarge),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Asigna un conductor a una ruta', style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Conductor', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                isExpanded: true,
                initialValue: _selectedDriverId,
                decoration: const InputDecoration(
                  hintText: 'Seleccionar conductor',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                items: drivers.map((d) {
                  return DropdownMenuItem(
                    value: d.id,
                    child: Text('${d.displayName} (${d.licenseNumber})', overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _selectedDriverId = v),
                validator: (v) => v == null ? 'Selecciona un conductor' : null,
              ),
              const SizedBox(height: 16),
              Text('Ruta', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                isExpanded: true,
                initialValue: _selectedRouteId,
                decoration: const InputDecoration(
                  hintText: 'Seleccionar ruta',
                  prefixIcon: Icon(Icons.route_outlined),
                ),
                items: routes.map((r) {
                  return DropdownMenuItem(
                    value: r.id,
                    child: Text('${r.code} — ${r.name}', overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _selectedRouteId = v),
                validator: (v) => v == null ? 'Selecciona una ruta' : null,
              ),
              const SizedBox(height: 16),
              Text('Vehículo', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                isExpanded: true,
                initialValue: _selectedVehicleId,
                decoration: const InputDecoration(
                  hintText: 'Seleccionar vehículo',
                  prefixIcon: Icon(Icons.directions_bus_outlined),
                ),
                items: vehicles.map((v) {
                  return DropdownMenuItem(
                    value: v.id,
                    child: Text('${v.plate} — ${v.brand} ${v.model}', overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _selectedVehicleId = v),
                validator: (v) => v == null ? 'Selecciona un vehículo' : null,
              ),
              const SizedBox(height: 16),
              Text('Fecha de asignación', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              TextFormField(
                controller: _assignmentDateCtrl,
                decoration: const InputDecoration(
                  hintText: 'Seleccionar fecha',
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                ),
                readOnly: true,
                onTap: _pickDate,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              Text('Notas', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesCtrl,
                decoration: const InputDecoration(
                  hintText: 'Notas adicionales...',
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text('Activa', style: theme.textTheme.titleMedium),
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
                  label: Text(provider.isLoading ? 'Guardando...' : (_isEditing ? 'Guardar cambios' : 'Crear asignación')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
