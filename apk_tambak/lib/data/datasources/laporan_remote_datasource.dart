import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';

class LaporanRemoteDataSourceImpl {
  final ApiClient apiClient;

  LaporanRemoteDataSourceImpl({required this.apiClient});

  Future<Map<String, dynamic>> getLaporan(int kolamId) async {
    try {
      final response = await apiClient.dio.get('/laporan/$kolamId');
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        final errorData = e.response!.data;
        if (errorData is Map<String, dynamic> && errorData.containsKey('message')) {
          throw Exception(errorData['message']);
        }
      }
      throw Exception(e.message ?? 'Gagal mengambil laporan.');
    }
  }
}
