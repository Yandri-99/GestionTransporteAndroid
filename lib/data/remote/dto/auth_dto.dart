class LoginRequestDto {
  final String username;
  final String password;

  LoginRequestDto({required this.username, required this.password});

  Map<String, dynamic> toJson() => {'username': username, 'password': password};
}

class RegisterRequestDto {
  final String username;
  final String email;
  final String password;

  RegisterRequestDto({required this.username, required this.email, required this.password});

  Map<String, dynamic> toJson() => {'username': username, 'email': email, 'password': password};
}

class LoginResponseDto {
  final String access;
  final String refresh;

  LoginResponseDto({required this.access, required this.refresh});

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) {
    return LoginResponseDto(
      access: json['access'],
      refresh: json['refresh'],
    );
  }
}

class PasswordResetRequestDto {
  final String email;

  PasswordResetRequestDto({required this.email});

  Map<String, dynamic> toJson() => {'email': email};
}

class PasswordResetConfirmDto {
  final String uid;
  final String token;
  final String newPassword;
  final String newPassword2;

  PasswordResetConfirmDto({
    required this.uid,
    required this.token,
    required this.newPassword,
    required this.newPassword2,
  });

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'token': token,
        'new_password': newPassword,
        'new_password2': newPassword2,
      };
}
