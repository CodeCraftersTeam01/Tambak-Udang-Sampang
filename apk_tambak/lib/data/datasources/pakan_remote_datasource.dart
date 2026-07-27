import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_endpoints.dart';

class PakanRemoteDataSourceImpl {
  final ApiClient apiClient;

  PakanRemoteDataSourceImpl({required this.apiClient});

  Future<List<Map<String, dynamic>>> getPakanList() async {
    try {
      final response = await apiClient.dio.get(ApiEndpoints.pakan);
      final dataList = response.data['data'] as List;
      return dataList.map((json) => json as Map<String, dynamic>).toList();
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        final responseData = e.response!.data;
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('errors')) {
            final errors = responseData['errors'] as Map<String, dynamic>;
            final firstError = errors.values.first.first;
            throw Exception(firstError.toString());
          } else if (responseData.containsKey('message')) {
            throw Exception(responseData['message'].toString());
          }
        }
        throw Exception('API Error [${e.response!.statusCode}]');
      }
      throw Exception(e.message ?? 'Network Error');
    }
  }

  Future<void> addPakan({
    required int kolamId,
    required String namaPakan,
    required double jumlah,
    required String tipe, // "masuk" or "keluar"
  }) async {
    try {
      final payload = {
        'kolam_id': kolamId,
        'nama_pakan': namaPakan,
        'jumlah_perminggu_kg': jumlah,
      };
      await apiClient.dio.post(ApiEndpoints.pakan, data: payload);
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        final responseData = e.response!.data;
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('errors')) {
            final errors = responseData['errors'] as Map<String, dynamic>;
            final firstError = errors.values.first.first;
            throw Exception(firstError.toString());
          } else if (responseData.containsKey('message')) {
            throw Exception(responseData['message'].toString());
          }
        }
        throw Exception('API Error [${e.response!.statusCode}]');
      }
      throw Exception(e.message ?? 'Network Error');
    }
  }
}
