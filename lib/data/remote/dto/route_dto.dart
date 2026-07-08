class RouteDto {
  final int id;
  final String code;
  final String name;
  final String description;
  final String companyName;

  RouteDto({
    required this.id,
    required this.code,
    required this.name,
    this.description = '',
    this.companyName = '',
  });

  factory RouteDto.fromJson(Map<String, dynamic> json) {
    return RouteDto(
      id: json['id'],
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      companyName: json['transport_company_name'] ?? '',
    );
  }
}

class BusStopDto {
  final int id;
  final String code;
  final String name;
  final double latitude;
  final double longitude;
  final int stopOrder;

  BusStopDto({
    required this.id,
    required this.code,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.stopOrder = 0,
  });

  factory BusStopDto.fromJson(Map<String, dynamic> json) {
    return BusStopDto(
      id: json['id'],
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      latitude: double.tryParse(json['latitude']?.toString() ?? '0') ?? 0,
      longitude: double.tryParse(json['longitude']?.toString() ?? '0') ?? 0,
      stopOrder: json['stop_order'] ?? 0,
    );
  }
}

class RouteCoordinateDto {
  final int id;
  final double latitude;
  final double longitude;
  final int order;

  RouteCoordinateDto({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.order,
  });

  factory RouteCoordinateDto.fromJson(Map<String, dynamic> json) {
    return RouteCoordinateDto(
      id: json['id'],
      latitude: double.tryParse(json['latitude']?.toString() ?? '0') ?? 0,
      longitude: double.tryParse(json['longitude']?.toString() ?? '0') ?? 0,
      order: json['order'],
    );
  }
}
