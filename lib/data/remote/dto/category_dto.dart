class IncidentTypeDto {
  final int id;
  final String name;

  IncidentTypeDto({required this.id, required this.name});

  factory IncidentTypeDto.fromJson(Map<String, dynamic> json) {
    return IncidentTypeDto(
      id: json['id'],
      name: json['name'] ?? '',
    );
  }
}
