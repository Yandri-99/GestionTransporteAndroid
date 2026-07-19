import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../providers/catalog_provider.dart';
import '../../widgets/loading_indicator.dart';
import '../../../theme/app_colors.dart';

class RouteMapScreen extends StatefulWidget {
  const RouteMapScreen({super.key});

  @override
  State<RouteMapScreen> createState() => _RouteMapScreenState();
}

class _RouteMapScreenState extends State<RouteMapScreen>
    with SingleTickerProviderStateMixin {
  int? _routeId;
  bool _loaded = false;
  late AnimationController _busAnim;
  late Animation<double> _busTween;
  List<LatLng> _points = [];
  LatLng _busPos = const LatLng(0, 0);

  @override
  void initState() {
    super.initState();
    _busAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat(reverse: true);
    _busTween = Tween<double>(begin: 0, end: 1).animate(_busAnim);
    _busAnim.addListener(() {
      setState(() {
        _busPos = _interpolateBus(_busTween.value);
      });
    });
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

  Color _busColor(String? code) {
    return switch (code) {
      'RT-ECO' => AppColors.secondary,
      'RT-TRO' => AppColors.primary,
      'RT-ME1' => const Color(0xFF2E7D32),
      'RT-SUR' => const Color(0xFF880E4F),
      _ => AppColors.primary,
    };
  }

  LatLng _interpolateBus(double t) {
    if (_points.isEmpty) return const LatLng(0, 0);
    if (_points.length == 1) return _points.first;
    final total = _points.length - 1;
    final raw = t * total;
    final i = raw.floor();
    final frac = raw - i;
    final a = _points[i];
    final b = _points[(i + 1).clamp(0, _points.length - 1)];
    return LatLng(a.latitude + (b.latitude - a.latitude) * frac,
        a.longitude + (b.longitude - a.longitude) * frac);
  }

  @override
  void dispose() {
    _busAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CatalogProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(provider.selectedRoute?.name ?? 'Mapa de Ruta'),
      ),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(CatalogProvider provider) {
    if (provider.isLoading) return const LoadingIndicator();

    final coords = provider.coordinates;
    final stops = provider.stops;

    if (coords.isEmpty) {
      return const Center(child: Text('No hay datos de recorrido'));
    }

    _points = coords.map((c) => LatLng(c.latitude, c.longitude)).toList();
    final stopPoints = stops
        .map((s) => LatLng(s.latitude, s.longitude))
        .toList();

    if (_points.isEmpty) {
      return const Center(child: Text('Sin coordenadas disponibles'));
    }

    final bounds = LatLngBounds.fromPoints(_points);

    return FlutterMap(
      options: MapOptions(
        initialCenter: _centerOf(_points),
        initialZoom: 13,
        initialCameraFit: CameraFit.bounds(bounds: bounds),
        maxZoom: 18,
        minZoom: 11,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.movicore.app',
        ),
        PolylineLayer(
          polylines: [
            Polyline(
              points: _points,
              color: AppColors.primary.withAlpha(200),
              strokeWidth: 4,
            ),
          ],
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: _busPos,
              width: 40,
              height: 40,
              child: Container(
                decoration: BoxDecoration(
                  color: _busColor(provider.selectedRoute?.code),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(60),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.directions_bus, color: Colors.white, size: 22),
              ),
            ),
            for (var i = 0; i < stopPoints.length; i++)
              Marker(
                point: stopPoints[i],
                width: 80,
                height: 50,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          '${i + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(210),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          stops[i].name,
                          style: const TextStyle(fontSize: 8),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  LatLng _centerOf(List<LatLng> points) {
    var lat = 0.0, lng = 0.0;
    for (final p in points) {
      lat += p.latitude;
      lng += p.longitude;
    }
    return LatLng(lat / points.length, lng / points.length);
  }
}
