import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/catalog_provider.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_message.dart';
import '../../../theme/app_colors.dart';

class RoutesScreen extends StatefulWidget {
  const RoutesScreen({super.key});

  @override
  State<RoutesScreen> createState() => _RoutesScreenState();
}

class _RoutesScreenState extends State<RoutesScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CatalogProvider>().loadRoutes();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CatalogProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Rutas Disponibles')),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(CatalogProvider provider) {
    if (provider.isLoading) return const LoadingIndicator();
    if (provider.error != null) {
      return ErrorMessage(
        message: provider.error!,
        onRetry: () => provider.loadRoutes(),
      );
    }
    if (provider.routes.isEmpty && _searchCtrl.text.isEmpty) {
      return const Center(child: Text('No hay rutas disponibles'));
    }

    final query = _searchCtrl.text.toLowerCase();
    final filtered = query.isEmpty
        ? provider.routes
        : provider.routes
              .where(
                (r) =>
                    r.name.toLowerCase().contains(query) ||
                    r.code.toLowerCase().contains(query) ||
                    r.description.toLowerCase().contains(query),
              )
              .toList();

    if (filtered.isEmpty) {
      return Column(
        children: [
          _buildSearchField(),
          Expanded(
            child: Center(
              child: Text(
                _searchCtrl.text.isEmpty
                    ? 'No hay rutas disponibles'
                    : 'No se encontraron rutas',
              ),
            ),
          ),
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadRoutes(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        itemCount: filtered.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) return _buildSearchField();

          final route = filtered[index - 1];
          final colors = [
            AppColors.primary,
            AppColors.secondary,
            AppColors.tertiary,
            const Color(0xFFE65100),
          ];
          final color = colors[index % colors.length];

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => Navigator.pushNamed(
                context,
                '/route_detail',
                arguments: route.id,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: color.withAlpha(20),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(Icons.route, color: color, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                route.name,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: color.withAlpha(20),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  route.code,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                  if (route.description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Text(
                        route.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: _searchCtrl,
        decoration: InputDecoration(
          hintText: 'Buscar ruta...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchCtrl.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() {});
                  },
                ),
          filled: true,
          fillColor: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withAlpha(80),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }
}
