import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/catalog_provider.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_message.dart';
import '../../../theme/app_colors.dart';

class RouteDetailScreen extends StatefulWidget {
  const RouteDetailScreen({super.key});

  @override
  State<RouteDetailScreen> createState() => _RouteDetailScreenState();
}

class _RouteDetailScreenState extends State<RouteDetailScreen> {
  int? _routeId;
  bool _loaded = false;

  Color _routeColor(String? code) {
    return switch (code) {
      'RT-ECO' => AppColors.secondary,
      'RT-TRO' => AppColors.primary,
      'RT-ME1' => const Color(0xFF2E7D32),
      'RT-SUR' => const Color(0xFF880E4F),
      _ => AppColors.primary,
    };
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routeId = ModalRoute.of(context)?.settings.arguments as int?;
    if (routeId != null && routeId != _routeId) {
      _routeId = routeId;
      _loaded = false;
    }
    if (!_loaded && _routeId != null) {
      _loaded = true;
      context.read<CatalogProvider>().loadRouteDetail(_routeId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CatalogProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(provider.selectedRoute?.name ?? 'Detalle Ruta'),
      ),
      body: _buildBody(provider, theme),
    );
  }

  Widget _buildBody(CatalogProvider provider, ThemeData theme) {
    if (provider.isLoading) return const LoadingIndicator();
    if (provider.error != null) {
      return ErrorMessage(message: provider.error!);
    }

    final route = provider.selectedRoute;
    if (route == null) return const Center(child: Text('Ruta no encontrada'));
    final Color routeColor = _routeColor(route.code);

    return RefreshIndicator(
      onRefresh: () => provider.loadRouteDetail(_routeId!),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Card(
            color: routeColor.withAlpha(8),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: routeColor.withAlpha(20),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.route,
                          color: routeColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              route.name,
                              style: theme.textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: routeColor.withAlpha(20),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                route.code,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: routeColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (route.description.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 18,
                          color: AppColors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Text('Información', style: theme.textTheme.titleMedium),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(route.description, style: theme.textTheme.bodyLarge),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        '/route_map',
                        arguments: _routeId,
                      ),
                      icon: const Icon(Icons.map),
                      label: const Text('Ver en mapa'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (provider.stops.isNotEmpty) ...[
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.directions_bus,
                    color: routeColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text('Paradas', style: theme.textTheme.titleLarge),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: routeColor.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${provider.stops.length}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: routeColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ...provider.stops.map((s) {
              final idx = provider.stops.indexOf(s);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: routeColor,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${idx + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        if (idx < provider.stops.length - 1)
                          Container(
                            width: 2,
                            height: 40,
                            color: routeColor.withAlpha(40),
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 4),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                s.code,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          if (provider.coordinates.isNotEmpty) ...[
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Icon(Icons.map, color: routeColor, size: 20),
                  const SizedBox(width: 8),
                  Text('Recorrido', style: theme.textTheme.titleLarge),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: routeColor.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${provider.coordinates.length} pts',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: routeColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ...provider.coordinates.map(
              (c) => Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                child: ListTile(
                  dense: true,
                  leading: Icon(
                    Icons.location_on,
                    color: routeColor,
                    size: 20,
                  ),
                  title: Text(
                    'Punto ${c.order}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    '${c.latitude.toStringAsFixed(4)}, ${c.longitude.toStringAsFixed(4)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
