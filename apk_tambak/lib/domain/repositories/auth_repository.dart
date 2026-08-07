import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login(String email, String password);
  Future<UserEntity> register(String name, String email, String password, int roleId);
  Future<void> logout();
  Future<bool> isLoggedIn();
}
