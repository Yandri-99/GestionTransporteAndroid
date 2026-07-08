class RouteModel {
  final int id;
  final String code;
  final String name;
  final String description;
  final String companyName;

  RouteModel({
    required this.id,
    required this.code,
    required this.name,
    this.description = '',
    this.companyName = '',
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      id: json['id'],
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      companyName: json['transport_company_name'] ?? '',
    );
  }
}

class BusStop {
  final int id;
  final String code;
  final String name;
  final double latitude;
  final double longitude;
  final int stopOrder;

  BusStop({
    required this.id,
    required this.code,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.stopOrder = 0,
  });

  factory BusStop.fromJson(Map<String, dynamic> json) {
    return BusStop(
      id: json['id'],
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      latitude: double.tryParse(json['latitude']?.toString() ?? '0') ?? 0,
      longitude: double.tryParse(json['longitude']?.toString() ?? '0') ?? 0,
      stopOrder: json['stop_order'] ?? 0,
    );
  }
}

class RouteCoordinate {
  final int id;
  final double latitude;
  final double longitude;
  final int order;

  RouteCoordinate({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.order,
  });

  factory RouteCoordinate.fromJson(Map<String, dynamic> json) {
    return RouteCoordinate(
      id: json['id'],
      latitude: double.tryParse(json['latitude']?.toString() ?? '0') ?? 0,
      longitude: double.tryParse(json['longitude']?.toString() ?? '0') ?? 0,
      order: json['order'],
    );
  }
}
