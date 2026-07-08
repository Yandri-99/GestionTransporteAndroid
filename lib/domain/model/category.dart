class IncidentType {
  final int id;
  final String name;

  IncidentType({required this.id, required this.name});

  factory IncidentType.fromJson(Map<String, dynamic> json) {
    return IncidentType(
      id: json['id'],
      name: json['name'] ?? '',
    );
  }
}
