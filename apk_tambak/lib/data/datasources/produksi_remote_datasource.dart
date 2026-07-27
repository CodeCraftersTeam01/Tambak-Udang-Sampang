import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_endpoints.dart';

class ProduksiRemoteDataSourceImpl {
  final ApiClient apiClient;

  ProduksiRemoteDataSourceImpl({required this.apiClient});

  Future<void> submitLog({
    required int kolamId,
    required double suhu,
    required double ph,
    required double doValue,
    required double tds,
    required double pakanKg,
    required double mbwGram,
    required int mortality,
  }) async {
    try {
      final payload = {
        'kolam_id': kolamId,
        'suhu': suhu,
        'ph': ph,
        'do': doValue,
        'tds': tds,
        'pakan_kg': pakanKg,
        'mbw_gram': mbwGram,
        'mortality_ekor': mortality,
      };
      await apiClient.dio.post(ApiEndpoints.produksiLog, data: payload);
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        final errorData = e.response!.data;
        if (errorData is Map<String, dynamic> && errorData.containsKey('message')) {
          throw Exception(errorData['message']);
        } else {
          throw Exception('API Error [${e.response!.statusCode}]: Unauthorized or Invalid Route.');
        }
      } else {
        throw Exception(e.message ?? 'Koneksi ke server gagal.');
      }
    }
  }

  Future<List<Map<String, dynamic>>> getLogs(int kolamId) async {
    try {
      final response = await apiClient.dio.get('${ApiEndpoints.produksiLog}/$kolamId');
      final dataList = response.data['data'] as List;
      return dataList.map((json) => json as Map<String, dynamic>).toList();
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        final errorData = e.response!.data;
        if (errorData is Map<String, dynamic> && errorData.containsKey('message')) {
          throw Exception(errorData['message']);
        } else {
          throw Exception('API Error [${e.response!.statusCode}]: Unauthorized or Invalid Route.');
        }
      } else {
        throw Exception(e.message ?? 'Koneksi ke server gagal.');
      }
    }
  }
}
