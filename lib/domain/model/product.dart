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

  Map<String, dynamic> toJson() => {
    if (id > 0) 'id': id,
    'code': code,
    'name': name,
    'description': description,
    'transport_company_name': companyName,
  };
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

  Map<String, dynamic> toJson() => {
    if (id > 0) 'id': id,
    'code': code,
    'name': name,
    'latitude': latitude,
    'longitude': longitude,
    'stop_order': stopOrder,
  };
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'latitude': latitude,
    'longitude': longitude,
    'order': order,
  };
}

class Vehicle {
  final int id;
  final String plate;
  final String brand;
  final String model;
  final int capacity;

  Vehicle({
    required this.id,
    required this.plate,
    this.brand = '',
    this.model = '',
    this.capacity = 0,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'],
      plate: json['plate'] ?? '',
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      capacity: json['capacity'] ?? 0,
    );
  }
}

class Trip {
  final int id;
  final String routeName;
  final String vehiclePlate;
  final String driverName;
  final String status;
  final String date;

  Trip({
    required this.id,
    this.routeName = '',
    this.vehiclePlate = '',
    this.driverName = '',
    this.status = '',
    this.date = '',
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'],
      routeName: json['route_name'] ?? json['route']?.toString() ?? '',
      vehiclePlate: json['vehicle_plate'] ?? json['vehicle']?.toString() ?? '',
      driverName: json['driver_name'] ?? json['driver']?.toString() ?? '',
      status: json['status'] ?? '',
      date: json['date'] ?? '',
    );
  }
}
