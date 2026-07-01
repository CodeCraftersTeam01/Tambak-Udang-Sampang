import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_endpoints.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login(String email, String password);
  Future<Map<String, dynamic>> register(String name, String email, String password, int roleId);
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await apiClient.dio.post(ApiEndpoints.login, data: {
        'email': email,
        'password': password,
      });
      return response.data;
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        throw Exception(e.response?.data['message'] ?? 'Login gagal');
      } else {
        throw Exception(e.message);
      }
    }
  }

  @override
  Future<Map<String, dynamic>> register(String name, String email, String password, int roleId) async {
    try {
      final response = await apiClient.dio.post(ApiEndpoints.register, data: {
        'name': name,
        'email': email,
        'password': password,
        'role_id': roleId,
      });
      return response.data;
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        throw Exception(e.response?.data['message'] ?? 'Registrasi gagal');
      } else {
        throw Exception(e.message);
      }
    }
  }

  @override
  Future<void> logout() async {
    try {
      await apiClient.dio.post(ApiEndpoints.logout);
    } catch (e) {
      // Ignored: If it fails, we still want to log out locally
    }
  }
}
