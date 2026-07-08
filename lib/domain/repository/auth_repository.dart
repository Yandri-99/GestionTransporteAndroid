import '../model/auth_models.dart';

abstract class AuthRepository {
  Future<User> login(String username, String password);
  Future<void> register(String username, String email, String password);
  Future<User> getMe();
  Future<void> logout();
  Future<bool> isLoggedIn();
}
