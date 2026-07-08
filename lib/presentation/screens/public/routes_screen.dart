import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/catalog_provider.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_message.dart';

class RoutesScreen extends StatefulWidget {
  const RoutesScreen({super.key});

  @override
  State<RoutesScreen> createState() => _RoutesScreenState();
}

class _RoutesScreenState extends State<RoutesScreen> {
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
    if (provider.routes.isEmpty) {
      return const Center(child: Text('No hay rutas disponibles'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.routes.length,
      itemBuilder: (context, index) {
        final route = provider.routes[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.route, size: 40),
            title: Text(route.name),
            subtitle: Text('${route.code}\n${route.description}',
                maxLines: 2, overflow: TextOverflow.ellipsis),
            onTap: () => Navigator.pushNamed(
              context,
              '/route_detail',
              arguments: route.id,
            ),
          ),
        );
      },
    );
  }
}
