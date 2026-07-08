class User {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String phone;
  final List<String> groups;

  User({
    required this.id,
    required this.username,
    this.email = '',
    this.firstName = '',
    this.lastName = '',
    this.phone = '',
    this.groups = const [],
  });

  bool get isAdmin => groups.contains('Administrator');
  String get fullName =>
      '$firstName $lastName'.trim().isNotEmpty ? '$firstName $lastName' : username;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      phone: json['phone'] ?? '',
      groups: List<String>.from(json['groups'] ?? []),
    );
  }
}

class LoginResponse {
  final String access;
  final String refresh;

  LoginResponse({required this.access, required this.refresh});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      access: json['access'],
      refresh: json['refresh'],
    );
  }
}
