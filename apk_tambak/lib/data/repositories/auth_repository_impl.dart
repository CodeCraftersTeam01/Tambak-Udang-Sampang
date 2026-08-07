import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';
import '../../core/security/secure_storage.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SecureStorage secureStorage;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.secureStorage,
  });

  @override
  Future<UserEntity> login(String email, String password) async {
    final response = await remoteDataSource.login(email, password);
    final token = response['access_token'];
    final userData = response['user'];

    await secureStorage.saveToken(token);
    return UserModel.fromJson(userData);
  }

  @override
  Future<UserEntity> register(String name, String email, String password, int roleId) async {
    final response = await remoteDataSource.register(name, email, password, roleId);
    final userData = response['data'];
    return UserModel.fromJson(userData);
  }

  @override
  Future<void> logout() async {
    await remoteDataSource.logout();
    await secureStorage.deleteToken();
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await secureStorage.getToken();
    return token != null;
  }
}
