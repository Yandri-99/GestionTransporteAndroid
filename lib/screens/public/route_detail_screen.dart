import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/routes_provider.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_message.dart';

class RouteDetailScreen extends StatefulWidget {
  const RouteDetailScreen({super.key});

  @override
  State<RouteDetailScreen> createState() => _RouteDetailScreenState();
}

class _RouteDetailScreenState extends State<RouteDetailScreen> {
  int? _routeId;
  bool _loaded = false;

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
      context.read<RoutesProvider>().loadRouteDetail(_routeId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RoutesProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(provider.selectedRoute?.name ?? 'Detalle Ruta')),
      body: _buildBody(provider, theme),
    );
  }

  Widget _buildBody(RoutesProvider provider, ThemeData theme) {
    if (provider.isLoading) return const LoadingIndicator();
    if (provider.error != null) {
      return ErrorMessage(message: provider.error!);
    }

    final route = provider.selectedRoute;
    if (route == null) return const Center(child: Text('Ruta no encontrada'));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(route.name, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(route.code, style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary)),
                if (route.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(route.description),
                ],
              ],
            ),
          ),
        ),
        if (provider.coordinates.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Recorrido', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...provider.coordinates.map((c) => Card(
            color: theme.colorScheme.surfaceContainerHighest,
            child: ListTile(
              dense: true,
              leading: Icon(Icons.location_on, color: theme.colorScheme.primary),
              title: Text('Punto ${c.order}: (${c.latitude.toStringAsFixed(4)}, ${c.longitude.toStringAsFixed(4)})'),
            ),
          )),
        ],
        if (provider.stops.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Paradas', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...provider.stops.map((s) => Card(
            color: theme.colorScheme.secondaryContainer,
            child: ListTile(
              leading: Icon(Icons.stop, color: theme.colorScheme.secondary),
              title: Text(s.name),
              subtitle: Text(s.code),
            ),
          )),
        ],
      ],
    );
  }
}
