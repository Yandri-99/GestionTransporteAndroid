class DriverAssignmentDto {
  final int id;
  final int driverId;
  final String driverName;
  final int routeId;
  final String routeName;
  final int vehicleId;
  final String vehiclePlate;
  final String assignmentDate;
  final bool isActive;
  final String notes;

  DriverAssignmentDto({
    required this.id,
    required this.driverId,
    this.driverName = '',
    required this.routeId,
    this.routeName = '',
    this.vehicleId = 0,
    this.vehiclePlate = '',
    this.assignmentDate = '',
    this.isActive = true,
    this.notes = '',
  });

  factory DriverAssignmentDto.fromJson(Map<String, dynamic> json) {
    final driver = json['driver'];
    final route = json['route'];
    final vehicle = json['vehicle'];
    return DriverAssignmentDto(
      id: json['id'],
      driverId: driver is int ? driver : int.tryParse(driver?.toString() ?? '0') ?? 0,
      driverName: json['driver_name'] ?? json['driver_display_name'] ?? '',
      routeId: route is int ? route : int.tryParse(route?.toString() ?? '0') ?? 0,
      routeName: json['route_name'] ?? json['route_display_name'] ?? '',
      vehicleId: vehicle is int ? vehicle : int.tryParse(vehicle?.toString() ?? '0') ?? 0,
      vehiclePlate: json['vehicle_plate'] ?? json['vehicle_display'] ?? '',
      assignmentDate: json['assignment_date'] ?? '',
      isActive: json['is_active'] ?? true,
      notes: json['notes'] ?? '',
    );
  }
}
