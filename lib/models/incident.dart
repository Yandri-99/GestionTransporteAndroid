class Incident {
  final int id;
  final int tripId;
  final String incidentTypeName;
  final String description;
  final String severity;
  final String status;
  final double latitude;
  final double longitude;
  final String createdAt;

  Incident({
    required this.id,
    required this.tripId,
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
      tripId: json['trip'] ?? 0,
      incidentTypeName: json['incident_type_name'] ?? '',
      description: json['description'] ?? '',
      severity: json['severity'] ?? 'medium',
      status: json['status'] ?? 'open',
      latitude: double.tryParse(json['latitude']?.toString() ?? '0') ?? 0,
      longitude: double.tryParse(json['longitude']?.toString() ?? '0') ?? 0,
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'trip': tripId,
    'incident_type': 1,
    'latitude': latitude.toString(),
    'longitude': longitude.toString(),
    'description': description,
    'severity': severity,
  };
}
