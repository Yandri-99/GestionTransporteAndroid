class Incident {
  final int id;
  final int? tripId;
  final int? vehicleId;
  final int? driverId;
  final int incidentTypeId;
  final String incidentTypeName;
  final String description;
  final String severity;
  final String status;
  final double latitude;
  final double longitude;
  final String createdAt;

  Incident({
    required this.id,
    this.tripId,
    this.vehicleId,
    this.driverId,
    this.incidentTypeId = 1,
    this.incidentTypeName = '',
    this.description = '',
    this.severity = 'medium',
    this.status = 'open',
    this.latitude = 0,
    this.longitude = 0,
    this.createdAt = '',
  });

  factory Incident.fromJson(Map<String, dynamic> json) {
    return Incident(
      id: json['id'],
      tripId: _parseId(json['trip']),
      vehicleId: _parseId(json['vehicle']),
      driverId: _parseId(json['driver']),
      incidentTypeId: _parseId(json['incident_type']) ?? 1,
      incidentTypeName: json['incident_type_name'] ?? (json['incident_type'] is Map ? json['incident_type']['name'] ?? '' : ''),
      description: json['description'] ?? '',
      severity: json['severity'] ?? 'medium',
      status: json['status'] ?? 'open',
      latitude: double.tryParse(json['latitude']?.toString() ?? '0') ?? 0,
      longitude: double.tryParse(json['longitude']?.toString() ?? '0') ?? 0,
      createdAt: json['created_at'] ?? '',
    );
  }

  static int? _parseId(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is Map && value.containsKey('id')) return value['id'] as int?;
    return int.tryParse(value.toString());
  }

  Map<String, dynamic> toJson() => {
    if (tripId != null) 'trip': tripId,
    if (vehicleId != null) 'vehicle': vehicleId,
    if (driverId != null) 'driver': driverId,
    'incident_type': incidentTypeId,
    'latitude': latitude.toString(),
    'longitude': longitude.toString(),
    'description': description,
    'severity': severity,
  };
}
