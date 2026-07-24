class DriverDto {
  final int id;
  final int userId;
  final String userFullName;
  final String userUsername;
  final String licenseNumber;
  final String licenseType;
  final String hireDate;
  final int experienceYears;
  final String observations;
  final bool isAvailable;
  final bool isActive;

  DriverDto({
    required this.id,
    this.userId = 0,
    this.userFullName = '',
    this.userUsername = '',
    required this.licenseNumber,
    this.licenseType = '',
    this.hireDate = '',
    this.experienceYears = 0,
    this.observations = '',
    this.isAvailable = true,
    this.isActive = true,
  });

  factory DriverDto.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    return DriverDto(
      id: json['id'],
      userId: user is int ? user : int.tryParse(user?.toString() ?? '0') ?? 0,
      userFullName: json['user_full_name'] ?? '',
      userUsername: json['user_username'] ?? '',
      licenseNumber: json['license_number'] ?? '',
      licenseType: json['license_type'] ?? '',
      hireDate: json['hire_date'] ?? '',
      experienceYears: json['experience_years'] ?? 0,
      observations: json['observations'] ?? '',
      isAvailable: json['is_available'] ?? true,
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'user': userId,
    'license_number': licenseNumber,
    'license_type': licenseType,
    'hire_date': hireDate,
    'experience_years': experienceYears,
    'observations': observations,
    'is_available': isAvailable,
    'is_active': isActive,
  };
}
