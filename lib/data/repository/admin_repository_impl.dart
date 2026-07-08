import '../../domain/model/auth_models.dart';
import '../../domain/repository/admin_repository.dart';
import '../remote/api/dio_client.dart';

class AdminRepositoryImpl implements AdminRepository {
  final DioClient _api = DioClient();

  @override
  Future<List<User>> getUsers() async {
    final response = await _api.get('/api/auth/users/');
    return (response.data as List).map((e) => User.fromJson(e)).toList();
  }

  @override
  Future<void> deleteUser(int id) async {
    await _api.delete('/api/auth/users/$id/');
  }
}
