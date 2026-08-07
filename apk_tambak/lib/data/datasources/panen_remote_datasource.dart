import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_endpoints.dart';

class PanenRemoteDataSourceImpl {
  final ApiClient apiClient;

  PanenRemoteDataSourceImpl({required this.apiClient});

  Future<List<Map<String, dynamic>>> getPanenList() async {
    try {
      final response = await apiClient.dio.get(ApiEndpoints.panen);
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

  Future<void> addPanen({
    required int kolamId,
    required String tanggalPanen,
    required double jumlahPanenKg,
    required String jenisPanen,
    required String shrimpSize,
    required double salePrice,
  }) async {
    try {
      final payload = {
        'kolam_id': kolamId,
        'tanggal_panen': tanggalPanen,
        'jumlah_panen_kg': jumlahPanenKg,
        'jenis_panen': jenisPanen,
        'shrimp_size': shrimpSize,
        'sale_price': salePrice,
      };
      await apiClient.dio.post(ApiEndpoints.panen, data: payload);
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
