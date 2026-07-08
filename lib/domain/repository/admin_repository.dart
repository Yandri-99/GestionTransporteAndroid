import '../model/auth_models.dart';

abstract class AdminRepository {
  Future<List<User>> getUsers();
  Future<void> deleteUser(int id);
}
