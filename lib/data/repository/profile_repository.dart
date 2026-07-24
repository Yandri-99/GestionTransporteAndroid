import 'package:dio/dio.dart';
import '../../domain/model/user_profile.dart';
import '../../core/error/api_exception.dart';
import '../remote/api/dio_client.dart';

class ProfileRepository {
  final DioClient _api = DioClient();

  String _parseError(dynamic data) {
    if (data == null) return 'Error de conexión';
    if (data is Map && data.containsKey('detail')) return data['detail'].toString();
    if (data is Map && data.containsKey('message')) return data['message'];
    return 'Error desconocido';
  }

  Future<UserProfile> getProfile() async {
    try {
      final meResponse = await _api.get('/api/auth/me/');
      final meData = meResponse.data as Map<String, dynamic>;

      final userId = meData['id'] ?? 0;
      final username = meData['username'] ?? '';
      final firstName = meData['first_name'] ?? '';
      final lastName = meData['last_name'] ?? '';
      final email = meData['email'] ?? '';
      final phone = meData['phone'] ?? '';

      try {
        final profileResponse = await _api.get('/api/auth/profile/');
        final profileData = profileResponse.data;

        Map<String, dynamic> profileMap;
        if (profileData is List && profileData.isNotEmpty) {
          profileMap = profileData.first as Map<String, dynamic>;
        } else if (profileData is Map) {
          profileMap = Map<String, dynamic>.from(profileData);
        } else {
          profileMap = {};
        }

        return UserProfile(
          id: profileMap['id'] ?? 0,
          userId: userId,
          username: username,
          firstName: firstName,
          lastName: lastName,
          email: email,
          phone: phone,
          avatar: profileMap['avatar'],
          address: profileMap['address'] ?? '',
          emergencyContact: profileMap['emergency_contact'] ?? '',
          emergencyPhone: profileMap['emergency_phone'] ?? '',
        );
      } on DioException {
        return UserProfile(
          id: 0,
          userId: userId,
          username: username,
          firstName: firstName,
          lastName: lastName,
          email: email,
          phone: phone,
        );
      }
    } on DioException catch (e) {
      throw ApiException(_parseError(e.response?.data), statusCode: e.response?.statusCode);
    }
  }

  Future<void> updateMe(UserProfile profile) async {
    try {
      await _api.put('/api/auth/me/', data: {
        'first_name': profile.firstName,
        'last_name': profile.lastName,
        'email': profile.email,
        'phone': profile.phone,
      });
    } on DioException catch (e) {
      throw ApiException(_parseError(e.response?.data), statusCode: e.response?.statusCode);
    }
  }

  Future<void> updateProfileDetails(UserProfile profile) async {
    try {
      final data = {
        'address': profile.address,
        'emergency_contact': profile.emergencyContact,
        'emergency_phone': profile.emergencyPhone,
      };
      if (profile.id > 0) {
        await _api.patch('/api/auth/profile/${profile.id}/', data: data);
      } else {
        await _api.post('/api/auth/profile/', data: data);
      }
    } on DioException catch (e) {
      throw ApiException(_parseError(e.response?.data), statusCode: e.response?.statusCode);
    }
  }

  Future<void> changePassword({required String oldPassword, required String newPassword}) async {
    try {
      await _api.post('/api/auth/change-password/', data: {
        'old_password': oldPassword,
        'new_password': newPassword,
      });
    } on DioException catch (e) {
      throw ApiException(_parseError(e.response?.data), statusCode: e.response?.statusCode);
    }
  }
}
