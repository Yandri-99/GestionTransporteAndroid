import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../providers/order_provider.dart';
import '../../../domain/model/order.dart';
import '../../../theme/app_colors.dart';

class IncidentMapScreen extends StatefulWidget {
  final int? incidentId;
  const IncidentMapScreen({super.key, this.incidentId});

  @override
  State<IncidentMapScreen> createState() => _IncidentMapScreenState();
}

class _IncidentMapScreenState extends State<IncidentMapScreen> {
  final MapController _mapController = MapController();
  LatLng? _currentPosition;
  StreamSubscription<Position>? _positionSubscription;
  bool _hasLocationPermission = false;
  bool _showMyLocation = false;
  bool _showLocationTooltip = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initLocation());
  }

  @override
  void dispose() {
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
      _hasLocationPermission = true;
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
    } catch (_) {}
  }

  void _showTooltip() {
    setState(() => _showLocationTooltip = true);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showLocationTooltip = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderProvider>();
    final incidents = provider.incidents;

    final displayIncidents = widget.incidentId != null
        ? incidents.where((i) => i.id == widget.incidentId).toList()
        : incidents;

    final validIncidents = displayIncidents
        .where((i) => i.latitude != 0 && i.longitude != 0)
        .toList();

    LatLng center;
    if (_showMyLocation && _currentPosition != null) {
      center = _currentPosition!;
    } else if (validIncidents.length == 1) {
      center =
          LatLng(validIncidents.first.latitude, validIncidents.first.longitude);
    } else if (validIncidents.isNotEmpty) {
      double latSum = 0, lngSum = 0;
      for (final i in validIncidents) {
        latSum += i.latitude;
        lngSum += i.longitude;
      }
      center = LatLng(latSum / validIncidents.length, lngSum / validIncidents.length);
    } else {
      center = const LatLng(-0.1807, -78.4678);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.incidentId != null
            ? 'Ubicación de Incidencia'
            : 'Mapa de Incidencias'),
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
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: center,
                    initialZoom:
                        validIncidents.length == 1 || _showMyLocation ? 15 : 12,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.ute.movicore',
                    ),
                    MarkerLayer(
                      markers: [
                        ...validIncidents.map((incident) {
                          final color = _severityColor(incident.severity);
                          return Marker(
                            point: LatLng(
                                incident.latitude, incident.longitude),
                            width: 44,
                            height: 44,
                            child: GestureDetector(
                              onTap: () =>
                                  _showIncidentDetail(context, incident),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                        color: color.withAlpha(100),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2)),
                                  ],
                                ),
                                child: Icon(
                                  _severityIcon(incident.severity),
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ),
                          );
                        }),
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
                                    border: Border.all(
                                        color: Colors.white, width: 3),
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
                Positioned(
                  bottom: validIncidents.isNotEmpty ? 172 : 16,
                  right: 16,
                  child: Column(
                    children: [
                      FloatingActionButton.small(
                        heroTag: 'zoom_in',
                        onPressed: () => _mapController.move(
                          _mapController.camera.center,
                          _mapController.camera.zoom + 1,
                        ),
                        child: const Icon(Icons.add),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton.small(
                        heroTag: 'zoom_out',
                        onPressed: () => _mapController.move(
                          _mapController.camera.center,
                          _mapController.camera.zoom - 1,
                        ),
                        child: const Icon(Icons.remove),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (validIncidents.isNotEmpty)
            Container(
              height: 160,
              padding: const EdgeInsets.all(12),
              color: Colors.white,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: validIncidents.length,
                itemBuilder: (context, index) {
                  final incident = validIncidents[index];
                  return _IncidentMiniCard(
                    incident: incident,
                    onTap: () => _showIncidentDetail(context, incident),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  void _showIncidentDetail(BuildContext context, Incident incident) {
    final color = _severityColor(incident.severity);
    final delay = _estimatedDelay(incident.severity);
    final isOperational = incident.severity == 'low';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      Icon(_severityIcon(incident.severity), color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(incident.incidentTypeName,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      Text(incident.createdAt,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.grey[600])),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(incident.severity.toUpperCase(),
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: color)),
                ),
              ],
            ),
            if (incident.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(incident.description,
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _InfoChip(
                    icon: Icons.schedule,
                    label: 'Demora est.',
                    value: delay,
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _InfoChip(
                    icon:
                        isOperational ? Icons.check_circle : Icons.cancel,
                    label: 'Estado',
                    value: isOperational ? 'Operativo' : 'No operativo',
                    color:
                        isOperational ? AppColors.success : AppColors.error,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _InfoChip(
                    icon: Icons.location_on,
                    label: 'Ubicación',
                    value:
                        '${incident.latitude.toStringAsFixed(4)}, ${incident.longitude.toStringAsFixed(4)}',
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            if (_currentPosition != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.navigation, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Tu ubicación: ${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}',
                      style: const TextStyle(fontSize: 12, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

String _estimatedDelay(String severity) {
  switch (severity) {
    case 'high':
      return '~60 min';
    case 'medium':
      return '~30 min';
    case 'low':
      return '~15 min';
    default:
      return '~30 min';
  }
}

Color _severityColor(String severity) {
  switch (severity) {
    case 'high':
      return AppColors.error;
    case 'medium':
      return AppColors.warning;
    case 'low':
      return AppColors.primary;
    default:
      return AppColors.primary;
  }
}

IconData _severityIcon(String severity) {
  switch (severity) {
    case 'high':
      return Icons.error;
    case 'medium':
      return Icons.warning;
    case 'low':
      return Icons.info;
    default:
      return Icons.info;
  }
}

class _IncidentMiniCard extends StatelessWidget {
  final Incident incident;
  final VoidCallback onTap;

  const _IncidentMiniCard({required this.incident, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = _severityColor(incident.severity);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withAlpha(10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(30)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(_severityIcon(incident.severity), color: color, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(incident.incidentTypeName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13),
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('Demora: ${_estimatedDelay(incident.severity)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[700])),
            Text(
                incident.status == 'resolved' ? 'Resuelta' : 'Abierta',
                style: TextStyle(
                    fontSize: 11,
                    color: incident.status == 'resolved'
                        ? AppColors.success
                        : color)),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoChip(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withAlpha(10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(fontSize: 10, color: Colors.grey[600])),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}
