import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/order_provider.dart';
import '../../../domain/model/product.dart';
import '../../../domain/model/order.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_message.dart';
import '../../navigation/app_transitions.dart';
import '../public/route_map_screen.dart';
import '../../../theme/app_colors.dart';

class RouteDetailScreen extends StatefulWidget {
  final int? routeId;
  const RouteDetailScreen({super.key, this.routeId});

  @override
  State<RouteDetailScreen> createState() => _RouteDetailScreenState();
}

class _RouteDetailScreenState extends State<RouteDetailScreen> {
  int? _routeId;
  bool _loaded = false;

  static const Map<String, String> _firstBus = {
    'RT-ECO': '05:00',
    'RT-TRO': '05:30',
    'RT-ME1': '06:00',
    'RT-SUR': '05:15',
  };

  static const Map<String, String> _lastBus = {
    'RT-ECO': '22:30',
    'RT-TRO': '23:00',
    'RT-ME1': '22:00',
    'RT-SUR': '21:30',
  };

  static const Map<String, String> _frequencies = {
    'RT-ECO': '5-8 min',
    'RT-TRO': '6-10 min',
    'RT-ME1': '8-12 min',
    'RT-SUR': '10-15 min',
  };

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
    final routeId = widget.routeId ?? ModalRoute.of(context)?.settings.arguments as int?;
    if (routeId != null && routeId != _routeId) {
      _routeId = routeId;
      _loaded = false;
    }
    if (!_loaded && _routeId != null) {
      _loaded = true;
      context.read<CatalogProvider>().loadRouteDetail(_routeId!);
      context.read<CatalogProvider>().loadTrips();
      context.read<OrderProvider>().loadIncidents();
    }
  }

  double _calculateDistance(List<RouteCoordinate> coords) {
    if (coords.length < 2) return 0;
    double total = 0;
    for (int i = 0; i < coords.length - 1; i++) {
      total += _haversine(
        coords[i].latitude, coords[i].longitude,
        coords[i + 1].latitude, coords[i + 1].longitude,
      );
    }
    return total;
  }

  double _haversine(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371;
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  double _toRad(double deg) => deg * pi / 180;

  String _estimatedTime(double km) {
    final minutes = (km / 20 * 60).round();
    if (minutes < 60) return '$minutes min';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return '${h}h ${m}min';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CatalogProvider>();
    final theme = Theme.of(context);
    final Color routeColor = _routeColor(provider.selectedRoute?.code);

    return Scaffold(
      appBar: AppBar(
        title: Text(provider.selectedRoute?.name ?? 'Detalle Ruta'),
        backgroundColor: routeColor,
        foregroundColor: Colors.white,
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
    final coords = provider.coordinates;
    final distance = _calculateDistance(coords);
    final time = _estimatedTime(distance);
    final frequency = _frequencies[route.code] ?? '8-12 min';
    final firstBus = _firstBus[route.code] ?? '06:00';
    final lastBus = _lastBus[route.code] ?? '22:00';

    return RefreshIndicator(
      onRefresh: () => provider.loadRouteDetail(_routeId!),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _buildHeaderCard(route, routeColor, theme, distance, time, frequency, firstBus, lastBus),
          const SizedBox(height: 16),
          _buildStatsRow(routeColor, distance, time, provider.stops.length),
          const SizedBox(height: 16),
          _buildIncidentsSection(route, routeColor, theme),
          const SizedBox(height: 16),
          _buildConnectionsSection(route, provider, routeColor, theme),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.push(
                context,
                AppTransitions.fadeSlide(RouteMapScreen(routeId: _routeId)),
              ),
              icon: const Icon(Icons.map),
              label: const Text('Ver en mapa'),
            ),
          ),
          if (provider.stops.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildStopsSection(provider, routeColor, theme),
          ],
        ],
      ),
    );
  }

  Widget _buildHeaderCard(dynamic route, Color routeColor, ThemeData theme,
      double distance, String time, String frequency, String firstBus, String lastBus) {
    return Card(
      color: routeColor.withAlpha(8),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: routeColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.directions_bus, color: routeColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(route.name, style: theme.textTheme.headlineSmall),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: routeColor.withAlpha(20),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(route.code,
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: routeColor)),
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
                  Icon(Icons.info_outline, size: 18, color: AppColors.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Text('Información', style: theme.textTheme.titleMedium),
                ],
              ),
              const SizedBox(height: 8),
              Text(route.description, style: theme.textTheme.bodyLarge),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(Color routeColor, double distance, String time, int stopsCount) {
    return Row(
      children: [
        Expanded(child: _StatCard(
          icon: Icons.straighten,
          label: 'Distancia',
          value: '${distance.toStringAsFixed(1)} km',
          color: routeColor,
        )),
        const SizedBox(width: 8),
        Expanded(child: _StatCard(
          icon: Icons.schedule,
          label: 'Tiempo est.',
          value: time,
          color: AppColors.warning,
        )),
        const SizedBox(width: 8),
        Expanded(child: _StatCard(
          icon: Icons.place,
          label: 'Paradas',
          value: '$stopsCount',
          color: AppColors.success,
        )),
      ],
    );
  }

  Widget _buildIncidentsSection(dynamic route, Color routeColor, ThemeData theme) {
    return Consumer<OrderProvider>(
      builder: (_, orderProv, child) {
        final routeIncidents = orderProv.incidents
            .where((i) => i.status != 'resolved')
            .where((i) => _incidentMatchesRoute(i, route.name, route.code))
            .toList();
        final hasIncidents = routeIncidents.isNotEmpty;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: (hasIncidents ? AppColors.error : AppColors.success).withAlpha(20),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        hasIncidents ? Icons.warning_amber : Icons.check_circle,
                        color: hasIncidents ? AppColors.error : AppColors.success,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text('Estado Operativo',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: (hasIncidents ? AppColors.error : AppColors.success).withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        hasIncidents ? 'CON INCIDENCIAS' : 'OPERATIVO',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: hasIncidents ? AppColors.error : AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
                if (hasIncidents) ...[
                  const SizedBox(height: 12),
                  ...routeIncidents.take(3).map((inc) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _incidentColor(inc.severity).withAlpha(10),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _incidentColor(inc.severity).withAlpha(30)),
                      ),
                      child: Row(
                        children: [
                          Icon(_incidentIcon(inc.severity), size: 16, color: _incidentColor(inc.severity)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(inc.incidentTypeName,
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                Text(inc.description,
                                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                    maxLines: 1, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                          Text(_incidentDelay(inc.severity),
                              style: TextStyle(fontSize: 11, color: _incidentColor(inc.severity), fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  )),
                ] else ...[
                  const SizedBox(height: 8),
                  Text('No hay incidencias activas en esta ruta',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildConnectionsSection(dynamic route, CatalogProvider provider, Color routeColor, ThemeData theme) {
    final connections = <String>{};
    for (final otherRoute in provider.routes) {
      if (otherRoute.id != route.id) {
        connections.add(otherRoute.name);
      }
    }
    final uniqueConnections = connections.take(4).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.tertiary.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.transfer_within_a_station, color: AppColors.tertiary, size: 20),
                ),
                const SizedBox(width: 12),
                Text('Puntos de Conexión', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 12),
            if (uniqueConnections.isNotEmpty) ...[
              ...uniqueConnections.map((name) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.swap_horiz, size: 16, color: AppColors.tertiary),
                    const SizedBox(width: 8),
                    Expanded(child: Text(name, style: const TextStyle(fontSize: 13))),
                  ],
                ),
              )),
            ] else ...[
              Text('Transbordo disponible en todas las paradas',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600])),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStopsSection(CatalogProvider provider, Color routeColor, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Icon(Icons.directions_bus, color: routeColor, size: 20),
              const SizedBox(width: 8),
              Text('Paradas', style: theme.textTheme.titleLarge),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: routeColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('${provider.stops.length}',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: routeColor)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...provider.stops.asMap().entries.map((entry) {
          final idx = entry.key;
          final s = entry.value;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(color: routeColor, shape: BoxShape.circle),
                      child: Center(
                        child: Text('${idx + 1}',
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    if (idx < provider.stops.length - 1)
                      Container(width: 2, height: 40, color: routeColor.withAlpha(40)),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    color: routeColor.withAlpha(8),
                    margin: const EdgeInsets.only(bottom: 4),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text(s.code, style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
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
    );
  }

  static Color _incidentColor(String severity) {
    return switch (severity) {
      'high' => AppColors.error,
      'medium' => AppColors.warning,
      _ => AppColors.primary,
    };
  }

  static IconData _incidentIcon(String severity) {
    return switch (severity) {
      'high' => Icons.error,
      'medium' => Icons.warning,
      _ => Icons.info,
    };
  }

  static String _incidentDelay(String severity) {
    return switch (severity) {
      'high' => '~60 min',
      'medium' => '~30 min',
      _ => '~15 min',
    };
  }

  bool _incidentMatchesRoute(Incident incident, String routeName, String routeCode) {
    if (incident.tripId == null) return false;
    final prov = context.read<CatalogProvider>();
    for (final trip in prov.trips) {
      if (trip.id == incident.tripId) {
        if (trip.routeName.toLowerCase().contains(routeName.toLowerCase()) ||
            trip.routeName.toUpperCase().contains(routeCode)) {
          return true;
        }
        final routeMatch = prov.routes.where((r) => r.id.toString() == trip.routeName);
        if (routeMatch.isNotEmpty) {
          final matchedRoute = routeMatch.first;
          return matchedRoute.code == routeCode ||
              matchedRoute.name.toLowerCase().contains(routeName.toLowerCase());
        }
      }
    }
    return false;
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        ],
      ),
    );
  }
}
