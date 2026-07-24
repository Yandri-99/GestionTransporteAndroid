import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../providers/catalog_provider.dart';
import '../../../domain/model/product.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_message.dart';
import '../../navigation/app_transitions.dart';
import '../public/route_detail_screen.dart';
import '../../../theme/app_colors.dart';
import '../../../core/services/analytics_service.dart';

class RoutesScreen extends StatefulWidget {
  const RoutesScreen({super.key});

  @override
  State<RoutesScreen> createState() => _RoutesScreenState();
}

class _RoutesScreenState extends State<RoutesScreen> {
  final _searchCtrl = TextEditingController();

  static const Map<String, String> _frequencies = {
    'RT-ECO': '5-8 min',
    'RT-TRO': '6-10 min',
    'RT-ME1': '8-12 min',
    'RT-SUR': '10-15 min',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = context.read<CatalogProvider>();
      prov.loadRoutes().then((_) {
        for (final route in prov.routes) {
          prov.loadStopsCount(route.id);
          prov.loadRouteCoordinatesForMap(route.id);
        }
      });
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
    if (provider.isLoading && provider.routes.isEmpty) return const LoadingIndicator();
    if (provider.error != null && provider.routes.isEmpty) {
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
          final color = _routeColor(route.code);
          final frequency = _frequencies[route.code] ?? '8-12 min';
          final stopsCount = provider.stopsCountMap[route.id];
          final coords = provider.routeCoordinatesMap[route.id];

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                AnalyticsService().logRouteView(route.code);
                Navigator.push(
                  context,
                  AppTransitions.fadeSlide(RouteDetailScreen(routeId: route.id)),
                );
              },
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
                  if (coords != null && coords.length >= 2)
                    SizedBox(
                      height: 120,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(0),
                          topRight: Radius.circular(0),
                        ),
                        child: IgnorePointer(
                          child: FlutterMap(
                            options: MapOptions(
                              initialCenter: _centerOf(coords),
                              initialZoom: 13,
                              interactionOptions: const InteractionOptions(
                                flags: InteractiveFlag.none,
                              ),
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.ute.movicore',
                              ),
                              PolylineLayer(
                                polylines: [
                                  Polyline(
                                    points: coords
                                        .map((c) => LatLng(c.latitude, c.longitude))
                                        .toList(),
                                    color: color,
                                    strokeWidth: 3,
                                  ),
                                ],
                              ),
                            ],
                          ),
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
                          child: Icon(Icons.directions_bus, color: color, size: 28),
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
                              Row(
                                children: [
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
                                  const SizedBox(width: 8),
                                  Icon(Icons.schedule, size: 14, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Text(
                                    frequency,
                                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  ),
                                ],
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Row(
                      children: [
                        _InfoBadge(
                          icon: Icons.place,
                          label: stopsCount != null ? '$stopsCount paradas' : 'Cargando...',
                          color: color,
                        ),
                        const SizedBox(width: 12),
                        _InfoBadge(
                          icon: Icons.schedule,
                          label: 'Frecuencia: $frequency',
                          color: AppColors.warning,
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

  static Color _routeColor(String code) {
    return switch (code) {
      'RT-ECO' => AppColors.secondary,
      'RT-TRO' => AppColors.primary,
      'RT-ME1' => const Color(0xFF2E7D32),
      'RT-SUR' => const Color(0xFF880E4F),
      _ => AppColors.primary,
    };
  }

  static LatLng _centerOf(List<RouteCoordinate> coords) {
    double lat = 0, lng = 0;
    for (final c in coords) {
      lat += c.latitude;
      lng += c.longitude;
    }
    return LatLng(lat / coords.length, lng / coords.length);
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoBadge({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: color),
          ),
        ],
      ),
    );
  }
}
