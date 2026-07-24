class UserProfile {
  final int id;
  final int userId;
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? avatar;
  final String address;
  final String emergencyContact;
  final String emergencyPhone;

  UserProfile({
    required this.id,
    required this.userId,
    this.username = '',
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.phone = '',
    this.avatar,
    this.address = '',
    this.emergencyContact = '',
    this.emergencyPhone = '',
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? 0,
      userId: json['user'] ?? json['user_id'] ?? 0,
      username: json['username'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      avatar: json['avatar'],
      address: json['address'] ?? '',
      emergencyContact: json['emergency_contact'] ?? '',
      emergencyPhone: json['emergency_phone'] ?? '',
    );
  }
}
