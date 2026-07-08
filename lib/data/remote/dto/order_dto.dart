class IncidentDto {
  final int id;
  final int tripId;
  final int incidentTypeId;
  final String incidentTypeName;
  final String description;
  final String severity;
  final String status;
  final double latitude;
  final double longitude;
  final String createdAt;

  IncidentDto({
    required this.id,
    this.tripId = 1,
    this.incidentTypeId = 1,
    this.incidentTypeName = '',
    this.description = '',
    this.severity = 'medium',
    this.status = 'open',
    this.latitude = 0,
    this.longitude = 0,
    this.createdAt = '',
  });

  factory IncidentDto.fromJson(Map<String, dynamic> json) {
    return IncidentDto(
      id: json['id'],
      tripId: json['trip'] ?? 1,
      incidentTypeId: json['incident_type'] ?? 1,
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
    'trip': tripId > 0 ? tripId : 1,
    'incident_type': incidentTypeId,
    'latitude': latitude.toString(),
    'longitude': longitude.toString(),
    'description': description,
    'severity': severity,
  };
}
