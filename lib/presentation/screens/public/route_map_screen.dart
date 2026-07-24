import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import '../../providers/catalog_provider.dart';
import '../../../domain/model/product.dart';
import '../../widgets/loading_indicator.dart';
import '../../../theme/app_colors.dart';

class RouteMapScreen extends StatefulWidget {
  final int? routeId;
  const RouteMapScreen({super.key, this.routeId});

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

  final MapController _mapController = MapController();
  LatLng? _currentPosition;
  StreamSubscription<Position>? _positionSubscription;
  bool _hasLocationPermission = false;
  bool _showMyLocation = false;
  bool _showLocationTooltip = false;

  List<LatLng> _walkingRoute = [];
  String? _nearestStopName;
  double? _walkingDistance;
  double? _walkingDuration;
  bool _isLoadingRoute = false;
  bool _showWalkingRoute = false;

  @override
  void initState() {
    super.initState();
    _busAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 180),
    )..repeat(reverse: true);
    _busTween = Tween<double>(begin: 0, end: 1).animate(_busAnim);
    _busAnim.addListener(() {
      setState(() {
        _busPos = _interpolateBus(_busTween.value);
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _initLocation());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routeId =
        widget.routeId ?? ModalRoute.of(context)?.settings.arguments as int?;
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
  void dispose() {
    _busAnim.dispose();
    _positionSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initLocation() async {
    final status = await Permission.location.request();
    if (status.isPermanentlyDenied) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Permiso de ubicación'),
          content: const Text(
            'El permiso de ubicación fue denegado permanentemente. '
            'Por favor, actívalo desde la configuración del dispositivo.',
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar')),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                openAppSettings();
              },
              child: const Text('Abrir Configuración'),
            ),
          ],
        ),
      );
      return;
    }

    if (status.isGranted || status.isLimited) {
      if (mounted) setState(() => _hasLocationPermission = true);
      await _startLocationTracking();
    }
  }

  Future<void> _startLocationTracking() async {
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((position) {
      if (!mounted) return;
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _showMyLocation = true;
      });
      if (!_showLocationTooltip) _showTooltip();
    });

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (!mounted) return;
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _showMyLocation = true;
      });
      _showTooltip();
    } catch (e) {
      debugPrint('[RouteMap] Error getting initial position: $e');
    }
  }

  void _showTooltip() {
    setState(() => _showLocationTooltip = true);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showLocationTooltip = false);
    });
  }

  Future<void> _navigateToNearestStop(List<BusStop> stops) async {
    if (_currentPosition == null || stops.isEmpty) return;

    final Distance distanceCalc = Distance();
    BusStop nearest = stops.first;
    double minDist = double.infinity;

    for (final stop in stops) {
      final d = distanceCalc(
        _currentPosition!,
        LatLng(stop.latitude, stop.longitude),
      );
      if (d < minDist) {
        minDist = d;
        nearest = stop;
      }
    }

    setState(() {
      _isLoadingRoute = true;
      _nearestStopName = nearest.name;
    });

    try {
      final dio = Dio();
      final url =
          'https://router.project-osrm.org/route/v1/foot/'
          '${_currentPosition!.longitude},${_currentPosition!.latitude};'
          '${nearest.longitude},${nearest.latitude}'
          '?overview=full&geometries=geojson';

      final response = await dio.get(url);
      final data = response.data;

      if (data['code'] == 'Ok' && data['routes'].isNotEmpty) {
        final route = data['routes'][0];
        final coords = route['geometry']['coordinates'] as List;
        final routePoints = coords
            .map((c) => LatLng(c[1] as double, c[0] as double))
            .toList();

        final distMeters = route['distance'] as double;
        final durSeconds = route['duration'] as double;

        if (mounted) {
          setState(() {
            _walkingRoute = routePoints;
            _walkingDistance = distMeters;
            _walkingDuration = durSeconds;
            _showWalkingRoute = true;
            _isLoadingRoute = false;
          });

          final bounds = LatLngBounds.fromPoints([
            _currentPosition!,
            LatLng(nearest.latitude, nearest.longitude),
          ]);
          _mapController.fitCamera(
            CameraFit.bounds(
              bounds: bounds,
              padding: const EdgeInsets.all(60),
            ),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingRoute = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo calcular la ruta')),
        );
      }
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

  String _formatDistance(double meters) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
    return '${meters.round()} m';
  }

  String _formatDuration(double seconds) {
    final mins = (seconds / 60).round();
    if (mins < 1) return '< 1 min';
    if (mins == 1) return '1 min';
    return '$mins min';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CatalogProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(provider.selectedRoute?.name ?? 'Mapa de Ruta'),
        actions: [
          if (_hasLocationPermission)
            IconButton(
              icon: Icon(
                Icons.my_location,
                color: _showMyLocation ? AppColors.primary : Colors.grey,
              ),
              onPressed: () {
                if (_currentPosition != null) {
                  _mapController.move(_currentPosition!, 15);
                  setState(() => _showMyLocation = true);
                  _showTooltip();
                }
              },
              tooltip: 'Mi ubicación',
            ),
        ],
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
    final stopPoints =
        stops.map((s) => LatLng(s.latitude, s.longitude)).toList();

    if (_points.isEmpty) {
      return const Center(child: Text('Sin coordenadas disponibles'));
    }

    final bounds = LatLngBounds.fromPoints(_points);

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _showMyLocation && _currentPosition != null
                ? _currentPosition!
                : _centerOf(_points),
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
                if (_showWalkingRoute && _walkingRoute.isNotEmpty)
                  Polyline(
                    points: _walkingRoute,
                    color: Colors.blue,
                    strokeWidth: 5,
                    borderColor: Colors.white,
                    borderStrokeWidth: 2,
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
                    child: const Icon(Icons.directions_bus,
                        color: Colors.white, size: 22),
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
                                horizontal: 4, vertical: 1),
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
                if (_showWalkingRoute &&
                    _walkingRoute.isNotEmpty &&
                    _currentPosition != null)
                  Marker(
                    point: _walkingRoute.last,
                    width: 30,
                    height: 30,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.secondary.withAlpha(80),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.directions_walk,
                          color: Colors.white, size: 16),
                    ),
                  ),
                if (_showMyLocation && _currentPosition != null)
                  Marker(
                    point: _currentPosition!,
                    width: 140,
                    height: 60,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedOpacity(
                          opacity: _showLocationTooltip ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(40),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Text(
                              '📍 Tú estás aquí',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withAlpha(80),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.person,
                              color: Colors.white, size: 14),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            if (_showMyLocation && _currentPosition != null)
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: _currentPosition!,
                    radius: 80,
                    color: Colors.blue.withAlpha(25),
                    borderColor: Colors.blue.withAlpha(60),
                    borderStrokeWidth: 1.5,
                  ),
                ],
              ),
          ],
        ),
        if (_showWalkingRoute &&
            _walkingDistance != null &&
            _walkingDuration != null &&
            _nearestStopName != null)
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.blue.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.directions_walk,
                        color: Colors.blue, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _nearestStopName!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_formatDistance(_walkingDistance!)} · ${_formatDuration(_walkingDuration!)} caminando',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () {
                      setState(() {
                        _showWalkingRoute = false;
                        _walkingRoute = [];
                        _walkingDistance = null;
                        _walkingDuration = null;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        Positioned(
          bottom: _showWalkingRoute ? 80 : 16,
          right: 16,
          child: Column(
            children: [
              FloatingActionButton.small(
                heroTag: 'route_zoom_in',
                onPressed: () => _mapController.move(
                  _mapController.camera.center,
                  _mapController.camera.zoom + 1,
                ),
                child: const Icon(Icons.add),
              ),
              const SizedBox(height: 8),
              FloatingActionButton.small(
                heroTag: 'route_zoom_out',
                onPressed: () => _mapController.move(
                  _mapController.camera.center,
                  _mapController.camera.zoom - 1,
                ),
                child: const Icon(Icons.remove),
              ),
            ],
          ),
        ),
        if (_hasLocationPermission)
          Positioned(
            bottom: 16,
            left: 16,
            child: FloatingActionButton.extended(
              heroTag: 'nearest_stop',
              onPressed: (_currentPosition == null || _isLoadingRoute)
                  ? null
                  : () => _navigateToNearestStop(stops),
              backgroundColor:
                  _currentPosition == null ? Colors.grey : Colors.blue,
              foregroundColor: Colors.white,
              icon: _isLoadingRoute
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : _currentPosition == null
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.directions_walk, size: 20),
              label: Text(
                _isLoadingRoute
                    ? 'Calculando...'
                    : _currentPosition == null
                        ? 'Obteniendo ubicación...'
                        : 'Ir a parada más cercana',
                style: const TextStyle(fontSize: 13),
              ),
            ),
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
